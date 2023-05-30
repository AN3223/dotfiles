// vi: ft=c

// Quantized pyramid of bilinear downscales minus the high frequencies

// XXX support non-luma

// Description: pyramid.glsl:

//!HOOK LUMA
//!BIND HOOKED
//!WIDTH HOOKED.w 1.125 /
//!HEIGHT HOOKED.h 1.125 /
//!DESC Pyramid (BLUR1)
//!SAVE BLUR1

vec4 hook()
{
	return HOOKED_texOff(0);
}

//!HOOK LUMA
//!BIND BLUR1
//!WIDTH BLUR1.w 4.0 /
//!HEIGHT BLUR1.h 4.0 /
//!DESC Pyramid (BLUR2)
//!SAVE BLUR2

vec4 hook()
{
	return BLUR1_texOff(0);
}

//!HOOK LUMA
//!BIND BLUR2
//!WIDTH BLUR2.w 4.0 /
//!HEIGHT BLUR2.h 4.0 /
//!DESC Pyramid (BLUR3)
//!SAVE BLUR3

vec4 hook()
{
	return BLUR2_texOff(0);
}

//!HOOK LUMA
//!BIND BLUR3
//!WIDTH BLUR3.w 4.0 /
//!HEIGHT BLUR3.h 4.0 /
//!DESC Pyramid (BLUR4)
//!SAVE BLUR4

vec4 hook()
{
	return BLUR3_texOff(0);
}


//!HOOK LUMA
//!BIND HOOKED
//!BIND BLUR1
//!BIND BLUR2
//!BIND BLUR3
//!BIND BLUR4
//!DESC Pyramid (pyramid.glsl)

vec4 hook()
{
	float blur1 = BLUR1_texOff(0).x;
	float blur2 = BLUR2_texOff(0).x;
	float blur3 = BLUR3_texOff(0).x;
	float blur4 = BLUR4_texOff(0).x;

	const float scale = 1.0/127.0;
	float result = packSnorm4x8(vec4(
		blur1 - blur2,
		blur2 - blur3,
		blur3 - blur4,
		blur4 * 2 - 1
	)) * scale;

	// reconstruct
	//vec4 unpacked = unpackSnorm4x8(uint(result * 127));
	//result = unpacked.x + unpacked.y + unpacked.z + (unpacked.w * 0.5 + 0.5);

	return vec4(result, 0, 0, 1.0);
}

