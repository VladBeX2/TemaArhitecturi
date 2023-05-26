    DOSSEG
    .MODEL SMALL
    .STACK 32
    .DATA
encoded     DB  80 DUP(0)
temp        DB  '0x', 160 DUP(0)
fileHandler DW  ?
filename    DB  'in/in.txt', 0          ; Trebuie sa existe acest fisier 'in/in.txt'!
outfile     DB  'out/out.txt', 0        ; Trebuie sa existe acest director 'out'!
message     DB  80 DUP(0)
msglen      DW  ?
padding     DW  0
nume        DB  'Vlad Cristescu',0
iterations  DW  0 
COD64       DB 'Bqmgp86CPe9DfNz7R1wjHIMZKGcYXiFtSU2ovJOhW4ly5EkrqsnAxubTV03a=L/d'
x           DW  ?
x0          DW  ?
a           DW  0
b           DW  0
    .CODE
START:
    MOV     AX, @DATA
    MOV     DS, AX

    CALL    FILE_INPUT                  ; NU MODIFICATI!
    
    CALL    SEED                        ; TODO - Trebuie implementata

    CALL    ENCRYPT                     ; TODO - Trebuie implementata
    
    CALL    ENCODE                      ; TODO - Trebuie implementata
    
                                        ; Mai jos se regaseste partea de
                                        ; afisare pe baza valorilor care se
                                        ; afla in variabilele x0, a, b, respectiv
                                        ; in sirurile message si encoded.
                                        ; NU MODIFICATI!
    MOV     AH, 3CH                     ; BIOS Int - Open file
    MOV     CX, 0
    MOV     AL, 1                       ; AL - Access mode ( Write - 1 )
    MOV     DX, OFFSET outfile          ; DX - Filename
    INT     21H
    MOV     [fileHandler], AX           ; Return: AX - file handler or error code

    CALL    WRITE                       ; NU MODIFICATI!

    MOV     AH, 4CH                     ; Bios Int - Terminate with return code
    MOV     AL, 0                       ; AL - Return code
    INT     21H
FILE_INPUT:
    MOV     AH, 3DH                     ; BIOS Int - Open file
    MOV     AL, 0                       ; AL - Access mode ( Read - 0 )
    MOV     DX, OFFSET fileName         ; DX - Filename
    INT     21H
    MOV     [fileHandler], AX           ; Return: AX - file handler or error code

    MOV     AH, 3FH                     ; BIOD Int - Read from file or device
    MOV     BX, [fileHandler]           ; BX - File handler
    MOV     CX, 80                      ; CX - Number of bytes to read
    MOV     DX, OFFSET message          ; DX - Data buffer
    INT     21H
    MOV     [msglen], AX                ; Return: AX - number of read bytes

    MOV     AH, 3EH                     ; BIOS Int - Close file
    MOV     BX, [fileHandler]           ; BX - File handler
    INT     21H

    RET
SEED:
    mov ax,[msglen]
    mov ah,0
    mov cl,3
    div cl
    mov al,ah
    mov ah,0
    sub cx,ax
    mov padding,cx
    cmp cx,3
    jne ContSeed 
    mov padding,0
    ContSeed:
    MOV     AH, 2CH                     ; BIOS Int - Get System Time
    INT     21H                                  ; TODO1: Completati subrutina SEED
                                        ; astfel incat la final sa fie salvat
    push dx
    mov ax,0
    mov ax,3600
    mov bx,0
    mov bl,ch
    mul bx             
    mov word ptr temp+2,dx
    mov dx,ax
    mov ax,0
    mov ax,60
    mov bl,cl
    push dx
    mul bx
    pop dx
    add dx,ax
    mov cx,dx
    pop dx
    mov bl,dh
    add cx,bx
    mov dh,0
    mov word ptr temp+4,dx
    mov ax,0
    mov ax,100
    mul cx
    push ax
    push dx
    mov ax,word ptr temp+2
    mov cx,100
    mul cx
    pop dx
    add dx,ax
    pop ax
    add ax,word ptr temp+4
    mov cx,0
    mov cx,255
    div cx                               ; in variabila 'x' si 'x0' continutul 
    mov x0, dx                                    ; termenului initial
    mov x,dx
    
    RET
ENCRYPT:
    mov si,offset nume
    mov ax,a
CALCUL_a:
    cmp byte ptr [si],20h
    je CALCUL_b
    mov bx,[si]
    mov bh,0
    add ax,bx
    add si,1
    mov a,ax
    jmp CALCUL_a
CALCUL_b:
    cmp byte ptr [si],0
    je END_a_b
    mov ax,b
    mov bx,[si]
    mov bh,0
    add ax,bx
    add si,1
    mov b,ax
    jmp CALCUL_b
END_a_b:
    mov ax,[a]
    mov dx,0
    mov cx,255
    div cx
    mov a,DX
    mov ax,[b]
    sub ax,20h
    mov dx,0
    mov cx,255
    div cx
    mov b,DX   
    MOV CX, [msglen]
    dec cx
    MOV SI, OFFSET message
    mov bx,[si]
    mov bh,0
    ; mov x0,13
    ; mov x,13
    ; mov a,104                       ;aici faceam modificarile pentru testarea temei
    ; mov b,200
    xor bx,x
    mov [si], byte ptr bl
    inc si
    
XORARE:                      
    call RAND                       ; TODO3: Completati subrutina ENCRYPT
    
    mov bx,[si]
    mov bh,0
    xor bx,x
    mov [si], byte ptr bl
    inc si
    
    LOOP XORARE
                                            ; astfel incat in cadrul buclei sa fie
                                            ; XOR-at elementul curent din sirul de
                                            ; intrare cu termenul corespunzator din
                                            ; sirul generat, iar mai apoi sa fie generat
                                            ; si termenul urmator
    RET
RAND:
    push cx
    MOV  AX, [x]
    mul a
    add ax,b
    mov cx,0
    mov cl,255
    div CX
    mov [x],dx
                                            ; TODO2: Completati subrutina RAND, astfel incat
                                            ; in cadrul acesteia va fi calculat termenul
                                            ; de rang n pe baza coeficientilor a, b si a 
                                            ; termenului de rang inferior (n-1) si salvat
                                            ; in cadrul variabilei 'x'

    pop cx
    RET
ENCODE:   
    mov si,offset message
    mov dx,0
    mov cx,0
    CODIFICARE:

        cmp cx,[msglen]
        mov iterations,dx
        je RETU
        jmp CONT
        RETU: 
            mov cx,[padding]
            mov ch,0
            cmp cx,0
            je NOT0
            ADD_Pad:
            mov si,offset encoded
            add si,dx
            mov [si],'+'
            inc dx
            loop ADD_Pad
            NOT0:
            mov iterations,dx
            RET
        CONT:
        mov ax,dX
        mov bl,4
        div bl
        cmp ah,0
        je OCT1
        cmp ah,1
        je OCT2
        cmp ah,2
        je OCT3
        jmp OCT4
        OCT1:
            mov bx,[si]
            push si
            mov bh,0
            sar bl,2
            and bl,63
            mov si,offset encoded
            add si,dx
            push cx
            push si
            mov si,OFFSET COD64
            mov bh,0
            add si,bx
            mov cl,byte ptr [si]
            pop si
            mov byte ptr [si],cl
            pop cx
            pop si
            inc dx
            jmp CODIFICARE
        OCT2:
            mov bx,[si]
            mov bh,0
            shl bl,4
            and bl,63
            inc si
            inc cx 
            mov bh,byte ptr [si]
            push si
            sar bh,4
            and bh,15
            or bl,bh
            mov si,offset encoded
            add si,dx
            push cx
            push si
            mov si,OFFSET COD64
            mov bh,0
            add si,bx
            mov cl,byte ptr [si]
            pop si
            mov byte ptr [si],cl
            pop cx
            pop si
            inc dx
            LOOPs:
            jmp CODIFICARE
        OCT3:
            mov bx,[si]
            mov bh,0
            shl bl,2
            and bl,60
            inc si
            inc cx
            mov bh,byte ptr [si]
            push si
            sar bh,6
            and bh,3
            or bl,bh
            mov si,offset encoded
            add si,dx
            push cx
            push si
            mov si,OFFSET COD64
            mov bh,0
            add si,bx
            mov cl,byte ptr [si]
            pop si
            mov byte ptr [si],cl
            pop cx
            pop si
            inc dx
        jmp LOOPs
            
        OCT4:
            mov bx,[si]
            mov bh,0
            and bl,63
            inc si
            push si
            mov si,offset encoded
            add si,dx
            push cx
            push si
            mov si,OFFSET COD64
            mov bh,0
            add si,bx
            mov cl,byte ptr [si]
            pop si
            mov byte ptr [si],cl
            pop cx
            pop si
            inc dx
            inc cx
         jmp LOOPs
                                            ; TODO4: Completati subrutina ENCODE, astfel incat
                                            ; in cadrul acesteia va fi realizata codificarea
                                            ; sirului criptat pe baza alfabetului COD64 mentionat                           ; in enuntul problemei si rezultatul va fi stocat
                                            ; in cadrul variabilei encoded
    
    RET
WRITE_HEX:
    MOV     DI, OFFSET temp + 2
    XOR     DX, DX
DUMP:
    MOV     DL, [SI]
    PUSH    CX
    MOV     CL, 4

    ROR     DX, CL
    
    CMP     DL, 0ah
    JB      print_digit1

    ADD     DL, 37h
    MOV     byte ptr [DI], DL
    JMP     next_digit

print_digit1:  
    OR      DL, 30h
    MOV     byte ptr [DI] ,DL
next_digit:
    INC     DI
    MOV     CL, 12
    SHR     DX, CL
    CMP     DL, 0ah
    JB      print_digit2

    ADD     DL, 37h
    MOV     byte ptr [DI], DL
    JMP     AGAIN

print_digit2:    
    OR      DL, 30h
    MOV     byte ptr [DI], DL
AGAIN:
    INC     DI
    INC     SI
    POP     CX
    LOOP    dump
    
    MOV     byte ptr [DI], 10
    RET
WRITE:
    MOV     SI, OFFSET x0
    MOV     CX, 1
    CALL    WRITE_HEX
    MOV     AH, 40h
    MOV     BX, [fileHandler]
    MOV     DX, OFFSET temp
    MOV     CX, 5
    INT     21h

    MOV     SI, OFFSET a
    MOV     CX, 1
    CALL    WRITE_HEX
    MOV     AH, 40h
    MOV     BX, [fileHandler]
    MOV     DX, OFFSET temp
    MOV     CX, 5
    INT     21H

    MOV     SI, OFFSET b
    MOV     CX, 1
    CALL    WRITE_HEX
    MOV     AH, 40h
    MOV     BX, [fileHandler]
    MOV     DX, OFFSET temp
    MOV     CX, 5
    INT     21H

    MOV     SI, OFFSET x
    MOV     CX, 1
    CALL    WRITE_HEX    
    MOV     AH, 40h
    MOV     BX, [fileHandler]
    MOV     DX, OFFSET temp
    MOV     CX, 5
    INT     21H

    MOV     SI, OFFSET message
    MOV     CX, [msglen]
    CALL    WRITE_HEX
    MOV     AH, 40h
    MOV     BX, [fileHandler]
    MOV     DX, OFFSET temp
    MOV     CX, [msglen]
    ADD     CX, [msglen]
    ADD     CX, 3
    INT     21h

    MOV     AX, iterations
    MOV     BX, 4
   ; MUL     BX
    MOV     CX, AX
    MOV     AH, 40h
    MOV     BX, [fileHandler]
    MOV     DX, OFFSET encoded
    INT     21H

    MOV     AH, 3EH                     ; BIOS Int - Close file
    MOV     BX, [fileHandler]           ; BX - File handler
    INT     21H
    RET
    END START