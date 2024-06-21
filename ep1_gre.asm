;***************************************************************
;
; Departamento de Engenharia Elétrica - UFES
; Sistemas Embarcados I - 2024/1
;
;***************************************************************
; EXERCÍCIO DE PROGRAMAÇÃO
;
; Aluno: Guilherme Raibolt Efgen
;
; Finalizado em: 21/06/2024
;
;***************************************************************
; O intuito do código é ler um arquivo txt chamado sinalep1.txtcontendo números de -128 até 127 
; e filtrá-lo utilizando filtros do tipo Finite Impulse Response, cujos coeficientes são:
; FIR1: coeficiente 6
; FIR2: coeficiente 11
; FIR3: coeficiente 18

segment code
..start:
    		mov 		ax,data
    		mov 		ds,ax
    		mov 		ax,stack
    		mov 		ss,ax
    		mov 		sp,stacktop

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
	call inicializa_mouse
	call desenha_interface
	call checa_clique
	

arquivo_invalido:
	call escreve_arquivo_invalido
ret

opcao_sair:
	; Instrução de saída
	mov ah,0                ; set video mode
	mov al,[modo_anterior]    ; modo anterior
	int 10h
	mov ax, 4C00h
	int 21h

opcao_histogramas:
    call escreve_abrir
    call escreve_fir1
    call escreve_fir2
    call escreve_fir3
    mov byte[cor], amarelo
    call escreve_histogramas1
    call escreve_histogramas2
    mov byte[cor], branco_intenso
    call escreve_nome
    call escreve_sair
    call checa_clique

opcao_fir3:
	call escreve_abrir
    call escreve_fir1
    call escreve_fir2
	mov byte[cor], amarelo
    call escreve_fir3
	mov byte[cor], branco_intenso
    call escreve_histogramas1
    call escreve_histogramas2
    call escreve_nome
    call escreve_sair

	call apaga_grafico

	mov byte[coef_filtro], 18
	call gera_array_filtrado
	mov byte[cor], verde_claro

	call plot_array_filtrado
	mov byte[cor], branco_intenso
	call checa_clique

opcao_fir2:
    call escreve_abrir
    call escreve_fir1
	mov byte[cor], amarelo
    call escreve_fir2
	mov byte[cor], branco_intenso
    call escreve_fir3
    call escreve_histogramas1
    call escreve_histogramas2
    call escreve_nome
    call escreve_sair

	call apaga_grafico

	mov byte[coef_filtro], 11
	call gera_array_filtrado
	mov byte[cor], azul

	call plot_array_filtrado

	mov byte[cor], branco_intenso
	call checa_clique

opcao_fir1:
    call escreve_abrir
	mov byte[cor], amarelo
    call escreve_fir1
	mov byte[cor], branco_intenso
    call escreve_fir2
    call escreve_fir3
    call escreve_histogramas1
    call escreve_histogramas2
    call escreve_nome
    call escreve_sair
	
	call apaga_grafico

	mov byte[coef_filtro], 6
	call gera_array_filtrado
	mov byte[cor], cyan

	call plot_array_filtrado
	mov byte[cor], branco_intenso
	call checa_clique

opcao_abrir:
	mov byte[cor], amarelo
    call escreve_abrir
	mov byte[cor], branco_intenso

    call escreve_fir1
    call escreve_fir2
    call escreve_fir3
    call escreve_histogramas1
    call escreve_histogramas2
    call escreve_nome
    call escreve_sair
	
	cmp byte[esta_aberto], 1   ; Se já estiver aberto ignora
	je checa_clique

	call abre_txt
	
	mov word[eixo_x], 70
	mov word[eixo_y], 350
	mov byte[cor],branco_intenso

	lea ax, [array_dados]
	mov [endereco_vetor_plot], ax     ; Plota o vetor lido
	call plot_array

    call checa_clique
	
		
