.data

	input: .space 9
	menu: .asciiz "\nSeleccione la representacion de entrada:\n1. Binario en Complemento a 2\n2. Decimal Empaquetado\n3. Base 10\n4. Octal\n5. Hexadecimal\n>>> "
	error: .asciiz "\nOpcion invalida. Por favor intente de nuevo.\n"
	salto: .asciiz "\n"
	Conversiones: .asciiz "\n\n-------------------------------- RESULTADO DE CONVERSIONES --------------------------------\n"
	Base10: .asciiz "Base 10: "
	Octal: .asciiz "Octal: "
	Hexadecimal: .asciiz "Hexadecimal: "
	Binario: .asciiz "Binario: "
	signoPositivo: .asciiz "+"
	signoNegativo: .asciiz "-"
	result: .space 9
	output: .space 9
	buffer: .space 9

.text
	#$t0 => Guarda la opcion ingresada por el usuario en el menu
	#$t1 => Guarda el resultado en decimal de cada conversion

main:

	li $v0, 4		#Imprime el menu
    	la $a0, menu
    	syscall

    	li $v0, 5		#Lee la opcion ingresada por el usuario y lo guarda en $t0
    	syscall
    	move $t0, $v0

    	
    	# Hace un Branch en base a la seleccion del usuario
    	beq $t0, 1, inputBinario	
    	beq $t0, 2, inputDecimalEmpaquetado
    	beq $t0, 3, inputBase10
    	beq $t0, 4, inputOctal
    	beq $t0, 5, inputHexadecimal

    
    	li $v0, 4		# Opción inválida en menu
    	la $a0, error
    	syscall
    	j main
    	
    	.macro READ_INPUT 	# Macro para recibir input
    	li $v0, 8
    	la $a0, input
    	li $a1, 32
    	syscall
	.end_macro

inputBinario:
    
    	READ_INPUT 		# Leer entrada binaria
    
    	jal binario_decimal 	# Llamar a la función de conversión a decimal
    	j conversionCompleta

inputDecimalEmpaquetado:
    	
    	READ_INPUT 		# Leer entrada binaria
    
    	jal base10_decimal 	# Llamar a la función de conversión a decimal
    	j conversionCompleta
    	
inputBase10:

    	READ_INPUT 		# Leer entrada binaria
    
    	jal base10_decimal 	# Llamar a la función de conversión a decimal
    	j conversionCompleta

inputOctal:
    	
    	READ_INPUT 		# Leer entrada binaria
    
    	jal octal_decimal	# Llamar a la función de conversión a decimal
    	j conversionCompleta

inputHexadecimal:

    	READ_INPUT 		 # Leer entrada binaria
    
    	jal hexadecimal_decimal  	 # Llamar a la función de conversión a decimal
    	j conversionCompleta


##################################### BASE 10 A DECIMAL ################################################
	
	#$t2 => Iterador
	#$t3 => Digito actual
	#$t4 => Acumulador
	#$t5 => Signo del numero
		
base10_decimal:
	
	li $t2, 0	      	# Inicia el iterador en 0
    	lb $t3, input($t2)    	# Carga el primer caracter de $t2 (Signo)
	li $t4, 0             	# Inicia el sumador en 0
    	li $t5, 1             	# Inicia el signo a positivo (+1)
    	
    	#Definir el signo del numero:
    	
    	beq $t3, '+', positivo
    	beq $t3, '-', negativo
    	
    	positivo:
    		addi $t2, $t2, 1		# Actualiza el iterador
    		j loop_base10_decimal
    	
    	negativo:
		li $t5, -1            	# Cambia el signo a negativo (-1)
    		addi $t2, $t2, 1		# Actualiza el iterador
	
	loop_base10_decimal: 
		
		lb $t3, input($t2)	#Carga el caracter actual
		beq $t3, 10, finLoop_base10_decimal	#Rompe el loop si llega al final de la cadena "\"
		subi $t3, $t3, 48	#Convierte el caracter a de ASCII a valor numerico
		
		#Actualiza el sumador
		mul $t4, $t4, 10 	#Multiplicar el sumador por 10
		add $t4, $t4, $t3	#Suma el digito actual
		
		addi $t2, $t2, 1		# Actualiza el iterador
		j loop_base10_decimal
		
	finLoop_base10_decimal:
		mul $t1, $t4, $t5     # Multiplica el signo al valor acumulado
		jr $ra

