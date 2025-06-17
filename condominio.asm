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
	cmd_ad_auto: .asciiz "ad_auto-"
	cmd_rm_auto: .asciiz "rm_auto-"
	cmd_limpar_ap: .asciiz "limpar_ap-" # NOVO: Comando para limpar apartamento
	cmd_info_ap: .asciiz "info_ap-" # NOVO: Comando para info_ap
	cmd_info_geral: .asciiz "info_geral" # NOVO: Comando para info_geral
	msg_invalido: .asciiz "Comando invalido\n"
	msg_debug: .asciiz "Apartamento: "
	
	tipo_buffer: .space 2
	
	# Strings
	msg_ap_cheio: .asciiz "Erro! Apartamento com numero maximo de moradores\n"
	msg_ap_invalido: .asciiz "Erro! Apartamento invalido.\n"
	msg_ad_sucesso: .asciiz "Morador adicionado!\n"
	
	# Mensagens para rm_morador
	msg_morador_nao_encontrado: .asciiz "Falha: morador nao encontrado\n"
	msg_rm_sucesso: .asciiz "Morador removido com sucesso!\n"
	
	# Mensagens para rm_auto
	msg_auto_nao_encontrado: .asciiz "Falha: automovel nao encontrado\n"
	msg_ap_invalido_auto: .asciiz "Falha: AP invalido\n"
	msg_tipo_invalido: .asciiz "Falha: tipo invalido\n"
	msg_rm_auto_sucesso: .asciiz "Automovel removido com sucesso!\n"
	
	# Mensagens para limpar_ap
	msg_limpar_sucesso: .asciiz "Apartamento limpo com sucesso!\n" # NOVO: Mensagem de sucesso para limpar_ap

	# Mensagens para info_ap
	msg_ap_vazio: .asciiz "Apartamento vazio\n"
	msg_ap_numero: .asciiz "AP: "
	msg_moradores: .asciiz "Moradores:\n"
	msg_carro: .asciiz "Carro:\n"
	msg_moto: .asciiz "Moto:\n"
	msg_modelo: .asciiz "Modelo: "
	msg_cor: .asciiz "Cor: "
	str_all: .asciiz "all"

	# Mensagens para info_geral
	msg_nao_vazios: .asciiz "Nao vazios: "
	msg_vazios: .asciiz "Vazios: "
	msg_porcentagem_open: .asciiz " ("
	msg_porcentagem_close: .asciiz "%)\n"

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
	addi $t0, $t0, -1
	
	lb $t1, 1($a0)
	sub $t1, $t1, 48
	
	lb $t2, 2($a0)
	sub $t2, $t2, 48
	
	li $t3, 10
	mul $t1, $t1, $t3
	add $t1, $t1, $t2
	addi $t1, $t1, -1
	
	li $t3, 4
	mul $t0, $t0, $t3
	add $v0, $t0, $t1
	
	jr $ra
	
obter_endereco_ap:
	la $t0, apartamentos # Carrega o endereço base do vetor

	li $t1, TAM_AP
	mul $t2, $a0, $t1 # Deslocamento = índice * TAM_AP

	add $v0, $t0, $t2 # Endereço do AP

	jr $ra
	
imprimir_banner:
	li $v0, 4
	la $a0, banner
	syscall
	jr $ra
	
ler_entrada:
	li $v0, 8 # syscall para ler string
	la $a0, entrada # buffer
	li $a1, 100 # tamanho máximo
	syscall
	jr $ra
	
verificar_comando:
	la $t0, entrada # início da string digitada

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

	# Verifica se começa com "limpar_ap-"
	la $t1, cmd_limpar_ap
	jal compara_prefixo
	beq $v0, 1, chama_limpar_ap

	# Verifica se começa com "info_ap-"
	la $t1, cmd_info_ap
	jal compara_prefixo
	beq $v0, 1, chama_info_ap

	# Verifica se é "info_geral"
	la $t1, cmd_info_geral
	jal compara_prefixo
	beq $v0, 1, chama_info_geral

	# Nenhum comando bateu -> comando inválido
	li $v0, 4
	la $a0, msg_invalido
	syscall
	jr $ra
	