checa_clique:
	; Chamada da int 33h para saber onde houve clique do mouse 
	mov ax,5              
	mov bx,0
	int 33h               
	; cx <- posição horizontal do último clique
	; dx <- posição vertical do último clique
	; bx <- # de cliques
	; Se bx for zero, não houve clique, deve retornar
	cmp bx,0              
	jne coord_clique
	jmp checa_clique

coord_clique:
	; Checa se está na barra de opções
	cmp cx, 65
	jb coord_menu_opcoes
	jmp checa_clique

coord_menu_opcoes:
	cmp dx, 400
	ja near opcao_sair

	cmp dx, 320
	ja near opcao_histogramas

	cmp dx, 240
	ja near opcao_fir3

	cmp dx, 160
	ja near opcao_fir2

	cmp dx, 80
	ja near opcao_fir1

	jmp near opcao_abrir
	

; Inicializando mouse
inicializa_mouse:
	mov ax,0
	int 33h
	mov ax,1
	int 33h 

desenha_interface:	
	call desenha_linhas
	call escreve_abrir
	call escreve_fir1
	call escreve_fir2
	call escreve_fir3
	call escreve_histogramas1
	call escreve_histogramas2
	call escreve_nome
	call escreve_sair
	ret


desenha_linhas:
	;Abrir
	mov ax, 0 ;x1
	push ax
	mov ax, 400 ;y1
	push ax
	mov ax, 65 ;x2
	push ax
	mov ax, 400 ;y2
	push ax
	call line
	;desenhar retas
	
	; Divisão menu - primeira linha vertical
	mov ax, 65 ;x1
	push ax
	mov ax, 0 ;y1
	push ax
	mov ax, 65 ;x2
	push ax
	mov ax, 480 ;y2
	push ax
	call line
	
	;FIR1
	mov ax, 0 ;x1
	push ax
	mov ax, 320 ;y1
	push ax
	mov ax, 65 ;x2
	push ax
	mov ax, 320 ;y2
	push ax
	call line
	;FIR2
	mov ax, 0 ;x1
	push ax
	mov ax, 240 ;y1
	push ax
	mov ax, 65 ;x2
	push ax
	mov ax, 240 ;y2
	push ax
	call line
	
	;Histogramas
	mov ax, 0 ;x1
	push ax
	mov ax, 160 ;y1
	push ax
	mov ax, 65 ;x2
	push ax
	mov ax, 160 ;y2
	push ax
	call line
	; Linha horizontal sair e Nome completo
	mov ax, 0 ;x1
	push ax
	mov ax, 80 ;y1
	push ax
	mov ax, 640 ;x2
	push ax
	mov ax, 80 ;y2
	push ax
	call line
	; Linha horizontal entre Area 1 e Area 2
	mov ax, 65 ;x1
	push ax
	mov ax, 250 ;y1
	push ax
	mov ax, 640 ;x2
	push ax
	mov ax, 250 ;y2
	push ax
	call line
	
	; Linha vertical entre Area 1 e Area 3
	mov ax, 385 ;x1
	push ax
	mov ax, 80 ;y1
	push ax
	mov ax, 385 ;x2
	push ax
	mov ax, 480 ;y2
	push ax
	call line
	ret
	

		

escreve_abrir:
	mov     	cx,5			;n�mero de caracteres
	mov     	bx,0
	mov     	dh,2			;linha 0-29
	mov     	dl,1			;coluna 0-79
	loop_abrir:
		call	cursor
		mov     al,[bx+palavraabrir]
		call	caracter
		inc     bx			;proximo caracter
		inc		dl			;avanca a coluna
		loop    loop_abrir
	ret

escreve_arquivo_invalido:
	mov byte[cor], vermelho
	mov     	cx,20			;n�mero de caracteres
	mov     	bx,0
	mov     	dh,6			;linha 0-29
	mov     	dl,17			;coluna 0-79
	loop_invalido1:
		call	cursor
		mov     al,[bx+palavrainvalida1]
		call	caracter
		inc     bx			;proximo caracter
		inc		dl			;avanca a coluna
		loop    loop_invalido1

	mov     	cx,12			;n�mero de caracteres
	mov     	bx,0
	mov     	dh,7			;linha 0-29
	mov     	dl,20			;coluna 0-79
	loop_invalido2:
		call	cursor
		mov     al,[bx+palavrainvalida2]
		call	caracter
		inc     bx			;proximo caracter
		inc		dl			;avanca a coluna
		loop    loop_invalido2
	
	ret
	


