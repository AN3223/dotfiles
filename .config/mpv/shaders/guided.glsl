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

/* "Self-guided" guided filter implementation using bilinear instead of box.
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
//!DESC Guided filter (MEANIP)
//!BIND HOOKED
//!WIDTH HOOKED.w 1.125 /
//!HEIGHT HOOKED.h 1.125 /
//!SAVE MEANIP

vec4 hook()
{
	return HOOKED_texOff(0);
}

//!HOOK LUMA
//!HOOK CHROMA
//!HOOK RGB
//!DESC Guided filter (IP_SQ)
//!BIND HOOKED
//!SAVE IP_SQ

vec4 hook()
{
	return HOOKED_texOff(0) * HOOKED_texOff(0);
}

//!HOOK LUMA
//!HOOK CHROMA
//!HOOK RGB
//!DESC Guided filter (CORRIP)
//!BIND IP_SQ
//!WIDTH MEANIP.w
//!HEIGHT MEANIP.h
//!SAVE CORRIP

vec4 hook()
{
	return IP_SQ_texOff(0);
}

//!HOOK LUMA
//!HOOK CHROMA
//!HOOK RGB
//!DESC Guided filter (A)
//!BIND MEANIP
//!BIND CORRIP
//!SAVE A

#define E 0.001

vec4 hook()
{
	vec4 var = CORRIP_texOff(0) - MEANIP_texOff(0) * MEANIP_texOff(0);
	vec4 cov = var;
	return cov / (var + E);
}

//!HOOK LUMA
//!HOOK CHROMA
//!HOOK RGB
//!DESC Guided filter (B)
//!BIND A
//!BIND MEANIP
//!SAVE B

vec4 hook()
{
	return MEANIP_texOff(0) - A_texOff(0) * MEANIP_texOff(0);
}

//!HOOK LUMA
//!HOOK CHROMA
//!HOOK RGB
//!DESC Guided filter (MEANA)
//!BIND A
//!WIDTH MEANIP.w
//!HEIGHT MEANIP.h
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
//!WIDTH MEANIP.w
//!HEIGHT MEANIP.h
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

