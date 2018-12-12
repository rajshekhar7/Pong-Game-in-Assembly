    org 100h
    
    start:
       call subs.cursorHide         ;hide the cursor
       call subs.clearScreen        ;clears screen
       call subs.drawPlayer         
       call subs.drawCPU
       call subs.drawBall
    
    main:
       call subs.processInput       ;check for input, if exist get it
       call subs.moveCPU            ; move cpu with ball
       call subs.padColCheck        ;check collision with either paddle
       call subs.moveBall           ;move ball according to postion and direction
       call subs.sleep              ;delay
       jmp main             ;looped

    subs:
    .endProgram:
       call .cursorShow
       mov ax,0x4c00        ;   return to OS
       int 0x21             ;   

    .processInput:
       mov ah,0x01          ;check for keystroke in key buffer
       int 0x16
       jz .processInputEnd  ;if no keystroke available
    .processInputGet:
       mov ah,0x00          ;get the keystroke from buffer
       int 0x16
       cmp al,0x1b          ;if ESC is pressed, end the program
       je .endProgram
       cmp ah,0x48          ;if up arrow is pressed BIOS input
       je .playerMoveUp
       cmp ah,0x50          ;if down arrow is pressed 
       je .playerMoveDown
    .processInputEnd:
       ret

    .moveCPU:
       mov ax, [ballLoc]    ;get ball location, y-coordinate in al
       mov ah, [cpuLoc]     ;get cpu head 
       inc ah               ;check for cpu paddle head
       cmp al,ah            
       jl .cpuMoveUp        
       jg .cpuMoveDown
       ret   

    .sleep:
       mov ah,0  ; function no. for read
       int 1ah   ; get the time of day count
       add dx,1  ; add one half second delay to low word
       mov bx,dx ; store end of delay value in bx
    .sleepLoop:
       int 1ah
       cmp dx,bx
       jne .sleepLoop
       ret

    .playerMoveUp:
       mov ch,[playerLoc]   ;get player paddle head
       cmp ch,0x01
       je .playerMoveNull   ;if on the top, it cannot move
       dec ch               ;else go up, decrease since y increases downwards
       mov [playerLoc],ch   ;store new position
       call .clearPlayer    ;clear the player(whole column)
       call .drawPlayer     ;draw at new location
       ret

    .playerMoveDown:
       mov ch,[playerLoc]   ;similar to above
       cmp ch,0x15
       je .playerMoveNull
       inc ch
       mov [playerLoc],ch
       call .clearPlayer
       call .drawPlayer
    .playerMoveNull:
       ret

    .cpuMoveUp:
       mov ch,[cpuLoc]      
       cmp ch,0x01
       je .cpuMoveNull
       dec ch
       mov [cpuLoc],ch
       call .clearCPU
       call .drawCPU
       ret

    .cpuMoveDown:
       mov ch,[cpuLoc]
       cmp ch,0x15
       je .cpuMoveNull
       inc ch
       mov [cpuLoc],ch
       call .clearCPU
       call .drawCPU
    .cpuMoveNull:
       ret


    .cursorShow:
       mov cx,0x0d0e
       mov ah,0x01
       int 0x10
       ret

    .cursorHide:
       mov cx,0x2000
       mov ah,0x01
       int 0x10
       ret

    .clearScreen:
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
       call .setCur
       ret

    .setCur:
       mov ah,0x02      ;set new cursor location
       mov bh,0x00
       mov dl,[curX]
       mov dh,[curY]
       int 0x10
       ret


    .drawPlayer:
       mov cl,0x00              ;get position
       mov ch,[playerLoc]       ;since x coordinate is always zero, only y changes
       mov [curX],cl
       mov [curY],ch
       call .setCur
       mov ah,0x02
       mov dl,0xb3          ;draw | at the given position
       int 0x21
       add ch,0x01
       mov [curY],ch        ;go down and draw again
       call .setCur
       mov ah,0x02
       mov dl,0xb3
       int 0x21
       inc ch
       mov [curY],ch    ;go down and draw again
       call .setCur
       mov ah,0x02
       mov dl,0xb3
       int 0x21
       ret

    .drawCPU:
       mov cl,0x4f      ;similar as above
       mov ch,[cpuLoc]
       mov [curX],cl
       mov [curY],ch
       call .setCur
       mov ah,0x02
       mov dl,0xb3
       int 0x21
       add ch,0x01
       mov [curY],ch
       call .setCur
       mov ah,0x02
       mov dl,0xb3
       int 0x21
       inc ch
       mov [curY],ch
       call .setCur
       mov ah,0x02
       mov dl,0xb3
       int 0x21
       ret

    .drawBall:
       mov cl,[ballLoc+1]
       mov ch,[ballLoc]
       mov [curX],cl
       mov [curY],ch
       call .setCur
       mov ah,0x02
       mov dl,0x2a      ; ascii-> 2Ah = '*' 
       int 0x21
       ret

    .moveBall:
       mov cl,[ballLoc+1]
       mov ch,[ballLoc]
       mov [curX],cl
       mov [curY],ch
       call .setCur
       mov ah,0x02
       mov dl,0x20 ; 0x20 = 32 = ascii - 'space; 
       int 0x21 ;previous location is deleted
       mov al,[ballDirection]   
       cmp al,0x01  ;if ball is moving in 01 direction
       je .moveBall1    
       cmp al,0x02      
       je .moveBall2
       cmp al,0x03
       je .moveBall3
       cmp al,0x04
       je .moveBall4

    .moveBall1:
       mov ax, [ballLoc]
       cmp ah,0x01             ;if x-axis is 01, end game
       je near .gameOver
       cmp al,0x02              ;check hit on upper surface
       je .setBallDirection4    ;if true change direction to 04
       dec al
       dec ah
       mov [ballLoc], ax
       call .drawBall
       ret

    .moveBall2:
       mov ax, [ballLoc]
       cmp ah,0x4f      ;if x axis is 4Fh, end game(right end)
       je near .gameOver
       cmp al,0x01              ; check hit on upper surface
       je .setBallDirection3    ; if yes, change dirn to 03
       inc ah
       dec al
       mov [ballLoc], ax
       call .drawBall
       ret

    .moveBall3:
       mov ax, [ballLoc]
       cmp ah,0x4f      ; if x-axis is 4Fh, end game(right end)
       je near .gameOver
       cmp al,0x17              ;check hit on lower surface
       je .setBallDirection2    ;if yes, change diren to 02
       inc ah
       inc al
       mov [ballLoc], ax
       call .drawBall
       ret

    .moveBall4:
       mov ax, [ballLoc]
       cmp ah,0x01  ;if x-axis is 1h ,end game (left end)
       je near .gameOver
       cmp al,0x17              ;check hit on lower surface
       je .setBallDirection1    ;if yes, change dir to 01
       dec ah
       inc al
       mov [ballLoc], ax
       call .drawBall
       ret

    .setBallDirection1:
       mov al,0x01
       mov [ballDirection],al
       call .drawBall
       ret
    .setBallDirection2:
       mov al,0x02
       mov [ballDirection],al
       call .drawBall
       ret
    .setBallDirection3:
       mov al,0x03
       mov [ballDirection],al
       call .drawBall
       ret
    .setBallDirection4:
       mov al,0x04
       mov [ballDirection],al
       call .drawBall
       ret

    .padColCheck:
       mov ax, [ballLoc]
       cmp ah,0x1           ;if ball is on left side
       je .padColCheck1
       cmp ah,0x4f          ;if ball is on right side
       je .padColCheck2
       ret

    .padColCheck1:
       mov bl, [playerLoc]
       cmp al,bl            ;if ball is touching head of played
       je .bouncePlayer
       inc bl               
       cmp al,bl            ;if ball is touching middle of addle
       je .bouncePlayer
       inc bl
       cmp al,bl            ;if ball is touching lower of player paddle
       je .bouncePlayer
       ret

    .padColCheck2:
       mov bl, [cpuLoc]
       cmp al,bl            ;if ball is touching head of cpu paddle
       je .bounceCpu
       inc bl
       cmp al,bl            ;if ball is touching middle of cpu paddle
       je .bounceCpu
       inc bl
       cmp al,bl            ;if ball is touching lower of cpu paddle
       je .bounceCpu
       ret

    .bouncePlayer:
       mov al,[ballDirection]
       cmp al,0x01              ;if ball direction is 01, change it to 02
       je .setBallDirection2
       cmp al,0x04              ;if ball direction is 04, change it to 03
       je .setBallDirection3
       ret

    .bounceCpu:
       mov al,[ballDirection]
       cmp al,0x02              ;if ball direction is 02, change it to 01
       je .setBallDirection1
       cmp al,0x03              ;if ball direction is 03, change it to 04
       je .setBallDirection4
       ret

    .clearPlayer:
       mov ch,0x00          ;start from upper row
       mov cl,0x27
       call .clearPlayerLoop
       ret
    .clearPlayerLoop:
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
       jne .clearPlayerLoop
       ret

    .clearCPU:
       mov ch,0x00          ; start from upper row
       mov cl,0x27
       call .clearCpuLoop
       ret
    .clearCpuLoop:
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
       jne .clearCpuLoop
       ret


    .gameOver:
       call .clearScreen
       mov ah,0x09
       mov dx,gameOver
       int 0x21
       jmp .endProgram

  

    section .data
       curX db 0x00
       curY db 0x00
       borderSymbols db 0xb0,0xb0,'$'
       playerLoc db 0x0a
       cpuLoc db 0x0a
       ballLoc db 0x0b,0x27
       ballDirection db 0x01
       gameOver db 'Game over!$'
