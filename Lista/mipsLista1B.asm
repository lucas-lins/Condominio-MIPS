.data
source:     .asciiz " Resp ok"     # 8 bytes: " Resp ok" + '\0'
dest:       .space 8               # Espa�o exatamente necess�rio
msg:        .asciiz "\nString copiada: "

.text
.globl main
main:
    # Preparar argumentos para memcpy
    la   $a0, dest             # $a0 ? endere�o do destino
    la   $a1, source           # $a1 ? endere�o da origem
    li   $a2, 8                # $a2 ? n�mero de bytes a copiar

    jal  memcpy                # Chamada da fun��o memcpy

    move $t4, $v0              # Salva o endere�o retornado pela fun��o (destino)

    # Exibir a mensagem
    li   $v0, 4		# indexa servi�o c�digo 4 - "print string" em $v0( vide SYSCALLS no help do MARS)
    la   $a0, msg	# Carrega mensagem " String copiada: " em $a0
    syscall		# executa a chamada de servi�o escolhido

    # Exibir o conte�do copiado (string no destino)
    li   $v0, 4        # indexa servi�o c�digo 4 - "print string" em $v0( vide SYSCALLS no help do MARS)
    move $a0, $t4      #  $a0 ? retorno de memcpy (endere�o de destino)
    syscall            # executa a chamada de servi�o escolhido

    # Encerrar o programa
    li   $v0, 10      # indexa servi�o c�digo 10 - "exit (terminate execution)" em $v0( vide SYSCALLS no help do MARS)
    syscall		# executa a chamada de servi�o escolhido

# Fun��o memcpy: copia $a2 bytes de $a1 para $a0, retorna destino em $v0
memcpy:
    move $t4, $a0              # $t3 ? guarda o endere�o inicial de destino

    beq  $a2, $zero, fim_memcpy  # Se $a2 == 0, fim da fun��o

Loop:
    lb   $t0, 0($a1)           # L� byte da origem
    sb   $t0, 0($a0)           # Escreve byte no destino

    addi $a0, $a0, 1           # Avan�a destino
    addi $a1, $a1, 1           # Avan�a origem
    addi $a2, $a2, -1          # Decrementa contador

    bne  $a2, $zero, Loop      # Continua se ainda houver bytes

fim_memcpy:
    move $v0, $t4              # Retorna endere�o original do destino
    jr   $ra                   # Retorna ao chamador - Ap�s o comando jal