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
//!HOOK CHROMA
//!HOOK RGB
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
//!HOOK CHROMA
//!HOOK RGB
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
//!BIND PREV1
//!BIND PREV2
//!BIND PREV3
//!BIND PREV4
//!BIND PREV5
//!BIND PREV6
//!BIND PREV7
//!BIND PREV8
//!BIND PREV9
//!BIND PREV10
//!DESC Non-local means

/* User variables
 *
 * S = denoising factor
 * P = patch size (odd number)
 * R = research size (odd number)
 * SS = spatial denoising factor
 *
 * A higher denoising factor will increase the denoising effect.
 *
 * With a higher spatial denoising factor, distant pixels will contribute less.
 *
 * Patch size should usually be 3. Higher values are not always better.
 *
 * Research size should be at least 3. Higher values are usually better, but 
 * slower and offer diminishing returns.
 *
 * It is usually preferable to denoise chroma and luma differently, so the user 
 * variables for luma and chroma are split.
 *
 * Suggested settings (assume defaults for unspecified parameters):
 * 	- Film (especially black and white):
 * 		- Disable chroma by removing the HOOK CHROMA lines above
 * 	- HQ (slow):
 * 		- LUMA=S=3:EP=0:RI=2:WD=2:WDT=1
 *
 * It is recommended to make multiple copies of this shader with settings 
 * tweaked for different types of content, and then dispatch the appropriate 
 * one via keybinds in input.conf, e.g.:
 *
 * F4 no-osd change-list glsl-shaders toggle "~~/shaders/nlmeans_luma.glsl"; show-text "Non-local means (LUMA only)"
 *
 * The shader can also be enabled by default in mpv.conf:
 *
 * glsl-shaders='~~/shaders/nlmeans.glsl'
 *
 * Both of the examples above assume the shader(s) being located in a 
 * subdirectory named "shaders" inside of mpv's config directory. Refer to the 
 * mpv documentation for more details.
 */
#ifdef LUMA_raw
#define S 1.25
#define P 3
#define R 5
#define SS 0.25
#else
#define S 2.0
#define P 3
#define R 5
#define SS 0.25
#endif

/* Weight discard
 *
 * Discard weights that fall below a threshold based on the average weight. 
 * This causes areas with less noise to receive less blur.
 * 
 * WD:
 * 	- 2: true average, very good quality, but slower and uses more memory
 * 	- 1: moving cumulative average, inaccurate, tends to blur directionally
 * 	- 0: disable
 *
 * WDT: Threshold coefficient, higher numbers discard more
 * WDP (WD=1): Higher numbers reduce the threshold more for small sample sizes
 */
#ifdef LUMA_raw
#define WD 1
#define WDT 0.875
#define WDP 6.0
#else
#define WD 1
#define WDT 0.875
#define WDP 6.0
#endif

/* Patch shape
 *
 * Useful for making patches with areas between 1x1, 3x3, 5x5, etc. for 
 * fine-grain control, might have other effects too. Always reduces patch area 
 * in comparison to square.
 *
 * 3: diamond
 * 2: vertical line
 * 1: horizontal line
 * 0: square
 */
#ifdef LUMA_raw
#define PS 3
#else
#define PS 3
#endif

/* Rotational invariance
 *
 * Number of rotations to try for each patch comparison. Slow, but can greatly 
 * increase feature preservation.
 *
 * Each additional rotation provides greatly diminishing returns.
 *
 * 0: 0
 * 1: 0, 90
 * 2: 0, 90, 180
 * 3: 0, 90, 180, 270
 * 4: 0, 90, 180, 270, hflip
 * 5: 0, 90, 180, 270, hflip, vflip
 */
#ifdef LUMA_raw
#define RI 0
#else
#define RI 0
#endif

/* Temporal denoising
 *
 * Limitations:
 * 	- Slower, since each frame is researched
 * 	- Requires gpu-next and nlmeans_next.glsl
 * 	- Luma-only (this is a bug)
 * 	- Max 3840x3840 resolution, limit can be increased at the bottom of the shader
 * 	- Max 10 frames, also hardcoded
 * 	- Might be buggy
 *
 * Gather samples across multiple frames. May cause motion blur and may 
 * struggle more with noise that persists across multiple frames, but can work 
 * very well on high quality video.
 *
 * For the spatial kernel, the distortion (SD) is a coefficient of the 
 * coordinates, with each component corresponding to an axis (X, Y, Z). For 
 * example:
 * 	- SD=(1,1,1): no distortion
 * 	- SD=(1,1,2): previous frames are twice as far away
 * 	- SD=(1,1,0.5): previous frames are half as far away
 * 	- SD=(1,1,0): previous frames are no further than the current frame
 *
 * SD is most useful for controlling motion blur, higher Z values produce less 
 * motion blur. SD only works if SS is greater than zero.
 *
 * The X and Y distortion of the spatial kernel can be controlled with SD too,
 * although I'm not aware of any practical use for them.
 *
 * T: number of frames used
 * SD: spatial distortion
 */