compara_prefixo:
	li $v0, 1 # assume que são iguais
	j compara_loop
	
limpa_newline:
	la $t0, entrada
	
loop_limpa:
	lb $t1, 0($t0)
	
	beq $t1, $zero, fim_limpa # Se é nulo, fim da string -> encerra
	beq $t1, 10, apaga_e_fim # Se é newline (ASCII 10), apaga e encerra
	
	addi $t0, $t0, 1 # Vai para o próximo caractere
	j loop_limpa
	
apaga_e_fim:
	sb $zero, 0($t0) # Substitui '\n' por nulo
	
fim_limpa:
	jr $ra

compara_loop:
	lb $t2, 0($t0) # pega caractere da entrada
	lb $t3, 0($t1) # pega caractere do prefixo

	beq $t3, $zero, fim_compara # chegou no fim do prefixo

	beq $t2, $t3, continua
	li $v0, 0 # são diferentes
	jr $ra

continua:
	addi $t0, $t0, 1
	addi $t1, $t1, 1
	j compara_loop

fim_compara:
	jr $ra
	
chama_ad_morador:
	# a0 = endereço base da entrada
	la $t0, entrada
	addi $t0, $t0, 11 # pula "ad_morador-" (11 chars)

	# Salvar endereço do número do apartamento
	move $a0, $t0
	jal ap_para_indice # $v0 = índice do apartamento
	move $s0, $v0 # salva o índice em $s0

	# pula os 3 dígitos do ap e o '-'
	addi $t0, $t0, 4
	move $a0, $t0 # agora $a0 aponta para o nome

	# agora chamar a função de adicionar morador
	move $a1, $a0 # $a1 = endereço do nome
	move $a0, $s0 # $a0 = índice do ap
	jal ad_morador

	jr $ra

ad_morador:
	addi $sp, $sp, -12
	sw $ra, 8($sp)
	sw $s0, 4($sp)
	sw $s1, 0($sp)
	
	# Implementação da função ad_morador aqui
	# Por enquanto, apenas restaura a pilha e retorna
	
	lw $s1, 0($sp)
	lw $s0, 4($sp)
	lw $ra, 8($sp)
	addi $sp, $sp, 12
	jr $ra

chama_rm_morador:
	la $t0, entrada
	addi $t0, $t0, 12 # pula "rm_morador-" (12 chars)
	
	move $a0, $t0
	jal ap_para_indice
	move $s0, $v0
	
	addi $t0, $t0, 4 # pula os 3 dígitos do ap e o '-'
	move $a0, $s0 # $a0 = índice do ap
	move $a1, $t0 # $a1 = nome do morador

	jal rm_morador
	
	jr $ra
	
# Implementação da função rm_morador
rm_morador:
	# Salva registradores na pilha
	addi $sp, $sp, -20
	sw $ra, 16($sp)
	sw $s0, 12($sp) # índice do apartamento
	sw $s1, 8($sp) # endereço do apartamento
	sw $s2, 4($sp) # nome do morador
	sw $s3, 0($sp) # contador/índice

	move $s0, $a0 # índice do apartamento
	move $s2, $a1 # endereço do nome do morador

	# Verifica se o apartamento é válido (0-39)
	bltz $s0, ap_invalido_rm
	li $t0, 40 # MAX_APARTAMENTOS
	bge $s0, $t0, ap_invalido_rm

	# Obtém endereço do apartamento
	move $a0, $s0
	jal obter_endereco_ap
	move $s1, $v0 # $s1 = endereço do apartamento

	# Verifica se o apartamento está ocupado
	li $t1, 204 # STATUS_AP_OFFSET
	add $t2, $s1, $t1
	lw $t0, 0($t2)
	beq $t0, $zero, morador_nao_encontrado # apartamento vazio

	# Procura o morador nos 5 slots
	li $s3, 0 # contador de moradores

