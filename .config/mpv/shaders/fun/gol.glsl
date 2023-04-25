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

// if DECAY_DEATH is enabled, cells die after they decay below this value
// otherwise, cells just stop decaying at this value
#define DEATH_THRESHOLD 0.2

// lower numbers decay faster, 1.0 doesn't decay at all
#define DECAY 0.9

// decays near frame edges, lower numbers decay more, 1.0 doesn't decay at all
#define EDGE_DECAY 0.1

// 1.0 seeds nothing, 0.0 seeds everything
#define LAPLACIAN_THRESHOLD 0.1

// My favorites: (0, 5, 7, 9, 10, 13)
#define RULE    0
#if     RULE == 0  // Life
#define B (live_neighbors == 3)
#define S (live_neighbors == 2 || live_neighbors == 3)
#elif   RULE == 1  // Seeds
#define B (live_neighbors == 2)
#define S (false)
#elif   RULE == 2  // Day and Night
#define B (live_neighbors == 3 || live_neighbors == 6 || live_neighbors == 7 || live_neighbors == 8)
#define S (live_neighbors == 3 || live_neighbors == 4 || live_neighbors == 6 || live_neighbors == 7 || live_neighbors == 8)
#elif   RULE == 3  // Geology
#define B (live_neighbors == 3 || live_neighbors == 5 || live_neighbors == 7 || live_neighbors == 8)
#define S (live_neighbors == 2 || live_neighbors == 4 || live_neighbors == 6 || live_neighbors == 7 || live_neighbors == 8)
#elif   RULE == 4  // Gnarl
#define B (live_neighbors == 1)
#define S (live_neighbors == 1)
#elif   RULE == 5  // HighLife
#define B (live_neighbors == 3 || live_neighbors == 6)
#define S (live_neighbors == 2 || live_neighbors == 3)
#elif   RULE == 6  // DotLife
#define B (live_neighbors == 3)
#define S (live_neighbors == 0 || live_neighbors == 2 || live_neighbors == 3)
#elif   RULE == 7  // 3-4 Life
#define B (live_neighbors == 3 || live_neighbors == 4)
#define S (live_neighbors == 3 || live_neighbors == 4)
#elif   RULE == 8  // Pseudo Life
#define B (live_neighbors == 3 || live_neighbors == 5 || live_neighbors == 7)
#define S (live_neighbors == 2 || live_neighbors == 3 || live_neighbors == 8)
#elif   RULE == 9  // DryLife
#define B (live_neighbors == 3 || live_neighbors == 7)
#define S (live_neighbors == 2 || live_neighbors == 3)
#elif   RULE == 10 // Pedestrian Life
#define B (live_neighbors == 3 || live_neighbors == 8)
#define S (live_neighbors == 2 || live_neighbors == 3)
#elif   RULE == 11 // Amoeba
#define B (live_neighbors == 3 || live_neighbors == 5 || live_neighbors == 7)
#define S (live_neighbors == 1 || live_neighbors == 3 || live_neighbors == 5 || live_neighbors == 8)
#elif   RULE == 12 // 2x2
#define B (live_neighbors == 3 || live_neighbors == 6)
#define S (live_neighbors == 1 || live_neighbors == 2 || live_neighbors == 5)
#elif   RULE == 13 // DrighLife
#define B (live_neighbors == 3 || live_neighbors == 6 || live_neighbors == 7)
#define S (live_neighbors == 2 || live_neighbors == 3)
#endif

// Shader code

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
		float cell = imageLoad(GOL, ivec2((LUMA_pos + LUMA_pt * neighbor) * LUMA_size)).x;

#if DECAY_DEATH
		if (cell >= DEATH_THRESHOLD) {
#else
		if (cell > 0) {
#endif
			live_neighbors++;
			avg_live_neighbor += cell;
		}

		laplacian -= LUMA_texOff(neighbor).x;
	}
	laplacian = abs(laplacian / 8); // normalize to 0-1
	avg_live_neighbor /= live_neighbors;

	if (poi_cell > 0) {
		if (S)
			poi_cell = max(poi_cell*DECAY*edge_decay, DEATH_THRESHOLD-DECAY_DEATH);
		else
			poi_cell = 0;
	} else if (B) {
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

