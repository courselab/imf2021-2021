;Incluir .text e .global change. Formatar o trecho para 'change:' e trocar o retorno para $0x10. Remover o call que popa em ax.

     file format elf32-i386











	push   %ebp
	mov    %esp,%ebp
	call   1272 <__x86.get_pc_thunk.ax>
	add    $0x2d82,%eax
	mov    0x8(%ebp),%edx
	mov    0xc(%ebp),%eax
	add    %eax,%edx
	mov    %edx,%eax
	sar    $0x1f,%eax
	shr    $0x18,%eax
	add    %eax,%edx
	movzbl %dl,%edx
	sub    %eax,%edx
	mov    %edx,%eax
	pop    %ebp
	ret    


