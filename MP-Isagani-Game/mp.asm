; Marvic Gabriel Ruiz
; Abram C. Dorado

.model small
.stack 100h
.data
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    gameTitle db "  Isagani Game Board","$"
    arrayBoard1 db "[X]-\-[X]-/-[X]", "$"
    arrayBoard2 db "[ ]---[ ]---[ ]", "$"
    arrayBoard3 db "[O]-/-[O]-\-[O]", "$"
    divider db "      |     |     |", "$"
    letters db "      a.    b.    c.", "$"
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    promptStart db "Isagani Game - Code by: Marvic Gabriel Ruiz, Abram Dorado","$"
    messagegoal db "Goal of the game: Make a row (in any direction) of your three pieces before the AI does!", "$"
    messagename db "Enter name: ", "$"
    
    
    promptAiMove01 db "  AI moves from ", "$"
    promptMoveCount db "  Number of moves: ", "$"
    promptSequence db "  Sequence ", "$"
    promptAiMove02 db " to ", "$"

    promptPlayerWins db "  Congratulations! You win ", "$"
    promptEnter db "  Press enter...", "$"
    promptAiWins db "  Computer wins! You lose ", "$"
    promptName db "Enter your name: ","$"
    prompt db "  Your move ","$"
    
    promptMoveFrom db "  Start position(ex: a3): ","$"
    promptMoveTo db "  End Position(ex: a2): ","$"
    promptToken db "Your token: ","$"
    promptInvalid db "  Invalid move!", "$"
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    
    empty db " ", "$"
    buffer db 0
    seqNumber dw ?
    one db "1.", "$"
    two db "2.", "$"
    three db "3.", "$"
    newline db 13, 10, "$"
    nameInput db 26, ?, 26 dup("$")
    inputT1 db ?
    inputT2 db ?
    inputF1 db ?
    inputF2 db ?
    playerInputT1 db ?
    playerInputT2 db ?
    playerInputF1 db ?
    playerInputF2 db ?
    win db 0
    win_ai db 0

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    place01 db ?
    place02 db ?
    place03 db ?
    place04 db ?
    place05 db ?
    place06 db ?
    place07 db ?
    place08 db ?
    place09 db ?
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    
    is_empty_bool db ?
    inp1 db ?
    inp2 db ?
    invalid_bool db ?
    invalid_bool_ai db ?
    valid_move_bool db ?
    valid_move_bool_ai db ?
    player_token_bool db 0
    ai_token db 0
    ai_avail db 0
    ai_token01 db 0
    ai_token02 db 0
    ai_token03 db 0
    ai_token_from1 db ?
    ai_token_to1 db ?
    ai_token_from2 db ?
    ai_token_to2 db ?
    randomNum db 0
    empty_spot1 db 0
    empty_spot2 db 0
    empty_spot3 db 0
    movesCounter dw 1
    aimovesCounter dw 1
    token1_maxmove db ?
    token2_maxmove db ?
    token3_maxmove db ?
    preferred_move db ?

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

.code
    ; Prints a space
    print_space proc near
        mov dl, 32
        mov ah, 02h
        int 21h
        ret
    print_space endp

    ;Prints a new line
    new_line proc near
        lea dx, newline
        mov ah, 09h
        int 21h
        ret
    new_line endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; number printer, sequence, and enter

    ;prints numbers
    number_printer proc near
        mov bx, 10          ;CONST
        xor cx, cx          ;Reset counter
        
        @first: 
        xor dx, dx          ;Setup for division DX:AX / BX
        div bx              ; -> AX is Quotient, Remainder DX=[0,9]
        push dx             ;(1) Save remainder for now
        inc cx              ;One more digit
        test ax, ax         ;Is quotient zero?
        jne @first          ;No, use as next dividend
        @second: 
        pop dx              ;(1)
        
        mov ah, 02h         ;DOS.DisplayCharacter
        add dl, "0"
        int 21h             ; -> AL
        loop @second

        ret
    number_printer endp

    sequence_printer proc near
        lea dx, promptSequence
        mov ah, 09h
        int 21h

        mov ax, seqNumber
        call number_printer

        mov dl, '.'
        mov ah, 02h
        int 21h

        ret
    sequence_printer endp

    press_enter proc near
        mov ah, 09h
        lea dx, promptEnter
        int 21h
        wait_for_enter:
            mov ah, 01h
            int 21h
            cmp al, 0Dh ; Check if Enter key is pressed
            jne wait_for_enter
        ret
    press_enter endp
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    ; Prints Isagani board
    board_printer proc near
        call new_line
        call new_line
        
        ;;;;;;;;;;;;;;;;;;;;;;
        ; Prints the first row which corresponds to the column names (a, b, and c)
        lea dx, letters
        mov ah, 09h
        int 21h
        call new_line
        ;;;;;;;;;;;;;;;;;;;;;;


        call print_space
        call print_space

        ; prints the name of the row (1)
        lea dx, one
        mov ah, 09h
        int 21h
        call print_space

        ; prints board line 1
        lea dx, arrayBoard1
        mov ah, 09h
        int 21h
        call new_line
        
        ; prints row divider
        lea dx, divider
        mov ah, 09h
        int 21h
        call new_line

        call print_space
        call print_space
        lea dx, two
        mov ah, 09h
        int 21h
        call print_space

        ; prints the name of the row (2)
        lea dx, arrayBoard2
        mov ah, 09h
        int 21h
        call new_line
        
        ; prints row divider
        lea dx, divider
        mov ah, 09h
        int 21h
        call new_line

        call print_space
        call print_space

        ; prints the name of the row (3)
        lea dx, three
        mov ah, 09h
        int 21h
        call print_space

        ; prints board line 3
        lea dx, arrayBoard3
        mov ah, 09h
        int 21h
        call new_line
        call new_line
        call new_line

        ret
    board_printer endp
    
    ; Indicates that the player's token is 'O'
    player_token_check proc near
        .if bl == 'O'
            mov player_token_bool, 01
        .endif
        ret
    player_token_check endp

    ;checks if the move of the player is valid
    valid_move proc near
        ; 2 8 14
        ; Check if input is "a1"
        .if playerInputF1 == 'a' && playerInputF2 == '1'
            ; Update valid spaces
            .if playerInputT1 == 'a' && playerInputT2 == '2'
                mov valid_move_bool, 01
            .elseif playerInputT1 == 'b' && playerInputT2 == '1'
                mov valid_move_bool, 01
            .elseif playerInputT1 == 'b' && playerInputT2 == '2'
                mov valid_move_bool, 01
            .else
                mov valid_move_bool, 00
            .endif
        ; Check if input is "b1"
        .elseif playerInputF1 == 'b' && playerInputF2 == '1'
            ; Update valid spaces
            .if playerInputT1 == 'a' && playerInputT2 == '1'
                mov valid_move_bool, 01
            .elseif playerInputT1 == 'b' && playerInputT2 == '2'
                mov valid_move_bool, 01
            .elseif playerInputT1 == 'c' && playerInputT2 == '1'
                mov valid_move_bool, 01
            .else
                mov valid_move_bool, 00
            .endif
        ; Check if input is "c1"
        .elseif playerInputF1 == 'c' && playerInputF2 == '1'
            ; Update valid spaces
            .if playerInputT1 == 'b' && playerInputT2 == '1'
                mov valid_move_bool, 01
            .elseif playerInputT1 == 'b' && playerInputT2 == '2'
                mov valid_move_bool, 01
            .elseif playerInputT1 == 'c' && playerInputT2 == '2'
                mov valid_move_bool, 01
            .else
                mov valid_move_bool, 00
            .endif
        ; Check if input is "a2"
        .elseif playerInputF1 == 'a' && playerInputF2 == '2'
            ; Update valid spaces
            .if playerInputT1 == 'a' && playerInputT2 == '1'
                mov valid_move_bool, 01
            .elseif playerInputT1 == 'a' && playerInputT2 == '3'
                mov valid_move_bool, 01
            .elseif playerInputT1 == 'b' && playerInputT2 == '2'
                mov valid_move_bool, 01
            .else
                mov valid_move_bool, 00
            .endif
        ; Check if input is "b2"
        .elseif playerInputF1 == 'b' && playerInputF2 == '2'
            .if playerInputT1 == 'a' && playerInputT2 == '1'
                mov valid_move_bool, 01
            .elseif playerInputT1 == 'a' && playerInputT2 == '2'
                mov valid_move_bool, 01
            .elseif playerInputT1 == 'a' && playerInputT2 == '3'
                mov valid_move_bool, 01
            .elseif playerInputT1 == 'b' && playerInputT2 == '1'
                mov valid_move_bool, 01
            .elseif playerInputT1 == 'b' && playerInputT2 == '3'
                mov valid_move_bool, 01
            .elseif playerInputT1 == 'c' && playerInputT2 == '1'
                mov valid_move_bool, 01
            .elseif playerInputT1 == 'c' && playerInputT2 == '2'
                mov valid_move_bool, 01
            .elseif playerInputT1 == 'c' && playerInputT2 == '3'
                mov valid_move_bool, 01
            .else
                mov valid_move_bool, 00
            .endif
        ; Check if input is "c2"
        .elseif playerInputF1 == 'c' && playerInputF2 == '2'
            ; Update valid spaces
            .if playerInputT1 == 'b' && playerInputT2 == '2'
                mov valid_move_bool, 01
            .elseif playerInputT1 == 'c' && playerInputT2 == '1'
                mov valid_move_bool, 01
            .elseif playerInputT1 == 'c' && playerInputT2 == '3'
                mov valid_move_bool, 01
            .else
                mov valid_move_bool, 00
            .endif
        ; Check if input is "a3"
        .elseif playerInputF1 == 'a' && playerInputF2 == '3'
            ; Update valid spaces
            .if playerInputT1 == 'a' && playerInputT2 == '2'
                mov valid_move_bool, 01
            .elseif playerInputT1 == 'b' && playerInputT2 == '2'
                mov valid_move_bool, 01
            .elseif playerInputT1 == 'b' && playerInputT2 == '3'
                mov valid_move_bool, 01
            .else
                mov valid_move_bool, 00
            .endif
        ; Check if input is "b3"
        .elseif playerInputF1 == 'b' && playerInputF2 == '3'
            ; Update valid spaces
            .if playerInputT1 == 'a' && playerInputT2 == '3'
                mov valid_move_bool, 01
            .elseif playerInputT1 == 'b' && playerInputT2 == '2'
                mov valid_move_bool, 01
            .elseif playerInputT1 == 'c' && playerInputT2 == '3'
                mov valid_move_bool, 01
            .else
                mov valid_move_bool, 00
            .endif
        .elseif playerInputF1 == 'c' && playerInputF2 == '3'
            .if playerInputT1 == 'b' && playerInputT2 == '2'
                mov valid_move_bool, 01
            .elseif playerInputT1 == 'b' && playerInputT2 == '3'
                mov valid_move_bool, 01
            .elseif playerInputT1 == 'c' && playerInputT2 == '2'
                mov valid_move_bool, 01
            .else
            mov valid_move_bool, 00
            .endif
        .endif

        ret
    valid_move endp

    ;checks if the move of the player is invalid & calls the player_move again if it is
    invalid_movement proc near
        ; Checks if the move was invalid
        .if invalid_bool == 01
            call new_line
            call new_line
            ; Dislay the invalid move message
            lea dx, promptInvalid
            mov ah, 09h
            int 21h
            call new_line
            call new_line
            ; Calls for the player to make another move
            call player_move
        .endif
        ret
    invalid_movement endp

    ; Checks if the space is empty
    is_empty proc near
        ; if the space contains nothing, it is empty
        .if bl == ' '
            mov is_empty_bool, 01
        ; Else, it is already occupied
        .else
            mov is_empty_bool, 00
        .endif
        ret
    is_empty endp

    ;sets the row to be modified as chosen by the player
    move_cond proc near
        ; Checks for the coordinates, then loads the address of the specific boardline
        ; Adjusts offset so that the proper space in the board is determined
        .if bl == 'a' && bh == '1'
            lea si, arrayBoard1
            add si, 1
        .elseif bl == 'b' && bh == '1'
            lea si, arrayBoard1
            add si, 7
        .elseif bl == 'c' && bh == '1'
            lea si, arrayBoard1
            add si, 13
        .elseif bl == 'a' && bh == '2'
            lea si, arrayBoard2
            add si, 1
        .elseif bl == 'b' && bh == '2'
            lea si, arrayBoard2
            add si, 7
        .elseif bl == 'c' && bh == '2'
            lea si, arrayBoard2
            add si, 13
        .elseif bl == 'a' && bh == '3'
            lea si, arrayBoard3
            add si, 1
        .elseif bl == 'b' && bh == '3'
            lea si, arrayBoard3
            add si, 7
        .elseif bl == 'c' && bh == '3'
            lea si, arrayBoard3
            add si, 13
        ; If there is no match, the space is invalid
        .else   
            mov invalid_bool, 01
        .endif

        ret
    move_cond endp 
    
    ; Check if player has won
    winner proc near
        ; Check the spaces of the game board
        lea si, arrayBoard1
        add si, 1
        mov bl, [si]
        mov place01, bl
        add si, 6
        mov bl, [si]
        mov place02, bl
        add si, 6
        mov bl, [si]
        mov place03, bl

        lea si, arrayBoard2
        add si, 1
        mov bl, [si]
        mov place04, bl
        add si, 6
        mov bl, [si]
        mov place05, bl
        add si, 6
        mov bl, [si]
        mov place06, bl

        lea si, arrayBoard3
        add si, 1
        mov bl, [si]
        mov place07, bl
        add si, 6
        mov bl, [si]
        mov place08, bl
        add si, 6
        mov bl, [si]
        mov place09, bl

        ; Check if those spaces are all 'O', indicating the player has won
        .if place01 == 'O' && place02 == 'O' && place03 == 'O'
            mov win, 1
        .elseif place04 == 'O' && place05 == 'O' && place06 == 'O'
            mov win, 1
        .elseif place01 == 'O' && place04 == 'O' && place07 == 'O'
            mov win, 1
        .elseif place02 == 'O' && place05 == 'O' && place08 == 'O'
            mov win, 1
        .elseif place03 == 'O' && place06 == 'O' && place09 == 'O'
            mov win, 1
        .elseif place01 == 'O' && place05 == 'O' && place09 == 'O'
            mov win, 1
        .elseif place07 == 'O' && place05 == 'O' && place03 == 'O'
            mov win, 1
        .else
            mov win, 0
        .endif
        ret
    winner endp

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    ;player's move
    player_move proc near
        ; Initializes the following variables to 0
        xor bl, bl
        xor bh, bh
        mov invalid_bool, 00
        mov player_token_bool, 00

        ; Displays message for player to make a move
        lea dx, prompt
        mov ah, 09h
        int 21h

        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        ; Displays player name
        mov ah, 09h
        lea dx, [nameInput + 2]
        int 21h
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

        call new_line

        ; Displays message for player to input starting coordinates
        lea dx, promptMoveFrom
        mov ah, 09h
        int 21h

        mov ah, 01h
        int 21h
        mov inputF1, al

        mov ah, 01h
        int 21h
        mov inputF2, al

        call new_line
    
        ; Displays message for player to input ending coordinates
        lea dx, promptMoveTo
        mov ah, 09h
        int 21h

        mov ah, 01h
        int 21h
        mov inputT1, al

        mov ah, 01h
        int 21h
        mov inputT2, al

        call new_line

        mov bl, inputF1
        mov bh, inputF2
        
        ; Determine correct address for position
        call move_cond

        mov bl, [si]
        ; Check if space is empty
        call is_empty
        ; Check if player token matches
        call player_token_check

        mov bl, inputF1
        mov bh, inputF2
        mov playerInputF1, bl
        mov playerInputF2, bh 


        mov bl, inputT1
        mov bh, inputT2
        mov playerInputT1, bl
        mov playerInputT2, bh 

        ; Check if starting move is valid
        call valid_move
        ; Move is valid, change token into empty space
        .if is_empty_bool == 1 || valid_move_bool == 00 || player_token_bool == 00
            mov invalid_bool, 01
            mov dl, empty
            xchg [si], dl
        ; Move is invalid
        .elseif is_empty_bool == 0 && valid_move_bool == 01 && player_token_bool == 01
            mov dl, empty
            xchg [si], dl
        .endif

        mov bl, inputT1
        mov bh, inputT2

        ; Point to end destination position
        call move_cond
        mov bl, [si]
        ; Check if the space is empty
        call is_empty
        ; Space is empty, change empty space into player token
        .if is_empty_bool == 01 && valid_move_bool == 01 && player_token_bool == 01;if empty
            xchg dl, [si]
        ; Move is invalid
        .elseif is_empty_bool == 00 || valid_move_bool == 00 || player_token_bool == 00
            mov bl, inputF1
            mov bh, inputF2
            call move_cond
            xchg dl, [si]
            mov invalid_bool, 01
        .endif
        
        ; Check if player called an invalid move
        call invalid_movement

        ret 
    player_move endp

    ;checks if the ai's move is valid
    ai_valid_move proc near
        ; 2 8 14
        ; Check if input is "a1"
        .if playerInputF1 == 'a' && playerInputF2 == '1'
            ; Update valid spaces
            .if playerInputT1 == 'a' && playerInputT2 == '2'
                mov valid_move_bool_ai, 01
            .elseif playerInputT1 == 'b' && playerInputT2 == '1'
                mov valid_move_bool_ai, 01
            .elseif playerInputT1 == 'b' && playerInputT2 == '2'
                mov valid_move_bool_ai, 01
            .else
                mov valid_move_bool_ai, 00
            .endif
        ; Check if input is "b1"
        .elseif playerInputF1 == 'b' && playerInputF2 == '1'
            ; Update valid spaces
            .if playerInputT1 == 'a' && playerInputT2 == '1'
                mov valid_move_bool_ai, 01
            .elseif playerInputT1 == 'b' && playerInputT2 == '2'
                mov valid_move_bool_ai, 01
            .elseif playerInputT1 == 'c' && playerInputT2 == '1'
                mov valid_move_bool_ai, 01
            .else
                mov valid_move_bool_ai, 00
            .endif
        ; Check if input is "c1"
        .elseif playerInputF1 == 'c' && playerInputF2 == '1'
            ; Update valid spaces
            .if playerInputT1 == 'b' && playerInputT2 == '1'
                mov valid_move_bool_ai, 01
            .elseif playerInputT1 == 'b' && playerInputT2 == '2'
                mov valid_move_bool_ai, 01
            .elseif playerInputT1 == 'c' && playerInputT2 == '2'
                mov valid_move_bool_ai, 01
            .else
                mov valid_move_bool_ai, 00
            .endif
        ; Check if input is "a2"
        .elseif playerInputF1 == 'a' && playerInputF2 == '2'
            ; Update valid spaces
            .if playerInputT1 == 'a' && playerInputT2 == '1'
                mov valid_move_bool_ai, 01
            .elseif playerInputT1 == 'a' && playerInputT2 == '3'
                mov valid_move_bool_ai, 01
            .elseif playerInputT1 == 'b' && playerInputT2 == '2'
                mov valid_move_bool_ai, 01
            .else
                mov valid_move_bool_ai, 00
            .endif
        ; Check if input is "b2"
        .elseif playerInputF1 == 'b' && playerInputF2 == '2'
            ; Update valid spaces
            .if playerInputT1 == 'a' && playerInputT2 == '1'
                mov valid_move_bool_ai, 01
            .elseif playerInputT1 == 'a' && playerInputT2 == '2'
                mov valid_move_bool_ai, 01
            .elseif playerInputT1 == 'a' && playerInputT2 == '3'
                mov valid_move_bool_ai, 01
            .elseif playerInputT1 == 'b' && playerInputT2 == '1'
                mov valid_move_bool_ai, 01
            .elseif playerInputT1 == 'b' && playerInputT2 == '3'
                mov valid_move_bool_ai, 01
            .elseif playerInputT1 == 'c' && playerInputT2 == '1'
                mov valid_move_bool_ai, 01
            .elseif playerInputT1 == 'c' && playerInputT2 == '2'
                mov valid_move_bool_ai, 01
            .elseif playerInputT1 == 'c' && playerInputT2 == '3'
                mov valid_move_bool_ai, 01
            .else
                mov valid_move_bool_ai, 00
            .endif
        ; Check if input is "c2"
        .elseif playerInputF1 == 'c' && playerInputF2 == '2'
            ; Update valid spaces
            .if playerInputT1 == 'b' && playerInputT2 == '2'
                mov valid_move_bool_ai, 01
            .elseif playerInputT1 == 'c' && playerInputT2 == '1'
                mov valid_move_bool_ai, 01
            .elseif playerInputT1 == 'c' && playerInputT2 == '3'
                mov valid_move_bool_ai, 01
            .else
                mov valid_move_bool_ai, 00
            .endif
        ; Check if input is "a3"
        .elseif playerInputF1 == 'a' && playerInputF2 == '3'
            ; Update valid spaces
            .if playerInputT1 == 'a' && playerInputT2 == '2'
                mov valid_move_bool_ai, 01
            .elseif playerInputT1 == 'b' && playerInputT2 == '2'
                mov valid_move_bool_ai, 01
            .elseif playerInputT1 == 'b' && playerInputT2 == '3'
                mov valid_move_bool_ai, 01
            .else
                mov valid_move_bool_ai, 00
            .endif
        ; Check if input is "b3"
        .elseif playerInputF1 == 'b' && playerInputF2 == '3'
            ; Update valid spaces
            .if playerInputT1 == 'a' && playerInputT2 == '3'
                mov valid_move_bool_ai, 01
            .elseif playerInputT1 == 'b' && playerInputT2 == '2'
                mov valid_move_bool_ai, 01
            .elseif playerInputT1 == 'c' && playerInputT2 == '3'
                mov valid_move_bool_ai, 01
            .else
                mov valid_move_bool_ai, 00
            .endif
        ; Check if input is "c3"
        .elseif playerInputF1 == 'c' && playerInputF2 == '3'
            ; Update valid space
            .if playerInputT1 == 'b' && playerInputT2 == '2'
                mov valid_move_bool_ai, 01
            .elseif playerInputT1 == 'b' && playerInputT2 == '3'
                mov valid_move_bool_ai, 01
            .elseif playerInputT1 == 'c' && playerInputT2 == '2'
                mov valid_move_bool_ai, 01
            .else
                mov valid_move_bool_ai, 00
            .endif
        .else   
            ; An invalid move was done
            mov invalid_bool_ai, 01
        .endif

        ret
    ai_valid_move endp

        ; Set the coordinates to choose AI starting position
    ai_move_cond proc near
        ; AI move is based on the random number generated
        .if bl == 'a' && bh == '1'
            lea si, arrayBoard1
            add si, 1
        .elseif bl == 'b' && bh == '1'
            lea si, arrayBoard1
            add si, 7
        .elseif bl == 'c' && bh == '1'
            lea si, arrayBoard1
            add si, 13
        .elseif bl == 'a' && bh == '2'
            lea si, arrayBoard2
            add si, 1
        .elseif bl == 'b' && bh == '2'
            lea si, arrayBoard2
            add si, 7
        .elseif bl == 'c' && bh == '2'
            lea si, arrayBoard2
            add si, 13
        .elseif bl == 'a' && bh == '3'
            lea si, arrayBoard3
            add si, 1
        .elseif bl == 'b' && bh == '3'
            lea si, arrayBoard3
            add si, 7
        .elseif bl == 'c' && bh == '3'
            lea si, arrayBoard3
            add si, 13
        .else   
            ; The remainder is invalid
            mov invalid_bool_ai, 01
        .endif

        ret
    ai_move_cond endp 
    
    invalid_movement_ai proc near
        ; Checks if the move the AI wants to do is invalid
        .if invalid_bool_ai == 01
            ; Calls for AI to make another move
            call ai_move
        .endif
        ret
    invalid_movement_ai endp

    ; Determines the AI token based on the Player token
    ai_from proc near
        .if bl == 'X'
            mov ai_token, 01
        .else
            mov ai_token, 00
        .endif
        ret
    ai_from endp
    
    ;checks where the token of the ai is located
    ai_movement proc near
        ; Initializes the following variables to 0
        mov ai_token01, 0
        mov ai_token02, 0
        mov ai_token03, 0

        ; Determine if the token belongs to the AI
        lea si, arrayBoard1
        add si, 1
        mov bl, [si]

        ; Iterate over specific positions of the board and check the tokens in those positions
        call ai_from
        .if ai_token == 01
            mov ai_token01, 01
        .endif
        add si, 6
        mov bl, [si]
        call ai_from
        .if ai_token == 01
            .if ai_token01 == 0
                mov ai_token01, 02
            .elseif ai_token01 > 0
                .if ai_token02 == 0
                    mov ai_token02, 02
                .elseif ai_token02 > 0
                    mov ai_token03, 02
                .endif
            .endif 
        .endif

        add si, 6
        mov bl, [si]
        call ai_from
        .if ai_token == 01
            .if ai_token01 == 0
                mov ai_token01, 03
            .elseif ai_token01 > 0
                .if ai_token02 == 0
                    mov ai_token02, 03
                .elseif ai_token02 > 0
                    mov ai_token03, 03
                .endif
            .endif 
        .endif
        lea si, arrayBoard2
        add si, 1
        mov bl, [si]
        call ai_from
        .if ai_token == 01
            .if ai_token01 == 0
                mov ai_token01, 04
            .elseif ai_token01 > 0
                .if ai_token02 == 0
                    mov ai_token02, 04
                .elseif ai_token02 > 0
                    mov ai_token03, 04
                .endif
            .endif 
        .endif
        add si, 6
        mov bl, [si]
        call ai_from
        .if ai_token == 01
            .if ai_token01 == 0
                mov ai_token01, 05
            .elseif ai_token01 > 0
                .if ai_token02 == 0
                    mov ai_token02, 05
                .elseif ai_token02 > 0
                    mov ai_token03, 05
                .endif
            .endif 
        .endif
        add si, 6
        mov bl, [si]
        call ai_from
        .if ai_token == 01
            .if ai_token01 == 0
                mov ai_token01, 06
            .elseif ai_token01 > 0
                .if ai_token02 == 0
                    mov ai_token02, 06
                .elseif ai_token02 > 0
                    mov ai_token03, 06
                .endif
            .endif 
        .endif

        lea si, arrayBoard3
        add si, 1
        mov bl, [si]
        call ai_from
        .if ai_token == 01
            .if ai_token01 == 0
                mov ai_token01, 07
            .elseif ai_token01 > 0
                .if ai_token02 == 0
                    mov ai_token02, 07
                .elseif ai_token02 > 0
                    mov ai_token03, 07
                .endif
            .endif 
        .endif
        add si, 6
        mov bl, [si]
        call ai_from
        .if ai_token == 01
            .if ai_token01 == 0
                mov ai_token01, 08
            .elseif ai_token01 > 0
                .if ai_token02 == 0
                    mov ai_token02, 08
                .elseif ai_token02 > 0
                    mov ai_token03, 08
                .endif
            .endif 
        .endif
        add si, 6
        mov bl, [si]
        call ai_from
        .if ai_token == 01
            .if ai_token01 == 0
                mov ai_token01, 09
            .elseif ai_token01 > 0
                .if ai_token02 == 0
                    mov ai_token02, 09
                .elseif ai_token02 > 0
                    mov ai_token03, 09
                .endif
            .endif 
        .endif


        ret
    ai_movement endp