buscar_morador:
	li $t0, 5 # MAX_MORADORES_AP
	bge $s3, $t0, morador_nao_encontrado

	# Calcula offset do morador atual
	li $t0, 40 # MAX_TAM_NOME
	mul $t1, $s3, $t0
	add $t2, $s1, $t1 # endereço do morador atual

	# Verifica se este slot tem um morador (primeiro byte não é zero)
	lb $t3, 0($t2)
	beq $t3, $zero, proximo_morador

	# Compara nomes
	move $a0, $t2 # endereço do nome no apartamento
	move $a1, $s2 # endereço do nome a ser removido
	jal strcmp
	beq $v0, 1, remover_morador

proximo_morador:
	addi $s3, $s3, 1
	j buscar_morador

remover_morador:
	# Limpa o nome do morador (preenche com zeros)
	li $t0, 40 # MAX_TAM_NOME
	mul $t1, $s3, $t0
	add $t2, $s1, $t1 # endereço do morador a ser removido

	li $t3, 0
limpar_nome:
	li $t5, 40 # MAX_TAM_NOME
	bge $t3, $t5, nome_limpo
	add $t4, $t2, $t3
	sb $zero, 0($t4)
	addi $t3, $t3, 1
	j limpar_nome

nome_limpo:
	# Decrementa o número de moradores
	li $t1, 200 # NUM_MORADORES_OFFSET
	add $t2, $s1, $t1
	lw $t0, 0($t2)
	addi $t0, $t0, -1
	sw $t0, 0($t2)

	# Verifica se o apartamento ficou vazio
	beq $t0, $zero, apartamento_vazio

	# Morador removido com sucesso
	li $v0, 4
	la $a0, msg_rm_sucesso
	syscall
	j fim_rm_morador

apartamento_vazio:
	# Marca apartamento como vazio
	li $t1, 204 # STATUS_AP_OFFSET
	add $t2, $s1, $t1
	sw $zero, 0($t2)

	# Remove automaticamente todos os veículos
	move $a0, $s0
	jal rm_auto_automatico

	# Mensagem de sucesso
	li $v0, 4
	la $a0, msg_rm_sucesso
	syscall
	j fim_rm_morador

morador_nao_encontrado:
	li $v0, 4
	la $a0, msg_morador_nao_encontrado
	syscall
	j fim_rm_morador

ap_invalido_rm:
	li $v0, 4
	la $a0, msg_ap_invalido
	syscall

fim_rm_morador:
	# Restaura registradores
	lw $s3, 0($sp)
	lw $s2, 4($sp)
	lw $s1, 8($sp)
	lw $s0, 12($sp)
	lw $ra, 16($sp)
	addi $sp, $sp, 20
	jr $ra

# Função auxiliar para comparar strings
strcmp:
	li $v0, 0 # assume que são diferentes

strcmp_loop:
	lb $t0, 0($a0) # carrega byte da primeira string
	lb $t1, 0($a1) # carrega byte da segunda string

	# Se chegou ao fim das duas strings, são iguais
	beq $t0, $zero, check_fim
	
	# Se são diferentes, retorna 0
	bne $t0, $t1, fim_strcmp

	# Próximo caractere
	addi $a0, $a0, 1
	addi $a1, $a1, 1
	j strcmp_loop

check_fim:
	# Verifica se a segunda string também acabou
	beq $t1, $zero, strings_iguais
	j fim_strcmp

strings_iguais:
	li $v0, 1 # strings são iguais

fim_strcmp:
	jr $ra

# Função auxiliar para remover veículos automaticamente quando apartamento fica vazio
rm_auto_automatico:
	addi $sp, $sp, -8
	sw $ra, 4($sp)
	sw $s0, 0($sp)

	move $s0, $a0 # índice do apartamento

	# Obtém endereço do apartamento
	move $a0, $s0
	jal obter_endereco_ap
	move $t0, $v0

	# Limpa a estrutura do veículo
	li $t2, 208 # VEICULO_OFFSET
	add $t1, $t0, $t2
	li $t2, 0

