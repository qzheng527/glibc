/* High precision, low overhead timing functions.  sparcv9 version.
   Copyright (C) 2001-2020 Free Software Foundation, Inc.
   This file is part of the GNU C Library.
   Contributed by David S. Miller <davem@redhat.com>, 2001.

   The GNU C Library is free software; you can redistribute it and/or
   modify it under the terms of the GNU Lesser General Public
   License as published by the Free Software Foundation; either
   version 2.1 of the License, or (at your option) any later version.

   The GNU C Library is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
   Lesser General Public License for more details.

   You should have received a copy of the GNU Lesser General Public
   License along with the GNU C Library; if not, see
   <https://www.gnu.org/licenses/>.  */

#ifndef _HP_TIMING_H

#include <sysdeps/generic/hp-timing.h>
/* Occlum note: Disable the HP_TIMING because rdtsc is an exception in SGXv1,
   it is too slow to handle it, maybe we can enable it in SGXv2 */
#if 0
#define _HP_TIMING_H	1

#define HP_TIMING_INLINE	(1)

typedef unsigned long long int hp_timing_t;

#define HP_TIMING_NOW(Var) \
      __asm__ __volatile__ ("rd %%tick, %L0\n\t" \
			    "srlx %L0, 32, %H0" \
			    : "=r" (Var))

#include <hp-timing-common.h>
#endif
#endif /* hp-timing.h */