escreve_fir1:
	mov     	cx,4			;n�mero de caracteres
	mov     	bx,0
	mov     	dh,7			;linha 0-29
	mov     	dl,1			;coluna 0-79
	loop_fir1:
		call	cursor
		mov     al,[bx+palavrafir1]
		call	caracter
		inc     bx			;proximo caracter
		inc		dl			;avanca a coluna
		loop    loop_fir1
	ret
escreve_fir2:
	mov     	cx,4			;n�mero de caracteres
	mov     	bx,0
	mov     	dh,12			;linha 0-29
	mov     	dl,1			;coluna 0-79
	loop_fir2:
		call	cursor
		mov     al,[bx+palavrafir2]
		call	caracter
		inc     bx			;proximo caracter
		inc		dl			;avanca a coluna
		loop    loop_fir2
	ret
	
escreve_fir3:
	mov     	cx,4			;n�mero de caracteres
	mov     	bx,0
	mov     	dh,17			;linha 0-29
	mov     	dl,1			;coluna 0-79
	loop_fir3:
		call	cursor
		mov     al,[bx+palavrafir3]
		call	caracter
		inc     bx			;proximo caracter
		inc		dl			;avanca a coluna
		loop    loop_fir3
	ret

escreve_histogramas1:
	mov     	cx,6			;n�mero de caracteres
	mov     	bx,0
	mov     	dh,21			;linha 0-29
	mov     	dl,1			;coluna 0-79
	loop_histogramas1:
		call	cursor
		mov     al,[bx+palavraHistogramas1]
		call	caracter
		inc     bx			;proximo caracter
		inc		dl			;avanca a coluna
		loop    loop_histogramas1
	ret	
	
escreve_histogramas2:
	mov     	cx,5			;n�mero de caracteres
	mov     	bx,0
	mov     	dh,22			;linha 0-29
	mov     	dl,1			;coluna 0-79
	loop_histogramas2:
		call	cursor
		mov     al,[bx+palavraHistogramas2]
		call	caracter
		inc     bx			;proximo caracter
		inc		dl			;avanca a coluna
		loop    loop_histogramas2
	ret

escreve_nome:
	mov     	cx,23			;n�mero de caracteres
	mov     	bx,0
	mov     	dh,27			;linha 0-29
	mov     	dl,32			;coluna 0-79
	loop_nome:
		call	cursor
		mov     al,[bx+palavraNome]
		call	caracter
		inc     bx			;proximo caracter
		inc		dl			;avanca a coluna
		loop    loop_nome
	ret
escreve_sair:
	mov     	cx,4			;n�mero de caracteres
	mov     	bx,0
	mov     	dh,27			;linha 0-29
	mov     	dl,1			;coluna 0-79
	loop_sair:
		call	cursor
		mov     al,[bx+palavraSair]
		call	caracter
		inc     bx			;proximo caracter
		inc		dl			;avanca a coluna
		loop    loop_sair
	ret

	


