.data
source:     .asciiz "87 � do Sport"
dest:       .space 50			# reservando 50 bytes para guardar a c�pia
newline:    .asciiz "\n"		# define a quebra de linha

.text
.globl main

main:
    la $a0, dest          # carrega o endere�o de destino em $a0
    la $a1, source        # carrega o endere�o de origem em $a1
    jal strcpy            # chama strcpy

    # imprime string copiada
    la $a0, dest	 # carrega o endere�o da string original
    li $v0, 4		 # chama o syscall pra imprimir string
    syscall

    # imprime nova linha
    la $a0, newline	 # chama o endere�o de 'newline' 
    li $v0, 4		 # chama o syscall pra imprimir string
    syscall
    
    # encerramento do programa
    li $v0, 10            # encerra programa com o syscall 10
    syscall

# Fun��o strcpy
strcpy:
    lb $t1, 0($a1)	# carrega um caractere da origem para $t1
    sb $t1, 0($a0)	# armazena o byte com o caractere no destino
    beq $t1, $zero, end_copy	# caso o byte for \0, pula pro encerramento
    addi $a0, $a0, 1	# avan�a o ponteiro do destino
    addi $a1, $a1, 1	# avan�a o ponteiro da origem
    j strcpy		# repete o loop

end_copy:
    jr $ra		# volta pra main
