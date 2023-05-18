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
//!DESC hdeband

// Higher numbers blur more when the neighbor run is further away
#define SS 100.0

// Higher numbers blur more when intensity varies more between bands
#define SI 0.005

// Starting weight, lower values give less weight to the input image
#define SW 0.1

// Bigger numbers search further, but slower
#define RADIUS 16

// Bigger numbers search further, but less accurate
#define SPARSITY 0.0

// Bigger numbers search in more directions, slower (max 8)
// Only 4 and 8 are symmetrical, everything else blurs directionally
#define DIRECTIONS 4

// A region is considered a run if it varies less than this
#define TOLERANCE 0.01

// 0 for avg, 1 for min, 2 for max
#define STRATEGY 0

// Shader code

#define gaussian(x) exp(-1 * (x) * (x))

// boolean logic w/ vectors
#define NOT(x) (1 - (x))
#define AND *
#define TERNARY(cond, x, y) ((x)*(cond) + (y)*NOT(cond))

// from NLM
#if defined(LUMA_raw)
#define val float
#define val_swizz(v) (v.x)
#define unval(v) vec4(v.x, 0, 0, poi_.a)
#define val_packed val
#define val_pack(v) (v)
#define val_unpack(v) (v)
#elif defined(CHROMA_raw)
#define val vec2
#define val_swizz(v) (v.xy)
#define unval(v) vec4(v.x, v.y, 0, poi_.a)
#define val_packed uint
#define val_pack(v) packUnorm2x16(v)
#define val_unpack(v) unpackUnorm2x16(v)
#else
#define val vec3
#define val_swizz(v) (v.xyz)
#define unval(v) vec4(v.x, v.y, v.z, poi_.a)
#define val_packed val
#define val_pack(v) (v)
#define val_unpack(v) (v)
#endif

vec4 poi_ = HOOKED_texOff(0);
val poi = val_swizz(poi_);

const float r_scale = 1/float(RADIUS*DIRECTIONS);
const float si_scale = 1/(SI);

vec4 hook()
{
#if STRATEGY == 0
	val total_weight = val(SW);
	val sum = poi * SW;
#elif STRATEGY == 1
	val extremum_px = poi;
	val extremum_weight = val(1);
#elif STRATEGY == 2
	val extremum_px = poi;
	val extremum_weight = val(0);
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

		// XXX support blurring more than two runs together at once
		val prev = poi;
		val normalized_prev;
		val runs = val(1);
		val run1_size = val(1); // includes POI
		val run2_size = val(0);

		for (int i = 1; i <= RADIUS; i++) {
#ifdef LUMA_raw
			normalized_prev = prev / TERNARY(int(runs == 1), run1_size, max(1, run2_size));
#else
			normalized_prev = prev / TERNARY(val(equal(runs, val(1))), run1_size, max(val(1), run2_size));
#endif

			float sparsity = floor(i * SPARSITY);
			float new_sparsity = sparsity - floor((i - 1) * SPARSITY);
			val px = val_swizz(HOOKED_texOff(direction * i + sparsity * direction));
			val is_run = val(step(abs(normalized_prev - px), val(TOLERANCE)));
			prev += px * is_run;

			runs += NOT(is_run);
			val in_bounds = step(runs, val(2));
			prev = TERNARY(NOT(is_run) AND in_bounds, px, prev);

			// consider skipped pixels as runs if their neighbors are both runs
			is_run += is_run AND new_sparsity;

#ifdef LUMA_raw
			run1_size += is_run AND val(runs == 1);
			run2_size += is_run AND val(runs == 2);
#else
			run1_size += is_run AND val(equal(runs, val(1)));
			run2_size += is_run AND val(equal(runs, val(2)));
#endif
		}

		val weight = val(1);
		weight *= 1 - gaussian(run1_size * SS * r_scale);
		weight *= gaussian(abs(poi - normalized_prev) * si_scale);

// XXX if (weight == extremum_weight) px should be picked randomly to prevent directional blur
#if STRATEGY == 0
		sum += normalized_prev * weight;
		total_weight += weight;
#elif STRATEGY == 1
		extremum_px = TERNARY(step(weight, extremum_weight), normalized_prev, extremum_px);
		extremum_weight = min(weight, extremum_weight);
#elif STRATEGY == 2
		extremum_px = TERNARY(step(weight, extremum_weight), extremum_px, normalized_prev);
		extremum_weight = max(weight, extremum_weight);
#endif
	}

#if STRATEGY == 0
	val result = sum / total_weight;
#elif STRATEGY == 1 || STRATEGY == 2
	val result = (extremum_px * extremum_weight + poi) / (extremum_weight + 1);
#endif

// XXX implement visualizations

	return unval(result);
}