##################################### BINARIO COMPLEMENTO A 2 A DECIMAL ################################################

	#$t2 => Iterador
	#$t3 => Digito actual
	#$t4 => Acumulador
	#$t5 => Signo del numero
	#$t6 => Acumulador de potencia
	
binario_decimal:
    	li $t2, 0	      	# Inicia el iterador en 0
    	lb $t3, input($t2)    	# Carga el primer caracter de $t2 (Signo)
    	li $t4, 0             	# Inicia el sumador en 0
    	li $t5, 0             	# Inicia el signo a positivo (0: Positivo, -1: Negativo)

    	# Verificar si el número es negativo 
    	beq $t3, '1', negativo_bin
    	j loop_binario_decimal

negativo_bin:
    	li $t5, -1              # Cambia el signo a negativo

loop_binario_decimal:
    	lb $t3, input($t2)         # Cargar el carácter actual
    	beq $t3, 10, finLoop_binario_decimal  # Si es el fin de la cadena (\), terminar
	subi $t3, $t3, 48	#Convierte el caracter a de ASCII a valor numerico
	
    	# Actualizar el sumador
    	mul $t4, $t4, 2        # Multiplicar el sumador por 2
    	add $t4, $t4, $t3      # Sumar el dígito actual

    	addi $t2, $t2, 1       # Mover al siguiente bit
    	j loop_binario_decimal

finLoop_binario_decimal:

    beq $t5, 0, positivo_binario  # Si es positivo, saltar a positivo_binario
	
    # Si es negativo, convertir usando complemento a 2
    subi $t2, $t2, 1 
    li $t6, 1
    potencia:
    	blt $t2, 0, signoMenos
    	mul $t6, $t6, 2
    	subi $t2, $t2, 1
    	b potencia
    	
    signoMenos: 
    sub $t4, $t4, $t6

positivo_binario:
    move $t1, $t4          # Mover el resultado al registro $t1
    jr $ra                 # Regresar de la función
		

##################################### HEXADECIMAL A DECIMAL ################################################

hexadecimal_decimal:
    la $t2, input          # Cargar la dirección de la entrada
    lb $t3, 0($t2)         # Cargar el primer carácter (signo)
    li $t4, 0              # Inicializar el acumulador a 0
    li $t5, 1              # Inicializar el signo a positivo (+1)
    
    # Determinar el signo del número
    beq $t3, '+', positivo_hex
    beq $t3, '-', negativo_hex

positivo_hex:
    addi $t2, $t2, 1       # Mover al siguiente carácter después del signo
    j loop_hexadecimal

negativo_hex:
    li $t5, -1             # Cambiar el signo a negativo (-1)
    addi $t2, $t2, 1       # Mover al siguiente carácter después del signo

loop_hexadecimal:
    lb $t3, 0($t2)         # Cargar el carácter actual
    beq $t3, 10, finLoop_hexadecimal  # Si es el fin de la cadena (nulo), terminar
    
    # Convertir el carácter a su valor numérico
    li $t6, 48             # ASCII '0'
    li $t7, 57             # ASCII '9'
    blt $t3, $t6, is_alpha # Si es menor que '0', es una letra
    bgt $t3, $t7, is_alpha # Si es mayor que '9', es una letra
    sub $t3, $t3, $t6      # Convertir de ASCII '0'-'9' a valor 0-9
    j update_accumulator

is_alpha:
    li $t6, 65             # ASCII 'A'
    li $t7, 70             # ASCII 'F'
    sub $t3, $t3, 55       # Convertir de ASCII 'A'-'F' a valor 10-15 ('A' es 65, así que 65 - 55 = 10)

