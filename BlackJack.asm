; ====== Blackjack.asm ======
; Author(s) : Taratong Dolinsky& Dathan
; Date: October 30, 2025
; Description: Simple Blackjack(21) game using Irvine32 library.
; Rules:
;   -Two players : user and computer
;   -Player can draw or stay
;   -After 3 rounds, whoever has more losses "dies"
; Notes:
;   -Uses RandomRange for card draws
;   -Basic comparison logic for win / loss
;   -Written for Visual Studio using Irvine32.inc and Irvine32.lib
; ============================ =


INCLUDE Irvine32.inc

.data

; ===Variables===
player1Total DWORD ?
player2Total DWORD ?
player1Losses DWORD 0
player2Losses DWORD 0
roundNum DWORD 1
choice BYTE ?
msgRound BYTE "=== ROUND ", 0
msgDraw BYTE "Do you want to draw another card? (y/n): ", 0
msgStay BYTE "You chose to stay.", 0
msgCard BYTE "You drew a card worth: ", 0
msgPlayerTotal BYTE "Your total is: ", 0
msgComputerTotal BYTE "Computer total is: ", 0
msgWin BYTE "You win this round!", 0
msgLose BYTE "You lose this round!", 0
msgTie BYTE "It's a tie!", 0
msgFinalDeath BYTE "You died.", 0
msgFinalSurvive BYTE "You've survived.", 0
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

; ==== = Reset totals each round ==== =
mov player1Total, 0
mov player2Total, 0

call RoundStart
inc roundNum
jmp GameLoop

EndGame :
call FinalResult
exit
main ENDP


; ==== = ROUND START ==== =
RoundStart PROC
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

PlayerTurn :
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

PlayerBust :
mov edx, OFFSET msgLose
call WriteString
call Crlf
inc player1Losses
ret

PlayerStay :
mov edx, OFFSET msgStay
call WriteString
call Crlf

ComputerTurn :
; Simple AI : draws until total >= 16
mov eax, player2Total
CompLoop :
cmp eax, 16
jge CompStay
call DrawCard
add player2Total, eax
mov eax, player2Total
jmp CompLoop

CompStay :
; Show computer total
mov edx, OFFSET msgComputerTotal
call WriteString
mov eax, player2Total
call WriteDec
call Crlf

call DetermineWinner
ret
RoundStart ENDP


; ==== = DETERMINE WINNER ==== =
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

Tie :
mov edx, OFFSET msgTie
call WriteString
call Crlf
ret

PlayerWin :
mov edx, OFFSET msgWin
call WriteString
call Crlf
ret

PlayerLose :
mov edx, OFFSET msgLose
call WriteString
call Crlf
inc player1Losses
ret
DetermineWinner ENDP


; ==== = DRAW CARD ==== =
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


; ==== = FINAL RESULT ==== =
FinalResult PROC
call Crlf
mov eax, player1Losses
cmp eax, 2
jg Died
mov edx, OFFSET msgFinalSurvive
call WriteString
call Crlf
ret
Died :
mov edx, OFFSET msgFinalDeath
call WriteString
call Crlf
ret
FinalResult ENDP

END main

