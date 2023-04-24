// vi: ft=c

// Conway's Game of Life

//!HOOK LUMA
//!BIND LUMA
//!BIND GOL

#define VISUALIZATION mix(poi.x, 1-poi.x, poi_gol)
//#define VISUALIZATION (poi.x - poi_gol)

#define DECAY 0.9
#define DEATH 0.05

// reset at this frame interval
//#define RESET (24*30)

vec4 hook()
{
	vec2 neighbor;
	vec4 poi = LUMA_texOff(0);
	int live_neighbors = 0;
	float avg_live_neighbor = 0;
	float laplacian = poi.x * 8;
	float poi_gol = clamp(imageLoad(GOL, ivec2(LUMA_pos*LUMA_size)).x, 0.0, 1.0);

	if (poi_gol < DEATH)
		poi_gol = 0;

// donut increment, never lands on (0,0)
#define DINCR(z,c) (z.c++,(z.c += int(z == vec2(0))))
	for (neighbor.x = -1; neighbor.x <= 1; DINCR(neighbor,x))
	for (neighbor.y = -1; neighbor.y <= 1; DINCR(neighbor,y)) {
		float gol = imageLoad(GOL, ivec2((LUMA_pos + LUMA_pt * neighbor) * LUMA_size)).x;

		if (gol > DEATH) {
			live_neighbors++;
			avg_live_neighbor += gol;
		}

		laplacian -= LUMA_texOff(neighbor).x;
	}
	laplacian = abs(laplacian / 8); // normalize to 0-1
	avg_live_neighbor /= live_neighbors;

	if (poi_gol > 0) {
		if (live_neighbors < 2 || live_neighbors > 3) // {under,over}population
			poi_gol = 0;
		else if (live_neighbors >= 2) // survive
			poi_gol = poi_gol * DECAY;
	} else if (live_neighbors == 3) { // reproduction
		poi_gol = avg_live_neighbor;
	}

	if (laplacian > DEATH) // seed
		poi_gol = DECAY;

	imageStore(GOL, ivec2(LUMA_pos*LUMA_size), vec4(poi_gol, 0, 0, 0));
	return vec4(clamp(VISUALIZATION, 0.0, 1.0), 0, 0, poi.a);
}

//!TEXTURE GOL
//!SIZE 3840 3840
//!FORMAT r16f
//!STORAGE

