/* vi: ft=c
 *
 * Based on vf_nlmeans.c from FFmpeg.
 *
 * Copyright (c) 2022 an3223 <ethanr2048@gmail.com>
 * Copyright (c) 2016 Clément Bœsch <u pkh me>
 *
 * This program is free software: you can redistribute it and/or modify it 
 * under the terms of the GNU Lesser General Public License as published by 
 * the Free Software Foundation, either version 2.1 of the License, or (at 
 * your option) any later version.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT 
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or 
 * FITNESS FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public License 
 * for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License 
 * along with this program. If not, see <https://www.gnu.org/licenses/>.
 */

//!HOOK LUMA
//!HOOK CHROMA
//!HOOK RGB
//!BIND HOOKED
//!DESC Non-local means

/* User variables
 *
 * S = denoising factor
 * P = patch size (odd number)
 * R = research size (odd number)
 *
 * Suggested values:
 *
 *         LUMA               CHROMA
 *   0<S<=15:P=3:R=21    0<S<=25:P=3:R=21
 *  15<S<=30:P=5:R=21   25<S<=55:P=5:R=35
 *  30<S<=45:P=7:R=35  55<S<=100:P=7:R=35
 *  45<S<=75:P=9:R=35
 * 75<S<=100:P=11:R=35
 *
 * Source:
 * https://www.ipol.im/pub/art/2011/bcm_nlm/article.pdf
 *
 * Increasing the patch and research sizes will be slower, but may do a better 
 * job at finding noise
 *
 * Increasing the denoising factor will increase blur
 *
 * It is generally preferable to denoise chroma more than luma, so the user 
 * variables for luma and chroma are split below. Other user variables can be 
 * moved into these blocks if desired.
 *
 * The defaults below are performance oriented, you may want to adjust them for 
 * your use case
 */
#ifdef LUMA_raw
#define S 1.0
#define P 3
#define R 9
#else
#define S 2.0
#define P 5
#define R 5
#endif

// Disabling might be faster, but will reduce denoising around the image edges
#define BOUNDS_CHECKING 1

/* Shader code */

const int hp = P/2;
const int hr = R/2;
const float h = S*10.0;
const float pdiff_scale = 1.0/(h*h);
const float range = 255.0; // for making pixels range from 0-255
const vec4 maxdiff = vec4(log(range)/pdiff_scale);

vec4 hook()
{
	vec4 weight, pdiff_sq, ignore;
	vec2 r, p;
	vec4 total_weight = vec4(1);
	vec4 sum = HOOKED_texOff(0);

	for (r.x = -hr; r.x <= hr; r.x++) {
		for (r.y = -hr; r.y <= hr; r.y++) {
			ignore = vec4(1);

#if BOUNDS_CHECKING
			vec2 abs_r = r * HOOKED_pt + HOOKED_pos;
			ignore *= int(clamp(abs_r, vec2(0), input_size) == abs_r);
#endif

			pdiff_sq = vec4(0);
			for (p.x = -hp; p.x <= hp; p.x++)
				for (p.y = -hp; p.y <= hp; p.y++)
					pdiff_sq += pow((HOOKED_texOff(r+p) - HOOKED_texOff(p)) * range, vec4(2));
			ignore *= step(pdiff_sq, maxdiff);

			// low pdiff_sq -> high weight, high weight -> more blur
			// XXX bad performance on AMD-Vulkan (but not OpenGL), seems to be rooted here?
			weight = exp(-pdiff_sq * pdiff_scale) * ignore;
			sum += weight * HOOKED_texOff(r);
			total_weight += weight;
		}
	}

	return sum / total_weight;
}

