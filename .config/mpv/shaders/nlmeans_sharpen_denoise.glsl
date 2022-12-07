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

// Profile description: Sharpen and denoise.

/* The recommended usage of this shader and its variants is to add them to 
 * input.conf and then dispatch the appropriate shader via a keybind during 
 * media playback. Here is an example input.conf entry:
 *
 * F4 no-osd change-list glsl-shaders toggle "~~/shaders/nlmeans_luma.glsl"; show-text "Non-local means (LUMA only)"
 *
 * These shaders can also be enabled by default in mpv.conf, for example:
 *
 * glsl-shaders='~~/shaders/nlmeans.glsl'
 *
 * Both of the examples above assume the shaders are located in a subdirectory 
 * named "shaders" within mpv's config directory. Refer to the mpv 
 * documentation for more details.
 *
 * This shader is highly configurable via user variables below. Although the 
 * default settings should offer good quality at a reasonable speed, you are 
 * encouraged to tweak them to your preferences. Be mindful that different 
 * settings may have different quality and/or speed characteristics.
 *
 * Denoising is most useful for noisy content. If there is no perceptible 
 * noise, you probably won't see a positive difference.
 *
 * Highly noisy content requires a high denoising factor, which will incur a 
 * high loss of detail. The default settings are generally tuned for low noise 
 * and high detail preservation.
 *
 * The denoiser will not work properly if the content has been upscaled 
 * beforehand, whether it was done by you or the content creator.
 *
 * You will probably get better speeds with --vo=gpu-next if available, 
 * different --gpu-api will likely vary in performance as well.
 */

//!HOOK LUMA
//!HOOK CHROMA
//!HOOK RGB
//!BIND HOOKED
//!DESC Non-local means (downscale)
//!SAVE RF
//!WIDTH HOOKED.w 2.0 /
//!HEIGHT HOOKED.h 2.0 /

vec4 hook()
{
	return HOOKED_texOff(0);
}

//!HOOK LUMA
//!HOOK CHROMA
//!HOOK RGB
//!BIND HOOKED
//!DESC Non-local means (downscale)
//!SAVE RF_LUMA
//!WIDTH HOOKED.w 1.25 /
//!HEIGHT HOOKED.h 1.25 /

vec4 hook()
{
	return HOOKED_texOff(0);
}

//!HOOK LUMA
//!HOOK CHROMA
//!HOOK RGB
//!BIND HOOKED
//!DESC Non-local means (downscale)
//!SAVE EP_LUMA
//!WIDTH HOOKED.w 3 /
//!HEIGHT HOOKED.h 3 /

vec4 hook()
{
	return HOOKED_texOff(0);
}

//!HOOK LUMA
//!HOOK CHROMA
//!HOOK RGB
//!BIND HOOKED
//!BIND RF
//!BIND RF_LUMA
//!BIND EP_LUMA
//!DESC Non-local means

/* User variables
 *
 * It is usually preferable to denoise chroma and luma differently, so the user 
 * variables for luma and chroma are split.
 */

/* S = denoising factor
 * P = patch size
 * R = research size
 *
 * The denoising factor controls the level of blur, higher is blurrier.
 *
 * Patch size should usually be 3. Higher values are slower and not always better.
 *
 * Research size should be at least 3. Higher values are usually better, but 
 * slower and offer diminishing returns.
 */
#ifdef LUMA_raw
#define S 9
#define P 3
#define R 5
#else
#define S 1.50
#define P 3
#define R 5
#endif

/* Adaptive sharpening
 *
 * Uses the blur incurred by denoising plus the weight map to perform an 
 * unsharp mask that gets applied most strongly to edges.
 *
 * Sharpening will amplify noise, so the denoising factor (S) should usually be 
 * increased to compensate.
 *
 * AS: 2 for sharpening, 1 for sharpening+denoising, 0 to disable
 * ASF: Sharpening factor, higher numbers make a sharper underlying image
 * ASP: Weight power, higher numbers use more of the sharp image
 */
#ifdef LUMA_raw
#define AS 1
#define ASF 1.0
#define ASP 4.0
#else
#define AS 0
#define ASF 1.0
#define ASP 4.0
#endif