update_accumulator:
    mul $t4, $t4, 16       # Multiplicar el acumulador por 16
    add $t4, $t4, $t3      # Sumar el dígito actual
    
    addi $t2, $t2, 1       # Mover al siguiente carácter de la cadena
    j loop_hexadecimal

finLoop_hexadecimal:
    mul $t1, $t4, $t5      # Aplicar el signo al valor acumulado
    jr $ra                 # Regresar de la función
	

##################################### OCTAL A DECIMAL ################################################

octal_decimal:
    la $t2, input          # Cargar la dirección de la entrada
    lb $t3, 0($t2)         # Cargar el primer carácter (signo)
    li $t4, 0              # Inicializar el acumulador a 0
    li $t5, 1              # Inicializar el signo a positivo (+1)
    
    # Determinar el signo del número
    beq $t3, '+', positivo_oct
    beq $t3, '-', negativo_oct

positivo_oct:
    addi $t2, $t2, 1       # Mover al siguiente carácter después del signo
    j loop_octal

negativo_oct:
    li $t5, -1             # Cambiar el signo a negativo (-1)
    addi $t2, $t2, 1       # Mover al siguiente carácter después del signo

loop_octal:
    lb $t3, 0($t2)         # Cargar el carácter actual
    beq $t3, 10, finLoop_octal  # Si es el fin de la cadena (nulo), terminar
    
    # Convertir el carácter a su valor numérico
    li $t6, 48             # ASCII '0'
    sub $t3, $t3, $t6      # Convertir de ASCII '0'-'7' a valor 0-7

    mul $t4, $t4, 8        # Multiplicar el acumulador por 8
    add $t4, $t4, $t3      # Sumar el dígito actual
    
    addi $t2, $t2, 1       # Mover al siguiente carácter de la cadena
    j loop_octal

finLoop_octal:
    mul $t1, $t4, $t5      # Aplicar el signo al valor acumulado
    jr $ra                 # Regresar de la función
    
    			
    						
    												
conversionCompleta:

	la $a0, Conversiones  #Imprime etiqueta de las conversiones
	li $v0, 4
	syscall
##################################### DECIMAL A BASE 10 ################################################

decimal_base10:
	
	la $a0, Base10  #Imprime etiqueta del resultado base 10
	li $v0, 4
	syscall
	
	bltz $t1, imprimirBase10 #Si es menor a cero imprime el numero
	
	la $a0, signoPositivo #Si es mayor que cero agrega +
	li $v0, 4
	syscall
	
	imprimirBase10:
		
		la $a0, ($t1) #Imprime el resultado
		li $v0, 1
		syscall
		
		la $a0, salto  #Agrega un salto de linea
		li $v0, 4
		syscall


##################################### DECIMAL A OCTAL ################################################	

decimal_octal:
	
	la $a0, Octal  #Imprime etiqueta del resultado base 10
	li $v0, 4
	syscall
	
	la $t3, ($t1)
	 
        bgez $t3, skip_neg
        
        # Verificar si es negativo
        li $v0, 4 
        la $a0, signoNegativo
        syscall
        
        mul $t3, $t3, -1
        

    skip_neg:
        # Convertir a octal
        li $t0, 0          	# Iterador en el numero
        li $s0, 0		# Iterador sobre el output
	li $t2, 0         	# Resto de division
        li $t7, 8
        

    loopDecimal_octal:
        
        div $t3, $t7 		# Dividir por 8
        mfhi $t2 		# Mover el residuo a $t2
        addi $t2, $t2, 48	# Convertir en ASCII 
        sb $t2, result($t0)   	# Guardar caracter en la posicion
        mflo $t3			# Actualizar el numero a dividit
        addi $t0, $t0, 1		# Actualizar iterador

        bge $t3, 8, loopDecimal_octal
        
        addi $t3, $t3, 48
        sb $t3, result($t0)
        addi $t0, $t0, 1
        sb $zero, result($t0)
       	subi $t0, $t0, 1

        
        invertirOctal:
        		blt $t0, 0, finInvertirOctal
        		lb $t3, result($t0)
        		sb $t3, output($s0)
        		subi $t0, $t0, 1
        		addi $s0, $s0, 1
        		b invertirOctal
        		
        	

	finInvertirOctal:
        # Imprimir el resultado
        		sb $zero, output($s0)
        		la $a0, output
        		li $v0, 4
        		syscall
        		
        		la $a0, salto  #Agrega un salto de linea
		li $v0, 4
		syscall
		
        		
