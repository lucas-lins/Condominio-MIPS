.data
source:     .asciiz "2008 tamb�m!"
dest:       .space 100         # Espa�o para armazenar a string concatenada
initial:    .asciiz "87 � nosso,  "  # Parte inicial da string destino
newline:    .asciiz "\n"

.text
.globl main

main:
    # Copia a string inicial para o destino
    la $a0, dest
    la $a1, initial
    jal strcpy                 # Usando uma fun��o strcpy para setup (pode implementar se desejar)

    # Chamada para strcat
    la $a0, dest               # $a0 = destino
    la $a1, source             # $a1 = origem
    jal strcat                 # chama strcat

    # Impress�o do resultado
    move $a0, $v0              # resultado da strcat est� em $v0
    li $v0, 4
    syscall

    # Imprimir nova linha
    la $a0, newline
    li $v0, 4
    syscall

    li $v0, 10
    syscall

# ------------------------------------------------------
# Fun��o strcat: concatena string em $a1 ao final da string em $a0
# Retorna $a0 em $v0
# ------------------------------------------------------
strcat:
    move $t0, $a0       # $t0 = endere�o de destino
    move $t1, $a1       # $t1 = endere�o de origem

find_null:
    lb $t2, 0($t0)      # carrega byte de destino
    beqz $t2, copy_loop # achou o '\0' ? ir para c�pia
    addiu $t0, $t0, 1   # avan�a destino
    j find_null

copy_loop:
    lb $t3, 0($t1)      # carrega byte de origem
    sb $t3, 0($t0)      # armazena no destino
    addiu $t0, $t0, 1   # avan�a destino
    addiu $t1, $t1, 1   # avan�a origem
    bnez $t3, copy_loop # continua at� encontrar '\0'

    move $v0, $a0       # retorna endere�o de destino
    jr $ra

# ------------------------------------------------------
# Fun��o auxiliar strcpy para copiar initial ? dest
# ------------------------------------------------------
strcpy:
    lb $t1, 0($a1)	# carrega um caractere da origem para $t1
    sb $t1, 0($a0)	# armazena o byte com o caractere no destino
    beq $t1, $zero, end_copy	# caso o byte for \0, pula pro encerramento
    addi $a0, $a0, 1	# avan�a o ponteiro do destino
    addi $a1, $a1, 1	# avan�a o ponteiro da origem
    j strcpy		# repete o loop

end_copy:
    jr $ra		# volta pra main