/* Weight discard
 *
 * Discard weights that fall below a fraction of the average weight. This culls 
 * the most dissimilar samples from the blur, yielding a much more pleasant 
 * result, especially around edges.
 * 
 * WD:
 * 	- 2: True average. Very good quality, but slower and uses more memory.
 * 	- 1: Moving cumulative average. Inaccurate, tends to blur directionally.
 * 	- 0: Disable
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

/* Spatial kernel
 *
 * Increasing the spatial denoising factor (SS) reduces the weight of further 
 * pixels.
 *
 * Spatial distortion instructs the spatial kernel to view that axis as 
 * closer/further, for instance SD=(1,1,0.5) would make the temporal axis 
 * appear closer and increase blur between frames.
 *
 * The intra-patch variants do not yet have well-understood effects. They are 
 * intended to make large patch sizes more useful. Likely significantly slower.
 *
 * SS: spatial denoising factor
 * SD: spatial distortion (X, Y, time)
 * PSS: intra-patch spatial denoising factor
 * PST: enables intra-patch spatial kernel if P>=PST, 0 fully disables
 * PSD: intra-patch spatial distortion (X, Y)
 */
#ifdef LUMA_raw
#define SS 0.25
#define SD vec3(1,1,1)
#define PST 0
#define PSS 0.0
#define PSD vec2(1,1)
#else
#define SS 0.25
#define SD vec3(1,1,1)
#define PST 0
#define PSS 0.0
#define PSD vec2(1,1)
#endif

/* Search shape
 *
 * Determines the shape of patches and research zones. Different shapes have 
 * different speed and quality characteristics. Every shape is smaller than 
 * square, with the exception of square itself.
 *
 * PS applies applies to patches, RS applies to research zones.
 *
 * For PS it is highly recommended to stick to textureGather optimized shapes, 
 * these will run much faster on GPUs that support textureGather.
 *
 * 0: square (symmetrical)
 * 1: horizontal line
 * 2: vertical line
 * 3: diamond (symmetrical)
 * 4: triangle (pointing upward, textureGather optimized at P=3)
 * 5: truncated triangle (last row halved)
 * 6: even sized square (textureGather optimized at any P size)
 */
#ifdef LUMA_raw
#define RS 3
#define PS 4
#else
#define RS 3
#define PS 4
#endif

/* Rotational/reflectional invariance
 *
 * Number of rotations/reflections to try for each patch comparison. Slow, but 
 * improves feature preservation, although adding more rotations/reflections 
 * gives diminishing returns.
 *
 * The angle in degrees of each rotation is 360/(RI+1), so RI=1 will do a 
 * single 180 degree rotation, RI=3 will do three 90 degree rotations, etc.
 *
 * The textureGather optimization is only available with:
 * - PS=4:RI=0
 * - PS=6:RI={0,1,3}:RFI={0,1}
 *
 * RI: Rotational invariance
 * RFI: Reflectional invariance
 */
#ifdef LUMA_raw
#define RI 0
#define RFI 0
#else
#define RI 0
#define RFI 0
#endif

/* Temporal denoising
 *
 * Caveats:
 * 	- Slower, each frame needs to be researched
 * 	- Requires vo=gpu-next and nlmeans_temporal.glsl
 * 	- Luma-only (this is a bug)
 * 	- Buggy
 *
 * Gather samples across multiple frames. May cause motion blur and may 
 * struggle more with noise that persists across multiple frames (compression 
 * noise, repeating frames), but can work very well on high quality video.
 *
 * T: number of frames used
 */
#ifdef LUMA_raw
#define T 0
#else
#define T 0
#endif

/* Extremes preserve
 *
 * Reduces denoising around very bright/dark areas. The downscaling factor of 
 * EP (located near the top of this shader) controls the area sampled for 
 * luminance (higher numbers consider more area).
 *
 * EP: 1 to enable, 0 to disable
 * DP: EP strength on dark patches, 0 to fully denoise
 * BP: EP strength on bright patches, 0 to fully denoise
 */
#ifdef LUMA_raw
#define EP 1
#define BP 0.75
#define DP 0.25
#else
#define EP 0
#define BP 0.0
#define DP 0.0
#endif

/* Robust filtering
 *
 * Compares the pixel-of-interest against downscaled pixels.
 *
 * This will virtually always improve quality, but will disable textureGather 
 * optimizations.
 *
 * The downscale factor can be modified in the WIDTH/HEIGHT directives for the 
 * RF texture (for CHROMA, RGB) and RF_LUMA (LUMA only) textures near the top 
 * of this shader, higher numbers increase blur.
 *
 * Any notation of RF as a positive number should be assumed to be referring to 
 * the downscaling factor, e.g., RF=3 means RF is enabled and the downscaling 
 * factor is set to 3.
 */
