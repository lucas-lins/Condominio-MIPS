.data
# Strings de teste para comparação
str1: .asciiz "cat"                    # String 1: "cat"
str2: .asciiz "cap"                    # String 2: "cap"  
str3: .asciiz "cat"                    # String 3: "cat" (igual à str1)
str4: .asciiz "dog"                    # String 4: "dog" (diferente)

# Mensagens explicativas para cada teste
titulo: .asciiz "=== DEMONSTRAÇÃO DA FUNÇÃO STRNCMP ===\n\n"
explicacao1: .asciiz "A função strncmp compara até N caracteres de duas strings\n"
explicacao2: .asciiz "Retorna: NEGATIVO se str1 < str2, ZERO se iguais, POSITIVO se str1 > str2\n\n"

# Mensagens para cada teste específico
teste_titulo1: .asciiz "TESTE 1: Comparando 'cat' com 'cap' (3 caracteres)\n"
teste_detalhes1: .asciiz "Analisando: 'cat' vs 'cap' -> Diferença no 3º caractere\n"
teste_detalhes1b: .asciiz "'t' tem código ASCII 116, 'p' tem código ASCII 112\n"

teste_titulo2: .asciiz "\nTESTE 2: Comparando 'cat' com 'cat' (3 caracteres)\n"
teste_detalhes2: .asciiz "Analisando: 'cat' vs 'cat' -> São IGUAIS\n"

teste_titulo3: .asciiz "\nTESTE 3: Comparando 'cat' com 'dog' (1 caractere)\n"
teste_detalhes3: .asciiz "Analisando: 'c' vs 'd' -> Diferença no 1º caractere\n"

teste_titulo4: .asciiz "\nTESTE 4: Comparando 'dog' com 'cap' (3 caracteres)\n"
teste_detalhes4: .asciiz "Analisando: 'dog' vs 'cap'\n"
teste_detalhes4b: .asciiz "Diferença no 1º caractere: 'd' vs 'c'\n"
teste_detalhes4c: .asciiz "'d' tem código ASCII 100, 'c' tem código ASCII 99\n"

resultado_msg: .asciiz "RESULTADO: "
conclusao_maior: .asciiz " -> Primeira string é MAIOR que a segunda\n"
conclusao_menor: .asciiz " -> Primeira string é MENOR que a segunda\n"
conclusao_igual: .asciiz " -> As strings são IGUAIS (nos caracteres analisados)\n"
separador: .asciiz "================================================\n"

.text
.globl main

