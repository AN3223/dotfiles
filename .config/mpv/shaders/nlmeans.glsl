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
 * WF = weight function
 * SS = spatial denoising factor (bilateral only)
 *
 * Speed is dictated by (R^2 * P^2), e.g., P=3:R=15 is about as fast as P=5:R=9
 *
 * Increasing the denoising factor will increase blur without impacting speed
 *
 * Decreasing spatial denoising factor will increase the locality, meaning 
 * distant pixels contribute less
 *
 * WF=0 uses non-local means
 * WF=1 uses bilateral
 *
 * It may be preferable to denoise chroma more than luma, so the user variables
 * for luma and chroma are split below. Other user variables can be moved into 
 * these blocks if desired.
 *
 * For film & anime you may want to disable chroma denoising by deleting the 
 * !HOOK CHROMA line above
 *
 * For anime you most likely want to disable EP below, and perhaps denoise more
 * aggressively with a configuration like 2:3:5
 *
 * It's recommended to make multiple copies of this shader with settings 
 * tweaked for different types of content, and then dispatch the appropriate 
 * one via keybinds in input.conf, e.g.:
 *
 * F4 no-osd change-list glsl-shaders toggle "~~/shaders/nlmeans_luma.glsl"; show-text "Non-local means (LUMA only)"
 */
#ifdef LUMA_raw
#define S 2.0
#define P 3
#define R 3
#define WF 0
#define SS 0
#else
#define S 2.0
#define P 3
#define R 5
#define WF 1
#define SS 6
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

/* Extremes preserve, reduces denoising around very bright/dark areas.
 *
 * EP is the size the zone to sample around each pixel for computing the average 
 * luminance. Set to 0 to disable extremes preserve.
 *
 * Higher DP increases the effect on dark patches.
 * Higher BP increases the effect on bright patches.
 *
 * DP and BP both start at 1, or 0 to disable.
 */
#ifdef LUMA_raw
#define EP 3
#define BP 3.0
#define DP 1.0
#endif

/* Robust filtering
 *
 * Compares the pixel of interest to blurred pixel. The blurred pixel is 
 * computed by averaging the pixels of the surrounding patch sized RF*RF.
 *
 * May improve quality, but can increase blur
 *
 * Must be an odd number. Set to 0 to disable.
 */
#define RF 0

/* Shader code */

const int hp = P/2;
const int hr = R/2;
const float p_scale = 1.0/(P*P);

#if RADIAL_SEARCH
int radius = 1;
vec2 radial_increment(vec2 r)
{
	if (r == vec2(radius))
		return -vec2(++radius); // new ring
	else if (r.x == radius)
		return vec2(-radius, ++r.y); // end row
	else if (abs(r.y) == radius)
		return vec2(++r.x, r.y); // top/bottom rows
	else
		return vec2(radius, r.y); // start row
}
#endif

#if RF
#define ROBUST_PROXY(r) blurred(r)
vec4 blurred(vec2 r)
{
	const int hrf = RF/2;
	const float hrf_scale = 1.0/(RF*RF);

	vec4 sum = vec4(0);
	for (int i = -hrf; i <= hrf; i++)
		for (int j = -hrf; j <= hrf; j++)
			sum += HOOKED_texOff(r + vec2(i,j));

	return sum * hrf_scale;
}
#else
#define ROBUST_PROXY HOOKED_texOff
#endif

vec4 hook()
{
	vec4 weight, ignore;
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

#if EP
	const int hep = EP/2;
	const float ep_scale = 1.0/(EP*EP);

	vec4 l = vec4(0);
	for (p.x = -hep; p.x <= hep; p.x++)
		for (p.y = -hep; p.y <= hep; p.y++)
			l += HOOKED_texOff(p);
	l *= ep_scale; // avg luminance

	vec4 ep_weight = pow(min(1-l, l)*2, step(l, vec4(0.5))*DP + step(vec4(0.5), l)*BP);
#endif

#if RADIAL_SEARCH
	// radial search
	for (r = vec2(-radius); radius <= hr; r = radial_increment(r)) {
#else
	// regular search
	for (r.x = -lower.x; r.x <= upper.x; r.x++)
	for (r.y = -lower.y; r.y <= upper.y; r.y++) {
#endif
		ignore = vec4(1);

#if BOUNDS_CHECKING == 1
		vec2 abs_r = HOOKED_pos * input_size + r;
		ignore *= int(clamp(abs_r, vec2(0), input_size) == abs_r);
#endif

		// low pdiff_sq -> high weight, high weight -> more blur
#if WF == 1
		const float pdiff_scale = 1.0/(S*0.005);

		vec4 pdiff = vec4(0);
		for (p.x = -hp; p.x <= hp; p.x++)
			for (p.y = -hp; p.y <= hp; p.y++)
				pdiff += ROBUST_PROXY(r+p) - HOOKED_texOff(p);
		pdiff *= p_scale; // avg pixel difference

		weight = exp(-pow(pdiff * pdiff_scale, vec4(2)));
#else
		const float h = S*10.0;
		const float pdiff_scale = 1.0/(h*h);
		const float range = 255.0; // for making pixels range from 0-255

		vec4 pdiff_sq = vec4(0);
		for (p.x = -hp; p.x <= hp; p.x++)
			for (p.y = -hp; p.y <= hp; p.y++)
				pdiff_sq += pow((ROBUST_PROXY(r+p) - HOOKED_texOff(p)) * range, vec4(2));

		weight = exp(-pdiff_sq * pdiff_scale);
#endif

#if SS
		const float length_scale = 1.0/float(SS);
		weight *= exp(-pow(length(r) * length_scale, 2));
#endif

		weight *= ignore;
#if EP
		weight *= ep_weight;
#endif

		sum += weight * HOOKED_texOff(r);
		total_weight += weight;
	}

	return sum / total_weight;
}