#ifdef LUMA_raw
#define RF 0
#else
#define RF 1
#endif

/* Estimator
 *
 * 0: means
 * 1: Euclidean medians (extremely slow, may be good for heavy noise)
 * 2: weight map (not a denoiser, maybe useful for generating image masks)
 * 3: weighted median intensity (slow, may be good for heavy noise)
 * 4: maximum weight (not a denoiser, intended for development use)
 */
#ifdef LUMA_raw
#define M 0
#else
#define M 0
#endif

/* Starting weight
 *
 * This can be used to modify the weight of the pixel-of-interest. Lower 
 * numbers give less weight to the pixel-of-interest.
 *
 * EPSILON may be used in place of zero to avoid divide-by-zero errors.
 */
#ifdef LUMA_raw
#define SW 1.0
#else
#define SW 1.0
#endif

/* Patch donut
 *
 * If enabled, ignores center pixel of patch comparisons.
 *
 * Disables textureGather optimizations.
 */
#ifdef LUMA_raw
#define PD 0
#else
#define PD 0
#endif

/* Blur factor
 *
 * The amount to blur the pixel-of-interest with the estimated pixel. For the 
 * means estimator this should always be 1.0, since it already blurs against 
 * the pixel-of-interest and the level of blur can be controlled with the 
 * denoising factor (S).
 *
 * BF (1>=BF>=0): blur factor, 1 being the estimation, 0 being the raw input
 */
#ifdef LUMA_raw
#define BF 1.0
#else
#define BF 1.0
#endif

/* Shader code */

#define EPSILON 0.00000000001

#if PS == 6
const int hp = P/2;
#else
const float hp = int(P/2) - 0.5*(1-(P%2));
#endif

#if RS == 6
const int hr = R/2;
#else
const float hr = int(R/2) - 0.5*(1-(R%2));
#endif

// donut increment, increments without landing on (0,0,0)
#define DINCR(z,c) (z.c++,(z.c += int(z == vec3(0))))

// search shapes and their corresponding areas
#define S_1X1(z) for (z = vec3(0); z.x <= 0; z.x++)

#define S_TRIANGLE(z,hz,incr) for (z.y = -hz; z.y <= 0; z.y++) for (z.x = -abs(abs(z.y) - hz); z.x <= abs(abs(z.y) - hz); incr)
#define S_TRUNC_TRIANGLE(z,hz,incr) for (z.y = -hz; z.y <= 0; z.y++) for (z.x = -abs(abs(z.y) - hz); z.x <= abs(abs(z.y) - hz)*int(z.y!=0); incr)
#define S_TRIANGLE_A(hz,Z) int(pow(hz, 2)+Z)

#define S_DIAMOND(z,hz,incr) for (z.x = -hz; z.x <= hz; z.x++) for (z.y = -abs(abs(z.x) - hz); z.y <= abs(abs(z.x) - hz); incr)
#define S_DIAMOND_A(hz,Z) int(pow(hz, 2)*2+Z)

#define S_VERTICAL(z,hz,incr) for (z.x = 0; z.x <= 0; z.x++) for (z.y = -hz; z.y <= hz; incr)
#define S_HORIZONTAL(z,hz,incr) for (z.x = -hz; z.x <= hz; incr) for (z.y = 0; z.y <= 0; z.y++)

#define S_SQUARE(z,hz,incr) for (z.x = -hz; z.x <= hz; z.x++) for (z.y = -hz; z.y <= hz; incr)
#define S_SQUARE_EVEN(z,hz,incr) for (z.x = -hz; z.x < hz; z.x++) for (z.y = -hz; z.y < hz; incr)