; Identify and store positions of empty positions in the game board    
    empty_spots proc near
        mov empty_spot1, 0
        mov empty_spot2, 0
        mov empty_spot3, 0
        ; Scan specific portions of the game board, check if its empty, designate it as an empty space
        lea si, arrayBoard1
        add si, 1
        mov bl, [si]
        call is_empty
        .if is_empty_bool == 01
            .if empty_spot1 == 0
                mov empty_spot1, 01
            .elseif empty_spot1 > 0
                .if empty_spot2 == 0
                    mov empty_spot2, 01
                .elseif empty_spot2 > 0
                    mov empty_spot3, 01
                .endif
            .endif 
        .endif
        add si, 6
        mov bl, [si]
        call is_empty
        .if is_empty_bool == 01
            .if empty_spot1 == 0
                mov empty_spot1, 02
            .elseif empty_spot1 > 0
                .if empty_spot2 == 0
                    mov empty_spot2, 02
                .elseif empty_spot2 > 0
                    mov empty_spot3, 02
                .endif
            .endif 
        .endif

        add si, 6
        mov bl, [si]
        call is_empty
        .if is_empty_bool == 01
            .if empty_spot1 == 0
                mov empty_spot1, 03
            .elseif empty_spot1 > 0
                .if empty_spot2 == 0
                    mov empty_spot2, 03
                .elseif empty_spot2 > 0
                    mov empty_spot3, 03
                .endif
            .endif 
        .endif
        lea si, arrayBoard2
        add si, 1
        mov bl, [si]
        call is_empty
        .if is_empty_bool == 01
            .if empty_spot1 == 0
                mov empty_spot1, 04
            .elseif empty_spot1 > 0
                .if empty_spot2 == 0
                    mov empty_spot2, 04
                .elseif empty_spot2 > 0
                    mov empty_spot3, 04
                .endif
            .endif 
        .endif
        add si, 6
        mov bl, [si]
        call is_empty
        .if is_empty_bool == 01
            .if empty_spot1 == 0
                mov empty_spot1, 05
            .elseif empty_spot1 > 0
                .if empty_spot2 == 0
                    mov empty_spot2, 05
                .elseif empty_spot2 > 0
                    mov empty_spot3, 05
                .endif
            .endif 
        .endif
        add si, 6
        mov bl, [si]
        call is_empty
        .if is_empty_bool == 01
            .if empty_spot1 == 0
                mov empty_spot1, 06
            .elseif empty_spot1 > 0
                .if empty_spot2 == 0
                    mov empty_spot2, 06
                .elseif empty_spot2 > 0
                    mov empty_spot3, 06
                .endif
            .endif 
        .endif

        lea si, arrayBoard3
        add si, 1
        mov bl, [si]
        call ai_from
        call is_empty
        .if is_empty_bool == 01
            .if empty_spot1 == 0
                mov empty_spot1, 07
            .elseif empty_spot1 > 0
                .if empty_spot2 == 0
                    mov empty_spot2, 07
                .elseif empty_spot2 > 0
                    mov empty_spot3, 07
                .endif
            .endif 
        .endif
        add si, 6
        mov bl, [si]
        call is_empty
        .if is_empty_bool == 01
            .if empty_spot1 == 0
                mov empty_spot1, 08
            .elseif empty_spot1 > 0
                .if empty_spot2 == 0
                    mov empty_spot2, 08
                .elseif empty_spot2 > 0
                    mov empty_spot3, 08
                .endif
            .endif 
        .endif
        add si, 6
        mov bl, [si]
        call is_empty
        .if is_empty_bool == 01
            .if empty_spot1 == 0
                mov empty_spot1, 09
            .elseif empty_spot1 > 0
                .if empty_spot2 == 0
                    mov empty_spot2, 09
                .elseif empty_spot2 > 0
                    mov empty_spot3, 09
                .endif
            .endif 
        .endif

        ret
    empty_spots endp


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ; Generate a random number based on system time
    genRandomNum proc near
        ; Call a add_delay 3 times to add some variation
        call delay
        call delay
        mov ah, 0
        ; Obtain current time
        int 1ah

        ; Store in ax
        mov ax, dx
        mov dx, 0
        mov bx, 3
        ; Div ax by 3
        div bx
        ; Remainder is stored as random number
        mov randomNum, dl
        ret
    genRandomNum endp

    ;helper procedure for the number generator
    ; add_delay procedure
    delay proc near
        xor cx, cx
        mov cx, 1
    startDelay:
        ; Control the duration of the add_delay
        cmp cx, 30000
        JE endDelay
        inc cx
        JMP startDelay
    endDelay:
        ret
    delay endp
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    ; Set the coordinates to choose AI starting position
    ai_move_condfrom proc near
    ; AI move is based on the random number generated

        .if bl == 01
            mov ai_token_from1, 'a'
            mov ai_token_from2, '1'
        .elseif bl == 02
            mov ai_token_from1, 'b'
            mov ai_token_from2, '1'
        .elseif bl == 03
            mov ai_token_from1, 'c'
            mov ai_token_from2, '1'
        .elseif bl == 04
            mov ai_token_from1, 'a'
            mov ai_token_from2, '2'
        .elseif bl == 05
            mov ai_token_from1, 'b'
            mov ai_token_from2, '2'
        .elseif bl == 06
            mov ai_token_from1, 'c'
            mov ai_token_from2, '2'
        .elseif bl == 07
            mov ai_token_from1, 'a'
            mov ai_token_from2, '3'
        .elseif bl == 08
            mov ai_token_from1, 'b'
            mov ai_token_from2, '3'
        .elseif bl == 09
            mov ai_token_from1, 'c'
            mov ai_token_from2, '3'
        .else 
            ; The remainder is invalid
            mov invalid_bool, 01
        .endif
        ret
    ai_move_condfrom endp

    ; Set the coordinates to choose AI ending position
    ai_move_condto proc near
        ; AI move is based on the random number generated
        .if bh == 01
            mov ai_token_to1, 'a'
            mov ai_token_to2, '1'
        .elseif bh == 02
            mov ai_token_to1, 'b'
            mov ai_token_to2, '1'
        .elseif bh == 03
            mov ai_token_to1, 'c'
            mov ai_token_to2, '1'
        .elseif bh == 04
            mov ai_token_to1, 'a'
            mov ai_token_to2, '2'
        .elseif bh == 05
            mov ai_token_to1, 'b'
            mov ai_token_to2, '2'
        .elseif bh == 06
            mov ai_token_to1, 'c'
            mov ai_token_to2, '2'
        .elseif bh == 07
            mov ai_token_to1, 'a'
            mov ai_token_to2, '3'
        .elseif bh == 08
            mov ai_token_to1, 'b'
            mov ai_token_to2, '3'
        .elseif bh == 09
            mov ai_token_to1, 'c'
            mov ai_token_to2, '3'
        .else   
            ; The remainder is invalid
            mov invalid_bool, 01
        .endif
        ret
    ai_move_condto endp

    max_aitoken1 proc near

        mov bl, ai_token01
        mov bh, empty_spot1
        call ai_move_condfrom
        call ai_move_condto

        mov bl, ai_token_from1
        mov bh, ai_token_from2
        mov playerInputF1, bl
        mov playerInputF2, bh 

        mov bl, ai_token_to1
        mov bh, ai_token_to2
        mov playerInputT1, bl
        mov playerInputT2, bh 

        call ai_valid_move
        .if valid_move_bool_ai == 01
            mov token1_maxmove, 01
        .endif

        mov bl, ai_token01
        mov bh, empty_spot2
        call ai_move_condfrom
        call ai_move_condto

        mov bl, ai_token_from1
        mov bh, ai_token_from2
        mov playerInputF1, bl
        mov playerInputF2, bh 

        mov bl, ai_token_to1
        mov bh, ai_token_to2
        mov playerInputT1, bl
        mov playerInputT2, bh 

        call ai_valid_move
        .if valid_move_bool_ai == 01
            add token1_maxmove, 01
        .endif

        mov bl, ai_token01
        mov bh, empty_spot3
        call ai_move_condfrom
        call ai_move_condto

        mov bl, ai_token_from1
        mov bh, ai_token_from2
        mov playerInputF1, bl
        mov playerInputF2, bh 

        mov bl, ai_token_to1
        mov bh, ai_token_to2
        mov playerInputT1, bl
        mov playerInputT2, bh 

        call ai_valid_move
        .if valid_move_bool_ai == 01
            add token1_maxmove, 01
        .endif
        ret
    max_aitoken1 endp
    
    max_aitoken2 proc near

        mov bl, ai_token02
        mov bh, empty_spot1
        call ai_move_condfrom
        call ai_move_condto

        mov bl, ai_token_from1
        mov bh, ai_token_from2
        mov playerInputF1, bl
        mov playerInputF2, bh 

        mov bl, ai_token_to1
        mov bh, ai_token_to2
        mov playerInputT1, bl
        mov playerInputT2, bh 

        call ai_valid_move
        .if valid_move_bool_ai == 01
            mov token2_maxmove, 01
        .endif

        mov bl, ai_token02
        mov bh, empty_spot2
        call ai_move_condfrom
        call ai_move_condto

        mov bl, ai_token_from1
        mov bh, ai_token_from2
        mov playerInputF1, bl
        mov playerInputF2, bh 

        mov bl, ai_token_to1
        mov bh, ai_token_to2
        mov playerInputT1, bl
        mov playerInputT2, bh 

        call ai_valid_move
        .if valid_move_bool_ai == 01
            add token2_maxmove, 01
        .endif

        mov bl, ai_token02
        mov bh, empty_spot3
        call ai_move_condfrom
        call ai_move_condto

        mov bl, ai_token_from1
        mov bh, ai_token_from2
        mov playerInputF1, bl
        mov playerInputF2, bh 

        mov bl, ai_token_to1
        mov bh, ai_token_to2
        mov playerInputT1, bl
        mov playerInputT2, bh 

        call ai_valid_move
        .if valid_move_bool_ai == 01
            add token2_maxmove, 01
        .endif
        ret
    max_aitoken2 endp
    
    max_aitoken3 proc near
        mov bl, ai_token03
        mov bh, empty_spot1
        call ai_move_condfrom
        call ai_move_condto

        mov bl, ai_token_from1
        mov bh, ai_token_from2
        mov playerInputF1, bl
        mov playerInputF2, bh 

        mov bl, ai_token_to1
        mov bh, ai_token_to2
        mov playerInputT1, bl
        mov playerInputT2, bh 

        call ai_valid_move
        .if valid_move_bool_ai == 01
            mov token3_maxmove, 01
        .endif

        mov bl, ai_token03
        mov bh, empty_spot2
        call ai_move_condfrom
        call ai_move_condto

        mov bl, ai_token_from1
        mov bh, ai_token_from2
        mov playerInputF1, bl
        mov playerInputF2, bh 

        mov bl, ai_token_to1
        mov bh, ai_token_to2
        mov playerInputT1, bl
        mov playerInputT2, bh 

        call ai_valid_move
        .if valid_move_bool_ai == 01
            add token3_maxmove, 01
        .endif

        mov bl, ai_token03
        mov bh, empty_spot3
        call ai_move_condfrom
        call ai_move_condto

        mov bl, ai_token_from1
        mov bh, ai_token_from2
        mov playerInputF1, bl
        mov playerInputF2, bh 

        mov bl, ai_token_to1
        mov bh, ai_token_to2
        mov playerInputT1, bl
        mov playerInputT2, bh 

        call ai_valid_move
        .if valid_move_bool_ai == 01
            add token3_maxmove, 01
        .endif
        ret
    max_aitoken3 endp

    ;ai's move
    ai_move proc near
        mov token1_maxmove, 0
        mov token2_maxmove, 0
        mov token3_maxmove, 0
        xor bl, bl
        xor bh, bh
        mov invalid_bool_ai, 00
        ; Determine AI move logic
        call ai_movement
        call empty_spots
        call max_aitoken1
        call max_aitoken2
        call max_aitoken3   
        mov bl, token2_maxmove
        mov bh, token3_maxmove

        .if token1_maxmove >= bl && token1_maxmove >= bh
            mov preferred_move, 01
        .elseif bl >= token1_maxmove && bl >= bh
            mov preferred_move, 02
        .elseif bh >= token1_maxmove && bh >= bl
            mov preferred_move, 03
        .endif

        .if preferred_move == 01
            mov bl, ai_token01
            call ai_move_condfrom
            call empty_spots
            call genRandomNum
            .if randomNum == 0
                mov bh, empty_spot1
                call ai_move_condto
            .elseif randomNum == 1
                mov bh, empty_spot2
                call ai_move_condto
            .elseif randomNum == 2
                mov bh, empty_spot3
                call ai_move_condto
            .endif
            
        .elseif preferred_move == 02
            mov bl, ai_token02
            call ai_move_condfrom
            call empty_spots
            call genRandomNum
            .if randomNum == 0
                mov bh, empty_spot1
                call ai_move_condto
            .elseif randomNum == 1
                mov bh, empty_spot2
                call ai_move_condto
            .elseif randomNum == 2
                mov bh, empty_spot3
                call ai_move_condto
            .endif

        .elseif preferred_move == 03
            mov bl, ai_token03
            call ai_move_condfrom
            call empty_spots
            call genRandomNum
            .if randomNum == 0
                mov bh, empty_spot1
                call ai_move_condto
            .elseif randomNum == 1
                mov bh, empty_spot2
                call ai_move_condto
            .elseif randomNum == 2
                mov bh, empty_spot3
                call ai_move_condto
            .endif

        .endif

        ; Set the random tokens into input start and input end
        mov bl, ai_token_from1
        mov bh, ai_token_from2
        
        call ai_move_cond

        mov bl, ai_token_from1
        mov bh, ai_token_from2
        mov playerInputF1, bl
        mov playerInputF2, bh 

        mov bl, ai_token_to1
        mov bh, ai_token_to2
        mov playerInputT1, bl
        mov playerInputT2, bh 

        call ai_valid_move

        .if valid_move_bool_ai == 01
            mov dl, empty
            xchg [si], dl
            mov bl, ai_token_to1
            mov bh, ai_token_to2

            call ai_move_cond
            xchg dl, [si]
        .elseif valid_move_bool_ai == 00
            mov invalid_bool_ai, 01
        .endif

        call invalid_movement_ai
        ret
    ai_move endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;AI printer
