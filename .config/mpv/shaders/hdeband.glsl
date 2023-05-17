/* vi: ft=c
 *
 * Copyright (c) 2023 an3223 <ethanr2048@gmail.com>
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

/* This is an implementation of a debanding algorithm where homogeneous regions 
 * are blurred with neighboring homogeneous regions.
 *
 * This is achieved by searching 1-dimensionally in multiple directions, 
 * identifying runs, and blurring them together based on the minimum run length 
 * and the difference in intensity between runs.
 */

//!HOOK LUMA
//!HOOK CHROMA
//!HOOK RGB
//!BIND HOOKED

// Higher numbers blur more when the neighbor run is further away
#define SS 500.0

// Higher numbers blur more when intensity varies more between bands
#define SI 0.005

// Starting weight, lower values give less weight to the input image
#define SW 0.001

// Bigger numbers search further, but slower
#define RADIUS 16

// Bigger numbers search further, but less accurate
#define SPARSITY 1

// Bigger numbers search in more directions, slower (max 8)
// Only 4 and 8 are symmetrical, everything else blurs directionally
#define DIRECTIONS 4

// A region is considered a run if it varies less than this
#define TOLERANCE 0.001

// 0 for avg, 1 for min, 2 for max
#define STRATEGY 0

// Shader code

#define gaussian(x) exp(-1 * (x) * (x))

// boolean logic w/ vectors
#define NOT(x) (1 - (x))
#define AND *
#define TERNARY(cond, x, y) ((x)*(cond) + (y)*NOT(cond))

const float r_scale = 1/float(RADIUS*DIRECTIONS);
const float ss_scale = 1/(SS*r_scale);
const float si_scale = 1/(SI);

// XXX implement dynamic types

vec4 hook()
{
	vec4 poi = HOOKED_texOff(0);

#if STRATEGY == 0
	vec4 total_weight = vec4(SW);
	vec4 sum = poi * SW;
#elif STRATEGY == 1
	vec4 extremum_px = poi;
	vec4 extremum_weight = vec4(1);
#elif STRATEGY == 2
	vec4 extremum_px = poi;
	vec4 extremum_weight = vec4(0);
#endif

	for (int dir = 0; dir < DIRECTIONS; dir++) {
		vec2 direction;
		switch (dir) {
		case 0: direction = vec2(1,  0); break;
		case 1: direction = vec2(-1, 0); break;
		case 2: direction = vec2(0,  1); break;
		case 3: direction = vec2(0, -1); break;
		case 4: direction = vec2(1,  1); break;
		case 5: direction = vec2(-1,-1); break;
		case 6: direction = vec2(1, -1); break;
		case 7: direction = vec2(-1, 1); break;
		}

		// XXX support blurring more than two regions together at once
		// XXX (optionally?) replace POI with avg of its run
		vec4 prev = poi;
		vec4 region = vec4(1);
		vec4 region1_size = vec4(1); // includes POI
		vec4 region2_size = vec4(0);

		// XXX have SPARSITY (optionally) increase more than linearly
		// XXX textureGather
		for (int i = 1; i <= RADIUS; i++) {
			vec4 px = HOOKED_texOff(direction * i * SPARSITY);
			vec4 is_run = vec4(step(abs(prev - px), vec4(TOLERANCE)));

			region += NOT(is_run);
			vec4 in_bounds = vec4(step(region, vec4(2)));
			prev = TERNARY(NOT(is_run) AND in_bounds, px, prev);

			region1_size += is_run AND vec4(equal(region, vec4(1)));
			region2_size += is_run AND vec4(equal(region, vec4(2)));
		}

		vec4 weight = vec4(1);
		weight *= gaussian(min(region1_size, region2_size) * ss_scale);
		weight *= gaussian(abs(poi - prev) * si_scale);

// XXX if (weight == extremum_weight) px should be picked randomly to prevent directional blur
#if STRATEGY == 0
		sum += prev * weight;
		total_weight += weight;
#elif STRATEGY == 1
		extremum_px = TERNARY(step(weight, extremum_weight), prev, extremum_px);
		extremum_weight = min(weight, extremum_weight);
#elif STRATEGY == 2
		extremum_px = TERNARY(step(weight, extremum_weight), extremum_px, prev);
		extremum_weight = max(weight, extremum_weight);
#endif
	}

#if STRATEGY == 0
	vec4 result = sum / total_weight;
#elif STRATEGY == 1 || STRATEGY == 2
	vec4 result = (extremum_px * extremum_weight + poi) / (extremum_weight + 1);
#endif

// XXX implement visualizations

	return result;
}