// research shapes
#define T1 (T+1)
#define FOR_FRAME for (r.z = 0; r.z < T1; r.z++)
#if R == 0 || R == 1
#define FOR_RESEARCH(r) FOR_FRAME S_1X1(r)
const int r_area = T1-1;
#elif RS == 6
#define FOR_RESEARCH(r) FOR_FRAME S_SQUARE_EVEN(r,hr,DINCR(r,y))
const int r_area = R*R*T1-1;
#elif RS == 5
#define FOR_RESEARCH(r) FOR_FRAME S_TRUNC_TRIANGLE(r,hr,DINCR(r,x))
const int r_area = S_TRIANGLE_A(hr,hr)*T1-1;
#elif RS == 4
#define FOR_RESEARCH(r) FOR_FRAME S_TRIANGLE(r,hr,DINCR(r,x))
const int r_area = S_TRIANGLE_A(hr,R)*T1-1;
#elif RS == 3
#define FOR_RESEARCH(r) FOR_FRAME S_DIAMOND(r,hr,DINCR(r,y))
const int r_area = S_DIAMOND_A(hr,R)*T1-1;
#elif RS == 2
#define FOR_RESEARCH(r) FOR_FRAME S_VERTICAL(r,hr,DINCR(r,y))
const int r_area = R*T1-1;
#elif RS == 1
#define FOR_RESEARCH(r) FOR_FRAME S_HORIZONTAL(r,hr,DINCR(r,x))
const int r_area = R*T1-1;
#elif RS == 0
#define FOR_RESEARCH(r) FOR_FRAME S_SQUARE(r,hr,DINCR(r,y))
const int r_area = R*R*T1-1;
#endif

#define RI1 (RI+1)
#define RFI1 (RFI+1)

#if RI
#define FOR_ROTATION for (float ri = 0; ri < 360; ri+=360.0/RI1)
#else
#define FOR_ROTATION
#endif

#if RFI
#define FOR_REFLECTION for (float rfi = 45; rfi < 225; rfi+=180.0/RFI1)
#else
#define FOR_REFLECTION
#endif

#if PD
#define PINCR DINCR
#else
#define PINCR(z,c) (z.c++)
#endif

// patch shapes
#if P == 0 || P == 1
#define FOR_PATCH(p) S_1X1(p) FOR_ROTATION FOR_REFLECTION
const int p_area = 1;
#elif PS == 6
#define FOR_PATCH(p) S_SQUARE_EVEN(p,hp,PINCR(p,y)) FOR_ROTATION FOR_REFLECTION
const int p_area = (P*P-PD)*RI1*RFI1;
#elif PS == 5
#define FOR_PATCH(p) S_TRUNC_TRIANGLE(p,hp,PINCR(p,x)) FOR_ROTATION FOR_REFLECTION
const int p_area = (S_TRIANGLE_A(hp,hp) - PD)*RI1*RFI1;
#elif PS == 4
#define FOR_PATCH(p) S_TRIANGLE(p,hp,PINCR(p,x)) FOR_ROTATION FOR_REFLECTION
const int p_area = (S_TRIANGLE_A(hp,P) - PD)*RI1*RFI1;
#elif PS == 3
#define FOR_PATCH(p) S_DIAMOND(p,hp,PINCR(p,y)) FOR_ROTATION FOR_REFLECTION
const int p_area = (S_DIAMOND_A(hp,P) - PD)*RI1*RFI1;
#elif PS == 2
#define FOR_PATCH(p) S_VERTICAL(p,hp,PINCR(p,y)) FOR_ROTATION FOR_REFLECTION
const int p_area = (P-PD)*RI1*RFI1;
#elif PS == 1
#define FOR_PATCH(p) S_HORIZONTAL(p,hp,PINCR(p,x)) FOR_ROTATION FOR_REFLECTION
const int p_area = (P-PD)*RI1*RFI1;
#elif PS == 0
#define FOR_PATCH(p) S_SQUARE(p,hp,PINCR(p,y)) FOR_ROTATION FOR_REFLECTION
const int p_area = (P*P-PD)*RI1*RFI1;
#endif

const float r_scale = 1.0/r_area;
const float p_scale = 1.0/p_area;

#if RF && defined(LUMA_raw)
#define TEX RF_LUMA_tex
#elif RF
#define TEX RF_tex
#else
#define TEX HOOKED_tex
#endif

#define load_(off)  HOOKED_tex(HOOKED_pos + HOOKED_pt * vec2(off))
#define load2_(off) TEX(HOOKED_pos + HOOKED_pt * vec2(off))

#if T
vec4 load(vec3 off)
{
	switch (int(off.z)) {
	case 0: return load_(off);
	//cfg_T_load
	}
}
vec4 load2(vec3 off)
{
	switch (int(off.z)) {
	case 0: return load2_(off);
	//cfg_T_load
	}
}
#else
#define load(off) load_(off)
#define load2(off) load2_(off)
#endif

#if RI // rotation
vec2 rot(vec2 p, float d)
{
	return vec2(
		p.x * cos(radians(d)) - p.y * sin(radians(d)),
		p.y * sin(radians(d)) + p.x * cos(radians(d))
	);
}
#else
#define rot(p, d) (p)
#endif

