  .file "handle_syscall.s"
  .text
  .globl handle_syscall_loader
  .internal handle_syscall_loader
  .type handle_syscall_loader, @function

handle_syscall_loader:
  # Save the registers
  pushq %rbx
  pushq %rcx
  pushq %rdx
  pushq %rsi
  pushq %rdi
  pushq %r8
  pushq %r10
  pushq %r11
  pushq %r12
  pushq %r13
  pushq %r14
  pushq %r15

  # Align the stack on a 16-byte boundary before the call
  push %rbp
  mov %rsp, %rbp
  and $0xfffffffffffffff0, %rsp

  # Adjust the arguments
  pushq %rsp         # reserve space for wrapper_sp
  pushq %r9          # arg6
  movq %rsp, 8(%rsp) # wrapper_sp
  movq %r8, %r9      # arg5
  movq %r10, %r8     # arg4
  movq %rdx, %rcx    # arg3
  movq %rsi, %rdx    # arg2
  movq %rdi, %rsi    # arg1
  movq %rax, %rdi    # sc_no

  # Call the actual handler
  call *ld_sc_handler@GOTPCREL(%rip)

  # Pop arguments
  popq %r9
  popq %r15    # skip wrapper_sp

  # Restore the stack
  mov %rbp, %rsp
  pop %rbp

  # Reload registers
  popq %r15
  popq %r14
  popq %r13
  popq %r12
  popq %r11
  popq %r10
  popq %r8
  popq %rdi
  popq %rsi
  popq %rdx
  popq %rcx
  popq %rbx

  # Epilogue
  addq $8, %rsp # I hate this.
  ret
  .size handle_syscall_loader, .-handle_syscall_loader
  .section .note.GNU-stack,"",@progbits
