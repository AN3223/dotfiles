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
 * The defaults below are performance oriented and tuned for images captured on 
 * a digital camera, but should be acceptable for other types of images as 
 * well
 *
 * The time to render a frame is linked to (R^2 * P^2), so P=3:R=15 will run 
 * about as fast as P=5:R=9
 *
 * Increasing the denoising factor will increase blur without impacting speed
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
 */
#ifdef LUMA_raw
#define S 2.0
#define P 3
#define R 3
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

/* Shader code */

const int hp = P/2;
const int hr = R/2;
const float h = S*10.0;
const float pdiff_scale = 1.0/(h*h);
const float range = 255.0; // for making pixels range from 0-255

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

#if EP
	vec4 ep_weight;
	const int hep = EP/2;
	vec4 l = vec4(0);
	for (p.x = -hep; p.x <= hep; p.x++)
		for (p.y = -hep; p.y <= hep; p.y++)
			l += HOOKED_texOff(p);
	l /= EP*EP; // avg luminance
	ep_weight = pow(min(1-l, l)*2, step(l, vec4(0.5))*DP + step(vec4(0.5), l)*BP);
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

		pdiff_sq = vec4(0);
		for (p.x = -hp; p.x <= hp; p.x++)
			for (p.y = -hp; p.y <= hp; p.y++)
				pdiff_sq += pow((HOOKED_texOff(r+p) - HOOKED_texOff(p)) * range, vec4(2));

		// low pdiff_sq -> high weight, high weight -> more blur
		// XXX bad performance on AMD-Vulkan (but not OpenGL) seems to be rooted here?
		weight = exp(-pdiff_sq * pdiff_scale) * ignore;
#if EP
		weight *= ep_weight;
#endif

		sum += weight * HOOKED_texOff(r);
		total_weight += weight;
	}

	return sum / total_weight;
}