#if RFI // reflection
vec2 ref(vec2 p, float d)
{
	return vec2(
		p.x * cos(2*radians(d)) + p.y * sin(2*radians(d)),
		p.y * sin(2*radians(d)) - p.x * cos(2*radians(d))
	);
}
#else
#define ref(p, d) (p)
#endif

vec4 patch_comparison(vec3 r, vec3 r2)
{
	vec3 p;
	vec4 pdiff_sq = vec4(0);

	FOR_PATCH(p) {
		vec3 transformed_p = vec3(ref(rot(p.xy, ri), rfi), p.z);
		vec4 diff_sq = pow(load(p + r2) - load2(transformed_p + r), vec4(2));
#if PST && P >= PST
		float pdist = exp(-pow(length(p.xy*PSD)*PSS, 2));
		diff_sq = pow(max(diff_sq, EPSILON), vec4(pdist));
#endif
		pdiff_sq += diff_sq;
	}

	return pdiff_sq * p_scale;
}

#if defined(LUMA_gather) && P == 3 && PS == 4 && RF == 0 && PD == 0 && RI == 0 && RFI == 0 && PST == 0
#define gather(off) (LUMA_mul * vec4(textureGatherOffsets(LUMA_raw, HOOKED_pos+(off)*HOOKED_pt, offsets)))
vec4 patch_comparison_gather(vec3 r, vec3 r2)
{
	const ivec2 offsets[4] = { ivec2(0,-1), ivec2(-1,0), ivec2(0,0), ivec2(1,0) };
	return vec4(dot(pow(gather(r2.xy) - gather(r.xy), vec4(2)), vec4(1)), 0, 0 ,0) * p_scale;
}
#elif defined(LUMA_gather) && PS == 6 && RF == 0 && PD == 0 && (RI == 0 || RI == 1 || RI == 3) && (RFI == 0 || RFI == 1)
#define gather(off) LUMA_gather(HOOKED_pos + (off)*HOOKED_pt, 0)
// tiled even square patch comparison using textureGather
vec4 patch_comparison_gather(vec3 r, vec3 r2)
{
	vec2 tile;
	vec4 pdiff_sq = vec4(0);

	/* gather order:
	 * w z
	 * x y
	 */
	for (tile.x = -hp; tile.x < hp; tile.x+=2) {
		for (tile.y = -hp; tile.y < hp; tile.y+=2) {
			vec4 stationary = gather(tile + r2.xy);

			FOR_ROTATION FOR_REFLECTION {
				vec4 transformer = gather(ref(rot(tile + 0.5, ri), rfi) - 0.5 + r.xy);
#if RI
				for (float i = 0; i < ri; i+=90)
					transformer = transformer.wxyz; // rotate 90 degrees
#endif
#if RFI
				for (float i = 45; i < rfi; i+=90)
					transformer = transformer.wzxy;
#endif

				vec4 diff_sq = pow(stationary - transformer, vec4(2));
#if PST && P >= PST
				vec4 pdist = vec4(
					exp(-pow(length((tile+vec2(0,1))*PSD)*PSS, 2)),
					exp(-pow(length((tile+vec2(1,1))*PSD)*PSS, 2)),
					exp(-pow(length((tile+vec2(1,0))*PSD)*PSS, 2)),
					exp(-pow(length((tile+vec2(0,0))*PSD)*PSS, 2))
				);
				diff_sq = pow(max(diff_sq, EPSILON), pdist);
#endif
				pdiff_sq.x += dot(diff_sq, vec4(1));
			}
		}
	}

	return pdiff_sq * p_scale;
}
#else
#define patch_comparison_gather patch_comparison
#endif

