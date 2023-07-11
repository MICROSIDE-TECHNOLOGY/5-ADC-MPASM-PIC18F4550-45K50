;====================================================================

	LIST P=18F4550 
	#include "P18f4550.INC" ;ENCABEZADO

;====================================================================
; Bits de configuracion
;--------------------------------------------------------------------

  CONFIG  PLLDIV = 5            ; PLL Prescaler Selection bits (Divide by 5 (20 MHz oscillator input))
  CONFIG  CPUDIV = OSC2_PLL3    ; System Clock Postscaler Selection bits ([Primary Oscillator Src: /2][96 MHz PLL Src: /3])
  CONFIG  USBDIV = 2            ; USB Clock Selection bit (used in Full-Speed USB mode only; UCFG:FSEN = 1) (USB clock source comes from the 96 MHz PLL divided by 2)
  CONFIG  FOSC = HSPLL_HS       ; Oscillator Selection bits (HS oscillator, PLL enabled (HSPLL))
  CONFIG  FCMEN = ON            ; Fail-Safe Clock Monitor Enable bit (Fail-Safe Clock Monitor enabled)
  CONFIG  PWRT = ON             ; Power-up Timer Enable bit (PWRT enabled)
  CONFIG  BOR = SOFT            ; Brown-out Reset Enable bits (Brown-out Reset enabled and controlled by software (SBOREN is enabled))
  CONFIG  BORV = 1              ; Brown-out Reset Voltage bits (Setting 2 4.33V)
  CONFIG  VREGEN = ON           ; USB Voltage Regulator Enable bit (USB voltage regulator enabled)
  CONFIG  WDT = OFF             ; Watchdog Timer Enable bit (WDT disabled (control is placed on the SWDTEN bit))
  CONFIG  PBADEN = OFF          ; PORTB A/D Enable bit (PORTB<4:0> pins are configured as digital I/O on Reset)
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
    MOVLW   0x0E
    BANKSEL(ADCON1)
    MOVLW   ADCON1  ;CONFIGURA EL CANAL 0 COMO ANALOGICO
    MOVLW   0xBE
    MOVWF   ADCON2  ;CONFIGURA TIEMPO DE ADQUISICION ANALOGICO
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