abre_txt:
    mov ah, 3Dh  ; Abre arquivo
    mov al, 00h  ; Abre para leitura
    mov dx, nome_arquivo  ; Ponteiro para o nome do arquivo
    int 21h
    jc near deu_erro  ; Verifica erro ao abrir arquivo
    
	mov byte[esta_aberto], 1
    mov [file_handle], ax  ; Salva o handle do arquivo
    mov si, 0
    mov di, 0
    mov word[qtd_numeros],0
    

		

	loop_byte:
		mov bx, [file_handle]  ; Handle do arquivo
		lea dx, [buffer]       ; Endereço do buffer
		mov cx, 1              ; Ler 1 byte
		mov ah, 3Fh
		int 21h
		
		
		cmp ax, 0
		je near final_arquivo


		mov al, [buffer]

		; Verifica se é um sinal negativo
		cmp al, '-'
		je negativo

		; Verificar se o byte é um espaço ou quebra de linha
		cmp al, 0ah   ; Verifica espaço
		je fim_linha
		cmp al, 0Dh   ; Carriage feed - ignorar
		je loop_byte
		cmp al, '.'  ; Verifica ponto
		je fim_linha

		; Armazenar no vetor que terá somente os ASCII daquela linha
		mov [array_ascii+di], al
		inc di

		

		inc byte[qtd_digitos]
		mov bl, byte[qtd_digitos]

		jmp loop_byte

	negativo:
		mov byte [neg_flag], 1
		jmp loop_byte



	fim_linha:
		cmp byte [qtd_digitos], 3
		je tres_digitos

		cmp byte [qtd_digitos], 2
		je dois_digitos

		cmp byte [qtd_digitos], 1
		je near um_digito

		mov byte [neg_flag], 0
		mov di, 0
		jmp loop_byte


	tres_digitos:       
		mov di, 0
		mov al, [array_ascii+di]
		sub al, '0'
		mov bl, 100
		mul bl
		mov cx, ax

		xor ah, ah
		mov di, 1
		mov al, [array_ascii + di]
		sub al, '0'
		mov bl, 10
		mul bl
		add cx, ax

		xor ah, ah
		mov di, 2
		mov al, [array_ascii + di]
		sub al, '0'
		add cx, ax

		cmp byte [neg_flag], 1
		je inverte

		jmp salva

	dois_digitos:
		mov di, 0
		mov al, [array_ascii+di]
		sub al, '0'
		mov bl, 10
		mul bl
		mov cx, ax

		xor ah, ah
		mov di, 1
		mov al, [array_ascii + di]
		sub al, '0'
		add cx, ax
		cmp byte [neg_flag], 1
		je inverte
		jmp salva

	um_digito:

		mov di, 0
		mov al, [array_ascii+di]
		sub al, '0'
		xor ah, ah
		mov cx, ax

		cmp byte [neg_flag], 1
		je inverte

		jmp salva

	salva:
		add word[qtd_numeros], 1
		mov byte [array_dados + si], cl
		inc si
		mov byte[qtd_digitos], 0
		mov byte [neg_flag], 0
		mov di, 0
		jmp loop_byte

	inverte:
		neg cx
		jmp salva



	deu_erro:
		;mov ah, 09h
		;mov dx, mensagem_erro
		;int 21h
		call arquivo_invalido
		call checa_clique

	final_arquivo:
		mov ah, 3Eh  ; Fecha arquivo
		int 21h
ret

gera_array_filtrado:
	mov byte[esta_filtrado], 1
    mov cx, word[qtd_numeros]
    mov si, 0

    loop_filtro:
        push cx
        call convolucao
        pop cx
        mov byte[array_filtro+si], al    ; Armazena no vetor
        inc si
        loop loop_filtro
ret

convolucao:
    mov bx, 0           ; Acumula a soma
    mov di, 0
    
    mov ah, 0
    mov al, byte[coef_filtro]
    cbw
    mov cx, ax

    ; Verifica se estamos nos valores iniciais
    cmp cx, ax
    jl valores_iniciais

    ; Convolução regular
    mov ch, 0
    mov cl, byte[coef_filtro]    ; Número de coeficientes para convolução

    continua_convolucao:
        mov di, si                   ; Começa no índice atual e vai para trás
        elemento_filtrado:
            mov ah, 0
            mov al, byte[array_dados + di]
            cbw                         ; Estende o sinal
            dec di
            add bx, ax
        loop elemento_filtrado

        ; Divide a soma acumulada pelo número de coeficientes
        mov ax, bx
        xor dx, dx                  ; Limpa DX para evitar problemas de divisão
        mov bl, byte[coef_filtro]
        idiv bl                     ; Divide AX por BL, resultado em AL
ret

