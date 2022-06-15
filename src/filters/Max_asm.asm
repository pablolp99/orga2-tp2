extern Max_c
global Max_asm

section .data
	; Mascara para obtener los colores de los pixles. Mask: | 0 | (10B) ... | 0 | 0x0F | 0x0B | 0x07 | 0x03 |
	get_pixel_colors_mask: DB 0x03, 0x07, 0x0B, 0x0F, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80 
	; Mascara para duplicar el primer dword en el segundo dword. Mask: | 0 | (6B) ... | 0 | 0x03 | 0x02 | 0x01 | 0x00 | 0x03 | 0x02 | 0x01 | 0x00 |
	copy_max_in_next_dword_mask: DB 0x00, 0x01, 0x02, 0x03, 0x00, 0x01, 0x02, 0x03, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80 
	; Mascara para limpiar la primera dword
	clean_first_dword_mask: DD 0x00000000, 0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF
	; Mascara para limpiar las ultimas 3 dwords
	clean_last_three_dword_mask: DD 0xFFFFFFFF, 0x00000000, 0x00000000, 0x00000000
	; Mascara para poder reodernar los pixels en orden de aparicion (cambia los dos valores del medio)
	reorder_to_compare_in_appereance_order_mask: DB 0x00, 0x01, 0x02, 0x03, 0x08, 0x09, 0x0A, 0x0B, 0x04, 0x05, 0x06, 0x07, 0x0C, 0x0D, 0x0E, 0x0F
	; Mascara para poder reordenar los max de los pixels (analogo de arriba)
	reorder_to_compare_sums_in_appereance_order_mask: DB 0x00, 0x01, 0x04, 0x05, 0x02, 0x03, 0x06, 0x07, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80 
section .text

%define pixel_size 4

; XMM0 <- row_0 ; XMM1 <- row_1 ; XMM2 <- row_2 ; XMM3 <- row_3
; XMM8 <- pixel_to_push
Max_push_beggining:
	movdqu XMM9, XMM8
	movdqu XMM10, XMM8
	movdqu XMM11, XMM8

	psrldq XMM9, 4
	psrldq XMM10, 8
	psrldq XMM11, 12

	pand XMM8,  [clean_last_three_dword_mask]
	pand XMM9,  [clean_last_three_dword_mask]
	pand XMM10, [clean_last_three_dword_mask]
	pand XMM11, [clean_last_three_dword_mask]

	pslldq XMM4, 4
	pslldq XMM5, 4
	pslldq XMM6, 4
	pslldq XMM7, 4

	paddd  XMM4, XMM8
	paddd  XMM5, XMM9
	paddd  XMM6, XMM10
	paddd  XMM7, XMM11

	ret


; La funcion agarra los cuatro registros XMMx con los pixels obtenidos de memoria
; y los ordena para comparar en orden de aparicion.
			; -------------------------             ; --------------------------
			; |  3  |  2  |  1  |  0  |				; |  12  |  8  |  4  |  0  | --- XMM0
	;Toma:	; |  7  |  6  |  5  |  4  |   Ordena a: ; |  13  |  9  |  5  |  1  | --- XMM1
			; |  11 |  10 |  9  |  8  |				; |  14  |  10 |  6  |  2  | --- XMM2
			; |  15 |  14 |  13 |  12 |				; |  15  |  11 |  7  |  3  | --- XMM3
			; ------------------------- 		 	; --------------------------
; XMM0 <- row_0
; XMM1 <- row_1
; XMM2 <- row_2
; XMM3 <- row_3
Max_reorder_pixels:
	movdqu XMM4, XMM3
	movdqu XMM5, XMM3
	movdqu XMM6, XMM3
	movdqu XMM7, XMM3

	psrldq XMM5, 4
	psrldq XMM6, 8
	psrldq XMM7, 12

	pand XMM4, [clean_last_three_dword_mask]
	pand XMM5, [clean_last_three_dword_mask]
	pand XMM6, [clean_last_three_dword_mask]
	pand XMM7, [clean_last_three_dword_mask]

	movdqu XMM8, XMM2
	call Max_push_beggining

	movdqu XMM8, XMM1
	call Max_push_beggining

	movdqu XMM8, XMM0
	call Max_push_beggining

	movdqu XMM12, XMM4
	movdqu XMM13, XMM5
	movdqu XMM14, XMM6
	movdqu XMM15, XMM7

	ret

