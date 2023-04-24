// vi: ft=c

/* Conway's Game of Life
 *
 * Requires vo=gpu-next
 *
 * Works by computing a laplacian image and using the edges as GOL seeds
 */

//!HOOK LUMA
//!BIND LUMA
//!BIND GOL

// enable if you don't want cells to linger in non-edge areas
#define DECAY_DEATH 0

// if death is enabled, cells die after they decay below this value
// otherwise, cells just stop decaying at this value
#define DEATH_THRESHOLD 0.05

// lower numbers decay faster
#define DECAY 0.9

// decays near frame edges
#define EDGE_DECAY 0.05

// lower numbers seed more
#define LAPLACIAN_THRESHOLD 0.1

vec4 hook()
{
	vec2 neighbor;
	vec4 poi = LUMA_texOff(0);
	int live_neighbors = 0;
	float avg_live_neighbor = 0;
	float laplacian = poi.x * 8;
	float poi_cell = clamp(imageLoad(GOL, ivec2(LUMA_pos*LUMA_size)).x, 0.0, 1.0);

	float edge_decay = min(1.0, min(
		min(LUMA_pos.x*LUMA_size.x, LUMA_pos.y*LUMA_size.y)*EDGE_DECAY,
		min(LUMA_size.x-LUMA_pos.x*LUMA_size.x, LUMA_size.y-LUMA_pos.y*LUMA_size.y)*EDGE_DECAY
	));

#if DECAY_DEATH
	if (poi_cell < DEATH_THRESHOLD)
		poi_cell = 0;
#endif

// donut increment, never lands on (0,0)
#define DINCR(z,c) (z.c++,(z.c += int(z == vec2(0))))
	for (neighbor.x = -1; neighbor.x <= 1; DINCR(neighbor,x))
	for (neighbor.y = -1; neighbor.y <= 1; DINCR(neighbor,y)) {
		float cell = imageLoad(GOL, ivec2((LUMA_pos + LUMA_pt * neighbor) * LUMA_size)).x + 0.001;

		if (cell >= DEATH_THRESHOLD) {
			live_neighbors++;
			avg_live_neighbor += cell;
		}

		laplacian -= LUMA_texOff(neighbor).x;
	}
	laplacian = abs(laplacian / 8); // normalize to 0-1
	avg_live_neighbor /= live_neighbors;

	if (poi_cell > 0) {
		if (live_neighbors < 2 || live_neighbors > 3) // {under,over}population
			poi_cell = 0;
		else if (live_neighbors >= 2) // survive
			poi_cell = max(poi_cell*DECAY*edge_decay, DEATH_THRESHOLD-DECAY_DEATH);
	} else if (live_neighbors == 3) { // reproduction
		poi_cell = max(avg_live_neighbor, DEATH_THRESHOLD);
	}

	if (laplacian > LAPLACIAN_THRESHOLD) // seed
		poi_cell = DECAY * edge_decay;

	imageStore(GOL, ivec2(LUMA_pos*LUMA_size), vec4(poi_cell, 0, 0, 0));
	return vec4(clamp(mix(poi.x, 1-poi.x, poi_cell*edge_decay), 0.0, 1.0), 0, 0, poi.a);
}

//!TEXTURE GOL
//!SIZE 3840 3840
//!FORMAT r16f
//!STORAGE

