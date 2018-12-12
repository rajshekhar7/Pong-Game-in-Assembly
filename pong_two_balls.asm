    org 100h
    
    start:
       call cursorHide         ;hide the cursor
       call clearScreen        ;clears screen
       call drawPlayer         
       call drawBall
       call drawBall2
    
    main:
       call processInput       ;check for input, if exist get it
       call padColCheck        ;check collision with either paddle
       call moveBall           ;move ball according to postion and direction
        call padColCheck2
       call moveBalll
       call sleep              ;delay
       jmp main             ;looped


    endProgram:
       call cursorShow
       mov ax,0x4c00        ;   return to OS
       int 0x21             ;   

    processInput:
       mov ah,0x01          ;check for keystroke in key buffer
       int 0x16
       jz processInputEnd  ;if no keystroke available
    processInputGet:
       mov ah,0x00          ;get the keystroke from buffer
       int 0x16
       cmp al,0x1b          ;if ESC is pressed, end the program
       je endProgram
       cmp ah,0x48          ;if up arrow is pressed BIOS input
       je playerMoveUp
       cmp ah,0x50          ;if down arrow is pressed 
       je playerMoveDown
    processInputEnd:
       ret


    sleep:
       mov ah,0  ; function no for read
       int 1ah   ; get the time of day count
       add dx,1  ; add one half second delay to low word
       mov bx,dx ; store end of delay value in bx
    sleepLoop:
       int 1ah
       cmp dx,bx
       jne sleepLoop
       ret

    playerMoveUp:
       mov ch,[playerLoc]   ;get player paddle head
       cmp ch,0x01
       je playerMoveNull   ;if on the top, it cannot move
       dec ch               ;else go up, decrease since y increases downwards
       mov [playerLoc],ch   ;store new position
       call clearPlayer    ;clear the player(whole column)
       call drawPlayer     ;draw at new location
       ret

    playerMoveDown:
       mov ch,[playerLoc]   ;similar to above
       cmp ch,0x12
       je playerMoveNull
       inc ch
       mov [playerLoc],ch
       call clearPlayer
       call drawPlayer
    playerMoveNull:
       ret


    cursorShow:
       mov cx,0x0d0e
       mov ah,0x01
       int 0x10
       ret

    cursorHide:
       mov cx,0x2000
       mov ah,0x01
       int 0x10
       ret

    clearScreen:
       mov ah,0x06
       mov al,0x00
       mov bh,0x07
       mov cx,0x0000
       mov dl,0x79
       mov dh,0x24
       int 0x10
       mov bx,0x0000
       mov [curX],bx
       mov [curY],bx
       call setCur
       ret

    setCur:
       mov ah,0x02      ;set new cursor location
       mov bh,0x00
       mov dl,[curX]
       mov dh,[curY]
       int 0x10
       ret

    drawPlayer:
        mov cl,0x00              ;get position
        mov ch,[playerLoc]       ;since x coordinate is always zero, only y changes
        mov [curX],cl
        mov bl, 0x05
        jmp drawPlayerloop

    drawPlayerloop:
        inc ch
        mov [curY],ch    ;go down and draw again
        call setCur
        mov ah,0x02
        mov dl,0xb3
        int 0x21
        dec bl
        cmp bl, 0
        jne drawPlayerloop
        ret


    drawBall:
       mov cl,[ballLoc+1]
       mov ch,[ballLoc]
       mov [curX],cl
       mov [curY],ch
       call setCur
       mov ah,0x02
       mov dl,0x2a      ; ascii-> 2Ah = '*' 
       int 0x21
       ret
    
    drawBall2:
       mov cl,[ballLoc2+1]
       mov ch,[ballLoc2]
       mov [curX],cl
       mov [curY],ch
       call setCur
       mov ah,0x02
       mov dl,0x2a      ; ascii-> 2Ah = '*' 
       int 0x21
       ret

    moveBall:
       mov cl,[ballLoc+1]
       mov ch,[ballLoc]
       mov [curX],cl
       mov [curY],ch
       call setCur
       mov ah,0x02
       mov dl,0x20 ; 0x20 = 32 = ascii - 'space; 
       int 0x21 ;previous location is deleted
       mov al,[ballDirection]   
       cmp al,0x01  ;if ball is moving in 01 direction
       je near moveBall1    
       cmp al,0x02      
       je near moveBall2
       cmp al,0x03
       je near moveBall3
       cmp al,0x04
       je near moveBall4
    

    moveBall1:
       mov ax, [ballLoc]
       cmp ah,0x01             ;if x-axis is 01, end game
       je near gameOver
       cmp al,0x02              ;check hit on upper surface
       je near setBallDirection4    ;if true change direction to 04
       dec al
       dec ah
       mov [ballLoc], ax
       call drawBall
       ret

    moveBall2:
       mov ax, [ballLoc]
       cmp ah,0x4f      ;if x axis is 4Fh, end game(right end)
       je near setBallDirection1
       cmp al,0x01              ; check hit on upper surface
       je near setBallDirection3    ; if yes, change dirn to 03
       inc ah
       dec al
       mov [ballLoc], ax
       call drawBall
       ret

    moveBall3:
       mov ax, [ballLoc]
       cmp ah,0x4f      ; if x-axis is 4Fh, end game(right end)
       je near setBallDirection4
       cmp al,0x17              ;check hit on lower surface
       je near setBallDirection2    ;if yes, change diren to 02
       inc ah
       inc al
       mov [ballLoc], ax
       call drawBall
       ret

    moveBall4:
       mov ax, [ballLoc]
       cmp ah,0x01  ;if x-axis is 1h ,end game (left end)
       je near gameOver
       cmp al,0x17              ;check hit on lower surface
       je near setBallDirection1    ;if yes, change dir to 01
       dec ah
       inc al
       mov [ballLoc], ax
       call drawBall
       ret

    moveBalll:
       mov cl,[ballLoc2+1]
       mov ch,[ballLoc2]
       mov [curX],cl
       mov [curY],ch
       call setCur
       mov ah,0x02
       mov dl,0x20 ; 0x20 = 32 = ascii - 'space; 
       int 0x21 ;previous location is deleted
       mov al,[ballDirection2]   
       cmp al,0x01  ;if ball is moving in 01 direction
       je moveBall21    
       cmp al,0x02      
       je near moveBall22
       cmp al,0x03
       je near moveBall23
       cmp al,0x04
       je near moveBall24
    moveBall21:
       mov ax, [ballLoc2]
       cmp ah,0x01             ;if x-axis is 01, end game
       je near gameOver
       cmp al,0x02              ;check hit on upper surface
       je near setBallDirection24    ;if true change direction to 04
       dec al
       dec ah
       mov [ballLoc2], ax
       call drawBall2
       ret

    moveBall22:
       mov ax, [ballLoc2]
       cmp ah,0x4f      ;if x axis is 4Fh, end game(right end)
       je setBallDirection21
       cmp al,0x01              ; check hit on upper surface
       je setBallDirection23    ; if yes, change dirn to 03
       inc ah
       dec al
       mov [ballLoc2], ax
       call drawBall2
       ret

    moveBall23:
       mov ax, [ballLoc2]
       cmp ah,0x4f      ; if x-axis is 4Fh, end game(right end)
       je setBallDirection24
       cmp al,0x17              ;check hit on lower surface
       je setBallDirection22    ;if yes, change diren to 02
       inc ah
       inc al
       mov [ballLoc2], ax
       call drawBall2
       ret

    moveBall24:
       mov ax, [ballLoc2]
       cmp ah,0x01  ;if x-axis is 1h ,end game (left end)
       je near gameOver
       cmp al,0x17              ;check hit on lower surface
       je setBallDirection21    ;if yes, change dir to 01
       dec ah
       inc al
       mov [ballLoc2], ax
       call drawBall2
       ret

    setBallDirection1:
       mov al,0x01
       mov [ballDirection],al
       call drawBall
       ret
    setBallDirection2:
       mov al,0x02
       mov [ballDirection],al
       call drawBall
       ret
    setBallDirection3:
       mov al,0x03
       mov [ballDirection],al
       call drawBall
       ret
    setBallDirection4:
       mov al,0x04
       mov [ballDirection],al
       call drawBall
       ret
    
    setBallDirection21:
       mov al,0x01
       mov [ballDirection2],al
       call drawBall2
       ret
    setBallDirection22:
       mov al,0x02
       mov [ballDirection2],al
       call drawBall2
       ret
    setBallDirection23:
       mov al,0x03
       mov [ballDirection2],al
       call drawBall2
       ret
    setBallDirection24:
       mov al,0x04
       mov [ballDirection2],al
       call drawBall2
       ret

    padColCheck:
       mov ax, [ballLoc]
       cmp ah,0x1           ;if ball is on left side
       je padColCheck1
       ret

    padColCheck1:
        mov bl, [playerLoc]
        cmp al,bl            ;if ball is touching head of played
        je bouncePlayer
        mov ch, 0x06

    padColCheckLoop:
        inc bl
        cmp al,bl            ;if ball is touching lower of player2 paddle
        je bouncePlayer
        dec ch
        cmp ch, 0
        jne padColCheckLoop
        ret


    padColCheck2:
       mov ax, [ballLoc2]
       cmp ah,0x1           ;if ball is on left side
       je padColCheck21
       ret

    padColCheck21:
        mov bl, [playerLoc]
        cmp al,bl            ;if ball is touching head of played
        je bouncePlayer2
        mov ch, 0x06

    padColCheckLoop2:
        inc bl
        cmp al,bl            ;if ball is touching lower of player2 paddle
        je bouncePlayer2
        dec ch
        cmp ch, 0
        jne padColCheckLoop2
        ret


    bouncePlayer:
       mov al,[ballDirection]
       cmp al,0x01              ;if ball direction is 01, change it to 02
       je setBallDirection2
       cmp al,0x04              ;if ball direction is 04, change it to 03
       je setBallDirection3
       ret


    bouncePlayer2:
       mov al,[ballDirection2]
       cmp al,0x01              ;if ball direction is 01, change it to 02
       je setBallDirection22
       cmp al,0x04              ;if ball direction is 04, change it to 03
       je setBallDirection23
       ret

    clearPlayer:
       mov ch,0x00          ;start from upper row
       mov cl,0x27
       call clearPlayerLoop
       ret
    clearPlayerLoop:
       mov ah,0x02      ;           set cursor
       mov bh,0x00      ;
       mov dh,ch        ;       dh - row
       mov dl,0x00      ;       dl - column
       int 0x10         
       mov ah,0x02      ;           write char
       mov dl,0x20      ;       0x20 = 32 = space char(clear)
       int 0x21         ;
       inc ch           
       cmp ch,0x18              ; go till the last row
       jne clearPlayerLoop
       ret

    gameOver:
       call clearScreen
       mov ah,0x09
       mov dx,gameOver1
       int 0x21
       jmp endProgram

    section data
       curX db 0x00
       curY db 0x00
       borderSymbols db 0xb0,0xb0,'$'
       playerLoc db 0x0a
       ballLoc2 db 0x0b,0x27
       ballDirection2 db 0x03
       ballLoc db 0x0b,0x27
       ballDirection db 0x01
       gameOver1 db 'Game over!$'
