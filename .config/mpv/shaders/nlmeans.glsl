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

/* Ranges from 0-2 in ascending order of quality, performance may vary wildly.
 *
 * Basically just tries to apply an appropriate amount of denoising to the 
 * edges of the image. The quality differences are miniscule unless you have a 
 * very large R, so this should only be turned up if it doesn't affect 
 * performance or when quality is very important.
 *
 * 0: perform no bounds checking
 * 1: ignore out-of-bounds pixels
 * 2: shift research zone to avoid out-of-bounds pixels
 */
#define BOUNDS_CHECKING 1

/* Bright preserve, reduces denoising on brighter parts of the image
 *
 * BP represents the size of a zone to sample around each pixel for getting the 
 * average luminance. If enabled, the recommended value is 3.
 *
 * BPW is range [0,1], lower values will increase the effect.
 */
#ifdef LUMA_raw
#define BP 3
#define BPW 0.25
#endif

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
	vec2 r, p, lower, upper;
	vec4 total_weight = vec4(1);
	vec4 sum = HOOKED_texOff(0);

#if BOUNDS_CHECKING == 2
	vec2 px_pos = HOOKED_pos * input_size;
	lower = min(vec2(hr), px_pos);
	upper = min(vec2(hr), input_size - px_pos);
	// try to extend sides opposite of truncated sides
	lower = min(lower + (vec2(hr) - upper), px_pos);
	upper = min(upper + (vec2(hr) - lower), input_size - px_pos);
#else
	lower = upper = vec2(hr);
#endif

	for (r.x = -lower.x; r.x <= upper.x; r.x++) {
		for (r.y = -lower.y; r.y <= upper.y; r.y++) {
			ignore = vec4(1);

#if BOUNDS_CHECKING == 1
			vec2 abs_r = HOOKED_pos * input_size + r;
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

#if BP
			const int hbp = BP/2;
			vec4 luminance = vec4(0);
			for (p.x = -hbp; p.x <= hbp; p.x++)
				for (p.y = -hbp; p.y <= hbp; p.y++)
					luminance += HOOKED_texOff(p);
			luminance /= BP*BP;
			weight *= (1 - luminance) * BPW;
#endif

			sum += weight * HOOKED_texOff(r);
			total_weight += weight;
		}
	}

	return sum / total_weight;
}