;printer of the ai's move
    ai_printer proc near
        lea dx, promptAiMove01
        mov ah, 09h
        int 21h

        mov dl, ai_token_from1
        mov ah, 02h
        int 21h

        mov dl, ai_token_from2
        mov ah, 02h
        int 21h

        lea dx, promptAiMove02
        mov ah, 09h
        int 21h

        mov dl, ai_token_to1
        mov ah, 02h
        int 21h

        mov dl, ai_token_to2
        mov ah, 02h
        int 21h

        mov dl, '.'
        mov ah, 02h
        int 21h
        ret
    ai_printer endp

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    ; Check if the AI has won
    winner_ai proc near
        ; Check the spaces of the game board
        lea si, arrayBoard1
        add si, 1
        mov bl, [si]
        mov place01, bl
        add si, 6
        mov bl, [si]
        mov place02, bl
        add si, 6
        mov bl, [si]
        mov place03, bl

        lea si, arrayBoard2
        add si, 1
        mov bl, [si]
        mov place04, bl
        add si, 6
        mov bl, [si]
        mov place05, bl
        add si, 6
        mov bl, [si]
        mov place06, bl

        lea si, arrayBoard3
        add si, 1
        mov bl, [si]
        mov place07, bl
        add si, 6
        mov bl, [si]
        mov place08, bl
        add si, 6
        mov bl, [si]
        mov place09, bl

        ; Check if those spaces are all 'X', indicating the player has won
        .if place04 == 'X' && place05 == 'X' && place06 == 'X'
            mov win_ai, 1
        .elseif place07 == 'X' && place08 == 'X' && place09 == 'X'
            mov win_ai, 1
        .elseif place01 == 'X' && place04 == 'X' && place07 == 'X'
            mov win_ai, 1
        .elseif place02 == 'X' && place05 == 'X' && place08 == 'X'
            mov win_ai, 1
        .elseif place03 == 'X' && place06 == 'X' && place09 == 'X'
            mov win_ai, 1
        .elseif place01 == 'X' && place05 == 'X' && place09 == 'X'
            mov win_ai, 1
        .elseif place07 == 'X' && place05 == 'X' && place03 == 'X'
            mov win_ai, 1
        .else
            mov win_ai, 0
        .endif
        ret
    winner_ai endp
    

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    main proc near
        ; Initializing data
        mov ax, @data
        mov ds, ax
        mov bh, 00

        ; Display start message
        lea dx, promptStart
        mov ah, 09h
        int 21h

        call new_line
        call new_line

        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        ; Display goal of the game
        lea dx, messagegoal
        mov ah, 09h
        int 21h

        call new_line

        ; Ask for player name
        lea dx, messagename
        mov ah, 09h
        int 21h

        ; Set player name as name input
        mov ah, 0ah
        lea dx, nameInput
        int 21h
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

        call new_line
        call new_line

        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        mov movesCounter, 1
        mov aimovesCounter, 1
        mov seqNumber, 1
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        
        ; Game Loop
        .while win_ai < 01 && win <01
            call sequence_printer

            call board_printer

            call winner_ai

            .if win_ai == 1
                lea dx, promptAiWins
                mov ah, 09h
                int 21h
                
                mov ah, 09h
                lea dx, [nameInput + 2]
                int 21h
                call new_line

                ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                lea dx, promptMoveCount
                mov ah, 09h
                int 21h

                mov ax, movesCounter
                call number_printer
                jmp @ending
                ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

            .elseif win == 1
                lea dx, promptPlayerWins
                mov ah, 09h
                int 21h

                mov ah, 09h
                lea dx, [nameInput + 2]
                int 21h

                call new_line

                ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                lea dx, promptMoveCount
                mov ah, 09h
                int 21h

                mov ax, aimovesCounter
                call number_printer
                jmp @ending
                ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
            .endif
            
            call player_move
            call press_enter
            call new_line
            inc movesCounter
            inc seqNumber
            call sequence_printer
            call board_printer
            call winner

            .if win_ai == 1
                lea dx, promptAiWins
                mov ah, 09h
                int 21h

                mov ah, 09h
                lea dx, [nameInput + 2]
                int 21h

                call new_line

                ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                lea dx, promptMoveCount
                mov ah, 09h
                int 21h

                mov ax, movesCounter
                call number_printer
                jmp @ending
                ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

            .elseif win == 1
                lea dx, promptPlayerWins
                mov ah, 09h
                int 21h

                mov ah, 09h
                lea dx, [nameInput + 2]
                int 21h

                call new_line

                ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                lea dx, promptMoveCount
                mov ah, 09h
                int 21h

                mov ax, aimovesCounter
                call number_printer
                jmp @ending
                ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
            .endif

            call ai_move
            call ai_printer 
            call new_line
            call press_enter
            inc aimovesCounter
            call new_line
            inc seqNumber
            call new_line
        .endw

        @ending:
        mov ax, 4c00h
        int 21h
    main endp
end main