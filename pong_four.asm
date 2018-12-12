org 100h

start:
    call hideCursor         ;hide the cursor
    call clearScreen        ;clears screen
    call drawplayer1      ; size -7   
    call drawplayer2    ; size -7
    call drawPlayer3    
    call drawPlayer4
    call drawBall

main:
    call processInput       ;check for input, if exist get it
    call padColCheck        ;check collision with either paddle
    call moveBall           ;move ball according to postion and direction
    call sleep              ;delay
    jmp main             ;looped

endProgram:
    call cursorShow
    mov ax,4c00h        ;   return to OS
    int 21h             ;   

processInput:
    mov ah,01h          ;check for keystroke in key buffer
    int 16h
    jz processInputEnd  ;if no keystroke available
processInputGet:
    mov ah,00h          ;get the keystroke from buffer
    int 16h
    cmp al, 1bh
    je near gameStopped
    cmp al,77h          ;if up arrow is pressed BIOS input
    je player1MoveUp
    cmp al,57h          ;if up arrow is pressed BIOS input
    je player1MoveUp
    cmp al,73h          ;if down arrow is pressed 
    je player1MoveDown
    cmp al,53h          ;if down arrow is pressed 
    je player1MoveDown
    cmp ah, 48h         ;right arrow
    je player2MoveUp        ;if right arrow player2 moves up
    cmp ah, 50h         ;left arrow
    je player2MoveDown      ;if left arrow player2 moves down
    cmp ah, 4dh ;RIGHT ARROW
    je  near player4MoveRight
    cmp ah, 4bh ;left arrow
    je near player4MoveLeft
    cmp al, 61h
    je near player3MoveLeft
    cmp al, 41h
    je near player3MoveLeft
    cmp al, 64h
    je near player3MoveRight
    cmp al, 44h
    je near player3MoveRight


processInputEnd:
    ret

sleep:
    mov ah,0  ; function no for read
    int 1ah   ; get the time of day count
    add dx,4  ; add one half second delay to low word
    mov bx,dx ; store end of delay value in bx
sleepLoop:
    int 1ah
    cmp dx,bx
    jne sleepLoop
    ret

player1MoveUp:
    mov ch,[player1Loc]   ;get player1 paddle head
    cmp ch,0x01
    je player1MoveNull   ;if on the top, it cannot move
    dec ch               ;else go up, decrease since y increases downwards
    mov [player1Loc],ch   ;store new position
    call clearplayer1    ;clear the player1(whole column)
    call drawplayer1     ;draw at new location
    ret

player1MoveDown:
    mov ch,[player1Loc]   ;similar to above
    cmp ch,0x11
    je player1MoveNull
    inc ch
    mov [player1Loc],ch
    call clearplayer1
    call drawplayer1
player1MoveNull:
    ret

player2MoveUp:
    mov ch,[player2Loc]      
    cmp ch,0x01
    je player2MoveNull
    dec ch
    mov [player2Loc],ch
    call clearplayer2
    call drawplayer2
    ret

player2MoveDown:
    mov ch,[player2Loc]
    cmp ch,0x11
    je player2MoveNull
    inc ch
    mov [player2Loc],ch
    call clearplayer2
    call drawplayer2
player2MoveNull:
    ret

player3MoveRight:
    mov ch,[player3Loc]      
    cmp ch,0x2f
    je player3MoveNull
    inc ch
    mov [player3Loc],ch
    call clearPlayer3
    call drawPlayer3
    ret

player3MoveLeft:
    mov ch,[player3Loc]
    cmp ch,0x01
    je player3MoveNull
    dec ch
    mov [player3Loc],ch
    call clearPlayer3
    call drawPlayer3
player3MoveNull:
    ret

player4MoveRight:
    mov ch,[player4Loc]      
    cmp ch,0x2f
    je player4MoveNull
    inc ch
    mov [player4Loc],ch
    call clearPlayer4
    call drawPlayer4
    ret

player4MoveLeft:
    mov ch,[player4Loc]
    cmp ch,0x01
    je player4MoveNull
    dec ch
    mov [player4Loc],ch
    call clearPlayer4
    call drawPlayer4
player4MoveNull:
    ret


cursorShow:
    mov cx,0x0d0e
    mov ah,0x01
    int 0x10
    ret