limpar_veiculo:
	li $t4, 46 # TAM_VEICULO
	bge $t2, $t4, fim_limpar_veiculo
	add $t3, $t1, $t2
	sb $zero, 0($t3)
	addi $t2, $t2, 1
	j limpar_veiculo

fim_limpar_veiculo:
	lw $s0, 0($sp)
	lw $ra, 4($sp)
	addi $sp, $sp, 8
	jr $ra
	
chama_ad_auto:
	# Endereço inicial da string
	la $t0, entrada
	addi $t0, $t0, 8 # pula "ad_auto-"

	# Pega índice do apartamento
	move $a0, $t0
	jal ap_para_indice # $v0 = índice do apartamento
	move $s0, $v0 # salva índice

	# Pula 3 dígitos do ap e o '-'
	addi $t0, $t0, 4

	# Pega o tipo (um caractere)
	lb $t1, 0($t0) # carrega o tipo (ex: 'C' ou 'M')
	sb $t1, tipo_buffer

	# Pula o tipo e o '-'
	addi $t0, $t0, 2

	# Modelo começa aqui
	move $t2, $t0

encontra_hifen:
	lb $t3, 0($t0)
	beq $t3, 45, fim_modelo # 45 = código ASCII de '-'
	addi $t0, $t0, 1
	j encontra_hifen

fim_modelo:
	sb $zero, 0($t0) # insere NULL terminador no fim do modelo
	addi $t0, $t0, 1 # pula o '-'

	# Agora t2 = modelo, t0 = cor
	move $a0, $s0 # índice do apartamento
	la $a1, tipo_buffer
	move $a2, $t2 # modelo
	move $a3, $t0 # cor

	jal ad_auto

	jr $ra

ad_auto:
	# Implementação da função ad_auto aqui
	jr $ra
	
chama_rm_auto:
	la $t0, entrada
	addi $t0, $t0, 8 # pula "rm_auto-"
	
	# Obtém índice do apartamento
	move $a0, $t0
	jal ap_para_indice
	move $s0, $v0 # salva índice do apartamento
	
	# Pula 3 dígitos do ap e o '-'
	addi $t0, $t0, 4
	
	# Pega o tipo (um caractere) e salva
	lb $t1, 0($t0)
	sb $t1, tipo_buffer
	
	# Pula o tipo e o '-'
	addi $t0, $t0, 2
	
	# Agora t0 aponta para o modelo
	move $t2, $t0 # salva posição do modelo
	
encontra_hifen_rm:
	lb $t3, 0($t0)
	beq $t3, 45, fim_modelo_rm # 45 = código ASCII de '-'
	addi $t0, $t0, 1
	j encontra_hifen_rm
	
fim_modelo_rm:
	sb $zero, 0($t0) # coloca terminador no modelo
	addi $t0, $t0, 1 # pula o '-'
	
	# Agora: s0=índice_ap, tipo_buffer=tipo, t2=modelo, t0=cor
	move $a0, $s0 # índice do apartamento
	la $a1, tipo_buffer # tipo
	move $a2, $t2 # modelo
	move $a3, $t0 # cor
	
	jal rm_auto
	
	jr $ra

rm_auto:
	# Salva registradores na pilha
	addi $sp, $sp, -24
	sw $ra, 20($sp)
	sw $s0, 16($sp) # índice do apartamento
	sw $s1, 12($sp) # endereço do apartamento
	sw $s2, 8($sp) # tipo
	sw $s3, 4($sp) # modelo
	sw $s4, 0($sp) # cor

	move $s0, $a0 # índice do apartamento
	move $s2, $a1 # endereço do tipo
	move $s3, $a2 # endereço do modelo
	move $s4, $a3 # endereço da cor

	# Verifica se o apartamento é válido (0-39)
	bltz $s0, ap_invalido_auto
	li $t0, 40 # MAX_APARTAMENTOS
	bge $s0, $t0, ap_invalido_auto

	# Verifica se o tipo é válido ('c' ou 'm')
	lb $t0, 0($s2)
	beq $t0, 99, tipo_valido # 'c' = 99
	beq $t0, 109, tipo_valido # 'm' = 109
	j tipo_invalido_auto

tipo_valido:
	# Obtém endereço do apartamento
	move $a0, $s0
	jal obter_endereco_ap
	move $s1, $v0 # $s1 = endereço do apartamento

	# Verifica se o apartamento está ocupado
	li $t1, 204 # STATUS_AP_OFFSET
	add $t2, $s1, $t1
	lw $t0, 0($t2)
	beq $t0, $zero, auto_nao_encontrado # apartamento vazio

	# Obtém endereço do veículo no apartamento
	li $t1, 208 # VEICULO_OFFSET
	add $t1, $s1, $t1 # $t1 = endereço do veículo

	# Verifica se existe um veículo (tipo não é zero)
	lb $t0, 0($t1)
	beq $t0, $zero, auto_nao_encontrado

	# Compara tipo
	lb $t2, 0($s2) # tipo procurado
	bne $t0, $t2, auto_nao_encontrado

	# Compara modelo
	addi $t3, $t1, 1 # endereço do modelo no veículo
	move $a0, $t3 # modelo armazenado
	move $a1, $s3 # modelo procurado
	jal strcmp
	beq $v0, 0, auto_nao_encontrado # modelos diferentes

	# Compara cor
	addi $t3, $t1, 31 # endereço da cor no veículo (1 + 30)
	move $a0, $t3 # cor armazenada
	move $a1, $s4 # cor procurada
	jal strcmp
	beq $v0, 0, auto_nao_encontrado # cores diferentes

	# Veículo encontrado - remover (limpar estrutura)
	li $t2, 0
limpar_veiculo_rm:
	li $t4, 46 # TAM_VEICULO
	bge $t2, $t4, veiculo_removido
	add $t3, $t1, $t2
	sb $zero, 0($t3)
	addi $t2, $t2, 1
	j limpar_veiculo_rm

veiculo_removido:
	# Mensagem de sucesso
	li $v0, 4
	la $a0, msg_rm_auto_sucesso
	syscall
	j fim_rm_auto

auto_nao_encontrado:
	li $v0, 4
	la $a0, msg_auto_nao_encontrado
	syscall
	j fim_rm_auto

ap_invalido_auto:
	li $v0, 4
	la $a0, msg_ap_invalido_auto
	syscall
	j fim_rm_auto

tipo_invalido_auto:
	li $v0, 4
	la $a0, msg_tipo_invalido
	syscall

fim_rm_auto:
	# Restaura registradores
	lw $s4, 0($sp)
	lw $s3, 4($sp)
	lw $s2, 8($sp)
	lw $s1, 12($sp)
	lw $s0, 16($sp)
	lw $ra, 20($sp)
	addi $sp, $sp, 24
	jr $ra

# Função para chamar limpar_ap
chama_limpar_ap:
	la $t0, entrada
	addi $t0, $t0, 10 # pula "limpar_ap-" (10 chars)
	
	# Obtém índice do apartamento
	move $a0, $t0
	jal ap_para_indice
	move $a0, $v0 # $a0 = índice do apartamento
	
	jal limpar_ap
	
	jr $ra

# Implementação da função limpar_ap
limpar_ap:
	# Salva registradores na pilha
	addi $sp, $sp, -16
	sw $ra, 12($sp)
	sw $s0, 8($sp) # índice do apartamento
	sw $s1, 4($sp) # endereço do apartamento
	sw $s2, 0($sp) # contador
	
	move $s0, $a0 # índice do apartamento
	
	# Verifica se o apartamento é válido (0-39)
	bltz $s0, ap_invalido_limpar
	li $t0, 40 # MAX_APARTAMENTOS
	bge $s0, $t0, ap_invalido_limpar
	
	# Obtém endereço do apartamento
	move $a0, $s0
	jal obter_endereco_ap
	move $s1, $v0 # $s1 = endereço do apartamento
	
	# Limpa todos os moradores (5 slots de 40 bytes cada)
	li $s2, 0 # contador de bytes
limpar_moradores:
	li $t0, 200 # 5 * MAX_TAM_NOME (5 moradores * 40 bytes)
	bge $s2, $t0, moradores_limpos
	add $t1, $s1, $s2
	sb $zero, 0($t1)
	addi $s2, $s2, 1
	j limpar_moradores
	
moradores_limpos:
	# Zera o número de moradores
	li $t1, 200 # NUM_MORADORES_OFFSET
	add $t2, $s1, $t1
	sw $zero, 0($t2)
	
	# Marca apartamento como vazio
	li $t1, 204 # STATUS_AP_OFFSET
	add $t2, $s1, $t1
	sw $zero, 0($t2)
	
	# Limpa a estrutura do veículo
	li $t1, 208 # VEICULO_OFFSET
	add $t1, $s1, $t1
	# endereço do veículo
	li $s2, 0 # contador
limpar_veiculo_completo:
	li $t0, 46 # TAM_VEICULO
	bge $s2, $t0, veiculo_limpo
	add $t2, $t1, $s2
	sb $zero, 0($t2)
	addi $s2, $s2, 1
	j limpar_veiculo_completo
	
veiculo_limpo:
	# Mensagem de sucesso
	li $v0, 4
	la $a0, msg_limpar_sucesso
	syscall
	j fim_limpar_ap
	
ap_invalido_limpar:
	li $v0, 4
	la $a0, msg_ap_invalido_auto # reutiliza a mensagem existente
	syscall

fim_limpar_ap:
	# Restaura registradores
	lw $s2, 0($sp)
	lw $s1, 4($sp)
	lw $s0, 8($sp)
	lw $ra, 12($sp)
	addi $sp, $sp, 16
	jr $ra

# Função para chamar info_ap
chama_info_ap:
	la $t0, entrada
	addi $t0, $t0, 8 # pula "info_ap-" (8 chars)
	
	# Verifica se é "all"
	move $a0, $t0
	la $a1, str_all
	jal strcmp
	beq $v0, 1, info_ap_all
	
	# Não é "all", então é um apartamento específico
	move $a0, $t0
	jal ap_para_indice
	move $a0, $v0 # índice do apartamento
	jal info_ap_single
	
	jr $ra

# Função para mostrar informações de todos os apartamentos
info_ap_all:
	addi $sp, $sp, -8
	sw $ra, 4($sp)
	sw $s0, 0($sp)
	
	li $s0, 0 # contador de apartamentos
	
loop_info_all:
	li $t0, 40 # MAX_APARTAMENTOS
	bge $s0, $t0, fim_info_all
	
	move $a0, $s0
	jal info_ap_single
	
	addi $s0, $s0, 1
	j loop_info_all
	
fim_info_all:
	lw $s0, 0($sp)
	lw $ra, 4($sp)
	addi $sp, $sp, 8
	jr $ra

# Função para mostrar informações de um apartamento específico
info_ap_single:
	addi $sp, $sp, -20
	sw $ra, 16($sp)
	sw $s0, 12($sp) # índice do apartamento
	sw $s1, 8($sp) # endereço do apartamento
	sw $s2, 4($sp) # contador
	sw $s3, 0($sp) # auxiliar
	
	move $s0, $a0 # índice do apartamento
	
	# Verifica se o apartamento é válido (0-39)
	bltz $s0, ap_invalido_info
	li $t0, 40 # MAX_APARTAMENTOS
	bge $s0, $t0, ap_invalido_info
	
	# Obtém endereço do apartamento
	move $a0, $s0
	jal obter_endereco_ap
	move $s1, $v0 # $s1 = endereço do apartamento
	
	# Verifica se o apartamento está ocupado
	li $t1, 204 # STATUS_AP_OFFSET
	add $t2, $s1, $t1
	lw $t0, 0($t2)
	beq $t0, $zero, ap_vazio_info
	
	# Apartamento ocupado - mostrar informações
	# Primeiro, mostra o número do apartamento
	li $v0, 4
	la $a0, msg_ap_numero
	syscall
	
	# Converte e imprime o número do apartamento (formato XXX)
	move $a0, $s0
	jal imprimir_numero_ap
	
	li $v0, 4
	la $a0, newline
	syscall
	
	# Mostra "Moradores:"
	li $v0, 4
	la $a0, msg_moradores
	syscall
	
	# Lista os moradores
	li $s2, 0 # contador de moradores
	
