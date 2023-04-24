// vi: ft=c

// Conway's Game of Life

//!HOOK LUMA
//!BIND LUMA
//!BIND GOL

// seed if this condition is true
#define SEED_IF (laplacian < 0.4 || laplacian > 0.6)
//#define SEED_IF (poi.x < 0.25)

#define VISUALIZATION mix(poi.x, poi_gol, 0.5)
//#define VISUALIZATION (poi.x - poi_gol)

// reset at this frame interval
#define RESET (24*20)

// whether or not to compute the laplacian image
#define LAPLACIAN 1

vec4 hook()
{
	int poi_gol;
	vec2 neighbor;
	vec4 poi = LUMA_texOff(0);
	int live_neighbors = 0;
	float laplacian = 0;

	for (neighbor.x = -1; neighbor.x <= 1; neighbor.x++)
	for (neighbor.y = -1; neighbor.y <= 1; neighbor.y++) {
		int gol = int(imageLoad(GOL, ivec2((LUMA_pos + LUMA_pt * neighbor) * LUMA_size)).x);

		if (neighbor == vec2(0,0))
			poi_gol = gol;
		else
			live_neighbors += gol;

#if LAPLACIAN
		if (neighbor == vec2(0,0))
			laplacian += poi.x * 8;
		else
			laplacian += LUMA_texOff(neighbor).x * -1;
#endif
	}
	laplacian = (laplacian + 8) / 16; // normalize to 0-1

	if (poi_gol == 1) {
		if (live_neighbors < 2 || live_neighbors > 3) // {under,over}population
			poi_gol = 0;
		else if (live_neighbors >= 2) // survive
			poi_gol = 1;
	} else if (live_neighbors == 3) { // reproduction
		poi_gol = 1;
	}

	if (SEED_IF || frame % RESET == 0) { // seed (hidden from output)
		imageStore(GOL, ivec2(LUMA_pos*LUMA_size), vec4(1, 0, 0, 0));
		return poi;
	} else {
		imageStore(GOL, ivec2(LUMA_pos*LUMA_size), vec4(poi_gol, 0, 0, 0));
		return vec4(clamp(VISUALIZATION, 0.0, 1.0), 0, 0, 1.0);
	}
}

//!TEXTURE GOL
//!SIZE 3840 3840
//!FORMAT r16f
//!STORAGE