#ifdef LUMA_raw
#define T 0
#define SD vec3(1,1,1)
#else
#define T 0
#define SD vec3(1,1,1)
#endif

/* Weight function
 *
 * NLM is generally preferable.
 *
 * Bilateral may do better with heavy noise, but can produce jaggies and even 
 * worse artifacts when used with RF.
 *
 * 0: non-local means (NLM)
 * 1: bilateral
 */
#ifdef LUMA_raw
#define WF 0
#else
#define WF 0
#endif

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
#endif

/* Robust filtering
 *
 * Compares the pixel of interest against downscaled pixels.
 *
 * This will almost always improve quality, except when bilateral is used.
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
 * 0: means
 * 1: Euclidean medians (extremely slow, may be better for heavy noise)
 * 2: weight map (not a denoiser, intended for development use)
 */
#ifdef LUMA_raw
#define M 0
#else
#define M 0
#endif

/* Blur factor
 *
 * The amount to blur the pixel of interest with the estimated pixel. For the 
 * means estimator this should always be 1.0, since it already blurs against 
 * the pixel of interest and the level of blur can be controlled with the S 
 * macro.
 *
 * BF (1>=BF>=0): blur factor, 1 being the estimation, 0 being the raw input
 */
#ifdef LUMA_raw
#define BF 1.0
#else
#define BF 1.0
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

/* Shader code */

#if RF && defined(LUMA_raw)
#define TEX DOWNSCALED_LUMA_tex
#elif RF
#define TEX DOWNSCALED_tex
#else
#define TEX HOOKED_tex
#endif

const int hp = P/2;
const int hr = R/2;
const int r_area = R*R*(T+1);
const float r_scale = 1.0/r_area;
const float range = 255.0;

#if P == 0 || P == 1 // 1x1
#define FOR_PATCH(p) for (p = vec3(0); p.x <= 0; p.x++) for (int ri = 0; ri <= 0; ri++)
const int p_area = 1;
#elif PS == 3        // diamond
#define FOR_PATCH(p) for (p.x = -hp; p.x <= hp; p.x++) for (p.y = -abs(abs(p.x) - hp); p.y <= abs(abs(p.x) - hp); p.y++) for (int ri = 0; ri <= RI; ri++)
const int p_area = int(pow(hp+1, 2))*(RI+1);
#elif PS == 2        // vertical
#define FOR_PATCH(p) for (p.x = 0; p.x <= 0; p.x++) for (p.y = -hp; p.y <= hp; p.y++) for (int ri = 0; ri <= RI; ri++)
const int p_area = P*(RI+1);
#elif PS == 1        // horizontal
#define FOR_PATCH(p) for (p.x = -hp; p.x <= hp; p.x++) for (p.y = 0; p.y <= 0; p.y++) for (int ri = 0; ri <= RI; ri++)
const int p_area = P*(RI+1);
#else                // square
#define FOR_PATCH(p) for (p.x = -hp; p.x <= hp; p.x++) for (p.y = -hp; p.y <= hp; p.y++) for (int ri = 0; ri <= RI; ri++)
const int p_area = P*P*(RI+1);
#endif

const float p_scale = 1.0/p_area;

