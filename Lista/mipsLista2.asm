.data

.text
main:
    li $t0, 0xFFFF0000      # Endere�o de controle do teclado
    li $t1, 0xFFFF0004      # Endere�o de dados do teclado
    li $t2, 0xFFFF0008      # Endere�o de controle do display
    li $t3, 0xFFFF000C      # Endere�o de dados do display

loop:
    lw $t4, 0($t0)          # L� o controle do teclado
    beq $t4, $zero, loop    # Se n�o h� tecla pressionada, volta para o loop

    lw $t5, 0($t1)          # L� o caractere do teclado

    # Espera o display estar pronto
espera_display:
    lw $t6, 0($t2)          # L� o controle do display
    beq $t6, $zero, espera_display

    sw $t5, 0($t3)          # Escreve o caractere no display

    j loop                  # Volta para o loop
#Para conectar e testar, v� em tools -> keyboard and display -> clice em connect to MIPS e escreva no keyboard.