main:
    # Imprime o título geral
    li $v0, 4                            # Código 4 = imprimir string
    la $a0, titulo                       # Carrega endereço do título
    syscall                              # Chama sistema para imprimir
    
    # Imprime explicação sobre strncmp
    li $v0, 4                            # Código 4 = imprimir string
    la $a0, explicacao1                  # Carrega explicação parte 1
    syscall                              # Chama sistema para imprimir
    
    li $v0, 4                            # Código 4 = imprimir string
    la $a0, explicacao2                  # Carrega explicação parte 2
    syscall                              # Chama sistema para imprimir
    
    # TESTE 1: "cat" vs "cap" (3 caracteres)
    li $v0, 4                            # Código 4 = imprimir string
    la $a0, teste_titulo1                # Carrega título do teste 1
    syscall                              # Chama sistema para imprimir
    
    li $v0, 4                            # Código 4 = imprimir string
    la $a0, teste_detalhes1              # Carrega detalhes do teste 1
    syscall                              # Chama sistema para imprimir
    
    li $v0, 4                            # Código 4 = imprimir string
    la $a0, teste_detalhes1b             # Carrega detalhes ASCII
    syscall                              # Chama sistema para imprimir
    
    # Chama a função strncmp para teste 1
    la $a0, str1                         # $a0 = endereço de "cat"
    la $a1, str2                         # $a1 = endereço de "cap"
    li $a2, 3                            # $a2 = 3 (comparar 3 caracteres)
    jal strncmp                          # Chama função strncmp
    
    # Imprime resultado do teste 1
    jal imprimir_resultado_detalhado     # Chama função para mostrar resultado
    
    # TESTE 2: "cat" vs "cat" (3 caracteres)
    li $v0, 4                            # Código 4 = imprimir string
    la $a0, teste_titulo2                # Carrega título do teste 2
    syscall                              # Chama sistema para imprimir
    
    li $v0, 4                            # Código 4 = imprimir string
    la $a0, teste_detalhes2              # Carrega detalhes do teste 2
    syscall                              # Chama sistema para imprimir
    
    # Chama a função strncmp para teste 2
    la $a0, str1                         # $a0 = endereço de "cat"
    la $a1, str3                         # $a1 = endereço de "cat"
    li $a2, 3                            # $a2 = 3 (comparar 3 caracteres)
    jal strncmp                          # Chama função strncmp
    
    # Imprime resultado do teste 2
    jal imprimir_resultado_detalhado     # Chama função para mostrar resultado
    
    # TESTE 3: "cat" vs "dog" (1 caractere)
    li $v0, 4                            # Código 4 = imprimir string
    la $a0, teste_titulo3                # Carrega título do teste 3
    syscall                              # Chama sistema para imprimir
    
    li $v0, 4                            # Código 4 = imprimir string
    la $a0, teste_detalhes3              # Carrega detalhes do teste 3
    syscall                              # Chama sistema para imprimir
    
    # Chama a função strncmp para teste 3
    la $a0, str1                         # $a0 = endereço de "cat"
    la $a1, str4                         # $a1 = endereço de "dog"
    li $a2, 1                            # $a2 = 1 (comparar apenas 1 caractere)
    jal strncmp                          # Chama função strncmp
    
    # Imprime resultado do teste 3
    jal imprimir_resultado_detalhado     # Chama função para mostrar resultado

    # TESTE 4: "dog" vs "cap" (3 caracteres)
    li $v0, 4                            # Código 4 = imprimir string
    la $a0, teste_titulo4                # Carrega título do teste 4
    syscall                              # Chama sistema para imprimir
    
    li $v0, 4                            # Código 4 = imprimir string
    la $a0, teste_detalhes4              # Carrega detalhes parte 1
    syscall                              # Chama sistema para imprimir
    
    li $v0, 4                            # Código 4 = imprimir string
    la $a0, teste_detalhes4b             # Carrega detalhes parte 2
    syscall                              # Chama sistema para imprimir
    
    li $v0, 4                            # Código 4 = imprimir string
    la $a0, teste_detalhes4c             # Carrega detalhes parte 3
    syscall                              # Chama sistema para imprimir
    
    # Chama a função strncmp para teste 4
    la $a0, str4                         # $a0 = endereço de "dog"
    la $a1, str2                         # $a1 = endereço de "cap"
    li $a2, 3                            # $a2 = 3 (comparar 3 caracteres)
    jal strncmp                          # Chama função strncmp
    
    # Imprime resultado do teste 4
    jal imprimir_resultado_detalhado     # Chama função para mostrar resultado
    
    # Imprime separador final
    li $v0, 4                            # Código 4 = imprimir string
    la $a0, separador                    # Carrega separador
    syscall                              # Chama sistema para imprimir
    
    # Finaliza o programa
    li $v0, 10                           # Código 10 = sair do programa
    syscall                              # Chama sistema para sair

# FUNÇÃO PARA IMPRIMIR RESULTADO DETALHADO
imprimir_resultado_detalhado:
    # Salva registrador de retorno na pilha
    addi $sp, $sp, -4                    # Reserva espaço na pilha
    sw $ra, 0($sp)                       # Salva endereço de retorno
    
    # Salva o resultado da strncmp
    move $t0, $v0                        # $t0 = resultado da strncmp
    
    # Imprime "RESULTADO: "
    li $v0, 4                            # Código 4 = imprimir string
    la $a0, resultado_msg                # Carrega mensagem "RESULTADO: "
    syscall                              # Chama sistema para imprimir
    
    # Imprime o número do resultado
    move $a0, $t0                        # $a0 = resultado numérico
    li $v0, 1                            # Código 1 = imprimir inteiro
    syscall                              # Chama sistema para imprimir número
    
    # Analisa o resultado e imprime conclusão
    beq $t0, $zero, resultado_igual      # Se resultado = 0, vai para "igual"
    blt $t0, $zero, resultado_menor      # Se resultado < 0, vai para "menor"
    
    # Caso resultado > 0 (primeira string é maior)
    li $v0, 4                            # Código 4 = imprimir string
    la $a0, conclusao_maior              # Carrega mensagem "MAIOR"
    syscall                              # Chama sistema para imprimir
    j fim_resultado                      # Pula para o fim
    