valores_iniciais:
    ; Calcula a convolução para os valores iniciais
    mov cx, si
    jmp continua_convolucao


    
plot_array_filtrado:
	lea ax, [array_filtro]
	mov [endereco_vetor_plot], ax     ; Plota o vetor filtrado
    mov word[eixo_x], 70
	mov word[eixo_y], 135

	call plot_array
ret

    
plot_array:
    mov cx, word[qtd_numeros]
    mov si, 0
    plota_ponto:
        mov bx, word[eixo_x]
        add word[eixo_x],1 ;x
        push bx 
        
        xor bh, bh

        push bx
        mov bx, [endereco_vetor_plot]
        mov al, byte[bx+si]
        pop bx

        mov bl, al

        and al, 80h

        cmp al, 80h
        je valor_negativo
        add bx,word[eixo_y] ;y

        finaliza_plot:
            push bx      
            inc si 
            call plot_xy
    loop plota_ponto
ret
valor_negativo:
        neg bl           ; Negativo do valor
        mov ax, word[eixo_y]      ; Altura máxima
        sub ax, bx       ; Subtrai o valor do eixo y
        mov bx, ax       ; Atualiza bx com o novo valor
        jmp finaliza_plot


apaga_grafico:
	cmp byte[esta_filtrado], 1
	je apaga
ret

apaga:
	mov byte[cor], preto
	call plot_array_filtrado
ret



	
		
;***************************************************************************
;
;   fun��o cursor
;
; dh = linha (0-29) e  dl=coluna  (0-79)
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
;_____________________________________________________________________________
;
;   fun��o caracter escrito na posi��o do cursor
;
; al= caracter a ser escrito
; cor definida na variavel cor
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
;_____________________________________________________________________________
;
;   fun��o plot_xy
;
; push x; push y; call plot_xy;  (x<639, y<479)
; cor definida na variavel cor
plot_xy:
		push		bp
		mov		bp,sp
		pushf
		push 		ax
		push 		bx
		push		cx
		push		dx
		push		si
		push		di
	    mov     	ah,0ch
	    mov     	al,[cor]
	    mov     	bh,0
	    mov     	dx,479
		sub		dx,[bp+4]
	    mov     	cx,[bp+6]
	    int     	10h
		pop		di
		pop		si
		pop		dx
		pop		cx
		pop		bx
		pop		ax
		popf
		pop		bp
		ret		4
;_____________________________________________________________________________
;    fun��o circle
;	 push xc; push yc; push r; call circle;  (xc+r<639,yc+r<479)e(xc-r>0,yc-r>0)
; cor definida na variavel cor
circle:
	push 	bp
	mov	 	bp,sp
	pushf                        ;coloca os flags na pilha
	push 	ax
	push 	bx
	push	cx
	push	dx
	push	si
	push	di
	
	mov		ax,[bp+8]    ; resgata xc
	mov		bx,[bp+6]    ; resgata yc
	mov		cx,[bp+4]    ; resgata r
	
	mov 	dx,bx	
	add		dx,cx       ;ponto extremo superior
	push    ax			
	push	dx
	call plot_xy
	
	mov		dx,bx
	sub		dx,cx       ;ponto extremo inferior
	push    ax			
	push	dx
	call plot_xy
	
	mov 	dx,ax	
	add		dx,cx       ;ponto extremo direita
	push    dx			
	push	bx
	call plot_xy
	
	mov		dx,ax
	sub		dx,cx       ;ponto extremo esquerda
	push    dx			
	push	bx
	call plot_xy
		
	mov		di,cx
	sub		di,1	 ;di=r-1
	mov		dx,0  	;dx ser� a vari�vel x. cx � a variavel y
	
;aqui em cima a l�gica foi invertida, 1-r => r-1
;e as compara��es passaram a ser jl => jg, assim garante 
;valores positivos para d

stay:				;loop
	mov		si,di
	cmp		si,0
	jg		inf       ;caso d for menor que 0, seleciona pixel superior (n�o  salta)
	mov		si,dx		;o jl � importante porque trata-se de conta com sinal
	sal		si,1		;multiplica por doi (shift arithmetic left)
	add		si,3
	add		di,si     ;nesse ponto d=d+2*dx+3
	inc		dx		;incrementa dx
	jmp		plotar
