;====================================================================

	LIST P=18F45K50 
	#include "P18f45K50.INC" ;ENCABEZADO

;====================================================================
; Bits de configuracion
;--------------------------------------------------------------------
  CONFIG  PLLSEL = PLL3X        ; PLL Selection (3x clock multiplier)
  CONFIG  CFGPLLEN = ON         ; PLL Enable Configuration bit (PLL Enabled)
  CONFIG  LS48MHZ = SYS48X8     ; Low Speed USB mode with 48 MHz system clock (System clock at 48 MHz, USB clock divider is set to 8)
  CONFIG  FOSC = INTOSCIO       ; Oscillator Selection (Internal oscillator)
  CONFIG  nPWRTEN = ON          ; Power-up Timer Enable (Power up timer enabled)
  CONFIG  BORV = 250            ; Brown-out Reset Voltage (BOR set to 2.5V nominal)
  CONFIG  nLPBOR = ON           ; Low-Power Brown-out Reset (Low-Power Brown-out Reset enabled)
  CONFIG  WDTEN = OFF           ; Watchdog Timer Enable bits (WDT disabled in hardware (SWDTEN ignored))
  CONFIG  PBADEN = OFF          ; PORTB A/D Enable bit (PORTB<5:0> pins are configured as digital I/O on Reset)
  CONFIG  LVP = OFF             ; Single-Supply ICSP Enable bit (Single-Supply ICSP disabled)

;====================================================================
; MEMORIA DE DATOS
;--------------------------------------------------------------------

	CBLOCK  0x00
	VPOT
	ENDC

;====================================================================
; VECTOR DE INICIO
;--------------------------------------------------------------------

	ORG		0x2000
	GOTO		START
	
	ORG		0x2008
	RETFIE
	
	ORG		0x2018
	RETFIE

;====================================================================
; PROGRAMA PRINCIPAL
;--------------------------------------------------------------------
     
START
    MOVLW   0x70
    MOVWF   OSCCON  ;CONFIGURA OSCILADOR
    SETF    TRISA   ;PUERTO A SE CONFIGURA COMO ENTRADAS
    CLRF    TRISB   ;PUERTO B SE CONFIGURA COMO SALIDAS
    CALL    SET_ADC ;CONFIGURA ADC-CANAL 0
LOOP
    CALL    GET_ADC ;OBTIENE VALOR ADC-CANAL 0
    MOVLW   0x03    ;MUEVE LITERAL A WREG
    CPFSLT  VPOT,0  ;COMPARA MSB DE VPOT CON WREG
    GOTO    M768
    MOVLW   0x02
    CPFSLT  VPOT,0
    GOTO    M512
    MOVLW   0x01
    CPFSLT  VPOT,0
    GOTO    M256
    MOVLW   0xE0
    CPFSLT  VPOT+1,0;COMPARA LSB DE VPOT CON WREG
    GOTO    M224
    MOVLW   0x70
    CPFSLT  VPOT+1,0
    GOTO    M112
    MOVLW   0x00
    MOVWF   LATB
    GOTO    LOOP
;BIFURCACION DEL PROGRAMA CUANDO VPOT > 112 EN DECIMAL
M112
    MOVLW   0x01
    MOVWF   LATB
    GOTO    LOOP
;BIFURCACION DEL PROGRAMA CUANDO VPOT > 224 EN DECIMAL
M224
    MOVLW   0x03
    MOVWF   LATB
    GOTO    LOOP
;BIFURCACION DEL PROGRAMA CUANDO VPOT > 256 EN DECIMAL
M256
    MOVLW   0xC0
    CPFSLT  VPOT+1,0
    GOTO    M448
;BIFURCACION DEL PROGRAMA CUANDO VPOT > 336 EN DECIMAL
M336
    MOVLW   0x07
    MOVWF   LATB
    GOTO    LOOP
;BIFURCACION DEL PROGRAMA CUANDO VPOT > 448 EN DECIMAL
M448
    MOVLW   0x0F
    MOVWF   LATB
    GOTO    LOOP
;BIFURCACION DEL PROGRAMA CUANDO VPOT > 512 EN DECIMAL
M512
    MOVLW   0xA0
    CPFSLT  VPOT+1,0
    GOTO    M672
;BIFURCACION DEL PROGRAMA CUANDO VPOT > 560 EN DECIMAL
M560
    MOVLW   0x1F
    MOVWF   LATB
    GOTO    LOOP
;BIFURCACION DEL PROGRAMA CUANDO VPOT > 672 EN DECIMAL
M672
    MOVLW   0x3F
    MOVWF   LATB
    GOTO    LOOP
;BIFURCACION DEL PROGRAMA CUANDO VPOT > 768 EN DECIMAL
M768
    MOVLW   0xB6
    CPFSLT  VPOT+1,0
    GOTO    M950
    MOVLW   0x7F
    MOVWF   LATB
    GOTO    LOOP
;BIFURCACION DEL PROGRAMA CUANDO VPOT > 950 EN DECIMAL
M950
    MOVLW   0xFF
    MOVWF   LATB
    GOTO    LOOP

;====================================================================
; ADC
;--------------------------------------------------------------------

SET_ADC
    MOVLW   0x2F
    BANKSEL(ANSELA)
    MOVWF   ANSELA
    CLRF    CCP2CON
    CLRF    CCPR2L
    CLRF    CCPR2H
    CLRF    ADCON1
    MOVLW   0xBE
    MOVWF   ADCON2
    CLRF    ADRESL
    CLRF    ADRESH
    MOVLW   0x01
    MOVWF   ADCON0
    RETURN

GET_ADC
    MOVLW   0x03    ;MUEVE LITERAL A WREG
    BANKSEL(ADCON0) ;SELECCIONA EL BANCO DE ADCON0
    MOVWF   ADCON0  ;CONFIGURA ENTRADA ANALOGICA
ADC_DONE
    NOP
    BTFSC   ADCON0,1;REVISA SI HA FINALIZADO CONVERSION ANALOGICA
    GOTO    ADC_DONE
    ;ADC CON RESOLUCION DE 10 BITS, DOS BYTES REQUERIDOS PARA ALMACENARLO
    MOVFF   ADRESH,VPOT	 ;BYTE MAS SIGNIFICATIVO (MSB)
    MOVFF   ADRESL,VPOT+1;BYTE MENOS SIGNIFICATIVO (LSB)
    RETURN

END