resultado_menor:
    # Primeira string é menor que a segunda
    li $v0, 4                            # Código 4 = imprimir string
    la $a0, conclusao_menor              # Carrega mensagem "MENOR"
    syscall                              # Chama sistema para imprimir
    j fim_resultado                      # Pula para o fim
    
resultado_igual:
    # Strings são iguais nos caracteres analisados
    li $v0, 4                            # Código 4 = imprimir string
    la $a0, conclusao_igual              # Carrega mensagem "IGUAIS"
    syscall                              # Chama sistema para imprimir
    
fim_resultado:
    # Restaura registrador de retorno da pilha
    lw $ra, 0($sp)                       # Restaura endereço de retorno
    addi $sp, $sp, 4                     # Libera espaço da pilha
    jr $ra                               # Retorna para quem chamou

# FUNÇÃO STRNCMP - COMPARAÇÃO DE STRINGS
strncmp:
    # Salva registradores temporários na pilha
    addi $sp, $sp, -12                   # Reserva 12 bytes na pilha
    sw $t0, 0($sp)                       # Salva $t0 (contador)
    sw $t1, 4($sp)                       # Salva $t1 (caractere str1)
    sw $t2, 8($sp)                       # Salva $t2 (caractere str2)
    
    # Verifica se num é 0 (não comparar nenhum caractere)
    beq $a2, $zero, igual                # Se num = 0, strings são "iguais"
    
    # Inicializa contador de caracteres comparados
    li $t0, 0                            # $t0 = 0 (contador inicia em zero)
    
loop:
    # Verifica se já comparamos 'num' caracteres
    beq $t0, $a2, igual                  # Se contador = num, já comparamos suficiente
    
    # Carrega um caractere de cada string
    lb $t1, 0($a0)                       # $t1 = caractere atual de str1
    lb $t2, 0($a1)                       # $t2 = caractere atual de str2
    
    # Verifica se alguma string terminou (caractere nulo '\0')
    beq $t1, $zero, char1_nulo           # Se str1 terminou, vai tratar
    beq $t2, $zero, char2_nulo           # Se str2 terminou, vai tratar
    
    # Compara os caracteres atuais
    bne $t1, $t2, diferente              # Se caracteres diferentes, vai calcular diferença
    
    # Caracteres são iguais, avança para o próximo
    addi $a0, $a0, 1                     # Avança ponteiro de str1
    addi $a1, $a1, 1                     # Avança ponteiro de str2
    addi $t0, $t0, 1                     # Incrementa contador
    
    j loop                               # Volta para comparar próximo caractere
    
char1_nulo:
    # str1 terminou, verifica se str2 também terminou
    beq $t2, $zero, igual                # Se ambas terminaram, são iguais
    li $v0, -1                           # str1 < str2 (str1 é menor)
    j fim_strncmp                        # Vai para o fim da função
    
char2_nulo:
    # str2 terminou, mas str1 ainda tem caracteres
    li $v0, 1                            # str1 > str2 (str1 é maior)
    j fim_strncmp                        # Vai para o fim da função
    
diferente:
    # Caracteres são diferentes, calcula a diferença
    sub $v0, $t1, $t2                    # $v0 = código ASCII de str1[i] - código ASCII de str2[i]
    j fim_strncmp                        # Vai para o fim da função
    
igual:
    # Strings são iguais nos caracteres analisados
    li $v0, 0                            # Retorna 0 (iguais)
    
fim_strncmp:
    # Restaura registradores temporários da pilha
    lw $t0, 0($sp)                       # Restaura $t0
    lw $t1, 4($sp)                       # Restaura $t1
    lw $t2, 8($sp)                       # Restaura $t2
    addi $sp, $sp, 12                    # Libera espaço da pilha
    
    jr $ra                               # Retorna para quem chamou a função