loop_moradores_info:
	li $t0, 5 # MAX_MORADORES_AP
	bge $s2, $t0, fim_moradores_info
	
	# Calcula offset do morador atual
	li $t0, 40 # MAX_TAM_NOME
	mul $t1, $s2, $t0
	add $t2, $s1, $t1 # endereço do morador atual
	
	# Verifica se este slot tem um morador
	lb $t3, 0($t2)
	beq $t3, $zero, proximo_morador_info
	
	# Imprime o nome do morador
	li $v0, 4
	move $a0, $t2
	syscall
	
	li $v0, 4
	la $a0, newline
	syscall
	
proximo_morador_info:
	addi $s2, $s2, 1
	j loop_moradores_info
	
fim_moradores_info:
	# Verifica se há veículo
	li $t1, 208 # VEICULO_OFFSET
	add $t1, $s1, $t1 # endereço do veículo
	
	# Verifica se existe um veículo (tipo não é zero)
	lb $t0, 0($t1)
	beq $t0, $zero, fim_info_single
	
	# Há veículo - verifica o tipo
	beq $t0, 99, mostrar_carro # 'c' = 99
	beq $t0, 109, mostrar_moto # 'm' = 109
	j fim_info_single
	
mostrar_carro:
	li $v0, 4
	la $a0, msg_carro
	syscall
	
	# Mostra modelo do carro
	li $v0, 4
	la $a0, msg_modelo
	syscall
	
	addi $a0, $t1, 1 # endereço do modelo
	li $v0, 4
	syscall
	
	li $v0, 4
	la $a0, newline
	syscall
	
	# Mostra cor do carro
	li $v0, 4
	la $a0, msg_cor
	syscall
	
	addi $a0, $t1, 31 # endereço da cor (1 + 30)
	li $v0, 4
	syscall
	
	li $v0, 4
	la $a0, newline
	syscall
	
	j fim_info_single
	
mostrar_moto:
	li $v0, 4
	la $a0, msg_moto
	syscall
	
	# Mostra modelo da moto
	li $v0, 4
	la $a0, msg_modelo
	syscall
	
	addi $a0, $t1, 1 # endereço do modelo
	li $v0, 4
	syscall
	
	li $v0, 4
	la $a0, newline
	syscall
	
	# Mostra cor da moto
	li $v0, 4
	la $a0, msg_cor
	syscall
	
	addi $a0, $t1, 31 # endereço da cor (1 + 30)
	li $v0, 4
	syscall
	
	li $v0, 4
	la $a0, newline
	syscall
	
	j fim_info_single
	
ap_vazio_info:
	li $v0, 4
	la $a0, msg_ap_vazio
	syscall
	j fim_info_single
	
ap_invalido_info:
	li $v0, 4
	la $a0, msg_ap_invalido_auto # reutiliza mensagem existente
	syscall
	
fim_info_single:
	lw $s3, 0($sp)
	lw $s2, 4($sp)
	lw $s1, 8($sp)
	lw $s0, 12($sp)
	lw $ra, 16($sp)
	addi $sp, $sp, 20
	jr $ra

# Função auxiliar para imprimir o número do apartamento no formato XXX
imprimir_numero_ap:
	addi $sp, $sp, -8
	sw $ra, 4($sp)
	sw $s0, 0($sp)
	
	move $s0, $a0 # índice do apartamento
	addi $s0, $s0, 1 # soma 1 para obter o número real do apartamento
	
	# Converte para formato XXX (3 dígitos)
	# Centena
	li $t0, 100
	div $s0, $t0
	mflo $t1 # quociente (centena)
	mfhi $t2 # resto
	
	addi $t1, $t1, 48 # converte para ASCII
	li $v0, 11
	move $a0, $t1
	syscall
	
	# Dezena
	li $t0, 10
	div $t2, $t0
	mflo $t1 # quociente (dezena)
	mfhi $t3 # resto (unidade)
	
	addi $t1, $t1, 48 # converte para ASCII
	li $v0, 11
	move $a0, $t1
	syscall
	
	# Unidade
	addi $t3, $t3, 48 # converte para ASCII
	li $v0, 11
	move $a0, $t3
	syscall
	
	lw $s0, 0($sp)
	lw $ra, 4($sp)
	addi $sp, $sp, 8
	jr $ra