; Compara los primeros 4 words de los 2 registros entrantes y devuelve uno con los valores maximos
; y otro registro con los valores de los pixeles originales maximos
; Todo esto asumiendo que a aparece antes que b en la imagen
; (Es un auxiliar y asumo que no se llama en otro lado, por lo que no respeto convencion C)
; llong Max_get_max(llong a, llong b, llong pixel_row_a, llong, pixel_row_b)
; XMM4 <- a
; XMM5 <- b
; XMM8 <- pixel_row_a
; XMM9 <- pixel_row_b
; XMM6 <- res
Max_get_max:
	; Comparamos XMM4 < XMM5
	; Copiamos XMM5
	movdqu XMM6, XMM5

	; Obtenemos una mascara con 1 si XMM4 < XMM5 y 0 si XMM4 >= XMM5
	pcmpgtw XMM6, XMM4

	; Ahora limpiamos los valores que fueron menores
	; y luego hacemos una suma vertical entre ambos registros
	; como los valores menores se transformaron en 0, obtenemos los valores mayores

	; Copiamos la mascara obtenida por la comparacion de XMM4 > XMM5
	movdqu XMM7,  XMM6
	; Para los pixeles los extendemos a dwords
	pmovsxwd XMM10, XMM6
	pmovsxwd XMM11, XMM6

	pand  XMM6, XMM5
	pandn XMM7, XMM4

	; Hacemos lo mismo para los pixeles
	pand  XMM10, XMM9
	pandn XMM11, XMM8

	; Obtenemos en un registro los valores maximos
	paddusw XMM6, XMM7
	; Obtenemos un registro con los pixeles maximos
	paddusb XMM10, XMM11

	ret


; Suma las componentes de los pixeles en un registro de 128bits
; (Es un auxiliar y asumo que no se llama en otro lado, por lo que no respeto convencion C)
; llong max_compare(llong a)
; XMM4 <- a
; XMM4 <- res
Max_sum_colors:
	; Copiamos en otros 2 registros XMMx el contenido de XMM4
	movdqu XMM5, XMM4
	movdqu XMM6, XMM4

	; Ahora hacemos un shift left de todo el registro en XMM1, dos shift left para XMM2 y tres shift left para XMM3
	pslldq XMM4, 1
	pslldq XMM5, 2
	pslldq XMM6, 3

	; Ahora tenemos que XMM1, XMM2 y XMM3:
	; XMM4: | r | g | b | a | ...| r | g | b | 0 | 
	; XMM5: | g | b | a | r | ...| g | b | 0 | 0 |
	; XMM6: | b | a | r | g | ...| b | 0 | 0 | 0 |

	; Obtenemos los colores a sumar y los guardamos empaquetados en XMMx
	pshufb XMM4, [get_pixel_colors_mask] 	; XMM4 <- | 0 | 0 | (10B)... | r_p_3 | r_p_2 | r_p_1 | r_p_0 |
	pshufb XMM5, [get_pixel_colors_mask] 	; XMM5 <- | 0 | 0 | (10B)... | g_p_3 | g_p_2 | g_p_1 | g_p_0 |
	pshufb XMM6, [get_pixel_colors_mask] 	; XMM6 <- | 0 | 0 | (10B)... | b_p_3 | b_p_2 | b_p_1 | b_p_0 |

	; Luego los extendemos a words para poder sumarlos (si nos quedamos con bytes, la estaríamos saturando)
	pmovzxbw XMM4, XMM4	; XMM4 <- | 0 | (7B)...|     r_p_3     |     r_p_2     |     r_p_1     |     r_p_0     |
	pmovzxbw XMM5, XMM5 ; XMM5 <- | 0 | (7B)...|     g_p_3     |     g_p_2     |     g_p_1     |     g_p_0     |
	pmovzxbw XMM6, XMM6 ; XMM6 <- | 0 | (7B)...|     b_p_3     |     b_p_2     |     b_p_1     |     b_p_0     |

	; Entonces sumamos XMM1 + XMM2 + XMM3, por lo que en los primeros 4 bytes tenemos la suma: b + g + r 
	; Guardamos el resultado en XMM1
	paddusw XMM4, XMM5
	paddusw XMM4, XMM6

	ret

