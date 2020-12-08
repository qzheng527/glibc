#ifndef _OCCLUM_SYSCALL_H_
#define _OCCLUM_SYSCALL_H_

#ifdef __ASSEMBLER__
.text
.macro OCCLUM_SYSCALL
    // Is running on Occlum?
    movq __occlum_entry@GOTPCREL(%rip), %r11
    movq (%r11), %r11
    cmpq $0, %r11
    je 688f
    // Do Occlum syscall
    lea 699f(%rip), %rcx
    jmp *%r11
688:
    // Do Linux syscall
    syscall
699:
.endm
#else /* !__ASSEMBLER__ */
asm (
".text\r\n"
".macro OCCLUM_SYSCALL\r\n"
"movq __occlum_entry@GOTPCREL(%rip), %r11\r\n"
"movq (%r11), %r11\r\n"
"cmpq $0, %r11\r\n"
"je 688f\r\n"
"lea 699f(%rip), %rcx\r\n"
"jmp *%r11\r\n"
"688:\r\n"
"syscall\r\n"
"699:\r\n"
".endm\r\n");
#endif /* __ASSEMBLER__ */

#endif /* _OCCLUM_SYSCALL_H_ */