# Função para chamar info_geral
chama_info_geral:
	jal info_geral
	jr $ra

# Implementação da função info_geral
info_geral:
	addi $sp, $sp, -20
	sw $ra, 16($sp)
	sw $s0, 12($sp) # contador de apartamentos
	sw $s1, 8($sp) # contador de apartamentos ocupados
	sw $s2, 4($sp) # contador de apartamentos vazios
	sw $s3, 0($sp) # endereço do apartamento atual
	
	li $s0, 0 # contador de apartamentos (0-39)
	li $s1, 0 # apartamentos ocupados
	li $s2, 0 # apartamentos vazios
	
loop_contar_aps:
	li $t0, 40 # MAX_APARTAMENTOS
	bge $s0, $t0, fim_contagem
	
	# Obtém endereço do apartamento atual
	move $a0, $s0
	jal obter_endereco_ap
	move $s3, $v0
	
	# Verifica se o apartamento está ocupado
	li $t1, 204 # STATUS_AP_OFFSET
	add $t2, $s3, $t1
	lw $t0, 0($t2)
	
	beq $t0, $zero, ap_vazio_count
	# Apartamento ocupado
	addi $s1, $s1, 1
	j proximo_ap_count
	
ap_vazio_count:
	# Apartamento vazio
	addi $s2, $s2, 1
	
proximo_ap_count:
	addi $s0, $s0, 1
	j loop_contar_aps
	
fim_contagem:
	# Exibe resultado para apartamentos não vazios
	li $v0, 4
	la $a0, msg_nao_vazios
	syscall
	
	# Imprime número de apartamentos ocupados
	li $v0, 1
	move $a0, $s1
	syscall
	
	# Calcula e imprime percentual de ocupados
	li $v0, 4
	la $a0, msg_porcentagem_open
	syscall
	
	# Cálculo: (ocupados * 100) / 40
	li $t0, 100
	mul $t1, $s1, $t0 # ocupados * 100
	li $t0, 40
	div $t1, $t0 # (ocupados * 100) / 40
	mflo $t2 # resultado da divisão
	
	li $v0, 1
	move $a0, $t2
	syscall
	
	li $v0, 4
	la $a0, msg_porcentagem_close
	syscall
	
	# Exibe resultado para apartamentos vazios
	li $v0, 4
	la $a0, msg_vazios
	syscall
	
	# Imprime número de apartamentos vazios
	li $v0, 1
	move $a0, $s2
	syscall
	
	# Calcula e imprime percentual de vazios
	li $v0, 4
	la $a0, msg_porcentagem_open
	syscall
	
	# Cálculo: (vazios * 100) / 40
	li $t0, 100
	mul $t1, $s2, $t0 # vazios * 100
	li $t0, 40
	div $t1, $t0 # (vazios * 100) / 40
	mflo $t2 # resultado da divisão
	
	li $v0, 1
	move $a0, $t2
	syscall
	
	li $v0, 4
	la $a0, msg_porcentagem_close
	syscall
	
	# Restaura registradores
	lw $s3, 0($sp)
	lw $s2, 4($sp)
	lw $s1, 8($sp)
	lw $s0, 12($sp)
	lw $ra, 16($sp)
	addi $sp, $sp, 20
	jr $ra

salvar:
	# Implementação da função salvar aqui
	jr $ra

recarregar:
	# Implementação da função recarregar aqui
	jr $ra

formatar:
	# Implementação da função formatar aqui
	jr $ra