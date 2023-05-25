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
 * are blurred with neighboring homogeneous regions by searching 
 * 1-dimensionally in multiple directions and blurring runs together.
 *
 * This should run prior to any other shaders and mpv's built in debanding 
 * should be disabled by setting deband=no in mpv.conf
 */


//!HOOK LUMA
//!HOOK CHROMA
//!HOOK RGB
//!BIND HOOKED
//!DESC hdeband

// User variables

// Higher numbers blur more when intensity varies more between bands
#define SI 0.005

// Starting weight, lower values give less weight to the input image
#define SW 0.25

// Bigger numbers search further, but slower
#define RADIUS 8

// Bigger numbers search further, but less accurate
#define SPARSITY 0.5

// Bigger numbers search in more directions, slower (max 8)
// Only 4 and 8 are symmetrical, everything else blurs directionally
#define DIRECTIONS 3

// A region is considered a run if it varies less than this
#define TOLERANCE 0.001

// Shader code

#define gaussian(x) exp(-1 * (x) * (x))

// boolean logic w/ vectors
#define NOT(x) (1 - (x))
#define AND *
#define TERNARY(cond, x, y) ((x)*(cond) + (y)*NOT(cond))
#ifdef LUMA_raw
#define EQ(x,y) val(val(x) == val(y))
#else
#define EQ(x,y) val(equal(val(x),val(y)))
#endif

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

const float si_scale = 1.0/float(SI);

vec4 poi_ = HOOKED_texOff(0);
val poi = val_swizz(poi_);

vec4 hook()
{
	val sum = poi * SW;
	val total_weight = val(SW);

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

		val prev_px = poi;
		val prev_weight = val(0);
		val not_done = val(1);
		for (int i = 1; i <= RADIUS; i++) {
			float sparsity = floor(i * SPARSITY);
			val px = val_swizz(HOOKED_texOff((i + sparsity) * direction));
			val weight = step(abs(prev_px - px), val(TOLERANCE));

			// stop blurring after discovering a 1px run
			not_done *= step(val(1), prev_weight + weight);

			// consider skipped pixels as runs if their neighbors are both runs
			float new_sparsity = sparsity - floor((i - 1) * SPARSITY);
			weight += weight * new_sparsity;

			// run's 2nd pixel has weight doubled to compensate for 1st pixel's weight of 0
			weight += weight * NOT(prev_weight);

			weight *= gaussian(abs(poi - px) * si_scale);

			weight *= 1 - step(abs(poi - px), val(TOLERANCE)) * (1 - SW);

			sum += prev_px * weight * not_done;
			total_weight += weight * not_done;

			weight = ceil(min(weight, val(1)));
			prev_px = TERNARY(weight, prev_px, px);
			prev_weight = weight;
		}
	}

	val result = sum / total_weight;
	return unval(result);
}