hideCursor:
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


drawplayer1:
    mov cl,0x00              ;get position
    mov ch,[player1Loc]       ;since x coordinate is always zero, only y changes
    mov [curX],cl
    mov bl, 0x05
    jmp drawPlayer1loop

drawPlayer1loop:
    inc ch
    mov [curY],ch    ;go down and draw again
    call setCur
    mov ah,0x02
    mov dl,0xb3
    int 0x21
    dec bl
    cmp bl, 0
    jne drawPlayer1loop
    ret

drawplayer2:
    mov cl,0x4f      ;similar as above
    mov ch,[player2Loc]
    mov [curX],cl
    mov bl, 0x05
    jmp drawPlayer2loop

drawPlayer2loop:
    inc ch
    mov [curY],ch
    call setCur
    mov ah,0x02
    mov dl,0xb3
    int 0x21
    dec bl
    jne drawPlayer2loop

drawPlayer3:
    mov cl,0x00      ;similar as above
    mov ch,[player3Loc]
    mov [curY],cl
    mov bl, 0x1f
    jmp drawPlayer3loop

drawPlayer3loop:
    inc ch
    mov [curX],ch
    call setCur
    mov ah,0x02
    mov dl,0x3d
    int 0x21
    dec bl
    jne drawPlayer3loop


drawPlayer4:
    mov cl,0x18      ;similar as above
    mov ch,[player4Loc]
    mov [curY],cl
    mov bl, 0x1f
    jmp drawPlayer4loop

drawPlayer4loop:
    inc ch
    mov [curX],ch
    call setCur
    mov ah,0x02
    mov dl,0x3d
    int 0x21
    dec bl
    jne drawPlayer4loop

drawBall:
    mov cl,[ballLoc+1]
    mov ch,[ballLoc]
    mov [curX],cl
    mov [curY],ch
    call setCur
    mov ah,0x02
    mov dl,0x6f      ; ascii-> 2Ah = '*' 
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
    je moveBall1    
    cmp al,0x02      
    je moveBall2
    cmp al,0x03
    je moveBall3
    cmp al,0x04
    je moveBall4

moveBall1:
    mov ax, [ballLoc]
    cmp ah,0x00             ;if x-axis is 01, end game
    je near gameOver
    cmp al,0x00              ;check hit on upper surface
    je near gameOver    ;if true change direction to 04
    dec al
    dec ah
    mov [ballLoc], ax
    call drawBall
    ret

moveBall2:
    mov ax, [ballLoc]
    cmp ah,0x4f      ;if x axis is 4Fh, end game(right end)
    je near gameOver
    cmp al,0x00              ; check hit on upper surface
    je near gameOver    ; if yes, change dirn to 03
    inc ah
    dec al
    mov [ballLoc], ax
    call drawBall
    ret

moveBall3:
    mov ax, [ballLoc]
    cmp ah,0x4f      ; if x-axis is 4Fh, end game(right end)
    je near gameOver
    cmp al,0x18              ;check hit on lower surface
    je near gameOver    ;if yes, change diren to 02
    inc ah
    inc al
    mov [ballLoc], ax
    call drawBall
    ret

moveBall4:
    mov ax, [ballLoc]
    cmp ah,0x00  ;if x-axis is 1h ,end game (left end)
    je near gameOver
    cmp al,0x18              ;check hit on lower surface
    je near gameOver    ;if yes, change dir to 01
    dec ah
    inc al
    mov [ballLoc], ax
    call drawBall
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

padColCheck:
    mov ax, [ballLoc]
    cmp ah,0x01           ;if ball is on left side
    je padColCheck1
    cmp ah,0x4e          ;if ball is on right side
    je padColCheck2
    cmp al, 0x01
    je padColCheck3
    cmp al, 0x17
    je padColCheck4
    ret

padColCheck1:
    mov bl, [player1Loc]
    cmp al,bl            ;if ball is touching head of played
    je bounceplayer1
    mov ch, 0x06

padColCheck1Loop:
    inc bl
    cmp al,bl            ;if ball is touching lower of player2 paddle
    je bounceplayer1
    dec ch
    cmp ch, 0
    jne padColCheck1Loop
    ret


padColCheck2:
    mov bl, [player2Loc]
    cmp al,bl            ;if ball is touching head of player2 paddle
    je bounceplayer2
    mov ch, 0x06

