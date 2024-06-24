segment code
..start:
    CLI                    ; Desabilita interrupções
    mov     ax, data       ; Move o segmento de dados para AX
    mov     ds, ax         ; Define o segmento de dados
    mov     ax, stack      ; Move o segmento de pilha para AX
    mov     ss, ax         ; Define o segmento de pilha
    mov     sp, stacktop   ; Define o ponteiro da pilha no topo da pilha
    XOR     AX, AX         ; Zera o registrador AX
    MOV     ES, AX         ; Zera o segmento extra ES
    MOV     AX, [ES:intr*4]; Carrega AX com o offset anterior do vetor de interrupção
    MOV     [offset_dos], AX ; Guarda o endereço para qual IP de int 8 estava apontando anteriormente
    MOV     AX, [ES:intr*4+2] ; Carrega AX com o segmento anterior de CS do vetor de interrupção
    MOV     [cs_dos], AX   ; Guarda o endereço anterior de CS
    MOV     [ES:intr*4+2], CS ; Define o segmento CS para a nova rotina de interrupção
    MOV     WORD [ES:intr*4], relogio ; Define o offset para a nova rotina de interrupção
    STI                    ; Habilita interrupções

l1:	
    cmp     byte [tique], 0 ; Compara o valor de `tique` com 0
    jne     ab             ; Se `tique` não for 0, pula para ab
    call    converte       ; Chama a função `converte` para atualizar a exibição
ab:
    mov     ah, 0bh        ; Função 0Bh de interrupção 21h: Verifica o buffer de teclado
    int     21h            ; Chama interrupção 21h para ler o buffer de teclado
    cmp     al, 0          ; Compara o valor de AL com 0
    jne     tratativa_teclado            ; Se AL não for 0, pula para fim
    jmp     l1             ; Volta para o início do loop l1

tratativa_teclado:
    mov ah, 7
    int 21h

    cmp al, 'q'
    je fim
    cmp al, 's'
    je opcao_s
    cmp al, 'm'
    je opcao_m
    cmp al, 'h'
    je opcao_h
    jmp l1

opcao_s:
    mov ah, 7
    int 21h
    sub al, '0'
    mov bl, 10
	mul bl
    mov dl, al

    mov ah, 7
    int 21h
    sub al, '0'
    add dl, al

    mov byte[segundo], dl
    call converte
    jmp l1
opcao_m:
    mov ah, 7
    int 21h
    sub al, '0'
    mov bl, 10
	mul bl
    mov dl, al

    mov ah, 7
    int 21h
    sub al, '0'
    add dl, al

    mov byte[minuto], dl
    call converte
    jmp l1
opcao_h:
    mov ah, 7
    int 21h
    sub al, '0'
    mov bl, 10
	mul bl
    mov dl, al

    mov ah, 7
    int 21h
    sub al, '0'
    add dl, al

    
    mov byte[hora], dl
    call converte
    jmp l1

fim:
    CLI                    ; Desabilita interrupções
    XOR     AX, AX         ; Zera o registrador AX
    MOV     ES, AX         ; Zera o segmento extra ES
    MOV     AX, [cs_dos]   ; Carrega AX com o segmento anterior de CS
    MOV     [ES:intr*4+2], AX ; Restaura o segmento CS anterior
    MOV     AX, [offset_dos] ; Carrega AX com o offset anterior de IP
    MOV     [ES:intr*4], AX ; Restaura o offset de IP anterior
    STI                    ; Habilita interrupções
    MOV     AH, 4Ch        ; Função 4Ch de interrupção 21h: Termina o programa
    int     21h            ; Chama interrupção 21h para terminar o programa

relogio:
    push    ax             ; Salva o registrador AX na pilha
    push    ds             ; Salva o registrador DS na pilha
    mov     ax, data       ; Move o segmento de dados para AX
    mov     ds, ax         ; Define o segmento de dados
    inc     byte [tique]   ; Incrementa o valor de `tique`
    cmp     byte [tique], 18 ; Compara `tique` com 18 (aproximadamente 1 segundo)
    jb      Fimrel         ; Se `tique` for menor que 18, pula para Fimrel
    mov     byte [tique], 0 ; Reseta `tique` para 0
    inc     byte [segundo] ; Incrementa `segundo`
    cmp     byte [segundo], 60 ; Compara `segundo` com 60
    jb      Fimrel         ; Se `segundo` for menor que 60, pula para Fimrel
    mov     byte [segundo], 0 ; Reseta `segundo` para 0
    inc     byte [minuto]  ; Incrementa `minuto`
    cmp     byte [minuto], 60 ; Compara `minuto` com 60
    jb      Fimrel         ; Se `minuto` for menor que 60, pula para Fimrel
    mov     byte [minuto], 0 ; Reseta `minuto` para 0
    inc     byte [hora]    ; Incrementa `hora`
    cmp     byte [hora], 24 ; Compara `hora` com 24
    jb      Fimrel         ; Se `hora` for menor que 24, pula para Fimrel
    mov     byte [hora], 0 ; Reseta `hora` para 0