inf:	
	mov		si,dx
	sub		si,cx  		;faz x - y (dx-cx), e salva em di 
	sal		si,1
	add		si,5
	add		di,si		;nesse ponto d=d+2*(dx-cx)+5
	inc		dx		;incrementa x (dx)
	dec		cx		;decrementa y (cx)
	
plotar:	
	mov		si,dx
	add		si,ax
	push    si			;coloca a abcisa x+xc na pilha
	mov		si,cx
	add		si,bx
	push    si			;coloca a ordenada y+yc na pilha
	call plot_xy		;toma conta do segundo octante
	mov		si,ax
	add		si,dx
	push    si			;coloca a abcisa xc+x na pilha
	mov		si,bx
	sub		si,cx
	push    si			;coloca a ordenada yc-y na pilha
	call plot_xy		;toma conta do s�timo octante
	mov		si,ax
	add		si,cx
	push    si			;coloca a abcisa xc+y na pilha
	mov		si,bx
	add		si,dx
	push    si			;coloca a ordenada yc+x na pilha
	call plot_xy		;toma conta do segundo octante
	mov		si,ax
	add		si,cx
	push    si			;coloca a abcisa xc+y na pilha
	mov		si,bx
	sub		si,dx
	push    si			;coloca a ordenada yc-x na pilha
	call plot_xy		;toma conta do oitavo octante
	mov		si,ax
	sub		si,dx
	push    si			;coloca a abcisa xc-x na pilha
	mov		si,bx
	add		si,cx
	push    si			;coloca a ordenada yc+y na pilha
	call plot_xy		;toma conta do terceiro octante
	mov		si,ax
	sub		si,dx
	push    si			;coloca a abcisa xc-x na pilha
	mov		si,bx
	sub		si,cx
	push    si			;coloca a ordenada yc-y na pilha
	call plot_xy		;toma conta do sexto octante
	mov		si,ax
	sub		si,cx
	push    si			;coloca a abcisa xc-y na pilha
	mov		si,bx
	sub		si,dx
	push    si			;coloca a ordenada yc-x na pilha
	call plot_xy		;toma conta do quinto octante
	mov		si,ax
	sub		si,cx
	push    si			;coloca a abcisa xc-y na pilha
	mov		si,bx
	add		si,dx
	push    si			;coloca a ordenada yc-x na pilha
	call plot_xy		;toma conta do quarto octante
	
	cmp		cx,dx
	jb		fim_circle  ;se cx (y) est� abaixo de dx (x), termina     
	jmp		stay		;se cx (y) est� acima de dx (x), continua no loop
	
	
fim_circle:
	pop		di
	pop		si
	pop		dx
	pop		cx
	pop		bx
	pop		ax
	popf
	pop		bp
	ret		6
;-----------------------------------------------------------------------------
;    fun��o full_circle
;	 push xc; push yc; push r; call full_circle;  (xc+r<639,yc+r<479)e(xc-r>0,yc-r>0)
; cor definida na variavel cor					  
full_circle:
	push 	bp
	mov	 	bp,sp
	pushf                        ;coloca os flags na pilha
	push 	ax
	push 	bx
	push	cx
	push	dx
	push	si
	push	di

	mov		ax,[bp+8]    ; resgata xc
	mov		bx,[bp+6]    ; resgata yc
	mov		cx,[bp+4]    ; resgata r
	
	mov		si,bx
	sub		si,cx
	push    ax			;coloca xc na pilha			
	push	si			;coloca yc-r na pilha
	mov		si,bx
	add		si,cx
	push	ax		;coloca xc na pilha
	push	si		;coloca yc+r na pilha
	call line
	
		
	mov		di,cx
	sub		di,1	 ;di=r-1
	mov		dx,0  	;dx ser� a vari�vel x. cx � a variavel y
	
