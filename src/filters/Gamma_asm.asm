section .rodata
  
  ff_mask: times 4 dd 0xff

  shuffle_low_pixel: db 0x00,0x01,0x80,0x80,0x02,0x03,0x80,0x80,0x04,0x05,0x80,0x80,0x06,0x07,0x80,0x80
  shuffle_high_pixel: db 0x08,0x09,0x80,0x80,0x0a,0x0b,0x80,0x80,0x0c,0x0d,0x80,0x80,0x0e,0x0f,0x80,0x80
 
  zeros_byte: times 4 DB 0x00, 0x00, 0x00, 0x00
  zeros_word: times 4 DW 0x00, 0x00, 0x00, 0x00

  %define PIXEL_SIZE 4
  %define TWO_PIXELS 8
  %define FOUR_PIXELS 16

section .text
  global Gamma_asm

  Gamma_asm:
    ; RDI -> uint8_t *src,
    ; RSI -> uint8_t *dst,
    ; EDX -> int width,
    ; ECX -> int height,
    ; R8D  -> int src_row_size,
    ; R9D  -> int dst_row_size
    push rbp
    mov rbp, rsp
    sub rbp, 8
    push rbx
    push r12
    push r13
    push r14
    push r15

    ; Guardo el src y dst
    mov rbx, rdi
    mov r12, rsi

    ; Guardo el width y height (Pixel)
    mov r13, rdx
    mov r14, rcx

    xor rax, rax
    ; Multiplico el width
    ; por 4 para poder tener el
    ; ancho en bytes
    mov rax, PIXEL_SIZE
    mul r13
    mov r13, rax

    ; Ahora ya tengo el width y height
    ; en bytes

    ; Contador de rows y filas (Bytes)
    mov r10, 0

    ; Tengo que iterar las rows
    ; hasta que r10 = r13

    .loopHeight:

    ; Contador de rows (bytes)
    ; Puede tomarse en cuenta como un offset
    mov r11, 0

    ; Tengo que iterar filas
    ; hasta que r11 = r14
		.loopWidth:
		; Clean registers
		xorps xmm1, xmm1

		; | p0 | p1 | p2 | p3 |
		movdqu xmm1, [rdi + r11]
		movdqa xmm3, xmm1

		movdqu xmm11, [zeros_byte]
		punpcklbw xmm1, xmm11
		punpckhbw xmm3, xmm11

		movdqu xmm11, [zeros_word]

		movdqa xmm2, xmm1
		movdqa xmm4, xmm3

		punpcklwd xmm1, xmm11
		punpckhwd xmm2, xmm11
		punpcklwd xmm3, xmm11
		punpckhwd xmm4, xmm11
	
		; Casteo a floats
		cvtdq2ps xmm1, xmm1
		cvtdq2ps xmm2, xmm2
		cvtdq2ps xmm3, xmm3
		cvtdq2ps xmm4, xmm4

		; Multiplico por 255
		movdqu xmm15, [ff_mask]
		cvtdq2ps xmm15, xmm15

		mulps xmm1, xmm15
		mulps xmm2, xmm15
		mulps xmm3, xmm15
		mulps xmm4, xmm15

		; Aplico raiz cuadrada
		sqrtps xmm1, xmm1
		sqrtps xmm2, xmm2
		sqrtps xmm3, xmm3
		sqrtps xmm4, xmm4

		; Convierto a entero
		cvttps2dq xmm1, xmm1
		cvttps2dq xmm2, xmm2
		cvttps2dq xmm3, xmm3
		cvttps2dq xmm4, xmm4

		; Empaquetado
		packusdw xmm1, xmm2
		packusdw xmm3, xmm4
		packuswb xmm1, xmm3

		movdqu [rsi + r11], xmm1
	
		; Avanzo cuatro pixeles
		add r11, FOUR_PIXELS
		cmp r13, r11

		jg .loopWidth

    inc r10
    cmp r14, r10
    jg .continueRowsCycles
    jmp .gammaRet

    ; Cambio el offset del src y dst
    .continueRowsCycles:
    add rdi, r13
    add rsi, r13
    jmp .loopHeight
    
    ; Terminacion de la ejecucion
    .gammaRet:
    add rbp, 8
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret
