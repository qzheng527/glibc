/* Copyright (C) 2001-2022 Free Software Foundation, Inc.
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
   License along with the GNU C Library; if not, see
   <https://www.gnu.org/licenses/>.  */

/* clone() is even more special than fork() as it mucks with stacks
   and invokes a function in the right context after its all over.  */

#include <sysdep.h>
#define _ERRNO_H	1
#include <bits/errno.h>
#include <asm-syntax.h>

/* The userland implementation is:
   int clone (int (*fn)(void *arg), void *child_stack, int flags,
	      void *arg, pid_t *parent_tid, void *tls, pid_t *child_tid);
   the kernel entry is:
   int clone (long flags, void *child_stack, pid_t *parent_tid,
	      pid_t *child_tid, void *tls);

   The parameters are passed in register and on the stack from userland:
   rdi: fn
   rsi: child_stack
   rdx:	flags
   rcx: arg
    r8:	TID field in parent
    r9: thread pointer
%rsp+8:	TID field in child

   The kernel expects:
   rax: system call number
   rdi: flags
   rsi: child_stack
   rdx: TID field in parent
   r10: TID field in child
   r8:	thread pointer  */


        .text
	.global __thread_start_on_occlum
	.hidden __thread_start_on_occlum
	.type   __thread_start_on_occlum,@function
__thread_start_on_occlum:
	// 16(%rsp) - void* args
	mov 16(%rsp), %rdi
	// 8(%rsp)  - int(*func)(void*)
	mov 8(%rsp), %rcx
	// Make %rsp 16-aligned before call
	and $-16, %rsp
	// Call user-given thread function
	call *%rcx

	// Call exit syscall
	//  int syscall_num - %rdi
	//  int exit_code - %rsi
	mov $SYS_ify(exit), %rdi
	mov %rax, %rsi
	call syscall@GOTPCREL(%rip)

	// This should never happen!
	hlt

ENTRY (__clone)
	/* Sanity check arguments.  */
	movq	$-EINVAL,%rax
	testq	%rdi,%rdi		/* no NULL function pointers */
	jz	SYSCALL_ERROR_LABEL

	/* Align stack to 16 bytes per the x86-64 psABI.  */
	andq	$-16, %rsi
	jz	SYSCALL_ERROR_LABEL	/* no NULL stack pointers */

	// Is running on Occlum?
	movq __occlum_entry@GOTPCREL(%rip), %r11
	movq (%r11), %r11
	cmpq $0, %r11
	je __clone_on_x84_64
	//
	// Pass args to the stack of the child
	//
	// Save child stack addr into another scratch register
	mov %rsi, %r10
	// Make child stack addr 16-byte aligned initially
	and $-16, %r10
	// Push args into the stack of the child
	sub $8, %r10
	mov %rcx, (%r10)
	// Push func into the stack of the child
	sub $8, %r10
	mov %rdi, (%r10)
	// Push "return address" for syscall
	// LibOS will find the entry point of the child by popping
	// the value from the top of the stack of the new thread.
	sub $8, %r10
	mov __thread_start_on_occlum@GOTPCREL(%rip), %r11
	mov %r11, (%r10)

	/* Do the system call.  */
	mov $SYS_ify(clone), %rdi
	mov %rdx, %rsi
	mov %r10, %rdx
	mov %r8, %rcx
	mov 8(%rsp), %r8
	call syscall@GOTPCREL(%rip)

	jmp __end

__clone_on_x84_64:
	/* Insert the argument onto the new stack.  */
	movq	%rcx,-8(%rsi)

	subq	$16,%rsi

	/* Save the function pointer.  It will be popped off in the
	   child.  */
	movq	%rdi,0(%rsi)

	/* Do the system call.  */
	movq	%rdx, %rdi
	movq	%r8, %rdx
	movq	%r9, %r8
	mov	8(%rsp), %R10_LP
	movl	$SYS_ify(clone),%eax

	/* End FDE now, because in the child the unwind info will be
	   wrong.  */
	cfi_endproc;
	syscall

	testq	%rax,%rax
	jl	SYSCALL_ERROR_LABEL
	jz	L(thread_start)

__end:
	ret

L(thread_start):
	cfi_startproc;
	/* Clearing frame pointer is insufficient, use CFI.  */
	cfi_undefined (rip);
	/* Clear the frame pointer.  The ABI suggests this be done, to mark
	   the outermost frame obviously.  */
	xorl	%ebp, %ebp

	/* Set up arguments for the function call.  */
	popq	%rax		/* Function to call.  */
	popq	%rdi		/* Argument.  */
	call	*%rax
	/* Call exit with return value from function call. */
	movq	%rax, %rdi
	movl	$SYS_ify(exit), %eax
	syscall
	cfi_endproc;

	cfi_startproc;
PSEUDO_END (__clone)

libc_hidden_def (__clone)
weak_alias (__clone, clone)
