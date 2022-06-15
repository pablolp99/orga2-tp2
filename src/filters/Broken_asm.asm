; ************************************************************
; ** BROKEN BY ROWS ******************************************
; ************************************************************

section .data
    offsets: DB 0, -4, 4, 8, 4, -4, 4, 8, 0, -4, 4, 8, -4, 0, 4, -4, -4, 4, 16, 32, 4, 0, 4, -4, -8, -16, 0, 8, 0, 4, -4, 0, 0, 4, 0, 16, 32, 16, 8, 4
   ; offsets: DB 0x00, 0xFC , 0x04, 0x08, 0x04, 0xFC , 0x04, 0x08, 0x00, 0xFC , 0x04, 0x08, 0xFC , 0x00, 0x04, 0xFC , 0xFC , 0x04, 0x10, 0x20, 0x04, 0x00, 0x04, 0xFC , 0xF8, 0xF0, 0x00, 0x08, 0x00, 0x04, 0xFC , 0x00, 0x00, 0x04, 0x00, 0x10, 0x20, 0x10, 0x08, 0x04
    mask_color: times 4 DB 0xFF, 0x00, 0x00, 0x00
    mask_alpha: times 4 DB 0x00, 0x00, 0x00, 0xFF


section .text
	%define PIXEL_SIZE 4

extern Broken_c
global Broken_asm
Broken_asm:
    ; void Broken_c(
    ;     uint8_t *src,     -> RDI
    ;     uint8_t *dst,     -> RSI
    ;     int width,        -> RDX
    ;     int height,       -> RCX
    ;     int src_row_size, -> R8
    ;     int dst_row_size) -> R9

    push rbp
    mov rbp, rsp
    push r12
    push r13
    push r14
    push r15
    sub rbp, 32

    mov r12, rdx    ; R12 -> width      
    mov r13, rcx    ; R13 -> height  

    mov rbx, r8
    shl rbx, 3      ; RBX -> 8*width
    
   ; mov r15, offsets    ; R15 -> array de offsets

    xor r11, r11        ; Contador de filas.
    .loopRow:
        
        mov r9, 10
        .getIndexLoop:
            mov rax, r11               ; i
            add rax, r9                ; i+10
            mov rdx, 0
            mov rcx, 40
            div rcx                     ; (i+10)%40 Reminder in RDX
            xor rax, rax
            mov al, [offsets + rdx]   ; a[(i+adder)%40]
            movsx rax, al               ; a[(i+adder)%40]
            add rax, rbx                ; 8*width + a[(i+adder)%40]
            push rax
        add r9, 10
        cmp r9, 40
        jl .getIndexLoop
        
        pop r15
        pop r14
        pop rcx

        xor r10, r10    ; Contador de columnas.
        .loopCol:
            movdqu xmm2, [mask_alpha]           ;xmm2:| FF | 00| 00 | 00| FF | 00| 00 | 00| FF | 00| 00 | 00| FF | 00| 00 | 00|
            
            ;BLUE
            mov rax, r15
            add rax, r10    ; j + 8*width + a[(i+10)%40]
            mov rdx, 0
            div r12         ; (j + 8*width + a[(i+10)%40]) % width -> Reminder in RDX

            ; Levanto 4 pixeles consecutivos de la i-esima fila
            lea r9, [rdi + rdx*PIXEL_SIZE] 
            ; clflush [r9]
            movdqu xmm0, [r9]                   ;xmm0:| A3 | R3| G3 | B3| A2 | R2| G2 | B2| A1 | R1| G1 | B1| A0 | R0| G0 | B0|
            movdqu xmm1, [mask_color]           ;xmm1:| 00 | 00| 00 | 11| 00 | 00| 00 | 11| 00 | 00| 00 | 11| 00 | 00| 00 | 11|
            pand xmm0, xmm1                     ;xmm0:| 00 | 00| 00 | B3| 00 | 00| 00 | B2| 00 | 00| 00 | B1| 00 | 00| 00 | B0|
            por xmm2, xmm0                   ;xmm2:| FF | 00| 00 | B3| FF | 00| 00 | B2| FF | 00| 00 | B1| FF | 00| 00 | B0|
            
            ;GREEN
            mov rax, r14
            add rax, r10    ; j + 8*width + a[(i+10)%40]
            mov rdx, 0
            div r12         ; (j + 8*width + a[(i+10)%40]) % width -> Reminder in RDX

            ; Levanto 4 pixeles consecutivos de la i-esima fila
            lea r9, [rdi + rdx*PIXEL_SIZE] 
            ; clflush [r9]
            movdqu xmm0, [r9]                   ;xmm0:| A3 | R3| G3 | B3| A2 | R2| G2 | B2| A1 | R1| G1 | B1| A0 | R0| G0 | B0|
            pslld xmm1,8                        ;xmm1:| 00 | 00| 11 | 00| 00 | 00| 11 | 00| 00 | 00| 11 | 00| 00 | 00| 11 | 00|                   
            pand xmm0, xmm1                     ;xmm0:| 00 | 00| G3 | 00| 00 | 00| G2 | 00| 00 | 00| G1 | 00| 00 | 00| G0 | 00|
            por xmm2, xmm0                   ;xmm2:| FF | 00| G3 | B3| FF | 00| G2 | B2| FF | 00| G1 | B1| FF | 00| G0 | B0|
            
            ;RED
            mov rax, rcx
            add rax, r10    ; j + 8*width + a[(i+10)%40]
            mov rdx, 0
            div r12         ; (j + 8*width + a[(i+10)%40]) % width -> Reminder in RDX

            ; Levanto 4 pixeles consecutivos de la i-esima fila
            lea r9, [rdi + rdx*PIXEL_SIZE] 
            ; clflush [r9]
            movdqu xmm0, [r9]                   ;xmm0:| A3 | R3| G3 | B3| A2 | R2| G2 | B2| A1 | R1| G1 | B1| A0 | R0| G0 | B0|
            pslld xmm1,8                        ;xmm1:| 00 | 11| 00 | 00| 00 | 11| 00 | 00| 00 | 11| 00 | 00| 00 | 11| 00 | 00|                   
            pand xmm0, xmm1                     ;xmm0:| 00 | R3| G3 | 00| 00 | 00| G2 | 00| 00 | 00| G1 | 00| 00 | 00| G0 | 00|
            por xmm2, xmm0                   ;xmm2:| FF | R3| G3 | B3| FF | 00| G2 | B2| FF | 00| G1 | B1| FF | 00| G0 | B0|
            

            ; ; Levanto 4 pixeles consecutivos de la i-esima fila  ;xmm0:| A3 | R3| G3 | B3| A2 | R2| G2 | B2| A1 | R1| G1 | B1| A0 | R0| G0 | B0|
            ; ; lea r12, [rdi + r10*PIXEL_SIZE]
            ; ; movdqu xmm0, [r12]                

            lea r9, [rsi + r10*PIXEL_SIZE]
            movdqu [r9], xmm2 

        add r10, 4      ; Incremento de 4 en 4 las cols.
        cmp r10, r12
        jl .loopCol 


    add rdi, r8     ; Avanzo a la siguiente fila
    add rsi, r8
    inc r11
    cmp r11, r13
    jl .loopRow

    add rbp, 32
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbp
    ret