vec4 hook()
{
	vec4 poi = load(vec3(0)); // pixel-of-interest
	vec3 r = vec3(0);
	vec3 p = vec3(0);
	vec4 total_weight = vec4(SW);
	vec4 sum = poi * SW;
	vec4 result = vec4(0);
	int r_index = 0;

#if WD == 2 || M == 3
	vec4 all_weights[r_area];
	vec4 all_pixels[r_area];
#elif WD == 1
	vec4 no_weights = vec4(1);
#endif

#if M == 1
	vec4 minsum = vec4(0);
#elif M == 4
	vec4 maxweight = vec4(0);
#endif

	FOR_RESEARCH(r) {
		const float h = S*0.013;
		const float pdiff_scale = 1.0/(h*h);

		vec4 pdiff_sq = r.z == 0 ? patch_comparison_gather(r, vec3(0)) : patch_comparison(r, vec3(0));
		vec4 weight = exp(-pdiff_sq * pdiff_scale);
		weight *= exp(-pow(length(r*SD)*SS, 2));

#if WD == 2 || M == 3 // true average, weighted median intensity
		all_weights[r_index] = weight;
		all_pixels[r_index] = load(r);
		r_index++;
#elif WD == 1 // cumulative moving average
		// XXX maybe keep early samples in a small buffer?
		vec4 wd_scale = 1.0/no_weights;
		vec4 keeps = step(total_weight*wd_scale*WDT*exp(-wd_scale*WDP), weight);
		weight *= keeps;
		no_weights += keeps;
#endif

		/* XXX Not 100% sure if load or load2 should be used here WRT RF. load2 is 
		 * the old behavior.
		 *
		 * In my opinion load looks better, but this should be tested with the test 
		 * script whenever that is finally cleaned up and fixed
		 */
		sum += load(r) * weight;
		total_weight += weight;

#if M == 1 // Euclidean median
		// Based on: https://arxiv.org/abs/1207.3056
		/* XXX Behavior changed w/ 0ef96d05a854a752048b80b08178d4823b62f1ef
		 *
		 * Now it requires rotation in order to behave similar to before that 
		 * commit. Maybe it was inappropriately rotating before?
		 */
		vec3 r2;
		vec4 wpdist_sum = vec4(0);
		FOR_RESEARCH(r2) {
			vec4 pdist = (r.z + r2.z) == 0 ? patch_comparison_gather(r, r2) : patch_comparison(r, r2);
			wpdist_sum += sqrt(pdist) * (1-weight);
		}

		// initialize minsum and result
		minsum += step(minsum, vec4(0)) * wpdist_sum;
		result += step(result, vec4(0)) * load(r);

		// find new minimums, exclude zeros
		vec4 newmin = step(wpdist_sum, minsum) * (1-step(wpdist_sum, vec4(0)));
		vec4 notmin = 1 - newmin;

		// update minimums
		minsum = (newmin * wpdist_sum) + (notmin * minsum);
		result = (newmin * load(r))    + (notmin * result);
#elif M == 4 // maximum weight
		vec4 newmax = step(maxweight, weight);
		vec4 notmax = 1 - newmax;
		result = newmax * load(r) + notmax * result;
		maxweight = max(maxweight, weight);
#endif
	}

#if T
	//cfg_T_store
#endif

	vec4 avg_weight = total_weight * r_scale;

#if WD == 2 // true average
	total_weight = vec4(SW);
	sum = poi * SW;

	for (int i = 0; i < r_area; i++) {
		vec4 keeps = step(avg_weight*WDT, all_weights[i]);
		all_weights[i] *= keeps;
		sum += all_pixels[i] * all_weights[i];
		total_weight += all_weights[i];
	}
#endif

#if M == 3 // weighted median intensity
	const float hr_area = r_area/2.0;
	vec4 is_median, gt, lt, gte, lte, neq;

	for (int i = 0; i < r_area; i++) {
		gt = lt = vec4(0);
		for (int j = 0; j < r_area; j++) {
			gte = step(all_pixels[i]*all_weights[i], all_pixels[j]*all_weights[j]);
			lte = step(all_pixels[j]*all_weights[j], all_pixels[i]*all_weights[i]);
			neq = 1 - gte * lte;
			gt += gte * neq;
			lt += lte * neq;
		}
		is_median = step(gt, vec4(hr_area)) * step(lt, vec4(hr_area));
		result += step(result, vec4(0)) * is_median * all_pixels[i];
	}
#elif M == 2 // weight map
	result = avg_weight;
#elif M == 0 // mean
	result = sum / total_weight;
#endif

#if AS // adaptive sharpening
	vec4 sharpened = poi + (poi - result) * ASF;
	vec4 sharpening_power = pow(avg_weight, vec4(ASP));
#endif

#if EP // extremes preserve
	float luminance = EP_LUMA_texOff(0).x;
	// epsilon is needed since pow(0,0) is undefined
	float ep_weight = pow(max(min(1-luminance, luminance)*2, EPSILON), (luminance < 0.5 ? DP : BP));
	result = mix(poi, result, ep_weight);
#endif

#if AS == 1 // sharpen+denoise
	result = mix(sharpened, result, sharpening_power);
#elif AS == 2 // sharpen only
	result = mix(sharpened, poi, sharpening_power);
#endif

	return mix(poi, result, BF);
}