; void Max_asm (uint8_t *src, uint8_t *dst, int width, int height,
;                     int src_row_size, int dst_row_size)
; RDI <- *src
; RSI <- *dst
; EDX <- width
; ECX <- height
; R8D <- src_row_size
; R9D <- dst_row_size
Max_asm:
	.start:
		; Prepare stackframe
		push RBP
		mov RBP, RSP

		push RBX
		push R12
		push R13
		push R14
		push R15

		xor R12, R12                        	; Limpiamos R12
		mov R12D, EDX							; R12D <- width
		mov R13D, ECX   						; R13D <- height

		; Inicializamos las condiciones de parada de los loops
		xor R14, R14                        	; Limpiamos R14
		xor R15, R15                        	; Limpiamos R15
		mov R14D, EDX   						; R14 <- width
		mov R15D, ECX							; R15 <- height
		sub R14, 2                              ; R14 <- width - 2
		sub R15, 2                              ; R15 <- height - 2

	; Inicializamos el contador de filas: i
	mov EBX, 0          						; EDX <- 0
    .rows_loop:
    	cmp R15D, EBX 							; Si height == i => Devolvemos la imagen procesada, sino seguimos iterando
	    je  .draw_borders

	    ; Multiplicamos RAX = i * width = fila a iterar
	    xor RAX, RAX							; Limpiamos RAX
	    mov EAX, R12D   						; EAX <- width
	    mul EBX         						; RAX <- width*i

	    ; Calculamos el indice de la fila
	    lea R8, [RDI + RAX * pixel_size] 		; R8 <- indice de la fila src
	    lea R9, [RSI + RAX * pixel_size] 		; R9 <- indice de la fila dst
			
		; Inicializamos el contador de columnas: j
		mov RCX, 0          					; ECX <- 0
	    .columns_loop:
	    	cmp R14D, ECX						; Si width == j => Avanzamos al siguiente bloque de pixeles
			je  .end_rows_loop

			lea R10, [R8 + RCX * pixel_size]	; R10 <- indice de los primeros 4 pixeles
			mov R11, R12                        ; R11 <- width
			shl R11, 2                          ; R11 <- width * pixel_size

			; La numeracion de los pixeles se toma imaginando este cuadrado
			; -------------------------
			; |  0  |  1  |  2  |  3  |
			; |  4  |  5  |  6  |  7  |
			; |  8  |  9  |  10 |  11 |
			; |  12 |  13 |  14 |  15 |
			; -------------------------
			; Obtenemos las sumas de los pixeles en cada row y las guardamos entre XMM0-XMM3
			.get_pixels_colors_sums:
				movdqu XMM0, [R10]
				movdqu XMM1, [R10 + R11]
				movdqu XMM2, [R10 + 2 * R11]
				lea R11, [R11 + 2 * R11]        ; R11 <- R11 * 3
				movdqu XMM3, [R10 + R11]

				call Max_reorder_pixels

				movdqu XMM4, XMM12
				call Max_sum_colors
				movdqu XMM0, XMM4               ; XMM0: | 0 | (6B)...| 0 |(r+g+b)_p_12 | (r+g+b)_p_8 | (r+g+b)_p_4 | (r+g+b)_p_0 |
				
				movdqu XMM4, XMM13
				call Max_sum_colors
				movdqu XMM1, XMM4               ; XMM1: | 0 | (6B)...| 0 |(r+g+b)_p_13 | (r+g+b)_p_9 | (r+g+b)_p_5 | (r+g+b)_p_1 |
				
				movdqu XMM4, XMM14
				call Max_sum_colors
				movdqu XMM2, XMM4               ; XMM2: | 0 | (6B)...| 0 |(r+g+b)_p_14 | (r+g+b)_p_10 | (r+g+b)_p_6 | (r+g+b)_p_2 |
				
				movdqu XMM4, XMM15
				call Max_sum_colors
				movdqu XMM3, XMM4               ; XMM3: | 0 | (6B)...| 0 |(r+g+b)_p_15 | (r+g+b)_p_11 | (r+g+b)_p_7 | (r+g+b)_p_3 |

			.compare_sums:
				; Comparamos XMM0 < XMM1
				movdqu XMM4, XMM0
				movdqu XMM5, XMM1
				movdqu XMM8, XMM12
				movdqu XMM9, XMM13
				call Max_get_max 				
				movdqu XMM0, XMM6				; XMM0: | 0 | (6B)...| 0 |  max(p_12, p_13)  |  max(p_8, p_9)  | max(p_4, p_5)  | max(p_0, p_1)  |
				movdqu XMM12, XMM10

				; Comparamos XMM2 < XMM3
				movdqu XMM4, XMM2
				movdqu XMM5, XMM3
				movdqu XMM8, XMM14
				movdqu XMM9, XMM15
				call Max_get_max 				
				movdqu XMM1, XMM6				; XMM1: | 0 | (6B)...| 0 | max(p_14, p_15) | max(p_10, p_11) | max(p_6, p_7) | max(p_2, p_3) |
				movdqu XMM13, XMM10

				; Ahora repetimos lo mismo con los resultados anteriores

				; Comparamos XMM0 < XMM1
				movdqu XMM4, XMM0
				movdqu XMM5, XMM1
				movdqu XMM8, XMM12
				movdqu XMM9, XMM13
				call Max_get_max 				
				movdqu XMM0, XMM6	            ; XMM0: | ... (8B) | max(p_12, p_13, p_14, p_15) |  max(p_8, p_9, p_10, p_11)  | max(p_4, p_5, p_6, p_7)  | max(p_0, p_1, p_2, p_3)  |
				movdqu XMM12, XMM10

				; Reordenamos XMM0 y XMM12 (intercambiamos los valores del medio)
				pshufb XMM0, [reorder_to_compare_sums_in_appereance_order_mask]
				pshufb XMM12, [reorder_to_compare_in_appereance_order_mask]

				; Comparamos los maximos obtenidos, replicando los valores en XMM1
				movdqu XMM1, XMM0
				psrldq XMM1, 4
				movdqu XMM13, XMM12
				psrldq XMM13, 8
				; Ahora tenemos que XMM0, XMM1, XMM12, XMM13:
				; XMM0:  |...(12B)| max(p_8, p_9, p_10, p_11)    |  max(p_0, p_1, p_2, p_3)   | 
				; XMM1:  |...(12B)| max(p_12, p_13, p_14, p_15)  |  max(p_4, p_5, p_6, p_7)   |
				; XMM12: |...(8B) | pixel(p_8, p_9, p_10, p_11)  | pixel(p_0, p_1, p_2, p_3)  | 
				; XMM13: |...(8B) | pixel(p_12, p_13, p_14, p_15)| pixel(p_4, p_5, p_6, p_7) |

				; Comparamos XMM0 < XMM1
				movdqu XMM4, XMM0
				movdqu XMM5, XMM1
				movdqu XMM8, XMM12
				movdqu XMM9, XMM13
				call Max_get_max 				
				movdqu XMM0, XMM6	            ; XMM0: | ... (12B) | max(p_8, p_9, p_10, p_11, p_12, p_13, p_14, p_15) |  max(p_0, p_1, p_2, p_3, p_4, p_5, p_6, p_7) |
				movdqu XMM12, XMM10

				; Volvemos a repetir una ultima vez la comparacion
				movdqu XMM1, XMM0
				psrldq XMM1, 2
				movdqu XMM13, XMM12
				psrldq XMM13, 4
				; Ahora tenemos que XMM0, XMM1:
				; XMM0:  |...(14B) | max(p_0, p_1, p_2, p_3, p_4, p_5, p_6, p_7)   		| 
				; XMM1:  |...(14B) | max(p_8, p_9, p_10, p_11, p_12, p_13, p_14, p_15)  |
				; XMM12: |...(12B) | pixel(p_0, p_1, p_2, p_3, p_4, p_5, p_6, p_7) 		| 
				; XMM13: |...(12B) | pixel(p_8, p_9, p_10, p_11, p_12, p_13, p_14, p_15)|

				; Comparamos XMM0 < XMM1
				movdqu XMM4, XMM0
				movdqu XMM5, XMM1
				movdqu XMM8, XMM12
				movdqu XMM9, XMM13
				call Max_get_max 				; XMM6:  | ... (14B) | max(p_0, p_1, p_2, p_3, p_4, p_5, p_6, p_7, p_8, p_9, p_10, p_11, p_12, p_13, p_14, p_15)   |		
												; XMM10: | ... (12B) | pixel(p_0, p_1, p_2, p_3, p_4, p_5, p_6, p_7, p_8, p_9, p_10, p_11, p_12, p_13, p_14, p_15) |
			.copy_max_value_in_inner_square:
				; Duplicamos el valor maximo en su siguiente word     
				pshufb XMM10, [copy_max_in_next_dword_mask]	; XMM6: | 0 | ... (10B) | 0 | max(all_pixels) | max(all_pixels) | 
				
				; Escribimos los pixeles que tomamos
				lea R10, [R9 + RCX * pixel_size + 4]	; R10 <- indice del segundo pixel de la primera row
				
				movq QWORD [R10 + 4 * R12], XMM10				; Movemos max a los pixeles 5  y 6
				movq QWORD [R10 + 8 * R12], XMM10               ; Movemos max a los pixeles 9 y 10

			add ECX, 2			; Avanzamos al siguiente cuadrado de la fila
			jmp .columns_loop

		.end_rows_loop:	
			add RBX, 2			; Avanzamos a las siguientes rows
			jmp .rows_loop

	.draw_borders:
		; Pintamos los bordes sin simd
  		.draw_first_last_row:
  			; Obtenemos en RAX = (height-1) * width
  			xor RAX, RAX
  			mov EBX, R13D
	 		dec EBX                                 ; EBX <- height-1
	 	    mov EAX, R12D   						; EAX <- width
	 	    mul EBX         						; RAX <- width*(height-1)

	 	    lea R9, [RSI + RAX * pixel_size] 		; R9  <- indice de la ultima fila dst
	 	    lea R10,[RSI]                           ; R10 <- indice de la primera fila dst

	 	    mov RCX, 0          					; ECX <- 0
  			.borders_columns_loop:
  				cmp R12D, ECX						; Si width == j => Pintamos los otros bordes
	 			je  .draw_first_last_column

	 			mov DWORD [R10 + RCX * pixel_size], 0xFFFFFFFF        ; dst[0][j] <- white_pixel
	 			mov DWORD [R9 + RCX * pixel_size], 0xFFFFFFFF         ; dst[i-1][j] <- white_pixel

	 			inc ECX
  				jmp .borders_columns_loop

  		.draw_first_last_column:
  			; Obtenemos en RAX =  width * pixel_size
  			xor RBX, RBX
  			mov EBX, R12D
	 		shl EBX, 2                              ; RBX <- width * pixel_size

	 	    lea R9, [RSI] 							; R9  <- indice de la primera columna dst
	 	    mov RAX, R12
	 	    dec RAX		                            ; RAX <- width-1
	 	    lea R10,[RSI + RAX * pixel_size]        ; R10 <- indice de la ultima columna dst

	 	    mov RCX, 0          					; ECX <- 0
  			.borders_rows_loop:
  				cmp R13D, ECX						; Si height == i => Terminamos
	 			je  .end

	 			xor RAX, RAX
	 			mov EAX, EBX
	 			mul ECX                             ; RAX <- width * pixel_size * i

	 			mov DWORD [R9 + RAX], 0xFFFFFFFF         ; dst[i][0] <- white_pixel
	 			mov DWORD [R10 + RAX], 0xFFFFFFFF         ; dst[i][j-1] <- white_pixel

	 			inc ECX
  				jmp .borders_rows_loop

	.end:
		; Unfold stackframe
		pop R15
		pop R14
		pop R13
		pop R12
		pop RBX
		pop RBP
		ret