; ************************************************************
; ** BROKEN BY COLS ******************************************
; ************************************************************

; section .data
;     offsets: DB 0, -4, 4, 8, 4, -4, 4, 8, 0, -4, 4, 8, -4, 0, 4, -4, -4, 4, 16, 32, 4, 0, 4, -4, -8, -16, 0, 8, 0, 4, -4, 0, 0, 4, 0, 16, 32, 16, 8, 4
;    ; offsets: DB 0x00, 0xFC , 0x04, 0x08, 0x04, 0xFC , 0x04, 0x08, 0x00, 0xFC , 0x04, 0x08, 0xFC , 0x00, 0x04, 0xFC , 0xFC , 0x04, 0x10, 0x20, 0x04, 0x00, 0x04, 0xFC , 0xF8, 0xF0, 0x00, 0x08, 0x00, 0x04, 0xFC , 0x00, 0x00, 0x04, 0x00, 0x10, 0x20, 0x10, 0x08, 0x04
;     mask_color: times 4 DB 0xFF, 0x00, 0x00, 0x00
;     mask_alpha: times 4 DB 0x00, 0x00, 0x00, 0xFF


; section .text
; 	%define PIXEL_SIZE 4

; extern Broken_c
; global Broken_asm
; Broken_asm:
;     ; void Broken_c(
;     ;     uint8_t *src,     -> RDI
;     ;     uint8_t *dst,     -> RSI
;     ;     int width,        -> RDX
;     ;     int height,       -> RCX
;     ;     int src_row_size, -> R8
;     ;     int dst_row_size) -> R9

;     push rbp
;     mov rbp, rsp
;     push r12
;     push r13
;     push r14
;     push r15
;     sub rbp, 32

;     mov r12, rdx    ; R12 -> width      
;     mov r13, rcx    ; R13 -> height  

;     mov rbx, r8
;     shl rbx, 3      ; RBX -> 8*width
    
;     xor r10, r10    ; Contador de columnas.
;     .loopCol:
;         push rbx
;         add rbx, r10    ; j + 8*width

;         xor r11, r11    ; Contador de filas
        
;         push rdi
;         push rsi

;         .loopRow:
;             movdqu xmm2, [mask_alpha]           ;xmm2:| FF | 00| 00 | 00| FF | 00| 00 | 00| FF | 00| 00 | 00| FF | 00| 00 | 00|
            
