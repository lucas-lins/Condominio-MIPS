.data
# Inicialmente, vamos definir as Estruturas de Dados do sistema

# 1 - Tamanhos máximos para Strings
	# O comando .eqv substitui o segundo valor pelo primeiro. Assim, sempre que
	# usarmos MAX_ALGUMA_COISA, essa "string" será substituída pelo valor ao lado.
	.eqv MAX_TAM_NOME 40
	.eqv MAX_TAM_MODELO 30
	.eqv MAX_TAM_COR 15
	.eqv MAX_MORADORES_AP 5
	.eqv MAX_APARTAMENTOS 40
	
# 2 - Estrutura dos veículos
	.eqv TIPO_VEICULO_OFFSET 0
	.eqv MODELO_VEICULO_OFFSET (TIPO_VEICULO_OFFSET + 1)
	.eqv COR_VEICULO_OFFSET (MODELO_VEICULO_OFFSET + MAX_TAM_MODELO)
	.eqv TAM_VEICULO (COR_VEICULO_OFFSET + MAX_TAM_COR)
	
# 3 - Estrutura dos moradores
	.eqv MORADOR1_OFFSET 0
	.eqv MORADOR2_OFFSET (MORADOR1_OFFSET + MAX_TAM_NOME)
	.eqv MORADOR3_OFFSET (MORADOR2_OFFSET + MAX_TAM_NOME)
	.eqv MORADOR4_OFFSET (MORADOR3_OFFSET + MAX_TAM_NOME)
	.eqv MORADOR5_OFFSET (MORADOR4_OFFSET + MAX_TAM_NOME)
	
	# Número de moradores (inteiro - 4 bytes)
	.eqv NUM_MORADORES_OFFSET (MORADOR5_OFFSET + MAX_TAM_NOME)
	
	# Ocupado/vazio
	.eqv STATUS_AP_OFFSET (NUM_MORADORES_OFFSET + 4)
	
	# Veículo
	.eqv VEICULO_OFFSET (STATUS_AP_OFFSET + 4)
	
	# Tamanho total do apartamento
	.eqv TAM_AP 256
	
	# Alocação de espaço para todos os apartamentos
	apartamentos: .space 10240
	
	# Parser
	entrada: .space 100
	banner: .asciiz "AGJL-shell>>"
	newline: .asciiz "\n"
	cmd_ad_morador: .asciiz "ad_morador-"
	cmd_rm_morador: .asciiz "rm_morador-"
	cmd_ad_auto:    .asciiz "ad_auto-"
	cmd_rm_auto:    .asciiz "rm_auto-"
	msg_invalido:   .asciiz "Comando invalido\n"
	msg_debug: .asciiz "Apartamento: "
	
	tipo_buffer: .space 2
	
	# Strings
	msg_ap_cheio: .asciiz "Erro! Apartamento com número máximo de moradores\n"
	msg_ap_invalido: .asciiz "Erro! Apartamento inválido."
	msg_ad_sucesso: .asciiz "Morador adicionado!"
	
.text 
.globl main

main:
	jal imprimir_banner
	jal ler_entrada
	jal limpa_newline
	jal verificar_comando
	j main


ap_para_indice:	# Transforma o índice do apartamento num índice interno
	lb $t0, 0($a0)
	sub $t0, $t0, 48
	subi $t0, $t0, 1
	
	lb   $t1, 1($a0)
	sub  $t1, $t1, 48
	
	lb   $t2, 2($a0)
	sub  $t2, $t2, 48
	
	li   $t3, 10
    	mul  $t1, $t1, $t3
    	add  $t1, $t1, $t2
    	subi $t1, $t1, 1
    	
    	li   $t3, 4
    	mul  $t0, $t0, $t3
    	add  $v0, $t0, $t1
    	
    	jr $ra
    	
obter_andereco_ap:
	la   $t0, apartamentos     # Carrega o endereço base do vetor

    	li   $t1, TAM_AP
    	mul  $t2, $a0, $t1         # Deslocamento = índice * TAM_AP

    	add  $v0, $t0, $t2         # Endereço do AP

    	jr   $ra 
	
imprimir_banner:
	li $v0, 4
    	la $a0, banner
    	syscall
    	jr $ra
    	
ler_entrada:
	li $v0, 8          # syscall para ler string
   	la $a0, entrada    # buffer
    	li $a1, 100        # tamanho máximo
    	syscall
    	jr $ra
    	