#if T
vec4 load(vec3 off)
{
	switch (int(off.z)) {
	case 0:
		return TEX(HOOKED_pos + HOOKED_pt * vec2(off));
#ifdef PREV1
	case 1:
		return imageLoad(PREV1, ivec2(HOOKED_pos * target_size + HOOKED_pt * vec2(off)));
#endif
#ifdef PREV2
	case 2:
		return imageLoad(PREV2, ivec2(HOOKED_pos * target_size + HOOKED_pt * vec2(off)));
#endif
#ifdef PREV3
	case 3:
		return imageLoad(PREV3, ivec2(HOOKED_pos * target_size + HOOKED_pt * vec2(off)));
#endif
#ifdef PREV4
	case 4:
		return imageLoad(PREV4, ivec2(HOOKED_pos * target_size + HOOKED_pt * vec2(off)));
#endif
#ifdef PREV5
	case 5:
		return imageLoad(PREV5, ivec2(HOOKED_pos * target_size + HOOKED_pt * vec2(off)));
#endif
#ifdef PREV6
	case 6:
		return imageLoad(PREV6, ivec2(HOOKED_pos * target_size + HOOKED_pt * vec2(off)));
#endif
#ifdef PREV7
	case 7:
		return imageLoad(PREV7, ivec2(HOOKED_pos * target_size + HOOKED_pt * vec2(off)));
#endif
#ifdef PREV8
	case 8:
		return imageLoad(PREV8, ivec2(HOOKED_pos * target_size + HOOKED_pt * vec2(off)));
#endif
#ifdef PREV9
	case 9:
		return imageLoad(PREV9, ivec2(HOOKED_pos * target_size + HOOKED_pt * vec2(off)));
#endif
#ifdef PREV10
	case 10:
		return imageLoad(PREV10, ivec2(HOOKED_pos * target_size + HOOKED_pt * vec2(off)));
#endif
	}
}
#else
#define load(off) TEX(HOOKED_pos + HOOKED_pt * vec2(off))
#endif

vec3 rotate(vec3 coords, int degree)
{
	switch (degree) {
	case 0: // 0 degrees
		return coords;
	case 1: // 90 degrees clockwise
		return coords.yxz * vec3(1,-1,1);
	case 2: // 180 degrees clockwise
		return coords * vec3(-1,-1,1);
	case 3: // 270 degrees clockwise
		return coords.yxz * vec3(-1,1,1);
	case 4: // flip horizontally
		return coords * vec3(-1,1,1);
	case 5: // flip vertically
		return coords * vec3(1,-1,1);
	}
}

vec4 hook()
{
	vec3 lower, upper;
	vec3 r = vec3(0);
	vec3 p = vec3(0);
	int r_index = 0;
	vec4 total_weight = vec4(1);
	vec4 sum = HOOKED_texOff(0);

#if WD == 2
	vec4 all_weights[r_area];
	vec4 all_pixels[r_area];
#elif WD == 1
	vec4 no_weights = vec4(1);
#endif

#if M == 1
	vec4 minsum = vec4(0);
	vec4 minpx = vec4(0);
#endif

#if BOUNDS_CHECKING == 2
	vec2 px_pos = HOOKED_pos * input_size;
	lower = min(vec2(hr), px_pos);
	upper = min(vec2(hr), input_size - px_pos);
	// try to extend sides opposite of truncated sides
	lower = min(lower + (vec2(hr) - upper), px_pos);
	upper = min(upper + (vec2(hr) - lower), input_size - px_pos);
#else
	lower = upper = vec3(hr);
#endif

#if EP
	vec4 l = EP_LUMA_texOff(0);
	vec4 ep_weight = pow(min(1-l, l)*2, step(l, vec4(0.5))*DP + step(vec4(0.5), l)*BP);
#endif

	for (r.z = 0; r.z <= T; r.z++)
	for (r.x = -lower.x; r.x <= upper.x; r.x++)
	for (r.y = -lower.y; r.y <= upper.y; r.y++,r_index++) {
		// low pdiff -> high weight, high weight -> more blur
#if WF == 1 // bilateral
		const float pdiff_scale = 1.0/(S*0.00166);

		vec4 pdiff = vec4(0);
		FOR_PATCH(p)
			pdiff += HOOKED_texOff(p) - load(rotate(p,ri)+r);

		vec4 weight = exp(-pow(pdiff * p_scale * pdiff_scale, vec4(2)));
#else // non-local means
		const float h = S*3.33;
		const float pdiff_scale = 1.0/(h*h);

		vec4 pdiff_sq = vec4(0);
		FOR_PATCH(p)
			pdiff_sq += pow((HOOKED_texOff(p) - load(rotate(p,ri)+r)) * range, vec4(2));

		vec4 weight = exp(-pdiff_sq * p_scale * pdiff_scale);
#endif

		weight *= exp(-pow(length(r*SD) * SS, 2));

#if EP
		weight *= ep_weight;
#endif

#if BOUNDS_CHECKING == 1
		vec2 abs_r = HOOKED_pos * input_size + vec2(r);
		weight *= int(clamp(abs_r, vec2(0), input_size) == abs_r);
#endif

#if WD == 2 // true average
		all_weights[r_index] = weight;
		all_pixels[r_index] = load(r) * weight;
#elif WD == 1 // cumulative moving average
		vec4 wd_scale = 1.0/no_weights;
		vec4 keeps = step(total_weight*wd_scale*WDT*exp(-wd_scale*WDP), weight);
		weight *= keeps;
		no_weights += keeps;
#endif

		sum += load(r) * weight;
		total_weight += weight;

#if M == 1 // Euclidean median
		// Based on: https://arxiv.org/abs/1207.3056
		// XXX currently this doesn't work with WD=2
		vec3 r2;
		vec4 wpdist_sum = vec4(0);
		for (r.z = 0; r.z <= T; r.z++)
		for (r2.x = -lower.x; r2.x <= upper.x; r2.x++)
		for (r2.y = -lower.y; r2.y <= upper.y; r2.y++) {
				vec4 pdist = vec4(0);
				FOR_PATCH(p)
					pdist += pow((load(p+r) - load(rotate(p,ri)+r2)) * 255, vec4(2));

				// opposite weight; regular weight doesn't seem to make sense here
				wpdist_sum += sqrt(pdist) * (1-weight);
		}

		// initialize minsum and minpx
		minsum += step(minsum, vec4(0)) * wpdist_sum;
		minpx  += step(minpx, vec4(0))  * load(r);

		// find new minimums, exclude zeros
		vec4 newmin = step(wpdist_sum, minsum) - step(wpdist_sum, vec4(0));
		vec4 notmin = 1 - newmin;

		// update minimums
		minsum = (newmin * wpdist_sum) + (notmin * minsum);
		minpx  = (newmin * load(r))    + (notmin * minpx);
#endif
	}

#ifdef PREV10
	imageStore(PREV10, ivec2(HOOKED_pos*target_size), load(vec3(0,0,9)));
#endif
#ifdef PREV9
	imageStore(PREV9, ivec2(HOOKED_pos*target_size), load(vec3(0,0,8)));
#endif
#ifdef PREV8
	imageStore(PREV8, ivec2(HOOKED_pos*target_size), load(vec3(0,0,7)));
#endif
#ifdef PREV7
	imageStore(PREV7, ivec2(HOOKED_pos*target_size), load(vec3(0,0,6)));
#endif
#ifdef PREV6
	imageStore(PREV6, ivec2(HOOKED_pos*target_size), load(vec3(0,0,5)));
#endif
#ifdef PREV5
	imageStore(PREV5, ivec2(HOOKED_pos*target_size), load(vec3(0,0,4)));
#endif
#ifdef PREV4
	imageStore(PREV4, ivec2(HOOKED_pos*target_size), load(vec3(0,0,3)));
#endif
#ifdef PREV3
	imageStore(PREV3, ivec2(HOOKED_pos*target_size), load(vec3(0,0,2)));
#endif
#ifdef PREV2
	imageStore(PREV2, ivec2(HOOKED_pos*target_size), load(vec3(0,0,1)));
#endif
#ifdef PREV1
	imageStore(PREV1, ivec2(HOOKED_pos*target_size), load(vec3(0)));
#endif

#if WD == 2 // true average
	vec4 avg_weight = total_weight * r_scale;
	total_weight = vec4(1);
	sum = HOOKED_texOff(0);

	for (int i = 0; i < r_area; i++) {
		vec4 keeps = step(avg_weight*WDT, all_weights[i]);
		sum += all_pixels[i] * keeps;
		total_weight += all_weights[i] * keeps;
	}
#endif

#if M == 2 // weight map
	vec4 result = total_weight * r_scale;
#elif M == 1 // Euclidean median
	vec4 result = minpx;
#else // mean
	vec4 result = sum / total_weight;
#endif

	return mix(HOOKED_texOff(0), result, BF);
}

//!TEXTURE PREV1
//!SIZE 3840 3840
//!FORMAT r32f
//!STORAGE

//!TEXTURE PREV2
//!SIZE 3840 3840
//!FORMAT r32f
//!STORAGE

//!TEXTURE PREV3
//!SIZE 3840 3840
//!FORMAT r32f
//!STORAGE

//!TEXTURE PREV4
//!SIZE 3840 3840
//!FORMAT r32f
//!STORAGE

//!TEXTURE PREV5
//!SIZE 3840 3840
//!FORMAT r32f
//!STORAGE

//!TEXTURE PREV6
//!SIZE 3840 3840
//!FORMAT r32f
//!STORAGE

//!TEXTURE PREV7
//!SIZE 3840 3840
//!FORMAT r32f
//!STORAGE

//!TEXTURE PREV8
//!SIZE 3840 3840
//!FORMAT r32f
//!STORAGE

//!TEXTURE PREV9
//!SIZE 3840 3840
//!FORMAT r32f
//!STORAGE

//!TEXTURE PREV10
//!SIZE 3840 3840
//!FORMAT r32f
//!STORAGE