##################################### DECIMAL A HEXADECIMAL ################################################		
decimal_Hexadecimal:

    	# Imprimir la etiqueta "Hexadecimal: "
    	la $a0, Hexadecimal
    	li $v0, 4
    	syscall
	
	
	
    	# Verificar si el número es negativo
    	la $t3, ($t1)
    	bltz $t3, negativoHexadecimal
    	j positivoHexadecimal

negativoHexadecimal:
    	# Imprimir el signo negativo
    	la $a0, signoNegativo
    	li $v0, 4
    	syscall

    	# Convertir el número a positivo
    	mul $t3, $t3, -1

positivoHexadecimal:
    	# Inicializar variables
    	la $s0, 0
    	li $t0, 0        # Iterador del número convertido
    	li $t2, 0        # Resto de la división

conversion:
    # Convertir el número a hexadecimal
    beqz $t3, fin_conversion
    li $t7, 16
    divu $t3, $t3, $t7
    mfhi $t2

    # Convertir el resto a su correspondiente carácter ASCII
    blt $t2, 10, digit_to_char
    addi $t2, $t2, 87  # 'a' es 97 en ASCII, 97 - 10 = 87
    j store_char

digit_to_char:
    addi $t2, $t2, 48  # Convertir a ASCII '0' es 48 en ASCII

store_char:
    sb $t2, buffer($s0)
    addi $s0, $s0, 1
    mflo $t3
    j conversion

fin_conversion:
    # Terminar la cadena con nulo
    sb $zero, buffer($s0)

    # Invertir la cadena para obtener el resultado correcto
    subi $s0, $s0, 1
    la $s1, 0
    subi $s1, $s1, 1  # Ajustar el puntero para la inversión

invertir:
    lb $t2, buffer($s0)
    blt $s0, 0, fin_invertir
    addi $s1, $s1, 1  # Mover al siguiente espacio
    sb $t2, output($s1)
    subi $s0, $s0, 1
    j invertir

fin_invertir:
    # Terminar la cadena con nulo
    addi $s1, $s1, 1
    sb $zero, output($s1)

    # Imprimir el resultado final
    la $a0, output
    li $v0, 4
    syscall
    
    la $a0, salto
    li $v0, 4
    syscall
    
##################################### DECIMAL A BINARIO COMPLEMENTO A 2 ################################################		
decimal_binario: 

 	la $a0, Binario
    	li $v0, 4
    	syscall 
    	
    li $t0, 8             # Contador para las 32 posiciones del número binario
    la $a0, output         # Dirección del comienzo del array de salida
    addi $a0, $a0, 8      # Mover al final del array de salida
    sb $zero, 0($a0)       # Poner null terminator al final
    addi $a0, $a0, -1      # Retroceder una posición para comenzar desde el final

loop_decimal_binario:
    beqz $t0, end_loop     # Si el contador llega a 0, salir del loop
    andi $t2, $t1, 1       # Máscara para obtener el bit menos significativo de $t1
    beqz $t2, write_zero   # Si el bit es 0, escribir '0'
    li $t3, 49             # ASCII de '1'
    j write_char

write_zero:
    li $t3, 48             # ASCII de '0'

write_char:
    sb $t3, 0($a0)         # Escribir el caracter en la posición actual de $a0
    srl $t1, $t1, 1        # Desplazar $t1 un bit a la derecha
    addi $a0, $a0, -1      # Mover el puntero del array una posición a la izquierda
    addi $t0, $t0, -1      # Decrementar el contador
    j loop_decimal_binario                # Repetir el loop

end_loop:
    la $a0, output         # Cargar la dirección del comienzo de la cadena en $a0
    li $v0, 4              # Código de syscall para imprimir cadena
    syscall                # Llamar a syscall
	
	
	
	
	

	
