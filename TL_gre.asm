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

; salvar modo corrente de video(vendo como est� o modo de video da maquina)
        mov  		ah,0Fh
        int  		10h
        mov  		[modo_anterior],al   

		


; alterar modo de video para gr�fico 640x480 16 cores
    	mov     	al,12h
   		mov     	ah,0
    	int     	10h
		

;Inicialização programa cores default
	mov byte[cor],branco_intenso 

l1:	
    cmp     byte [tique], 0 ; Compara o valor de `tique` com 0
    jne     ab             ; Se `tique` não for 0, pula para ab
    call escreve_menu
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
    je near fim
    cmp al, 's'
    je opcao_s
    cmp al, 'm'
    je opcao_m
    cmp al, 'h'
    je opcao_h
    jmp l1

opcao_s:
    call checa_ascii

    sub al, '0'
    mov bl, 10
	mul bl
    mov dl, al

    call checa_ascii

    sub al, '0'
    add dl, al


    cmp dl, 59
    jg near deu_erro

    mov byte[segundo], dl

    jmp apaga_erro


opcao_m:
    
    call checa_ascii

    sub al, '0'
    mov bl, 10
	mul bl
    mov dl, al

    call checa_ascii
    sub al, '0'
    add dl, al
    
    cmp dl, 59
    jg near deu_erro


    mov byte[minuto], dl

    jmp apaga_erro

opcao_h:
    call checa_ascii
    sub al, '0'
    mov bl, 10
	mul bl
    mov dl, al

    call checa_ascii
    sub al, '0'
    add dl, al

    cmp dl, 23
    jg near deu_erro
    
        mov byte[hora], dl

    jmp apaga_erro

checa_ascii:
    mov ah, 7
    int 21h

    cmp al, '0'
    jl near deu_erro
    cmp al, '9'
    jg near deu_erro
ret

fim:
    CLI                    ; Desabilita interrupções
    XOR     AX, AX         ; Zera o registrador AX
    MOV     ES, AX         ; Zera o segmento extra ES
    MOV     AX, [cs_dos]   ; Carrega AX com o segmento anterior de CS
    MOV     [ES:intr*4+2], AX ; Restaura o segmento CS anterior
    MOV     AX, [offset_dos] ; Carrega AX com o offset anterior de IP
    MOV     [ES:intr*4], AX ; Restaura o offset de IP anterior
    STI                    ; Habilita interrupções
    mov ah,0                ; set video mode
	mov al,[modo_anterior]    ; modo anterior
	int 10h
	mov ax, 4C00h
	int 21h

relogio:
    push    ax             ; Salva o registrador AX na pilha
    push    ds             ; Salva o registrador DS na pilha
    mov     ax, data       ; Move o segmento de dados para AX
    mov     ds, ax         ; Define o segmento de dados
    inc     byte [tique]   ; Incrementa o valor de `tique`
    cmp     byte [tique], 14 ; Compara `tique` com 18 (aproximadamente 1 segundo)
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

    escreve_horario:
	mov     	cx,8			;n�mero de caracteres
	mov     	bx,0
	mov     	dh,10			;linha 0-29
	mov     	dl,32			;coluna 0-79
	loop_horario:
		call	cursor
		mov     al,[bx+horario]
		call	caracter
		inc     bx			;proximo caracter
		inc		dl			;avanca a coluna
	loop    loop_horario

    ;mov     ah, 09h        ; Função 09h de interrupção 21h: Imprimir string
    ;mov     dx, horario    ; Define a string a ser impressa
    ;int     21h            ; Chama interrupção 21h para imprimir a string
    pop     ds             ; Restaura o registrador DS
    pop     ax             ; Restaura o registrador AX
ret                        ; Retorna da função

deu_erro:
    mov byte[cor], vermelho
    call escreve_erro
    jmp l1

apaga_erro:
    mov byte[cor], preto
    call escreve_erro
    call converte
    jmp l1

escreve_erro:
    mov     	cx,25			;n�mero de caracteres
	mov     	bx,0
	mov     	dh,14			;linha 0-29
	mov     	dl,23			;coluna 0-79
	loop_erro:
		call	cursor
		mov     al,[bx+mensagem_erro]
		call	caracter
		inc     bx			;proximo caracter
		inc		dl			;avanca a coluna
	loop    loop_erro
    mov byte[cor], branco_intenso
ret

escreve_menu:
	mov     	cx,35			;n�mero de caracteres
	mov     	bx,0
	mov     	dh,1			;linha 0-29
	mov     	dl,20			;coluna 0-79
	loop_titulo:
		call	cursor
		mov     al,[bx+titulo]
		call	caracter
		inc     bx			;proximo caracter
		inc		dl			;avanca a coluna
	loop    loop_titulo

    mov     	cx,15			;n�mero de caracteres
	mov     	bx,0
	mov     	dh,17			;linha 0-29
	mov     	dl,28			;coluna 0-79
	loop_titulo_menu:
		call	cursor
		mov     al,[bx+palavra_titulo_menu]
		call	caracter
		inc     bx			;proximo caracter
		inc		dl			;avanca a coluna
		loop    loop_titulo_menu
    

    mov     	cx,7			;n�mero de caracteres
	mov     	bx,0
	mov     	dh,19			;linha 0-29
	mov     	dl,32			;coluna 0-79
	loop_menu_q:
		call	cursor
		mov     al,[bx+palavra_menu_q]
		call	caracter
		inc     bx			;proximo caracter
		inc		dl			;avanca a coluna
		loop    loop_menu_q
    
	mov     	cx,53			;n�mero de caracteres
	mov     	bx,0
	mov     	dh,20			;linha 0-29
	mov     	dl,10			;coluna 0-79
	loop_menu_s:
		call	cursor
		mov     al,[bx+palavra_menu_s]
		call	caracter
		inc     bx			;proximo caracter
		inc		dl			;avanca a coluna
		loop    loop_menu_s
    
    mov     	cx,52			;n�mero de caracteres
	mov     	bx,0
	mov     	dh,21			;linha 0-29
	mov     	dl,11			;coluna 0-79
	loop_menu_m:
		call	cursor
		mov     al,[bx+palavra_menu_m]
		call	caracter
		inc     bx			;proximo caracter
		inc		dl			;avanca a coluna
		loop    loop_menu_m
    
    mov     	cx,50			;n�mero de caracteres
	mov     	bx,0
	mov     	dh,22			;linha 0-29
	mov     	dl,11			;coluna 0-79
	loop_menu_h:
		call	cursor
		mov     al,[bx+palavra_menu_h]
		call	caracter
		inc     bx			;proximo caracter
		inc		dl			;avanca a coluna
		loop    loop_menu_h
ret

cursor:
	pushf
	push 		ax
	push 		bx
	push		cx
	push		dx
	push		si
	push		di
	push		bp
	mov     	ah,2
	mov     	bh,0
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

    titulo db 'TL_2024/1 - GUILHERME RAIBOLT EFGEN'
    palavra_titulo_menu db 'Menu de teclas:'
    palavra_menu_q db 'q: sair'
    palavra_menu_s db 's: para o contador dos segundos e aguarda novo valor.'
    palavra_menu_m db 'm: para o contador dos minutos e aguarda novo valor.'
    palavra_menu_h db 'h: para o contador das horas e aguarda novo valor.'
    mensagem_erro db 'Valor inserido invalido!!'  ;25
    

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

