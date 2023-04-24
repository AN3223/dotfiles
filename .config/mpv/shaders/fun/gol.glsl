// vi: ft=c

// Conway's Game of Life

//!HOOK LUMA
//!BIND LUMA
//!BIND GOL

// seed if this condition is true
#define SEED_IF (poi.x < 0.25)

// reset at this frame interval
#define RESET (24*10)

vec4 hook()
{
	int poi_gol;
	vec2 neighbor;
	vec4 poi = LUMA_texOff(0);
	int live_neighbors = 0;

	if (SEED_IF || frame % RESET == 0) { // seed (hidden from output)
		imageStore(GOL, ivec2(LUMA_pos*LUMA_size), vec4(1, 0, 0, 0));
		return poi;
	} else {
	for (neighbor.x = -1; neighbor.x <= 1; neighbor.x++)
	for (neighbor.y = -1; neighbor.y <= 1; neighbor.y++) {
		int gol = int(imageLoad(GOL, ivec2((LUMA_pos + LUMA_pt * neighbor) * LUMA_size)).x);

		if (neighbor == vec2(0,0))
			poi_gol = gol;
		else
			live_neighbors += gol;
	}

	if (poi_gol == 1) {
		if (live_neighbors < 2 || live_neighbors > 3) // {under,over}population
			poi_gol = 0;
		else if (live_neighbors >= 2) // survive
			poi_gol = 1;
	} else if (live_neighbors == 3) { // reproduction
		poi_gol = 1;
	}
	}
	imageStore(GOL, ivec2(LUMA_pos*LUMA_size), vec4(poi_gol, 0, 0, 0));
	return vec4(
			clamp(poi.x - poi_gol, 0.0, 1.0),
			0, 0, 1.0);
}

//!TEXTURE GOL
//!SIZE 3840 3840
//!FORMAT r16f
//!STORAGE