;             ;BLUE
;             mov rax, r11                ; i
;             add rax, 30                 ; i+10            
;             mov rdx, 0  
;             mov rcx, 40
;             div rcx                     ; (i+10)%40 Reminder in RDX
;             xor rax, rax
;             mov al, [offsets + rdx]     ; a[(i+adder)%40]
;             movsx rax, al               ; a[(i+adder)%40]
;             add rax, rbx                ; j + 8*width + a[(i+adder)%40]
;             mov rdx, 0
;             div r12         ; (j + 8*width + a[(i+10)%40]) % width -> Reminder in RDX
            
;             ; Levanto 4 pixeles consecutivos de la i-esima fila
;             lea r9, [rdi + rdx*PIXEL_SIZE] 
;             movdqu xmm0, [r9]                   ;xmm0:| A3 | R3| G3 | B3| A2 | R2| G2 | B2| A1 | R1| G1 | B1| A0 | R0| G0 | B0|
;             movdqu xmm1, [mask_color]           ;xmm1:| 00 | 00| 00 | 11| 00 | 00| 00 | 11| 00 | 00| 00 | 11| 00 | 00| 00 | 11|
;             pand xmm0, xmm1                     ;xmm0:| 00 | 00| 00 | B3| 00 | 00| 00 | B2| 00 | 00| 00 | B1| 00 | 00| 00 | B0|
;             por xmm2, xmm0                   ;xmm2:| FF | 00| 00 | B3| FF | 00| 00 | B2| FF | 00| 00 | B1| FF | 00| 00 | B0|

;             ;GREEN
;             mov rax, r11                ; i
;             add rax, 20                 ; i+20            
;             mov rdx, 0  
;             mov rcx, 40
;             div rcx                     ; (i+20)%40 Reminder in RDX
;             xor rax, rax
;             mov al, [offsets + rdx]     ; a[(i+adder)%40]
;             movsx rax, al               ; a[(i+adder)%40]
;             add rax, rbx                ; j + 8*width + a[(i+adder)%40]
;             mov rdx, 0
;             div r12         ; (j + 8*width + a[(i+10)%40]) % width -> Reminder in RDX
            
;             ; Levanto 4 pixeles consecutivos de la i-esima fila
;             lea r9, [rdi + rdx*PIXEL_SIZE] 
;             movdqu xmm0, [r9]                   ;xmm0:| A3 | R3| G3 | B3| A2 | R2| G2 | B2| A1 | R1| G1 | B1| A0 | R0| G0 | B0|
;             pslld xmm1,8                        ;xmm1:| 00 | 00| 11 | 00| 00 | 00| 11 | 00| 00 | 00| 11 | 00| 00 | 00| 11 | 00|                   
;             pand xmm0, xmm1                     ;xmm0:| 00 | 00| G3 | 00| 00 | 00| G2 | 00| 00 | 00| G1 | 00| 00 | 00| G0 | 00|
;             por xmm2, xmm0                   ;xmm2:| FF | 00| G3 | B3| FF | 00| G2 | B2| FF | 00| G1 | B1| FF | 00| G0 | B0|
            
;             ;RED
;             mov rax, r11                ; i
;             add rax, 10                 ; i+30            
;             mov rdx, 0  
;             mov rcx, 40
;             div rcx                     ; (i+30)%40 Reminder in RDX
;             xor rax, rax
;             mov al, [offsets + rdx]     ; a[(i+adder)%40]
;             movsx rax, al               ; a[(i+adder)%40]
;             add rax, rbx                ; j + 8*width + a[(i+adder)%40]
;             mov rdx, 0
;             div r12         ; (j + 8*width + a[(i+10)%40]) % width -> Reminder in RDX
            
;             ; Levanto 4 pixeles consecutivos de la i-esima fila
;             lea r9, [rdi + rdx*PIXEL_SIZE] 
;             movdqu xmm0, [r9]                   ;xmm0:| A3 | R3| G3 | B3| A2 | R2| G2 | B2| A1 | R1| G1 | B1| A0 | R0| G0 | B0|
;             pslld xmm1,8                        ;xmm1:| 00 | 11| 00 | 00| 00 | 11| 00 | 00| 00 | 11| 00 | 00| 00 | 11| 00 | 00|                   
;             pand xmm0, xmm1                     ;xmm0:| 00 | R3| G3 | 00| 00 | 00| G2 | 00| 00 | 00| G1 | 00| 00 | 00| G0 | 00|
;             por xmm2, xmm0                   ;xmm2:| FF | R3| G3 | B3| FF | 00| G2 | B2| FF | 00| G1 | B1| FF | 00| G0 | B0|
            
;             lea r9, [rsi + r10*PIXEL_SIZE]
;             movdqu [r9], xmm2 

;         add rdi, r8     ; Avanzo a la siguiente fila
;         add rsi, r8
;         inc r11
;         cmp r11, r13
;         jl .loopRow

;         pop rsi
;         pop rdi
;         pop rbx

;     add r10, 4      ; Incremento de 4 en 4 las cols.
;     cmp r10, r12
;     jl .loopCol 

;     add rbp, 32
;     pop r15
;     pop r14
;     pop r13
;     pop r12
;     pop rbp
;     ret
