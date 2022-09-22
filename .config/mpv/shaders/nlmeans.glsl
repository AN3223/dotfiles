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
//!DESC Non-local means (downscale)
//!WIDTH HOOKED.w 2.0 /
//!HEIGHT HOOKED.h 2.0 /
//!SAVE DOWNSCALED

vec4 hook()
{
	return HOOKED_texOff(0);
}

//!HOOK LUMA
//!BIND HOOKED
//!DESC Non-local means (downscale)
//!WIDTH HOOKED.w 1.25 /
//!HEIGHT HOOKED.h 1.25 /
//!SAVE DOWNSCALED_LUMA

vec4 hook()
{
	return HOOKED_texOff(0);
}

//!HOOK LUMA
//!BIND HOOKED
//!DESC Non-local means (EP downscale)
//!WIDTH HOOKED.w 3 /
//!HEIGHT HOOKED.h 3 /
//!SAVE EP_LUMA

vec4 hook()
{
	return HOOKED_texOff(0);
}

//!HOOK LUMA
//!HOOK CHROMA
//!HOOK RGB
//!BIND HOOKED
//!BIND DOWNSCALED
//!BIND DOWNSCALED_LUMA
//!BIND EP_LUMA
//!DESC Non-local means

/* User variables
 *
 * S = denoising factor
 * P = patch size (odd number)
 * R = research size (odd number)
 * SS = spatial denoising factor
 *
 * Speed is dictated by (R^2 * P^2), e.g., P=3:R=15 is about as fast as P=5:R=9
 *
 * Increasing the denoising factor will increase blur without impacting speed.
 *
 * Decreasing spatial denoising factor will increase the locality, meaning 
 * distant pixels contribute less. Set SS to 0 disable this feature.
 *
 * Patch size should usually be 3. P=5 may be better sometimes, especially for 
 * bilateral chroma denoising. P>=7 is usually worse. P=1 is fairly low 
 * quality, but better than no denoising, so it could be useful for weak GPUs.
 *
 * Research size should be at least 3. Higher values are usually better, but 
 * slower and offer diminishing returns.
 *
 * It is usually preferable to denoise chroma and luma differently, so the user 
 * variables for luma and chroma are split.
 *
 * Suggested settings (assume defaults for unspecified parameters):
 * 	- Film (especially black and white):
 * 		- Disable chroma by removing the !HOOK CHROMA line above this comment
 * 	- HQ (slow):
 * 		- LUMA=S=1.5:P=3:R=15:SS=4:EP=0
 * 		- CHROMA=S=2:P=3:R=15:SS=4
 * 	- Anime (middleground between defaults & HQ, HQ offers better quality):
 * 		- LUMA=S=2:P=3:R=9:SS=0:EP=0
 *		- CHROMA=S=3:P=3:R=5:SS=0
 *
 * It's recommended to make multiple copies of this shader with settings 
 * tweaked for different types of content, and then dispatch the appropriate 
 * one via keybinds in input.conf, e.g.:
 *
 * F4 no-osd change-list glsl-shaders toggle "~~/shaders/nlmeans_luma.glsl"; show-text "Non-local means (LUMA only)"
 */
#ifdef LUMA_raw
#define S 1.25
#define P 3
#define R 5
#define SS 4
#else
#define S 3.0
#define P 3
#define R 5
#define SS 4
#endif

/* Weight function
 *
 * Bilateral scales well with heavy noise, and can offer good feature 
 * preservation on low-contrast detail (e.g., wood grain, reflections).
 *
 * NLM is great at low noise levels, and tends to preserve lines and patterns.
 *
 * 0: non-local means (NLM)
 * 1: bilateral
 */
#ifdef LUMA_raw
#define WF 0
#else
#define WF 0
#endif

/* Bounds checking
 *
 * Attempts to apply an appropriate amount of denoising to the edges of the 
 * image. The difference in quality usually imperceptible.
 *
 * 0: perform no bounds checking
 * 1: ignore out-of-bounds pixels (preferred)
 * 2: shift research zones to avoid out-of-bounds pixels (may be slow)
 */
#define BOUNDS_CHECKING 1

/* Extremes preserve
 *
 * Reduces denoising around very bright/dark areas. The downscaling factor of 
 * EP_LUMA (located near the top of this shader) controls the area sampled for 
 * luminance (higher numbers consider more area).
 *
 * EP: 1 to enable, 0 to disable
 * DP (starts at 1): EP strength on dark patches, 0 to fully denoise
 * BP (starts at 1): EP strength on bright patches, 0 to fully denoise
 */
#ifdef LUMA_raw
#define EP 1
#define BP 3.0
#define DP 1.0
#else
#define EP 0
#define BP 0.0
#define DP 0.0
#endif

/* Robust filtering
 *
 * Compares the pixel of interest against downscaled pixels.
 *
 * May improve quality, especially for low patch sizes, but can cause blur and 
 * distortion, especially in tandem with bilateral. Sigma may need to be 
 * decreased to account for the added blur.
 *
 * The downscale factor can be modified in the WIDTH/HEIGHT directives for the 
 * DOWNSCALED (for CHROMA, RGB) and DOWNSCALED_LUMA (LUMA only) textures near 
 * the top of this shader, higher numbers increase blur.
 *
 * Any notation of RF as a positive number should be assumed to be referring to 
 * the downscaling factor, e.g., RF=3 means RF is enabled and the downscaling 
 * factor is set to 3.
 */
