segment code
..start:
;inicar os registrosd e segumento DS e SS e o ponteiro de pilha SP
    mov     ax,data
    mov     ds,ax
    mov     ax,stack
    mov     ss,ax
    mov     sp,stacktop
;codigo do programa

;Terminar o programa e voltar para o sistema operacional
    mov     ah,4ch
    int     21h
;definicao das variaveis
segment data
;aqui entram as variaveis do programa

;definicao da pilha com total de 256 bytes
segment stack stack
    resb 256
stacktop: