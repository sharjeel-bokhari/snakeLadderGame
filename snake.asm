[org 0x0100]

jmp start

    titleAndCredits:
        push bp
        mov bp, sp
        sub sp, 2
        
        push ax
        push bx
        push cx
        push dx
        push di
        push si

        mov di, 0
        mov ax, 0xb800
        mov es, ax

        loop1:
            mov word [es : di],  0x0720
            add di, 2
            cmp di, 4000
            jne loop1

        mov si, [bp + 12]
        mov ax, 0
        mov [bp - 2], ax
        mov ax, 0xb800
        mov es, ax
        mov di, 164
        mov ah, 0x01
        
        loop4:
            mov al, [si]
            mov [es : di], ax

            cmp di, 312
            jb firstLine
            je norm

                cmp di, 3684
                jae firstLine
                jmp border
            
            firstLine:
                cmp di, 3832
                je norm
                    add di, 4
                    jmp skip1
            
            norm:
                add di, 2
                jmp skip1

            border:
                mov dx, [bp - 2]
                cmp dx, 1
                je skip

                    add di, 10
                    mov dx, 1
                    mov [bp - 2], dx
                    jmp skip1

            skip:
            
                add di, 150
                mov dx, 0
                mov [bp - 2], dx
            
            skip1:
                cmp di, 3838
                jne loop4


        mov si, [bp + 4]
        xor cx, cx

        mov di, 220
        mov ah, 0xc0

        loop2:
            mov al, [si]
            mov word [es : di], ax
            add di, 2
            inc si
            inc cx
            cmp cx, [bp + 6]
            jne loop2
        
        mov di, 3696
        mov cx, 0
        mov ax, 0xb800
        mov es, ax
        mov si, [bp + 8]
        mov ah, 0xc0

        loop3:
            mov al, [si]
            mov [es : di], ax
            inc si
            add di, 2
            inc cx
            cmp cx, [bp + 10]
            jne loop3
        

        pop si
        pop di
        pop dx
        pop cx
        pop bx
        pop ax
        add sp, 2
        pop bp

    ret 10

    printUsers:
        push bp
        mov bp, sp

        push es
        push ax
        push bx
        push cx
        push dx
        push di
        push si
        
        mov ax, 0xb800
        mov es, ax

        xor cx, cx
        mov si, [bp + 4]                ;the text
        mov di, [bp + 8]                ;the position to print it
        mov ah, 0x07

        hello1:
            mov al, [si]
            mov [es : di], ax
            inc si
            inc cx
            add di, 2
            cmp cx, [bp + 6]            ;the length of text
            jne hello1

        pop si
        pop di
        pop dx
        pop cx
        pop bx
        pop ax
        pop es
        pop bp
    ret 6


    printScore:
        push bp
        mov bp, sp
        
        push es
        push ax
        push bx
        push cx
        push dx
        push di

        mov ax, [bp + 4]                ;the number to print
        mov bx, 10
        mov cx, 0

        hello2:
            mov dx, 0
            div bx
            add dl, 0x30
            push dx
            inc cx
            cmp ax, 0
            jnz hello2
        
        mov ax, 0xb800
        mov es, ax
        mov di, [bp + 6]                ;location where it should print number

        hello3:
            pop dx
            mov dh, 0x07
            mov [es : di], dx
            add di, 2
            loop hello3
        
        pop di
        pop dx
        pop cx
        pop bx
        pop ax
        pop es
        pop bp
    
    ret 4

    switchTurn:
        push bp
        mov bp, sp

        push ax
        push bx
        push cx
        push dx
        push di
        push si

        mov ax, [flag]
        cmp ax, 0
        jne otherPlayer
            
            mov ax, 1970
            push ax

            mov ax, [promptlen]
            push ax

            mov ax, prompt              ;print "press any key..."
            push ax

            call printUsers

                mov ah, 0x1                 ;take input
                int 21h

            mov ax, 1970
            push ax

            mov ax, [promptlen]         ;erase "press any key..." prompt
            push ax

            call clearLine

            call delay

            mov ax, 2156
            push ax

            mov ax, 12
            push ax

            call clearLine
            
            call getDiceNum

            mov ax, [addScore]
            mov si, [player1Score]
            add si, ax
            cmp si, 100
            ja skipp                          ;check if the dice number doesn't increment above a 100

                add [player1Score], ax            ;player1 score

                call snakeOrLadder

            skipp:
                call delay

                mov ax, 2156
                push ax

                mov ax, 12
                push ax

                call clearLine

                mov ax, 1
                mov [flag], ax                    ;give turn over to player2

                mov ax, 534                       ;the location to print it at
                push ax

                mov ax, [player1Score]            ;player1 score passed as paramter
                push ax

                call printScore

                jmp endSubroutine

        otherPlayer:

            mov ax, 1970
            push ax

            mov ax, [promptlen]
            push ax

            mov ax, prompt
            push ax

            call printUsers  

            mov ah, 0x1                 ;take input
            int 21h

            mov ax, 1970
            push ax

            mov ax, [promptlen]
            push ax

            call clearLine

            call delay

            mov ax, 2156
            push ax

            mov ax, 12
            push ax

            call clearLine              ;prompt is cleared after key press
            
            call getDiceNum

            mov ax, [addScore]
            mov si, [player2Score]
            add si, ax
            cmp si, 100
            ja skipp1

                add [player2Score], ax            ;player2 score

                call snakeOrLadder
            
            skipp1:
                call delay

                mov ax, 2156
                push ax

                mov ax, 12
                push ax

                call clearLine

                mov ax, 0   
                mov [flag], ax                    ;give turn to player1

                mov ax, 694
                push ax

                mov ax, [player2Score]            ;player2 score passed as parameter
                push ax

                call printScore
            
        endSubroutine:

            pop si
            pop di
            pop dx
            pop cx
            pop bx
            pop ax
            pop bp

    ret

    getDiceNum:
        push ax
        push bx
        push cx
        push dx
        push si

        mov ah, 2ch
        int 21h

        mov ch, 0x0
        push cx

        call changeRandom
        
        mov al, cl
        mov bx, 7
        xor dx, dx
        div bx

        cmp dx, 0
        ja sendNum
            inc dx
        sendNum:
            mov [addScore], dx
        
        mov ax, 628
        push ax

        push dx

        call printScore
        
        pop si
        pop dx
        pop cx
        pop bx
        pop ax

    ret

    runGame:
        push ax
        push bx
        push cx
        push dx
        
        mov ax, [flag]
        cmp ax, 0
        jne next
            mov ax, 650
            push ax

            mov ax, [frameLen]
            push ax

            call clearLine

            mov ax, 490
            push ax

            mov ax, [frameLen]
            push ax

            mov ax, frame
            push ax
        
            call printUsers
            jmp next1

        next:
            mov ax, 490
            push ax

            mov ax, [frameLen]
            push ax

            call clearLine

            mov ax, 650
            push ax

            mov ax, [frameLen]
            push ax

            mov ax, frame
            push ax
        
            call printUsers
            jmp next1

        next1:
        call switchTurn

        mov bx, 100
        cmp [player1Score], bx
        jne winPlayer2
        
            mov ax, 2000
            push ax

            mov ax, [winPmptLen]
            push ax

            mov ax, winPmpt
            push ax

            call printUsers
            jmp ends

        winPlayer2:
            mov dx, 100
            cmp [player2Score], dx
            jne nextcompare

                mov ax, 2000
                push ax

                mov ax, [winPmptLen2]
                push ax

                mov ax, winPmpt2
                push ax

                call printUsers
                jmp ends
        nextcompare:
            call runGame
            
        ends:

            pop dx
            pop cx
            pop bx
            pop ax
    ret

    clearLine:
        push bp
        mov bp, sp

        push ax
        push bx
        push cx
        push dx
        push di
        
        mov ax, 0xb800
        mov es, ax
        xor cx, cx
        mov di, [bp + 6]

        reoccur:
            mov ax, 0x720
            mov [es : di], ax
            add di, 2
            inc cx
            cmp cx, [bp + 4]
            jne reoccur
        
        pop di
        pop dx
        pop cx
        pop bx
        pop ax
        pop bp

    ret 4

    delay:
        push bp
        mov bp, sp
        push ax
        push bx
        push cx
        push dx
        push di

        mov bx, 0
        
        mov ax, 0xb800
        mov es, ax
        mov di, 2156

        looping:

            mov ah, 0x07
            mov al, [frame]
            mov [es : di], ax

            mov ax, 9
            d:
                mov cx, 255
                d1:
                    mov dx, 0
                d2:
                    inc dx
                    cmp dx, 255
                    jne d2
                checkCx:
                    dec cx
                    cmp cx, 0
                    jne d1
            
            dec ax
            cmp ax, 0
            jne d
            
            add di, 4
            inc bx
            cmp bx, 3
            jne looping
        
        pop di
        pop dx
        pop cx
        pop bx
        pop ax
        pop bp
    
    ret

    changeRandom:
        push bp
        mov bp, sp
        push ax
        push bx
        push di
        push dx

        mov di, [index]
        mov ax, [bp + 4]
        mul word [random + di]
        
        mov cx, ax     ;return value
        cmp di, 6
        jnz restart
            
            mov bx, 0
            loop10:
                mov ax, [random + bx]
                inc ax
                mov [random + bx], ax
                add bx, 2
                cmp bx, 6
                jnz loop10

           mov word[index], 0
        restart:
            add word[index],2

        pop dx
        pop di
        pop bx
        pop ax
        pop bp
    ret 2

    snakeOrLadder:
        push bp
        mov bp, sp

        push ax
        push bx
        push cx
        push dx

        mov cx, 0
        mov bx, 0
        mov ax, [flag]
        cmp ax, 0
        jne newPlayer              ;player2

            osman:
                mov ax, [ladderArr + bx]
                cmp ax, [player1Score]
                jne stepIn

                    mov dx, [ladderInc + bx]
                    mov [player1Score], dx
                        call promptsPrintLadder

                    jmp ending1

                stepIn:
                    add bx, 2
                    inc cx
                    cmp cx, 3
                    jne osman
            
            mov cx, 0
            mov bx, 0
            nikola:
                mov ax, [snakeArr + bx]
                cmp ax, [player1Score]
                jne stepIn3

                    mov dx, [snakeDec + bx]
                    mov [player1Score], dx
                    call promptsPrintSnake

                    jmp ending1

                stepIn3:
                    add bx, 2
                    inc cx
                    cmp cx, 3
                    jne nikola

        newPlayer:
            mov cx, 0
            mov bx, 0
            osman1:
                mov ax, [ladderArr + bx]
                cmp ax, [player2Score]
                jne stepIn1

                    mov dx, [ladderInc + bx]
                    mov [player2Score], dx

                        mov ax, 1970
                        push ax

                        mov ax, [ladderLen]
                        push ax

                        mov ax, ladder
                        push ax

                        call printUsers                 ;prompt display
                        
                        call delay                      ;delay called
                        
                        mov ax, 1970
                        push ax

                        mov ax, [ladderLen]
                        push ax

                        call clearLine                  ;prompt erased

                        mov ax, 2156
                        push ax

                        mov ax, 12
                        push ax

                        call clearLine                  ;delay erased
                        
                        mov ax, 694
                        push ax

                        mov ax, 4
                        push ax

                        call clearLine                  ;score erased
                    
                        mov ax, 694
                        push ax

                        mov ax, [player2Score]
                        push ax

                        call printScore                 ;score display

                    jmp ending1

                stepIn1:
                    add bx, 2
                    inc cx
                    cmp cx, 3
                    jne osman1
            
            mov cx, 0
            mov bx, 0
            nikola1:
                mov ax, [snakeArr + bx]
                cmp ax, [player2Score]
                jne stepIn2

                    mov dx, [snakeDec + bx]
                    mov [player2Score], dx
                        
                        mov ax, 1970
                        push ax

                        mov ax, [snakePromptLen]
                        push ax

                        mov ax, snakePrompt
                        push ax

                        call printUsers                 ;prompt display
                        
                        call delay                      ;delay called
                        
                        mov ax, 1970
                        push ax

                        mov ax, [snakePromptLen]
                        push ax

                        call clearLine                  ;prompt erased

                        mov ax, 2156
                        push ax

                        mov ax, 12
                        push ax

                        call clearLine                  ;delay erased

                        mov ax, 694
                        push ax

                        mov ax, 4
                        push ax

                        call clearLine                  ;score erased
                    
                        mov ax, 694
                        push ax

                        mov ax, [player2Score]
                        push ax

                        call printScore                 ;score display
                    jmp ending1

                stepIn2:
                    add bx, 2
                    inc cx
                    cmp cx, 3
                    jne nikola1

        ending1:
            pop dx
            pop cx
            pop bx
            pop ax
            pop bp

    ret

    promptsPrintLadder:
        mov ax, 1970
        push ax

        mov ax, [ladderLen]
        push ax

        mov ax, ladder
        push ax

        call printUsers                 ;prompt display
        
        call delay                      ;delay called
        
        mov ax, 1970
        push ax

        mov ax, [ladderLen]
        push ax

        call clearLine                  ;prompt erased

        mov ax, 2156
        push ax

        mov ax, 12
        push ax

        call clearLine                  ;delay erased

        mov ax, 534
        push ax

        mov ax, 4
        push ax

        call clearLine                  ;score erased

        mov ax, 534
        push ax

        mov ax, [player1Score]
        push ax

        call printScore                 ;score display
    ret

    promptsPrintSnake:
        mov ax, 1970
        push ax

        mov ax, [snakePromptLen]
        push ax

        mov ax, snakePrompt
        push ax

        call printUsers                 ;prompt display
        
        call delay                      ;delay called
        
        mov ax, 1970
        push ax

        mov ax, [snakePromptLen]
        push ax

        call clearLine                  ;prompt erased

        mov ax, 2156
        push ax

        mov ax, 12
        push ax

        call clearLine                  ;delay erased

        mov ax, 534
        push ax

        mov ax, 6
        push ax

        call clearLine                  ;score erased
    
        mov ax, 534
        push ax

        mov ax, [player1Score]
        push ax

        call printScore                 ;score display
    ret

    displaySnkLdrValues:
        push bp
        mov bp, sp

        push ax
        push bx
        push cx
        push dx
        push si
        push di

        mov ax, 970
        push ax

        mov ax, [ldrValLen]
        push ax

        mov ax, ladderVal
        push ax

        call printUsers
        
        mov bx, 0
        mov cx, 1138
        mov dx, 0
        
        ldrPrint:
            mov ax, [ladderArr + bx]
            push cx

            push ax

            call printScore

            add cx, 160
            add bx, 2
            inc dx
            cmp dx, 3
            jne ldrPrint
        
        mov ax, 1010
        push ax

        mov ax, [snkValLen]
        push ax

        mov ax, snakeVal
        push ax

        call printUsers

        mov bx, 0
        mov cx, 1178
        mov dx, 0
        
        snkPrint:
            mov ax, [snakeArr + bx]
            push cx

            push ax

            call printScore

            add cx, 160
            add bx, 2
            inc dx
            cmp dx, 3
            jne snkPrint

        pop di
        pop si
        pop dx
        pop cx
        pop bx
        pop ax
        pop bp
    ret

    title: db "The Snake Ladder Game"    
    length: dw $ - title
    crtdby: db "Created By:", 0x0
    name1:  db "Sharjeel Hussain Bokhari,", 0x0
    name2:  db "Farhan Ali and",    0x0
    name3:  db "Qalandar Ali"
    creditLength: dw $ - crtdby
    frame:  db '*'
    frameLen:   dw  $ - frame
    playerName1:    db "Player 1:   "
    len1:   dw $ - playerName1
    playerName2:    db "Player 2:   "
    len2:   dw $ - playerName2

    winPmpt:    db  "-------Player 1 Wins-------"
    winPmptLen:     dw  $ - winPmpt

    winPmpt2:   db "--------Player2 Wins--------"
    winPmptLen2:    dw  $ - winPmpt2

    dice:   db  "Dice Number:  "
    diceLen:    dw $ - dice

    prompt: db  "Press any Key to Roll The Dice"
    promptlen:  dw  $ - prompt

    snakePrompt:    db  "S N A K E !"
    snakePromptLen: dw  $ - snakePrompt

    ladder: db  "CLIMB THE LADDER!"
    ladderLen:  dw  $ - ladder

    snakeVal:   db  "Snakes:    "
    snkValLen:  dw  $ - snakeVal

    ladderVal:  db  "Ladders:    "
    ldrValLen:  dw  $ - ladderVal

    player1Score:   dw  00
    player2Score:   dw  00
    addScore:   dw  00
    flag:   dw    0
    random: dw 42,13,17,18
    index:  dw 0
    snakeArr:   dw  19, 54, 98
    ladderArr:  dw  12, 48, 80
    snakeDec:   dw  07, 24, 38
    ladderInc:  dw  31, 55, 92

start:
    mov ax, frame
    push ax

    mov ax, [creditLength]
    push ax

    mov ax, crtdby
    push ax

    mov ax, [length]
    push ax

    mov ax, title
    push ax

    call titleAndCredits

    mov ax, 494
    push ax

    mov ax, [len1]
    push ax

    mov ax, playerName1
    push ax

    call printUsers

    mov ax, 654
    push ax

    mov ax, [len2]
    push ax

    mov ax, playerName2
    push ax

    call printUsers

    mov ax, 600
    push ax

    mov ax, [diceLen]
    push ax

    mov ax, dice
    push ax

    call printUsers

    call displaySnkLdrValues

    call runGame
    
    mov ah, 0x1
    int 0x21

mov ax, 0x4c00
int 0x21