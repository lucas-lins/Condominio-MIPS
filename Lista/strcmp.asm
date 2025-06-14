.data
	str1: .asciiz "um"
	str2: .asciiz "raios"
	resultado: .asciiz "Resultado: "
	linha: .asciiz "\n"
	
.text
.globl main

main:
	li $v0, 4 # Esse comando faz com que $v0 receba o inteiro 4, ou seja, dizemos ao sistema que vamos fazer a impressão de uma string
	la $a0, resultado # Passamos o endereço de 'resultado' para o registrador $a0, para que o syscall possa funcionar
	syscall # Execução da tarefa solicitada
	
	# Para as duas instruções que seguem, la (load address) nos permite
	# carregar os endereços de 'str1' e 'str2' para $a0 e $a1 respectivamente
	la $a0, str1
	la $a1, str2
	
	jal strcmp # A instrução jal (jump and link) chama a função strcmp
	# Ao ser executada, jal salva o endereço da próxima instrução para voltar pra ela quando a função for finalizada
	
	move $t0, $v0 # ----------------
	li $v0, 1 # De maneira semelhante ao li $v0, 4 usado no começo, esse comando prepara o sistema para imprimir um inteiro
	move $a0, $t0 # move é basicamente fazer add com o registrador $0. No fim, ele vai transferir o conteúdo de $v0 para $a0 (pra usar o syscall)
	              # Isso deve acontecer aqui pois o retorno de strcmp está em $v0, mas o syscall só executa com $a0
	syscall 
	
	li $v0, 4 # Indicação ao sistema de que vamos imprimir uma string
	la $a0, linha # Passar o endereço da string a ser impressa
	syscall # Execução
	
	li $v0, 10 # Passar o inteiro 10 pra $v0 indica o encerramento do programa
	syscall # Execução

strcmp: 
strcmp_loop: # Loop para comparação de byte a byte
	lb $t0, 0($a0) # Carregamos o byte apontado por $a0 (str1) em $t0
	lb $t1, 0($a1) # Carregamos o byte apontado por $a1 (str2) em $t1
	
	bne $t0, $t1, charDif # Se os caracteres são diferentes, a gente pula pra charDif
	beq $t0, $zero, charIgu # Se os caracteres são iguais, a gente pula pra charIgu
	# Se os dois bytes foram nulos, as strings são iguais até o fim, então retornamos 0
	
	addiu $a0, $a0, 1 # Incrementa o ponteiro de str1 para o próximo caractere
	addiu $a1, $a1, 1 # Incrementa o ponteiro de str2 para o próximo caractere
	j strcmp_loop # Volta para o início do loop e verifica os próximos pares de caracteres. Como não precisamos guardar o endereço da próxima instrução, não tem porque usar jar
	
charDif:
	subu $v0, $t0, $t1 # Calcula a diferença dos valores (str1[i] - str[2]) e adiciona em $v0
	jr $ra # Retorna para a main
	
charIgu:
	li $v0, 0 # Aqui, os caracteres são iguais e nulos
	jr $ra # Retorna para a main
