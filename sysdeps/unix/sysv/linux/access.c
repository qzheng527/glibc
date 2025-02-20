/* Linux implementation for access function.
   Copyright (C) 2016-2020 Free Software Foundation, Inc.
   This file is part of the GNU C Library.

   The GNU C Library is free software; you can redistribute it and/or
   modify it under the terms of the GNU Lesser General Public
   License as published by the Free Software Foundation; either
   version 2.1 of the License, or (at your option) any later version.

   The GNU C Library is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
   Lesser General Public License for more details.

   You should have received a copy of the GNU Lesser General Public
   License along with the GNU C Library.  If not, see
   <https://www.gnu.org/licenses/>.  */

#include <fcntl.h>
#include <unistd.h>
#include <sysdep-cancel.h>

int
__access (const char *file, int type)
{
#ifdef __NR_access
  return INLINE_SYSCALL_CALL (access, file, type);
#else
  /* Occlum note: Occlum accepts the 4th argument */
  return INLINE_SYSCALL_CALL (faccessat, AT_FDCWD, file, type, 0);
#endif
}
libc_hidden_def (__access)
weak_alias (__access, access)
