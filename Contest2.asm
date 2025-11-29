; ====== Horror Blackjack.asm ======
; Author(s): Taratong Dolinsky & Dathan
; Modified: Horror Version with Screen Flash Effects
; Date: October 30, 2025

INCLUDE Irvine32.inc

.data

; === Variables ===
player1Total DWORD ?
player2Total DWORD ?
player1Losses DWORD 0
player2Losses DWORD 0
roundNum DWORD 1
choice BYTE ?

; === Horror Messages ===
msgRound BYTE "=== RITUAL PHASE ", 0
msgDraw BYTE "Do you dare pull another cursed card? (y/n): ", 0
msgStay BYTE "You freeze... your trembling hand refuses to draw.", 0
msgCard BYTE "The deck groans. It disgorges a corrupted fragment worth: ", 0

msgPlayerTotal BYTE "Your corruption level: ", 0
msgComputerTotal BYTE "The Entity's corruption level: ", 0

msgWin BYTE "A shriek erupts... the Entity recoils. You survive this phase.", 0
msgLose BYTE "The Entity smiles. It FEEDS on your suffering.", 0
msgTie BYTE "A dead silence... neither soul gains ground.", 0

msgFinalDeath BYTE "The ritual completes. Your spirit is torn from your flesh.", 0
msgFinalSurvive BYTE "You crawl from the chamber... but something follows.", 0

msgAtmos BYTE "The candles sputter. Shadows twitch behind you.", 13,10,0
msgFlash BYTE "** A VIOLENT FLASH OF DARKNESS OVERWHELMS YOU **", 0

newline BYTE 13, 10, 0


.code
main PROC
    call Randomize
    mov roundNum, 1

GameLoop:
    call Clrscr
    mov eax, roundNum
    cmp eax, 4
    jge EndGame

    ; Reset totals each round
    mov player1Total, 0
    mov player2Total, 0

    call RoundStart
    inc roundNum
    jmp GameLoop

EndGame:
    call FinalResult
    exit
main ENDP


; === Screen Flash Effect ===
ScreenFlash PROC
    ; Flash 1
    call Clrscr
    mov edx, OFFSET msgFlash
    call WriteString
    call Crlf
    mov eax, 150
    call Delay

    ; Flash 2
    call Clrscr
    mov eax, 100
    call Delay

    ; Flash 3
    call Clrscr
    mov edx, OFFSET msgFlash
    call WriteString
    call Crlf
    mov eax, 200
    call Delay

    call Clrscr
    ret
ScreenFlash ENDP


; === ROUND START ===
RoundStart PROC
    call ScreenFlash     ; Dramatic round intro

    mov edx, OFFSET msgRound
    call WriteString
    mov eax, roundNum
    call WriteDec
    call Crlf
    call Crlf

    ; Initial cards
    call DrawCard
    mov player1Total, eax
    call DrawCard
    mov player2Total, eax

PlayerTurn:
    mov edx, OFFSET msgAtmos
    call WriteString

    ; Show current total
    mov edx, OFFSET msgPlayerTotal
    call WriteString
    mov eax, player1Total
    call WriteDec
    call Crlf

    mov edx, OFFSET msgDraw
    call WriteString
    call ReadChar
    mov choice, al
    call Crlf

    cmp choice, 'y'
    jne PlayerStay

    call DrawCard
    add player1Total, eax
    cmp player1Total, 21
    jg PlayerBust
    jmp PlayerTurn

PlayerBust:
    call ScreenFlash
    mov edx, OFFSET msgLose
    call WriteString
    call Crlf
    inc player1Losses
    ret

PlayerStay:
    mov edx, OFFSET msgStay
    call WriteString
    call Crlf

ComputerTurn:
    mov eax, player2Total
CompLoop:
    cmp eax, 16
    jge CompStay
    call DrawCard
    add player2Total, eax
    mov eax, player2Total
    jmp CompLoop

CompStay:
    mov edx, OFFSET msgComputerTotal
    call WriteString
    mov eax, player2Total
    call WriteDec
    call Crlf

    call DetermineWinner
    ret
RoundStart ENDP


; === DETERMINE WINNER ===
DetermineWinner PROC
    mov eax, player1Total
    mov ebx, player2Total

    cmp eax, 21
    jg PlayerLose
    cmp ebx, 21
    jg PlayerWin

    cmp eax, ebx
    ja PlayerWin
    jb PlayerLose

Tie:
    mov edx, OFFSET msgTie
    call WriteString
    call Crlf
    ret

PlayerWin:
    mov edx, OFFSET msgWin
    call WriteString
    call Crlf
    ret

PlayerLose:
    call ScreenFlash
    mov edx, OFFSET msgLose
    call WriteString
    call Crlf
    inc player1Losses
    ret
DetermineWinner ENDP


; === DRAW CARD ===
DrawCard PROC
    mov eax, 10
    call RandomRange
    inc eax
    mov edx, OFFSET msgCard
    call WriteString
    push eax
    call WriteDec
    call Crlf
    pop eax
    ret
DrawCard ENDP


; === FINAL RESULT ===
FinalResult PROC
    call Crlf
    mov eax, player1Losses
    cmp eax, 2
    jg Died

    mov edx, OFFSET msgFinalSurvive
    call WriteString
    call Crlf
    ret

Died:
    call ScreenFlash
    mov edx, OFFSET msgFinalDeath
    call WriteString
    call Crlf
    ret
FinalResult ENDP


END main
