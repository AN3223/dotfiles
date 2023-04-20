/* vi: ft=c
 *
 * Copyright (c) 2022 an3223 <ethanr2048@gmail.com>
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

// Description: guided_lgc.glsl: Luma-guided-chroma denoising.

/* The radius can be adjusted with the MEANI stage's downscaling factor. 
 * Higher numbers give a bigger radius.
 *
 * The E variable can be found in the A stage.
 *
 * The subsampling (fast guided filter) can be adjusted with the I stage's 
 * downscaling factor. Higher numbers are faster.
 *
 * The guide's subsampling can be adjusted with the PREI stage's downscaling 
 * factor. Higher numbers downscale more.
 */

//!HOOK CHROMA
//!BIND LUMA
//!WIDTH LUMA.w
//!HEIGHT LUMA.h
//!DESC Guided filter (I, share)
//!SAVE I

vec4 hook()
{
	return LUMA_texOff(0);
}


//!HOOK CHROMA
//!DESC Guided filter (P)
//!BIND HOOKED
//!WIDTH I.w
//!HEIGHT I.h
//!SAVE P

vec4 hook()
{
	return HOOKED_texOff(0);
}

//!HOOK CHROMA
//!DESC Guided filter (MEANI)
//!BIND I
//!SAVE MEANI
//!WIDTH I.w 2.0 /
//!HEIGHT I.h 2.0 /

vec4 hook()
{
	return I_texOff(0);
}

//!HOOK CHROMA
//!DESC Guided filter (MEANP)
//!BIND P
//!WIDTH MEANI.w
//!HEIGHT MEANI.h
//!SAVE MEANP

vec4 hook()
{
	return P_texOff(0);
}

//!HOOK CHROMA
//!DESC Guided filter (I_SQ)
//!BIND I
//!WIDTH I.w
//!HEIGHT I.h
//!SAVE I_SQ

vec4 hook()
{
	return I_texOff(0) * I_texOff(0);
}

//!HOOK CHROMA
//!DESC Guided filter (IXP)
//!BIND I
//!BIND P
//!WIDTH I.w
//!HEIGHT I.h
//!SAVE IXP

vec4 hook()
{
	return I_texOff(0) * P_texOff(0);
}

//!HOOK CHROMA
//!DESC Guided filter (CORRI)
//!BIND I_SQ
//!WIDTH MEANI.w
//!HEIGHT MEANI.h
//!SAVE CORRI

vec4 hook()
{
	return I_SQ_texOff(0);
}

//!HOOK CHROMA
//!DESC Guided filter (CORRP)
//!BIND IXP
//!WIDTH MEANI.w
//!HEIGHT MEANI.h
//!SAVE CORRP

vec4 hook()
{
	return IXP_texOff(0);
}

//!HOOK CHROMA
//!DESC Guided filter (A)
//!BIND MEANI
//!BIND MEANP
//!BIND CORRI
//!BIND CORRP
//!WIDTH I.w
//!HEIGHT I.h
//!SAVE A

#define E 100.0

vec4 hook()
{
	vec4 var = CORRI_texOff(0) - MEANI_texOff(0) * MEANI_texOff(0);
	vec4 cov = CORRP_texOff(0) - MEANI_texOff(0) * MEANP_texOff(0);
	return cov / (var + E);
}

//!HOOK CHROMA
//!DESC Guided filter (B)
//!BIND A
//!BIND MEANI
//!BIND MEANP
//!WIDTH I.w
//!HEIGHT I.h
//!SAVE B

vec4 hook()
{
	return MEANP_texOff(0) - A_texOff(0) * MEANI_texOff(0);
}

//!HOOK CHROMA
//!DESC Guided filter (MEANA)
//!BIND A
//!WIDTH MEANI.w
//!HEIGHT MEANI.h
//!SAVE MEANA

vec4 hook()
{
	return A_texOff(0);
}

//!HOOK CHROMA
//!DESC Guided filter (MEANB)
//!BIND B
//!WIDTH MEANI.w
//!HEIGHT MEANI.h
//!SAVE MEANB

vec4 hook()
{
	return B_texOff(0);
}

//!HOOK CHROMA
//!DESC Guided filter
//!BIND HOOKED
//!BIND MEANA
//!BIND MEANB

vec4 hook()
{
	return MEANA_texOff(0) * HOOKED_texOff(0) + MEANB_texOff(0);
}

