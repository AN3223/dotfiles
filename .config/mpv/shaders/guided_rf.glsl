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

/* Guided filter guided by the downscaled image. Output is currently junk!
 * 
 * The radius can be adjusted with the downscaling factors below. The E 
 * variable can be found in the "Guided filter (A)" stage.
 *
 * The quality is not very good compared to non-local means, may be useful for 
 * fast & heavy denoising though?
 */

//!HOOK LUMA
//!HOOK CHROMA
//!HOOK RGB
//!DESC Guided filter (P)
//!BIND HOOKED
//!WIDTH HOOKED.w 1.125 /
//!HEIGHT HOOKED.h 1.125 /
//!SAVE P

vec4 hook()
{
	return HOOKED_texOff(0);
}

//!HOOK LUMA
//!HOOK CHROMA
//!HOOK RGB
//!DESC Guided filter (MEANI)
//!BIND HOOKED
//!WIDTH HOOKED.w 1.125 /
//!HEIGHT HOOKED.h 1.125 /
//!SAVE MEANI

vec4 hook()
{
	return HOOKED_texOff(0);
}

//!HOOK LUMA
//!HOOK CHROMA
//!HOOK RGB
//!DESC Guided filter (MEANP)
//!BIND P
//!WIDTH P.w 1.125 /
//!HEIGHT P.h 1.125 /
//!SAVE MEANP

vec4 hook()
{
	return P_texOff(0);
}

//!HOOK LUMA
//!HOOK CHROMA
//!HOOK RGB
//!DESC Guided filter (I_SQ)
//!BIND HOOKED
//!SAVE I_SQ

vec4 hook()
{
	return HOOKED_texOff(0) * HOOKED_texOff(0);
}

//!HOOK LUMA
//!HOOK CHROMA
//!HOOK RGB
//!DESC Guided filter (IXP)
//!BIND HOOKED
//!BIND P
//!SAVE IXP

vec4 hook()
{
	return HOOKED_texOff(0) * P_texOff(0);
}

//!HOOK LUMA
//!HOOK CHROMA
//!HOOK RGB
//!DESC Guided filter (CORRI)
//!BIND I_SQ
//!WIDTH MEANI.w
//!HEIGHT MEANI.h
//!SAVE CORRI

vec4 hook()
{
	return I_SQ_texOff(0);
}

//!HOOK LUMA
//!HOOK CHROMA
//!HOOK RGB
//!DESC Guided filter (CORRP)
//!BIND IXP
//!WIDTH MEANI.w
//!HEIGHT MEANI.h
//!SAVE CORRP

vec4 hook()
{
	return IXP_texOff(0);
}

//!HOOK LUMA
//!HOOK CHROMA
//!HOOK RGB
//!DESC Guided filter (MEANI_SQ)
//!BIND MEANI
//!WIDTH MEANI.w
//!HEIGHT MEANI.h
//!SAVE MEANI_SQ

vec4 hook()
{
	return MEANI_texOff(0) * MEANI_texOff(0);
}

//!HOOK LUMA
//!HOOK CHROMA
//!HOOK RGB
//!DESC Guided filter (MEANIXP)
//!BIND MEANI
//!BIND MEANP
//!WIDTH MEANP.w
//!HEIGHT MEANP.h
//!SAVE MEANIXP

vec4 hook()
{
	return MEANI_texOff(0) * MEANP_texOff(0);
}

//!HOOK LUMA
//!HOOK CHROMA
//!HOOK RGB
//!DESC Guided filter (A)
//!BIND MEANI_SQ
//!BIND MEANIXP
//!BIND CORRI
//!BIND CORRP
//!SAVE A

#define E 0.001

vec4 hook()
{
	vec4 var = CORRI_texOff(0) - MEANI_SQ_texOff(0);
	vec4 cov = CORRP_texOff(0) - MEANIXP_texOff(0);
	return cov / (var + E);
}

//!HOOK LUMA
//!HOOK CHROMA
//!HOOK RGB
//!DESC Guided filter (B)
//!BIND A
//!BIND MEANI
//!BIND MEANP
//!SAVE B

vec4 hook()
{
	return MEANP_texOff(0) - A_texOff(0) * MEANI_texOff(0);
}

//!HOOK LUMA
//!HOOK CHROMA
//!HOOK RGB
//!DESC Guided filter (MEANA)
//!BIND A
//!WIDTH MEANI.w
//!HEIGHT MEANI.h
//!SAVE MEANA

vec4 hook()
{
	return A_texOff(0);
}

//!HOOK LUMA
//!HOOK CHROMA
//!HOOK RGB
//!DESC Guided filter (MEANB)
//!BIND B
//!WIDTH MEANI.w
//!HEIGHT MEANI.h
//!SAVE MEANB

vec4 hook()
{
	return B_texOff(0);
}

//!HOOK LUMA
//!HOOK CHROMA
//!HOOK RGB
//!DESC Guided filter
//!BIND HOOKED
//!BIND MEANA
//!BIND MEANB

vec4 hook()
{
	return MEANA_texOff(0) * HOOKED_texOff(0) + MEANB_texOff(0);
}