padColCheck2Loop:
    inc bl
    cmp al,bl            ;if ball is touching lower of player2 paddle
    je bounceplayer2
    dec ch
    cmp ch, 0
    jne padColCheck2Loop
    ret

padColCheck3:
    mov bl, [player3Loc]
    cmp ah,bl            ;if ball is touching head of player2 paddle
    je bounceplayer3
    mov ch, 0x1f

padColCheck3Loop:
    inc bl
    cmp ah,bl            ;if ball is touching lower of player2 paddle
    je bounceplayer3
    dec ch
    cmp ch, 0
    jne padColCheck3Loop
    ret


padColCheck4:
    mov bl, [player4Loc]
    cmp ah,bl            ;if ball is touching head of player2 paddle
    je bounceplayer4
    mov ch, 0x1f

padColCheck4Loop:
    inc bl
    cmp ah,bl            ;if ball is touching lower of player2 paddle
    je bounceplayer4
    dec ch
    cmp ch, 0
    jne padColCheck4Loop
    ret


bounceplayer1:
    mov al,[ballDirection]
    cmp al,0x01              ;if ball direction is 01, change it to 02
    je setBallDirection2
    cmp al,0x04              ;if ball direction is 04, change it to 03
    je setBallDirection3
    ret

bounceplayer2:
    mov al,[ballDirection]
    cmp al,0x02              ;if ball direction is 02, change it to 01
    je setBallDirection1
    cmp al,0x03              ;if ball direction is 03, change it to 04
    je setBallDirection4
    ret

bounceplayer3:
    mov al,[ballDirection]
    cmp al,0x02              ;if ball direction is 02, change it to 01
    je setBallDirection3
    cmp al,0x01              ;if ball direction is 03, change it to 04
    je setBallDirection4
    ret

bounceplayer4:
    mov al,[ballDirection]
    cmp al,0x04              ;if ball direction is 02, change it to 01
    je setBallDirection1
    cmp al,0x03              ;if ball direction is 03, change it to 04
    je setBallDirection2
    ret

clearplayer1:
    mov ch,0x00          ;start from upper row
    mov cl,0x27
    call clearplayer1Loop
    ret
clearplayer1Loop:
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
    jne clearplayer1Loop
    ret

clearplayer2:
    mov ch,0x00          ; start from upper row
    mov cl,0x27
    call clearplayer2Loop
    ret
clearplayer2Loop:
    mov ah,0x02      
    mov bh,0x00      
    mov dh,ch
    mov dl,0x4f
    int 0x10
    mov ah,0x02
    mov dl,0x20
    int 0x21
    inc ch
    cmp ch,0x18
    jne clearplayer2Loop
    ret

clearPlayer3:
    mov ch,0x00          ; start from upper row
    mov cl,0x00
    call clearPlayer3Loop
    ret
clearPlayer3Loop:
    mov ah,0x02      
    mov bh,0x00      
    mov dl,cl
    mov dh,0x00
    int 0x10
    mov ah,0x02
    mov dl,0x20
    int 0x21
    inc cl
    cmp cl,0x4f
    jne clearPlayer3Loop
    ret

clearPlayer4:
    mov ch,0x00          ; start from upper row
    mov cl,0x00
    call clearPlayer4Loop
    ret
clearPlayer4Loop:
    mov ah,0x02      
    mov bh,0x00      
    mov dl,cl
    mov dh,0x18
    int 0x10
    mov ah,0x02
    mov dl,0x20
    int 0x21
    inc cl
    cmp cl,0x4f
    jne clearPlayer4Loop
    ret


gameOver:
    call clearScreen
    mov ah,0x09
    mov dx,gameOver1
    int 0x21
    jmp endProgram

gameStopped:
    call clearScreen
    mov ah,0x09
    mov dx,gameStopped1
    int 0x21
    jmp endProgram


section data
    curX db 0x00
    curY db 0x00
    borderSymbols db 0xb0,0xb0,'$'
    player1Loc db 0x0a
    player2Loc db 0x0a
    player3Loc db 0x14
    player4Loc db 0x14
    ballLoc db 0x0b,0x27
    ballDirection db 0x01
    gameOver1 db 'Game over!$'
    gameStopped1 db 'ESC pressed!$'