#ifdef LUMA_raw
#define RF 1
#else
#define RF 1
#endif

/* Estimator
 *
 * 0: means (default, recommended)
 * 1: Euclidean medians (extremely slow, may be better for heavy noise)
 */
#define M 0

/* Shader code */

#if RF
#ifdef LUMA_raw
#define ROBUST_texOff(off) DOWNSCALED_LUMA_tex(HOOKED_pos + HOOKED_pt * vec2(off))
#else
#define ROBUST_texOff(off) DOWNSCALED_tex(HOOKED_pos + HOOKED_pt * vec2(off))
#endif
#else
#define ROBUST_texOff HOOKED_texOff
#endif

const int hp = P/2;
const int hr = R/2;
const float p_scale = 1.0/(P*P);

vec4 hook()
{
	vec2 r, p, lower, upper;

#if M == 1
	vec4 minsum = vec4(0);
	vec4 minpx = vec4(0);
#else
	vec4 total_weight = vec4(1);
	vec4 sum = HOOKED_texOff(0);
#endif

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

#if EP
	vec4 l = EP_LUMA_texOff(0);
	vec4 ep_weight = pow(min(1-l, l)*2, step(l, vec4(0.5))*DP + step(vec4(0.5), l)*BP);
#endif

	for (r.x = -lower.x; r.x <= upper.x; r.x++) {
	for (r.y = -lower.y; r.y <= upper.y; r.y++) {
		// low pdiff -> high weight, high weight -> more blur
#if WF == 1
		const float pdiff_scale = 1.0/(S*0.005);

		vec4 pdiff = vec4(0);
		for (p.x = -hp; p.x <= hp; p.x++)
			for (p.y = -hp; p.y <= hp; p.y++)
				pdiff += ROBUST_texOff(r+p) - HOOKED_texOff(p);
		pdiff *= p_scale; // avg pixel difference

		vec4 weight = exp(-pow(pdiff * pdiff_scale, vec4(2)));
#else
		const float h = S*10.0;
		const float pdiff_scale = 1.0/(h*h);
		const float range = 255.0; // for making pixels range from 0-255

		vec4 pdiff_sq = vec4(0);
		for (p.x = -hp; p.x <= hp; p.x++)
			for (p.y = -hp; p.y <= hp; p.y++)
				pdiff_sq += pow((ROBUST_texOff(r+p) - HOOKED_texOff(p)) * range, vec4(2));

		vec4 weight = exp(-pdiff_sq * pdiff_scale);
#endif

#if SS
		const float length_scale = 1.0/float(SS);
		weight *= exp(-pow(length(r) * length_scale, 2));
#endif

#if EP
		weight *= ep_weight;
#endif

#if BOUNDS_CHECKING == 1
		vec2 abs_r = HOOKED_pos * input_size + r;
		weight *= int(clamp(abs_r, vec2(0), input_size) == abs_r);
#endif

#if M == 1
		/* Based on: https://arxiv.org/abs/1207.3056
		 *
		 * It describes using the center pixel of the patch that results in the 
		 * minimum sum of the weighted patch distances.
		 *
		 * However, this implementation uses the opposite weight, one minus weight. 
		 * Using the regular weight doesn't seem to make sense, as that would 
		 * reduce the sum for patches that are the most different from the patch 
		 * around the pixel of interest, therefore the most dissimilar pixels would 
		 * get selected.
		 */
		vec2 r2;
		vec4 wpdist_sum = vec4(0);
		for (r2.x = -lower.x; r2.x <= upper.x; r2.x++) {
			for (r2.y = -lower.y; r2.y <= upper.y; r2.y++) {
				vec4 pdist = vec4(0);
				for (p.x = -hp; p.x <= hp; p.x++)
					for (p.y = -hp; p.y <= hp; p.y++)
						pdist += pow((HOOKED_texOff(r2+p) - HOOKED_texOff(r+p)) * 255, vec4(2));
				wpdist_sum += sqrt(pdist) * (1-weight);
			}
		}

		// initialize minsum and minpx
		minsum += step(minsum, vec4(0)) * wpdist_sum;
		minpx  += step(minpx, vec4(0))  * HOOKED_texOff(r);

		// find new minimums, exclude zeros
		vec4 newmin = step(wpdist_sum, minsum) - step(wpdist_sum, vec4(0));
		vec4 notmin = 1 - newmin;

		// update minimums
		minsum = (newmin * wpdist_sum)       + (notmin * minsum);
		minpx  = (newmin * HOOKED_texOff(r)) + (notmin * minpx);
#else
		sum += HOOKED_texOff(r) * weight;
		total_weight += weight;
#endif
	}
	}

#if M == 1
	return minpx;
#else
	return sum / total_weight;
#endif
}