Fimrel:
    mov     al, 20h        ; Prepara valor para enviar EOI (End of Interrupt)
    out     20h, al        ; Envia EOI para o controlador de interrupções
    pop     ds             ; Restaura o registrador DS
    pop     ax             ; Restaura o registrador AX
    iret                   ; Retorna da interrupção

converte:
    push    ax             ; Salva o registrador AX na pilha
    push    ds             ; Salva o registrador DS na pilha
    mov     ax, data       ; Move o segmento de dados para AX
    mov     ds, ax         ; Define o segmento de dados
    xor     ah, ah         ; Zera o registrador AH
    MOV     BL, 10         ; Define divisor para divisão decimal
    mov     al, byte [segundo] ; Move `segundo` para AL
    DIV     BL             ; Divide AL por BL
    ADD     AL, 30h        ; Converte o quociente para ASCII
    MOV     byte [horario+6], AL ; Armazena o quociente no formato de horário
    ADD     AH, 30h        ; Converte o resto para ASCII
    mov     byte [horario+7], AH ; Armazena o resto no formato de horário

    xor     ah, ah         ; Zera o registrador AH
    mov     al, byte [minuto] ; Move `minuto` para AL
    DIV     BL             ; Divide AL por BL
    ADD     AL, 30h        ; Converte o quociente para ASCII
    MOV     byte [horario+3], AL ; Armazena o quociente no formato de horário
    ADD     AH, 30h        ; Converte o resto para ASCII
    mov     byte [horario+4], AH ; Armazena o resto no formato de horário

    xor     ah, ah         ; Zera o registrador AH
    mov     al, byte [hora] ; Move `hora` para AL
    DIV     BL             ; Divide AL por BL
    ADD     AL, 30h        ; Converte o quociente para ASCII
    MOV     byte [horario], AL ; Armazena o quociente no formato de horário
    ADD     AH, 30h        ; Converte o resto para ASCII
    mov     byte [horario+1], AH ; Armazena o resto no formato de horário
    mov     ah, 09h        ; Função 09h de interrupção 21h: Imprimir string
    mov     dx, horario    ; Define a string a ser impressa
    int     21h            ; Chama interrupção 21h para imprimir a string
    pop     ds             ; Restaura o registrador DS
    pop     ax             ; Restaura o registrador AX
    ret                    ; Retorna da função


caracter:
	pushf
	push 		ax
	push 		bx
	push		cx
	push		dx
	push		si
	push		di
	push		bp
		mov     	ah,9
		mov     	bh,0
		mov     	cx,1
	mov     	bl,[cor]
		int     	10h
	pop		bp
	pop		di
	pop		si
	pop		dx
	pop		cx
	pop		bx
	pop		ax
	popf
	ret


segment data
    cor		db		branco_intenso

    ;	I R G B COR
    ;	0 0 0 0 preto
    ;	0 0 0 1 azul
    ;	0 0 1 0 verde
    ;	0 0 1 1 cyan
    ;	0 1 0 0 vermelho
    ;	0 1 0 1 magenta
    ;	0 1 1 0 marrom
    ;	0 1 1 1 branco
    ;	1 0 0 0 cinza
    ;	1 0 0 1 azul claro
    ;	1 0 1 0 verde claro
    ;	1 0 1 1 cyan claro
    ;	1 1 0 0 rosa
    ;	1 1 0 1 magenta claro
    ;	1 1 1 0 amarelo
    ;	1 1 1 1 branco intenso

    preto		equ		0
    azul		equ		1
    verde		equ		2
    cyan		equ		3
    vermelho	equ		4
    magenta		equ		5
    marrom		equ		6
    branco		equ		7
    cinza		equ		8
    azul_claro	equ		9
    verde_claro	equ		10
    cyan_claro	equ		11
    rosa		equ		12
    magenta_claro	equ		13
    amarelo		equ		14
    branco_intenso	equ		15


    modo_anterior	db		0
    eoi         EQU 20h    ; Define o valor EOI (End of Interrupt)
    intr        EQU 08h    ; Define o número da interrupção do timer
    char        db  0      ; Caractere temporário (não usado)
    offset_dos  dw  0      ; Guarda o offset anterior do vetor de interrupção
    cs_dos      dw  0      ; Guarda o segmento anterior do vetor de interrupção
    tique       db  0      ; Contador de tique (incrementado a cada interrupção)
    segundo     db  0      ; Contador de segundos
    minuto      db  0      ; Contador de minutos
    hora        db  0      ; Contador de horas
    horario     db  0,0,':',0,0,':',0,0,' ', 13,'$' ; String de horário formatada para exibição
segment stack stack
    resb 256               ; Reserva 256 bytes para a pilha
stacktop:                  ; Define o topo da pilha

