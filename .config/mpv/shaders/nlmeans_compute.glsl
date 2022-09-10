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

//
// This is a compute shader variant of nlmeans. It's not much use right now, 
// you should probably use the fragmentation shader instead.
//

//!HOOK LUMA
//!HOOK CHROMA
//!HOOK RGB
//!BIND HOOKED
//!COMPUTE 16 16
//!DESC Non-local means
#define THREADS (16*16)
#define BLOCKSIZE uvec2(16,16)

/* User variables
 *
 * S = denoising factor
 * P = patch size (odd number)
 * R = research size (odd number)
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

// Uses more memory, may be faster (memory usage increases with S)
#define WEIGHT_LUT 1

/* Shader code */

#define OFF(x) (HOOKED_pt * (x))

const int hp = P/2;
const int hr = R/2;
const int e = hp + hr;
const float h = S*10.0;
const float pdiff_scale = 1.0/(h*h);
const float range = 255.0; // for making pixels range from 0-255
const int maxdiff = int(log(range)/pdiff_scale);
#if WEIGHT_LUT
shared float weight_lut[maxdiff+1];
#endif

vec4 nlmeans(vec2 px)
{
	vec4 weight, pdiff_sq, ignore;
	vec2 r, p, lower, upper;
	vec4 total_weight = vec4(1);
	vec4 sum = HOOKED_tex(px);

#if BOUNDS_CHECKING == 2
	vec2 abs_px = px * input_size;
	lower = min(vec2(hr), abs_px);
	upper = min(vec2(hr), input_size - abs_px);
	// try to extend sides opposite of truncated sides
	lower = min(lower + (vec2(hr) - upper), abs_px);
	upper = min(upper + (vec2(hr) - lower), input_size - abs_px);
#else
	lower = upper = vec2(hr);
#endif

	for (r.x = -lower.x; r.x <= upper.x; r.x++) {
		for (r.y = -lower.y; r.y <= upper.y; r.y++) {
			ignore = vec4(1);

#if BOUNDS_CHECKING == 1
			vec2 abs_r = px * input_size + r;
			ignore *= int(clamp(abs_r, vec2(0), input_size) == abs_r);
#endif

			pdiff_sq = vec4(0);
			for (p.x = -hp; p.x <= hp; p.x++)
				for (p.y = -hp; p.y <= hp; p.y++)
					pdiff_sq += pow((HOOKED_tex(px+OFF(r+p)) - HOOKED_tex(px+OFF(p))) * range, vec4(2));

			// low pdiff_sq -> high weight, high weight -> more blur
			// XXX bad performance on AMD-Vulkan (but not OpenGL), seems to be rooted here?
#if WEIGHT_LUT
#define WEIGHT(P) weight_lut[min(int(pdiff_sq.P), maxdiff)]
			weight = vec4(WEIGHT(x), WEIGHT(y), WEIGHT(z), WEIGHT(w));
#else
			ignore *= step(pdiff_sq, vec4(maxdiff));
			weight = exp(-pdiff_sq * pdiff_scale) * ignore;
#endif

			sum += weight * HOOKED_tex(px+OFF(r));
			total_weight += weight;
		}
	}

	return sum / total_weight;
}

void hook()
{
	ivec2 block = ivec2(gl_WorkGroupID.xy * BLOCKSIZE);

#if WEIGHT_LUT
	for (uint i = gl_LocalInvocationIndex; i < maxdiff; i += THREADS)
		weight_lut[i] = exp(-int(i) * pdiff_scale);
	weight_lut[maxdiff] = 0;
	barrier();
#endif

	for (uint idx = gl_LocalInvocationIndex; idx < (BLOCKSIZE.x * BLOCKSIZE.y); idx += THREADS) {
		ivec2 px = ivec2(idx%BLOCKSIZE.x, idx/BLOCKSIZE.y);
		imageStore(out_image, block+px, nlmeans(OFF(block+px+0.5)));
	}
}