;aqui em cima a l�gica foi invertida, 1-r => r-1
;e as compara��es passaram a ser jl => jg, assim garante 
;valores positivos para d

stay_full:				;loop
	mov		si,di
	cmp		si,0
	jg		inf_full       ;caso d for menor que 0, seleciona pixel superior (n�o  salta)
	mov		si,dx		;o jl � importante porque trata-se de conta com sinal
	sal		si,1		;multiplica por doi (shift arithmetic left)
	add		si,3
	add		di,si     ;nesse ponto d=d+2*dx+3
	inc		dx		;incrementa dx
	jmp		plotar_full
inf_full:	
	mov		si,dx
	sub		si,cx  		;faz x - y (dx-cx), e salva em di 
	sal		si,1
	add		si,5
	add		di,si		;nesse ponto d=d+2*(dx-cx)+5
	inc		dx		;incrementa x (dx)
	dec		cx		;decrementa y (cx)
	
plotar_full:	
	mov		si,ax
	add		si,cx
	push	si		;coloca a abcisa y+xc na pilha			
	mov		si,bx
	sub		si,dx
	push    si		;coloca a ordenada yc-x na pilha
	mov		si,ax
	add		si,cx
	push	si		;coloca a abcisa y+xc na pilha	
	mov		si,bx
	add		si,dx
	push    si		;coloca a ordenada yc+x na pilha	
	call 	line
	
	mov		si,ax
	add		si,dx
	push	si		;coloca a abcisa xc+x na pilha			
	mov		si,bx
	sub		si,cx
	push    si		;coloca a ordenada yc-y na pilha
	mov		si,ax
	add		si,dx
	push	si		;coloca a abcisa xc+x na pilha	
	mov		si,bx
	add		si,cx
	push    si		;coloca a ordenada yc+y na pilha	
	call	line
	
	mov		si,ax
	sub		si,dx
	push	si		;coloca a abcisa xc-x na pilha			
	mov		si,bx
	sub		si,cx
	push    si		;coloca a ordenada yc-y na pilha
	mov		si,ax
	sub		si,dx
	push	si		;coloca a abcisa xc-x na pilha	
	mov		si,bx
	add		si,cx
	push    si		;coloca a ordenada yc+y na pilha	
	call	line
	
	mov		si,ax
	sub		si,cx
	push	si		;coloca a abcisa xc-y na pilha			
	mov		si,bx
	sub		si,dx
	push    si		;coloca a ordenada yc-x na pilha
	mov		si,ax
	sub		si,cx
	push	si		;coloca a abcisa xc-y na pilha	
	mov		si,bx
	add		si,dx
	push    si		;coloca a ordenada yc+x na pilha	
	call	line
	
	cmp		cx,dx
	jb		fim_full_circle  ;se cx (y) est� abaixo de dx (x), termina     
	jmp		stay_full		;se cx (y) est� acima de dx (x), continua no loop
	
	
fim_full_circle:
	pop		di
	pop		si
	pop		dx
	pop		cx
	pop		bx
	pop		ax
	popf
	pop		bp
	ret		6
;-----------------------------------------------------------------------------
;
;   fun��o line
;
; push x1; push y1; push x2; push y2; call line;  (x<639, y<479)
line:
		push		bp
		mov		bp,sp
		pushf                        ;coloca os flags na pilha
		push 		ax
		push 		bx
		push		cx
		push		dx
		push		si
		push		di
		mov		ax,[bp+10]   ; resgata os valores das coordenadas
		mov		bx,[bp+8]    ; resgata os valores das coordenadas
		mov		cx,[bp+6]    ; resgata os valores das coordenadas
		mov		dx,[bp+4]    ; resgata os valores das coordenadas
		cmp		ax,cx
		je		line2
		jb		line1
		xchg		ax,cx
		xchg		bx,dx
		jmp		line1
line2:		; deltax=0
		cmp		bx,dx  ;subtrai dx de bx
		jb		line3
		xchg		bx,dx        ;troca os valores de bx e dx entre eles
