processor 18F8722
radix   dec
    
CONFIG  OSC = HS  ; use the high speed external crystal on the PCB
CONFIG  WDT = OFF ; turn off the watchdog timer
CONFIG  LVP = OFF ; turn off low voltage mode

#include <xc.inc>

DIGIT0 equ 0b10000100
DIGIT1 equ 0b11110101
DIGIT2 equ 0b01001100
DIGIT3 equ 0b01100100
DIGIT4 equ 0b00110101
DIGIT5 equ 0b00100110
DIGIT6 equ 0b00000110
DIGIT7 equ 0b11110100
DIGIT8 equ 0b00000100
DIGIT9 equ 0b00100100

DIGIT0_DOT equ 0b10000000
DIGIT1_DOT equ 0b11110001
DIGIT2_DOT equ 0b01001000
DIGIT3_DOT equ 0b01100000
DIGIT4_DOT equ 0b00110001
DIGIT5_DOT equ 0b00100010
DIGIT6_DOT equ 0b00000010
DIGIT7_DOT equ 0b11110000
DIGIT8_DOT equ 0b00000000
DIGIT9_DOT equ 0b00100000


PSECT resetVector, class=CODE, reloc=2
resetVector:
	goto start

; --- VARIABLES ---

DELAY_COUNTER_OUTER	equ 0x200
DELAY_COUNTER_INNER	equ 0x201

; --- FUNCTIONS ---

delay:; void -> void
	_delay_loop_inner:
		incf	DELAY_COUNTER_INNER, a
		incf	DELAY_COUNTER_INNER, a
		incf	DELAY_COUNTER_INNER, a
		incf	DELAY_COUNTER_INNER, a
		decf	DELAY_COUNTER_INNER, a
		decf	DELAY_COUNTER_INNER, a
		decf	DELAY_COUNTER_INNER, a
		bz	_delay_loop_inner_end
		goto	_delay_loop_inner
	_delay_loop_inner_end:
	incf	DELAY_COUNTER_OUTER, a
	incf	DELAY_COUNTER_OUTER, a
	incf	DELAY_COUNTER_OUTER, a
	incf	DELAY_COUNTER_OUTER, a
	decf	DELAY_COUNTER_OUTER, a
	decf	DELAY_COUNTER_OUTER, a
	decf	DELAY_COUNTER_OUTER, a
	bz	delay
	return

; --- START ---

; IO ports:
; RFx -> General output (inverted for 7-segment displays, normal for bulbs)
; RH0 -> Q1 (capacitor for right 7-segment display, inverted)
; RH1 -> Q2 (capacitor for left 7-segment display, inverted)
; RA4 -> Q3 (capacitor for LED bulbs)
; RB0 -> PB2 (left push button)
; RJ5 -> PB1 (right push button)

PSECT start, class=CODE, reloc=2
start:
	; init TRIS states
	clrf	TRISF, a	; RFx -> General output
	bcf	TRISH, 0, a	; RH0 -> Q1
	bcf	TRISH, 1, a	; RH1 -> Q2
	bcf	TRISA, 4, a	; RA4 -> Q3
	bsf	TRISB, 0, a	; RB0 -> PB2
	bsf	TRISJ, 5, a	; RB1 -> PB1

loop:
	; LED bulbs
	movlw	0b10101010
	movwf	LATF
	bsf	LATA, 4, a
	call	delay
	bcf	LATA, 4, a
	
	; Left 7-segment display
	movlw	DIGIT6
	movwf	LATF, a
	bcf	LATH, 1, a
	call	delay
	bsf	LATH, 1, a
	
	; Right 7-segment display
	movlw	DIGIT4
	movwf	LATF, a
	bcf	LATH, 0, a
	call	delay
	bsf	LATH, 0, a
	
	bra loop
	end
