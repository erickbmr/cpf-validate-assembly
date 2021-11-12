.data
	val: .asciiz "CPF Válido"
	inv: .asciiz "CPF Inválido"

.text
	main:
	#leitura do CPF
	li $v0, 5
	syscall
	move $s1, $v0		#s1 = 000.000.000
	
	
	#leitura do dígito verificador do CPF
	li $v0, 5
	syscall
	move $s3, $v0		#s3= ...-00
	
	li $s2, 0		#auxiliar para soma
	li $t0, 10 		#auxiliar para diminuir o divisor
	li $t1, 1		#auxiliar para guardar numero UM
	li $t2, 10		#auxiliar para guardar o MULTIPLICADOR
	li $t3, 100000000	#auxiliar para guardar o DIVISOR
	la $s6, ($s1)		#copia os 9 numeros do CPF para o $s6, para auxiliar no futuro
	
	calc_first:
	div $s6, $t3		#divide para pegar o quociente
	mflo $t4		#guarda o QUOCIENTE em $t4
	mfhi $t5 		#guarda o RESTO em $t5
	mul $t6, $t4, $t2	#guarda o PRODUTO em $t6
	add $s2, $s2, $t6	#guarda a SOMA em $s2
	sub $t2, $t2, $t1	#guarda o MULTIPLICADOR em $t2
	div $t3, $t0		#diminui o DIVISOR para pegar o 1 algarismo
	mflo $t3		#guarda novo DIVISOR em $t3
	bne $t2, $t1, fit_number#testa se o multiplicador é diferente de 1
	beq $t1, $t2, continue  #testa se o multiplicador é igual a 1
	
	fit_number:	
	#recalcula o novo numero para auxiliar na soma
	move $s6, $t5
	j calc_first
	
	continue:
	li $t0, 11		#guarda 11 para ser DIVISOR da conferência
	li $t3, 9		#guarda 9 para auxiliar no teste
	div $s2, $t0		#divide a soma por 11
	mfhi $t1		#guarda o RESTO em $t1
	mflo $t2		#guarda o QUOCIENTE em $t2
	bgt $t1, $t3, get_first_digit	#testa se o RESTO é maior que 9
	sub $s4, $t0, $t1	#diminui 11 - resto e guarda em $t4
	
	get_first_digit:
	#pega o primeiro digito verificador
	li $t0, 10
	div $s3, $t0		#divide os dois digitos por 10 para pegar o primeiro
	mflo $t1		#guarda o PRIMEIRO DIGITO em $t1
	beq $t1, $zero, calc_prox	#testa se o PRIMEIRO DIGITO é igual a zero
	beq $s4, $t1, calc_prox #testa se a diferença é igual ao primeiro digito
	j invalidate
	
	calc_prox:
	li $s2, 0		#auxiliar para soma
	li $t0, 10 		#auxiliar para diminuir o divisor
	li $t1, 1		#auxiliar para guardar numero UM
	li $t2, 11		#auxiliar para guardar o MULTIPLICADOR
	li $t3, 100000000	#auxiliar para guardar o DIVISOR
	li $t7, 2		#auxiliar para guardar numero DOIS
	
	calc_second:
	div $s1, $t3		#divide para pegar o quociente
	mflo $t4		#guarda o QUOCIENTE em $t4
	mfhi $s5 		#guarda o RESTO em $t5
	mul $t6, $t4, $t2	#guarda o PRODUTO em $t6
	add $s2, $s2, $t6	#guarda a SOMA em $s2
	sub $t2, $t2, $t1	#guarda o MULTIPLICADOR em $t2
	div $t3, $t0		#diminui o DIVISOR para pegar o 1 algarismo
	mflo $t3		#guarda novo DIVISOR em $t3
	bne $t2, $t7, fit_num	#testa se o multiplicador é igual a 2
	beq $t7, $t2, sum_last	#testa se o multiplicador é igual a 2
	
	fit_num:
		#recalcula o novo numero para auxiliar na soma
	move $s1, $s5
	j calc_second
	
	sum_last:
	li $t0, 10		#guarda o DIVISOR para auxiliar
	li $t2, 2		#guarda o MULTIPLICADOR para auxiliar
	div $s3, $t0		#divide os dois digitos por 10 para pegar o primeiro
	mflo $t1		#guarda o PRIMEIRO DIGITO em $t1
	mul $t3, $t1, $t2	#salva em $t3, o produto do primeiro digito com 2
	add $s2, $s2, $t3	#adiciona o resultado na soma
	
	testing:
	li $t0, 11		#guarda 11 para ser DIVISOR da conferência
	li $t3, 9		#guarda 9 para auxiliar no teste
	div $s2, $t0		#divide a soma por 11
	mfhi $t1		#guarda o RESTO em $t1
	mflo $t2		#guarda o QUOCIENTE em $t2
	bgt $t1, $t3, get_second_digit	#testa se o RESTO é maior que 9
	sub $s4, $t0, $t1	#diminui 11 - resto e guarda em $s4
	
	get_second_digit:
	#pega o segundo digito verificador
	li $t0, 10
	div $s3, $t0		#divide os dois digitos por 10 para pegar o primeiro
	mfhi $t1		#guarda o (resto) SEGUNDO DIGITO em $t1
	beq $t1, $zero, validate	#testa se o SEGUNDO DIGITO é igual a zero
	beq $s4, $t1, validate		#testa se a DIFERENÇA é igual ao SEGUNDO DIGITO
	j invalidate
	
	#CPF validado, segue para o output
	validate:
	li $v0, 4
	la $a0, val
	syscall
	j exit
	
	#CPF invlidado, segue para o output	
	invalidate:
	li $v0, 4
	la $a0, inv
	syscall
	j exit	

	exit:
		
