; ====== Horror Blackjack.asm ======
; Author(s): Taratong Dolinsky & Dathan
; Modified: Horror Version with Screen Flash Effects
; Date: October 30, 2025
INCLUDE Irvine32.inc

.data
msgUser BYTE "The deck groans, you hear a whisper. You received a card: ", 0
msgUserCurrent BYTE "Your current card value is: ", 0
msgComp BYTE "Your opponent has appeared with a card: ", 0
msgCompCurrent BYTE "Opponent's current card value is: ", 0
msgCard BYTE "Do you wish to draw another card? (Y/N): ", 0
msgNewCard BYTE "You drew another card worth: ", 0

msgBust BYTE "You have exceeded 21... the chainsaw draws nearer.", 0
msgDealerBust BYTE "Your opponent exceeded 21... the chainsaw has spared you!", 0
msgWin BYTE "Your total is higher. The chainsaw has spared you!", 0
msgLose BYTE "Your opponent has a higher total. The chainsaw draws nearer.", 0
msgTie BYTE "Both totals are equal... The chainsaw remains still.", 0

msgEndBad BYTE "You died....", 0
msgEndGood BYTE "You survived.... for now.", 0
msgRedemption BYTE "The wins are equal... last round", 0

msgFlash BYTE "VIOLENT FLASH", 0

userWins DWORD 0
compWins DWORD 0
roundCount DWORD 0


.code
main PROC
    call Randomize

; ---------------------------------------------------------
; 3-ROUND LOOP
; ---------------------------------------------------------
RoundLoop:
    mov eax, roundCount
    cmp eax, 3
    je EvaluateGame

    call ScreenFlash
    call RunRound

    inc roundCount
    jmp RoundLoop


; ---------------------------------------------------------
; AFTER 3 ROUNDS
; ---------------------------------------------------------
EvaluateGame:
    mov eax, userWins
    mov ebx, compWins
    cmp eax, ebx
    je RedemptionRound

    ja GoodEnding
    jmp BadEnding


; ---------------------------------------------------------
; REDEMPTION ROUND
; ---------------------------------------------------------
RedemptionRound:
    call CrLf
    mov edx, OFFSET msgRedemption
    call WriteString
    call CrLf

    call ScreenFlash

    ; reset round counter to avoid skipping logic
    mov roundCount, 0 

    call RunRound

    mov eax, userWins
    mov ebx, compWins

    cmp eax, ebx
    ja GoodEnding
    jb BadEnding
    jmp BadEnding        ; still tied ? death


; ---------------------------------------------------------
; GOOD ENDING
; ---------------------------------------------------------
GoodEnding:
    call CrLf
    mov edx, OFFSET msgEndGood
    call WriteString
    call CrLf
    jmp ExitProgram


; ---------------------------------------------------------
; BAD ENDING
; ---------------------------------------------------------
BadEnding:
    call CrLf
    mov edx, OFFSET msgEndBad
    call WriteString
    call CrLf
    jmp ExitProgram


; ---------------------------------------------------------
; SCREEN FLASH (10 flashes)
; ---------------------------------------------------------
ScreenFlash PROC
    mov ecx, 10

FlashLoop:
    call Clrscr
    mov edx, OFFSET msgFlash
    call WriteString
    call CrLf

    mov eax, 50
    call Delay

    call Clrscr
    mov eax, 50
    call Delay

    loop FlashLoop

    call Clrscr
    ret
ScreenFlash ENDP


; ---------------------------------------------------------
; PLAY ONE ROUND
; ---------------------------------------------------------
RunRound PROC
    mov ebx, 0       ; user total
    mov edi, 0       ; dealer total

    ; PLAYER FIRST CARD
    mov edx, OFFSET msgUser
    call WriteString

    mov eax, 10
    call RandomRange
    inc eax
    mov ebx, eax
    call WriteDec
    call CrLf

    ; DEALER FIRST CARD
    mov edx, OFFSET msgComp
    call WriteString

    mov eax, 10
    call RandomRange
    inc eax
    mov edi, eax
    call WriteDec
    call CrLf


; ---------------------------------------------------------
; PLAYER TURN
; ---------------------------------------------------------
PlayerTurn:
    mov edx, OFFSET msgCard
    call WriteString
    call ReadChar

    cmp al, 'y'
    je DrawPlayerCard
    cmp al, 'Y'
    je DrawPlayerCard
    cmp al, 'n'
    je DealerTurn
    cmp al, 'N'
    je DealerTurn
    jmp PlayerTurn


; ---------------------------------------------------------
; PLAYER DRAWS
; ---------------------------------------------------------
DrawPlayerCard:
    call CrLf
    mov edx, OFFSET msgNewCard
    call WriteString

    mov eax, 10
    call RandomRange
    inc eax

    mov esi, eax
    call WriteDec
    call CrLf

    add ebx, esi

    mov edx, OFFSET msgUserCurrent
    call WriteString
    mov eax, ebx
    call WriteDec
    call CrLf

    cmp ebx, 21
    jg PlayerBust

    jmp PlayerTurn


; ---------------------------------------------------------
; PLAYER BUST
; ---------------------------------------------------------
PlayerBust:
    mov edx, OFFSET msgBust
    call WriteString
    call CrLf

    inc compWins
    ret


; ---------------------------------------------------------
; DEALER TURN
; ---------------------------------------------------------
DealerTurn:

DealerLoop:
    cmp edi, 17
    jge CompareTotals

    mov eax, 10
    call RandomRange
    inc eax

    add edi, eax

    ; >>> FIXED: NOW PRINT DEALER’S NEW TOTAL <<<
    mov edx, OFFSET msgCompCurrent
    call WriteString
    mov eax, edi
    call WriteDec
    call CrLf

    cmp edi, 21
    jg DealerBust
    jmp DealerLoop


DealerBust:
    mov edx, OFFSET msgDealerBust
    call WriteString
    call CrLf
    inc userWins
    ret


; ---------------------------------------------------------
; COMPARE TOTALS
; ---------------------------------------------------------
CompareTotals:
    cmp ebx, edi
    je RoundTie

    cmp ebx, edi
    jg RoundUserWin
    jmp RoundDealerWin


RoundUserWin:
    mov edx, OFFSET msgWin
    call WriteString
    call CrLf
    inc userWins
    ret


RoundDealerWin:
    mov edx, OFFSET msgLose
    call WriteString
    call CrLf
    inc compWins
    ret


RoundTie:
    mov edx, OFFSET msgTie
    call WriteString
    call CrLf
    ret

RunRound ENDP


ExitProgram:
    exit

main ENDP
END main
