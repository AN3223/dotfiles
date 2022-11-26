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
// This is a variant of nlmeans_compute that uses integral images
//
// But do not use this shader! It is extremely slow!
//

//!HOOK LUMA
//!HOOK CHROMA
//!HOOK RGB
//!BIND HOOKED
//!COMPUTE 8 8
//!DESC Non-local means
#define THREADS (8*8)
#define BLOCKSIZE uvec2(8,8)

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
shared vec4 ii[BLOCKSIZE.x+P-1][BLOCKSIZE.y+P-1];
vec4 total_weight, sum;

void fill_ii(ivec2 block, ivec2 r)
{
	for (uint idx = gl_LocalInvocationIndex; idx < (BLOCKSIZE.x+P-1)*(BLOCKSIZE.y+P-1); idx += THREADS) {
		ivec2 px = ivec2(idx%(BLOCKSIZE.x+P-1), idx/(BLOCKSIZE.y+P-1));
		ii[px.x][px.y] = (HOOKED_tex(OFF(block+r+px+0.5)) - HOOKED_tex(OFF(block+px+0.5))) * range;
		ii[px.x][px.y] *= ii[px.x][px.y];
	}
	barrier();
	// XXX slow spot
	if (gl_LocalInvocationIndex == 0)
		for (int x = 0; x < BLOCKSIZE.x+P-1; x++)
			for (int y = 0; y < BLOCKSIZE.y+P-1; y++)
				ii[x][y] += (y>0 ? ii[x][y-1] : vec4(0)) - (y>0 && x>0 ? ii[x-1][y-1] : vec4(0)) + (x>0 ? ii[x-1][y] : vec4(0));
	barrier();
}

vec4 sum_pdiff_sq(ivec2 p)
{
	/*
	 * Comment from vf_nlmeans_init.h from FFmpeg:
	 *
	 * M is a discrete map where every entry contains the sum of all the entries
	 * in the rectangle from the top-left origin of M to its coordinate. In the
	 * following schema, "i" contains the sum of the whole map:
	 *
	 * M = +----------+-----------------+----+
	 *     |          |                 |    |
	 *     |          |                 |    |
	 *     |         a|                b|   c|
	 *     +----------+-----------------+----+
	 *     |          |                 |    |
	 *     |          |                 |    |
	 *     |          |        X        |    |
	 *     |          |                 |    |
	 *     |         d|                e|   f|
	 *     +----------+-----------------+----+
	 *     |          |                 |    |
	 *     |         g|                h|   i|
	 *     +----------+-----------------+----+
	 *
	 * The sum of the X box can be calculated with:
	 *    X = e-d-b+a
	 *
	 * See https://en.wikipedia.org/wiki/Summed_area_table
	 */
	vec4 iie = ii[p.x+hp][p.y+hp];
	vec4 iib = (p.y-hp-1 >= 0) ? ii[p.x+hp][p.y-hp-1] : vec4(0);
	vec4 iid = (p.x-hp-1 >= 0) ? ii[p.x-hp-1][p.y+hp] : vec4(0);
	vec4 iia = (p.y-hp-1 >= 0 && p.x-hp-1 >= 0) ? ii[p.x-hp-1][p.y-hp-1] : vec4(0);
	return iie - iid - iib + iia;
}

void nlmeans(ivec2 block, ivec2 r, ivec2 px)
{
	vec4 pdiff_sq = sum_pdiff_sq(px);

	// low pdiff_sq -> high weight, high weight -> more blur
#if WEIGHT_LUT
#define WEIGHT(P) weight_lut[min(int(pdiff_sq.P), maxdiff)]
	vec4 weight = vec4(WEIGHT(x), WEIGHT(y), WEIGHT(z), WEIGHT(w));
#else
	vec4 weight = exp(-pdiff_sq * pdiff_scale) * step(pdiff_sq, vec4(maxdiff));
#endif

	sum += weight * HOOKED_tex(OFF(block+r+px+0.5));
	total_weight += weight;
}

void hook()
{
	ivec2 r;
	ivec2 block = ivec2(gl_WorkGroupID.xy * BLOCKSIZE);

#if WEIGHT_LUT
	for (uint i = gl_LocalInvocationIndex; i < maxdiff; i += THREADS)
		weight_lut[i] = exp(-int(i) * pdiff_scale);
	weight_lut[maxdiff] = 0;
	barrier();
#endif

	// initialize weights and sums
	for (uint idx = gl_LocalInvocationIndex; idx < (BLOCKSIZE.x * BLOCKSIZE.y); idx += THREADS) {
		ivec2 px = ivec2(idx%BLOCKSIZE.x, idx/BLOCKSIZE.y);
		total_weight = vec4(1);
		sum = HOOKED_tex(OFF(block+px+0.5));
	}

	for (r.x = -hr; r.x <= hr; r.x++) {
		for (r.y = -hr; r.y <= hr; r.y++) {
			fill_ii(block, r);
			for (uint idx = gl_LocalInvocationIndex; idx < (BLOCKSIZE.x * BLOCKSIZE.y); idx += THREADS) {
				ivec2 px = ivec2(idx%BLOCKSIZE.x, idx/BLOCKSIZE.y);
				nlmeans(block, r, px);
			}
		}
	}
	barrier();

	for (uint idx = gl_LocalInvocationIndex; idx < (BLOCKSIZE.x * BLOCKSIZE.y); idx += THREADS) {
		ivec2 px = ivec2(idx%BLOCKSIZE.x, idx/BLOCKSIZE.y);
		imageStore(out_image, block+px, sum/total_weight);
	}
}