verificar_comando:
 	la $t0, entrada        # início da string digitada

    	# Verifica se começa com "ad_morador-"
    	la $t1, cmd_ad_morador
    	jal compara_prefixo
    	beq $v0, 1, chama_ad_morador

    	# Verifica se começa com "rm_morador-"
    	la $t1, cmd_rm_morador
    	jal compara_prefixo
    	beq $v0, 1, chama_rm_morador

    	# Verifica se começa com "ad_auto-"
    	la $t1, cmd_ad_auto
    	jal compara_prefixo
    	beq $v0, 1, chama_ad_auto

    	# Verifica se começa com "rm_auto-"
    	la $t1, cmd_rm_auto
    	jal compara_prefixo
    	beq $v0, 1, chama_rm_auto

    	# Nenhum comando bateu → comando inválido
    	li $v0, 4
    	la $a0, msg_invalido
    	syscall
    	jr $ra
    	
compara_prefixo:
	li $v0, 1  # assume que são iguais
	
limpa_newline:
	la $t0, entrada
	
loop_limpa:
	lb $t1, 0($t0)
	
	beq  $t1, $zero, fim_limpa  # Se é nulo, fim da string → encerra
   	beq  $t1, 10, apaga_e_fim   # Se é newline (ASCII 10), apaga e encerra
	
	addi $t0, $t0, 1   # Vai para o próximo caractere
    	j loop_limpa
    	
apga_e_fim:
	sb $zero, 0($t0) # Substitui '\n' por nulo
	
fim_limpa:
	jr $ra  

compara_loop:
	lb $t2, 0($t0)   # pega caractere da entrada
    	lb $t3, 0($t1)   # pega caractere do prefixo

    	beq $t3, $zero, fim_compara  # chegou no fim do prefixo

    	beq $t2, $t3, continua
    	li $v0, 0      # são diferentes
    	jr $ra

continua:
	addi $t0, $t0, 1
    	addi $t1, $t1, 1
    	j compara_loop

fim_compara:
    	jr $ra
    	
chama_ad_morador:
 	# a0 = endereço base da entrada
    	la   $t0, entrada
    	addi $t0, $t0, 11     # pula "ad_morador-" (11 chars)

    	# Salvar endereço do número do apartamento
    	move $a0, $t0         
    	jal  ap_para_indice   # $v0 = índice do apartamento
    	move $s0, $v0         # salva o índice em $s0

    	# pula os 3 dígitos do ap e o '-'
    	addi $t0, $t0, 4      
    	move $a0, $t0         # agora $a0 aponta para o nome

    	# agora chamar a função de adicionar morador
    	move $a1, $a0         # $a1 = endereço do nome
    	move $a0, $s0         # $a0 = índice do ap
    	jal  ad_morador

    	jr $ra

ad_morador:
	addi $sp, $sp, -12
	sw $ra, 8($sp)
	sw $s0, 4($sp)
	sw $s1, 0($sp)
	
	li $t0, TOTAL_APARTAMENTOS
	

chama_rm_morador:
    	la $t0, entrada
    	addi $t0, $t0, 12
    	
    	move $a0, $t0
    	jal ap_para_indice
    	move $s0, $v0
    	
    	addi $t0, $t0, 4
    	move $a0, $s0          # $a0 = índice do ap
    	move $a1, $t0

	jal rm_morador
	
	jr $ra
	
rm_morador:
	# Implementação
	
chama_ad_auto:
    	# Endereço inicial da string
    	la   $t0, entrada
   	addi $t0, $t0, 8      # pula "ad_auto-"

    	# Pega índice do apartamento
    	move $a0, $t0
    	jal  ap_para_indice   # $v0 = índice do apartamento
    	move $s0, $v0         # salva índice

    	# Pula 3 dígitos do ap e o '-'
    	addi $t0, $t0, 4

    	# Pega o tipo (um caractere)
    	lb   $t1, 0($t0)      # carrega o tipo (ex: 'C' ou 'M')
    	sb   $t1, tipo_buffer

    	# Pula o tipo e o '-'
    	addi $t0, $t0, 2

    	# Modelo começa aqui
    	move $t2, $t0

encontra_hifen:
    	lb $t3, 0($t0)
    	beq $t3, 45, fim_modelo  # 45 = código ASCII de '-'
    	addi $t0, $t0, 1
    	j encontra_hifen

fim_modelo:
    	sb $zero, 0($t0)    # insere NULL terminador no fim do modelo
    	addi $t0, $t0, 1    # pula o '-'

    	# Agora t2 = modelo, t0 = cor
    	move $a0, $s0       # índice do apartamento
    	la   $a1, tipo_buffer
    	move $a2, $t2       # modelo
    	move $a3, $t0       # cor

    	jal  ad_auto

    	jr $ra

ad_auto:
	#Implementação
	
chama_rm_auto:
    	la $t0, entrada
    	addi $t0, $t0, 8
    	
    	move $a0, $t0
    	jal ap_para_indice
    	
    	move $a0, $v0
    
 	jal rm_auto
 	
 	jr $ra

rm_auto:
	#Implementação

limpar_ap:

info_ap:

info_geral:

salvar:

recarregar:

formatar:
