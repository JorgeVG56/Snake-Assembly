DRAW_BG PROC

    SAVE_REGS <AX,BX,CX,DX>

    ; BORDER
    MOV AH, 6
    MOV AL, 0
    MOV BH, BORDER_COLOR
    MOV CH, 0
    MOV CL, 0

    MOV DH, Y_SCREEN
    MOV DL, X_SCREEN
    INT 10H

    ; INSIDE
    MOV AH,7
    MOV AL,0
    MOV BH,INSIDE_COLOR
    MOV CH,1
    MOV CL,2
    MOV DH, Y_LIM
    MOV DL, X_LIM

    INT 10H

    RESTORE_REGS <DX,CX,BX,AX>
    RET
    
DRAW_BG ENDP

IMPRIMIR_GAMEOVER PROC
    SAVE_REGS< DX >
    CALCULAR_CENTRO Y_SCREEN, 1, msgsRenglonIn
    LEA DX, msgFin
    MOV msgsAct, DX
    LEA DX, tamMsgFin
    MOV msgsTamsAct, DX
    MOV nMsgsAct, 1
    CALL IMPRIMIR_TEXTO_CENTRADO
    RESTORE_REGS< DX >
    RET
ENDP

IMPRIMIR_MENU PROC
    
    SAVE_REGS< DX >
    
    CALL DRAW_BG
    ;TITULO:
    MOV msgsRenglonIn, 2
    LEA DX, titulo
    MOV msgsAct, DX
    LEA DX, tamsTitulo
    MOV msgsTamsAct, DX
    ONEB_TWOB_REG DL, DH, nMsgsTitulo
    MOV nMsgsAct, DX
    CALL IMPRIMIR_TEXTO_CENTRADO
    
    ;INTEGRANTES:
    MOV msgsRenglonIn, 9
    CALL IMPRIMIR_INTEGRANTES
    
    ;CONTINUAR:
    MOV msgsRenglonIn, 19
    LEA DX, msgPausa
    MOV msgsAct, DX
    LEA DX, tamMsgPausa
    MOV msgsTamsAct, DX
    MOV nMsgsAct, 1
    CALL IMPRIMIR_TEXTO_CENTRADO

    RESTORE_REGS< DX >
    RET
IMPRIMIR_MENU ENDP

IMPRIMIR_INTEGRANTES PROC

    SAVE_REGS< AX, BX, CX, DX, DI, SI >
    MOV DH, msgsRenglonIn
    MOV SI, 0
    MOV DI, 0
    MOV CX, 0
    
    CENTRAR_TEXTO_INTEGRANTES:
    ; POSICIONAR CURSOR:
        ONEB_TWOB_REG AL, AH, tamsNoms[DI]
        MOV BL, AL
        ADD BL, tamIDs
        CALCULAR_CENTRO X_SCREEN, BL, DL
        
        ADD AX, SI;SIG.NOM
        PUSH AX
        
        ONEB_TWOB_REG AH, AL, 2 ;INTEGRANTE
        MOV BH, 0
        INT 10H
        SAVE_REGS< AX, DX >
        PRINT_CAR "*"
        INC DL
        INT 10H
        PRINT_CAR " "
        RESTORE_REGS< DX, AX >
        ADD DL, 2
        INT 10H
        SAVE_REGS< AX, DX >
        PRINT noms[SI]
        RESTORE_REGS< DX, AX >
        
        ADD DL, tamsNoms[DI] ;ID
        INT 10H
        MOV SI, CX
        ADD CL, tamIDs
        PUSH DX
        PRINTLN IDs[SI]
        POP DX
        
        INC DH; SIG RENGLON
        POP SI; SIG NOM
        INC SI; $->
        INC DI; SIG POS
        
    CMP DI, nIntegrantes
    JL CENTRAR_TEXTO_INTEGRANTES

    RESTORE_REGS< SI, DI, DX, CX, BX, AX >
    RET
IMPRIMIR_INTEGRANTES ENDP

IMPRIMIR_TEXTO_CENTRADO PROC
    
    SAVE_REGS< AX, BX, DX, DI, SI >
    MOV DH, msgsRenglonIn
    MOV SI, 0
    MOV DI, 0
    
    CENTRAR_TEXTO:
    ; POSICIONAR CURSOR:
        MOV BX, msgsTamsAct
        ONEB_TWOB_REG AL, AH, [BX][DI]
        CALCULAR_CENTRO X_SCREEN, [BX][DI], DL
        ADD AX, SI;SIG.POS
        PUSH AX
        
        ONEB_TWOB_REG AH, AL, 2
        MOV BX, 0
        INT 10H
        
        MOV BX, msgsAct
        PUSH DX
        PRINTLN [BX][SI]
        POP DX
        INC DH; SIG RENGLON
        POP SI; SIG NOM
        INC SI; $->
        INC DI; SIG POS
        
    CMP DI, nMsgsAct
    JL CENTRAR_TEXTO

    RESTORE_REGS< SI, DI, DX, BX, AX >
    RET
    
IMPRIMIR_TEXTO_CENTRADO ENDP

DIBUJAR_MARCADOR PROC
    SAVE_REGS <AX, BX, CX, DX>

    ; --- 1. IMPRIMIR SCORE ACTUAL (Arriba a la izquierda: Fila 0, Columna 2) ---
    MOV AH, 02H
    MOV BH, 0
    MOV DH, 0               ; Fila 0
    MOV DL, 2               ; Columna 2
    INT 10H

    MOV AH, 09H
    LEA DX, lblScore
    INT 21H

    MOV AX, score
    CALL CONVERTIR_A_ASCII
    MOV DX, AX              ; Dirección de la cadena devuelta por la subrutina
    MOV AH, 09H
    INT 21H

    ; --- 2. IMPRIMIR HIGHSCORE (Arriba a la derecha: Fila 0, Columna 62) ---
    MOV AH, 02H
    MOV BH, 0
    MOV DH, 0               ; Fila 0
    MOV DL, 62              ; Columna 62
    INT 10H

    MOV AH, 09H
    LEA DX, lblHigh
    INT 21H

    MOV AX, highscore
    CALL CONVERTIR_A_ASCII
    MOV DX, AX
    MOV AH, 09H
    INT 21H

    RESTORE_REGS <DX, CX, BX, AX>
    RET
DIBUJAR_MARCADOR ENDP


; ========================================================
; SUBRUTINA AUXILIAR: CONVERTIR_A_ASCII
; Recibe: AX = Valor numérico a convertir
; Devuelve: AX = Puntero al inicio de la cadena en numBuffer
; ========================================================
CONVERTIR_A_ASCII PROC
    PUSH BX
    PUSH CX
    PUSH DX
    PUSH SI

    LEA SI, numBuffer
    ADD SI, 5
    MOV BYTE PTR [SI], '$'  ; Fin de cadena para la INT 21h
    MOV CX, 10              ; Divisor base 10

.CICLO_DIV:
    DEC SI
    XOR DX, DX              ; Limpiar residuo
    DIV CX                  ; AX = Cociente, DX = Residuo (el dígito)
    ADD DL, '0'             ; Convertir a carácter ASCII
    MOV [SI], DL            ; Guardar en el búfer
    OR AX, AX               ; ¿El cociente es 0?
    JNZ .CICLO_DIV          ; Si no, seguir dividiendo

    MOV AX, SI              ; Retornar la posición exacta donde empieza el número

    POP SI
    POP DX
    POP CX
    POP BX
    RET
CONVERTIR_A_ASCII ENDP