line3:	; dx > bx
		push		ax
		push		bx
		call 		plot_xy
		cmp		bx,dx
		jne		line31
		jmp		fim_line
line31:		inc		bx
		jmp		line3
;deltax <>0
line1:
; comparar m�dulos de deltax e deltay sabendo que cx>ax
	; cx > ax
		push		cx
		sub		cx,ax
		mov		[deltax],cx
		pop		cx
		push		dx
		sub		dx,bx
		ja		line32
		neg		dx
line32:		
		mov		[deltay],dx
		pop		dx

		push		ax
		mov		ax,[deltax]
		cmp		ax,[deltay]
		pop		ax
		jb		line5

	; cx > ax e deltax>deltay
		push		cx
		sub		cx,ax
		mov		[deltax],cx
		pop		cx
		push		dx
		sub		dx,bx
		mov		[deltay],dx
		pop		dx

		mov		si,ax
line4:
		push		ax
		push		dx
		push		si
		sub		si,ax	;(x-x1)
		mov		ax,[deltay]
		imul		si
		mov		si,[deltax]		;arredondar
		shr		si,1
; se numerador (DX)>0 soma se <0 subtrai
		cmp		dx,0
		jl		ar1
		add		ax,si
		adc		dx,0
		jmp		arc1
ar1:		sub		ax,si
		sbb		dx,0
arc1:
		idiv		word [deltax]
		add		ax,bx
		pop		si
		push		si
		push		ax
		call		plot_xy
		pop		dx
		pop		ax
		cmp		si,cx
		je		fim_line
		inc		si
		jmp		line4

line5:		cmp		bx,dx
		jb 		line7
		xchg		ax,cx
		xchg		bx,dx
line7:
		push		cx
		sub		cx,ax
		mov		[deltax],cx
		pop		cx
		push		dx
		sub		dx,bx
		mov		[deltay],dx
		pop		dx



		mov		si,bx
line6:
		push		dx
		push		si
		push		ax
		sub		si,bx	;(y-y1)
		mov		ax,[deltax]
		imul		si
		mov		si,[deltay]		;arredondar
		shr		si,1
; se numerador (DX)>0 soma se <0 subtrai
		cmp		dx,0
		jl		ar2
		add		ax,si
		adc		dx,0
		jmp		arc2
ar2:		sub		ax,si
		sbb		dx,0
arc2:
		idiv		word [deltay]
		mov		di,ax
		pop		ax
		add		di,ax
		pop		si
		push		di
		push		si
		call		plot_xy
		pop		dx
		cmp		si,dx
		je		fim_line
		inc		si
		jmp		line6

fim_line:
		pop		di
		pop		si
		pop		dx
		pop		cx
		pop		bx
		pop		ax
		popf
		pop		bp
		ret		8
;*******************************************************************
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
linha   	dw  		0
coluna  	dw  		0
deltax		dw		0
deltay		dw		0	
volta		db		0
mens    	db  		'Funcao Grafica'
palavraabrir    db     'Abrir'
palavrafir1 db 'FIR1'
palavrafir2 db 'FIR2'
palavrafir3 db 'FIR3'
palavrainvalida1 db 'Arquivo sinalep1.txt'
palavrainvalida2 db 'inexistente!'
palavraHistogramas1 db 'Histog'
palavraHistogramas2 db 'ramas'
endereco_vetor_plot dw 0
palavraNome db 'GUILHERME RAIBOLT EFGEN'
palavraSair db 'Sair'
coef_filtro db 0
esta_aberto db 0
esta_filtrado db 0

; Variáveis para abertura e plot do arquivo
eixo_x dw 0
eixo_y dw 0
index_dados db 0
qtd_digitos db 0
nome_arquivo db 'sinalep1.txt', 0
qtd_numeros dw 0
array_filtro resb 8000
array_ascii resb 10
file_handle dw 0
neg_flag db 0
buffer resb 5
array_dados resb 8000   ; Reserva 8000 bytes para o array


segment stack stack
    		resb 		512
stacktop:
