.data

    	input: .space 17
    	menu: .asciiz "\nSeleccione la representacion de entrada:\n1. Binario en Complemento a 2\n2. Decimal Empaquetado\n3. Base 10\n4. Octal\n5. Hexadecimal\n>>> "
    	error: .asciiz "\nOpcion invalida. Por favor intente de nuevo.\n"
    	salto: .asciiz "\n"
    	solicitud: .asciiz "Por favor, ingrese el numero a convertir: "
    	Conversiones: .asciiz "\n\n-------------------------------- RESULTADO DE CONVERSIONES --------------------------------\n"
    	Base10: .asciiz "Base 10: "
    	Octal: .asciiz "Octal: "
    	Hexadecimal: .asciiz "Hexadecimal: "
    	Binario: .asciiz "Binario: "
    	signoPositivo: .asciiz "+"
    	signoNegativo: .asciiz "-"
    	result: .space 17
    	output: .space 17
    	buffer: .space 17

.text


.macro PRINT_MSG %msg_label
    la $a0, %msg_label
    li $v0, 4
    syscall
.end_macro

.macro READ_INPUT
	PRINT_MSG solicitud
    	
    	li $v0, 8
    	la $a0, input
    	li $a1, 17
    	syscall
    	
.end_macro





main:
    	PRINT_MSG menu  # Imprime el menu

    	li $v0, 5  # Lee la opción ingresada por el usuario
    	syscall
    	move $t0, $v0

    	# Hace un Branch en base a la selección del usuario
    	beq $t0, 1, inputBinario
    	beq $t0, 2, inputDecimalEmpaquetado
    	beq $t0, 3, inputBase10
    	beq $t0, 4, inputOctal
    	beq $t0, 5, inputHexadecimal

    	PRINT_MSG error  # Opción inválida en menu
    	j main
    	
	

inputBinario:
    	READ_INPUT  # Leer entrada binaria
    	jal binario_decimal  # Llamar a la función de conversión a decimal
    	j conversionCompleta

inputDecimalEmpaquetado:
    	READ_INPUT  # Leer entrada decimal empaquetado
    	jal decimalEmpaquetado_decimal  # Llamar a la función de conversión a decimal
    	j conversionCompleta

inputBase10:
    	READ_INPUT  # Leer entrada base 10
    	jal base10_decimal  # Llamar a la función de conversión a decimal
    	j conversionCompleta

inputOctal:
    	READ_INPUT  # Leer entrada octal
    	jal octal_decimal  # Llamar a la función de conversión a decimal
    	j conversionCompleta

inputHexadecimal:
    	READ_INPUT  # Leer entrada binaria
    	jal hexadecimal_decimal  # Llamar a la función de conversión a decimal
    	j conversionCompleta
    

##################################### BASE 10 A DECIMAL ################################################
	
		
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
		
##################################### DECIMAL EMPAQUETADO A DECIMAL ################################################
decimalEmpaquetado_decimal:
	li $t1, 0    # Inicializa el resultado final
	li $t2, 0    # Inicializa el decimal parcial
	li $t3, 0    # Indice de entrada
	li $t4, 8    # Multiplicador inicial
	li $t5, 1000 # Base ajustada para 16 bits

convertirBinarioDecimal:
	# Verifica el fin de la entrada
	lb $t0, input($t3)
	beq $t0, 10, finConversion

	# Convertir el carácter ASCII a numero
	subi $t0, $t0, 48

	# Multiplica el valor binario por el multiplicador
	mul $t0, $t0, $t4
	add $t2, $t2, $t0
	div $t4, $t4, 2
	addi $t3, $t3, 1

	# Verifica si el multiplicador se ha reducido a 0
	beq $t4, 0, procesarDecimal
	j convertirBinarioDecimal

procesarDecimal:
	# Verifica si el decimal parcial excede el valor máximo permitido
	bgt $t2, 11, verificarSigno

	# Empaqueta el decimal parcial en el resultado final
	mul $t2, $t2, $t5
	add $t1, $t1, $t1

	# Reinicia los valores para el siguiente grupo de bits
	li $t4, 8
	div $t5, $t5, 10
	li $t2, 0
	j convertirBinarioDecimal

	verificarSigno:
	# Verifica si el decimal parcial es el signo
	beq $t2, 12, finConversion
	mul $t1, $t1, -1

	finConversion:
	div $t1, $t1, 10
	jr $ra

##################################### HEXADECIMAL A DECIMAL ################################################

hexadecimal_decimal:
	la $t2, 0       # Cargar la dirección de la entrada
    	lb $t3, input($t2)         # Cargar el primer carácter (signo)
    	li $t4, 0              # Inicializar el acumulador a 0
    	li $t5, 1              # Inicializar el signo a positivo (+1)
    
    	# Determinar el signo del número
    	beq $t3, '+', positivo_hex
    	beq $t3, '-', negativo_hex

positivo_hex:
    	addi $t2, $t2, 1       # Mover al siguiente Caracter
    	j loop_hexadecimal

negativo_hex:
    	li $t5, -1             # Cambiar el signo a negativo (-1)
    	addi $t2, $t2, 1       # Mover al siguiente carácter 

loop_hexadecimal:
    	lb $t3, input($t2)         # Cargar el carácter actual
    	beq $t3, 10, finLoop_hexadecimal  # Si es el fin de la cadena, terminar
    
    	# Convertir el carácter a su valor numérico
    	li $t6, 48     
    	li $t7, 57         
    	blt $t3, $t6, es_alfa
    	bgt $t3, $t7, es_alfa
    	sub $t3, $t3, $t6      
    	j actualizar_sumador

es_alfa:
    	li $t6, 65             # Convertir de ASCII A-F a valor 10-15
    	li $t7, 70             
    	sub $t3, $t3, 55       

actualizar_sumador:
    	mul $t4, $t4, 16       # Multiplicar el sumador por 16
    	add $t4, $t4, $t3      # Sumar el dígito actual
    
    	addi $t2, $t2, 1       # Mover al siguiente carácter de la cadena
    	j loop_hexadecimal

finLoop_hexadecimal:
    	mul $t1, $t4, $t5      # Aplicar el signo al valor acumulado
    	jr $ra                 # Regresar de la función
	

##################################### OCTAL A DECIMAL ################################################

octal_decimal:
    	la $t2, 0          	# Cargar la dirección de la entrada
    	lb $t3, input($t2)	# Cargar el primer carácter (signo)
    	li $t4, 0              	# Inicializar el sumador a 0
    	li $t5, 1              	# Inicializar el signo a positivo (+1)
    
    	# Determinar el signo del número
    	beq $t3, '+', positivo_oct
    	beq $t3, '-', negativo_oct

positivo_oct:
    	addi $t2, $t2, 1       # Mover al siguiente carácter 
    	j loop_octal

negativo_oct:
    	li $t5, -1             # Cambiar el signo a negativo (-1)
    	addi $t2, $t2, 1       # Mover al siguiente carácter

loop_octal:
    	lb $t3, input($t2)         # Cargar el carácter actual
    	beq $t3, 10, finLoop_octal  # Si es el fin de la cadena, terminar
    
    	# Convertir el carácter a su valor numérico
    	li $t6, 48            
    	sub $t3, $t3, $t6      

    	mul $t4, $t4, 8        # Multiplicar el sumador por 8
    	add $t4, $t4, $t3      # Sumar el dígito actual
    
    	addi $t2, $t2, 1       # Mover al siguiente carácter
    	j loop_octal

finLoop_octal:
    	mul $t1, $t4, $t5      # Aplicar el signo al resultado
    	jr $ra                 

																				
conversionCompleta:

    	PRINT_MSG Conversiones  # Imprime la etiqueta de conversiones

##################################### DECIMAL A BASE 10 ################################################

decimal_base10:
	
	PRINT_MSG Base10  #Imprime etiqueta del resultado base 10
	
	bltz $t1, imprimirBase10 #Si es menor a cero imprime el numero
	
	PRINT_MSG signoPositivo #Si es mayor que cero agrega +
	
	imprimirBase10:
		
		la $a0, ($t1) #Imprime el resultado
		li $v0, 1
		syscall
		
		PRINT_MSG salto


##################################### DECIMAL A OCTAL ################################################	

decimal_octal:
	
	PRINT_MSG Octal  #Imprime etiqueta del resultado octal
	
	la $t3, ($t1) #Carga el numero a $t3
	
	# Verificar si es negativo  
        bgez $t3, skip_neg

        PRINT_MSG signoNegativo
        
        mul $t3, $t3, -1 #Multiplica por -1 para trabajarlo como positivo
        

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
        
        
        #Agrega el ultimo digito y posiciona los iteradores para comenzar a invertir
        addi $t3, $t3, 48
        sb $t3, result($t0)
        addi $t0, $t0, 1
        sb $zero, result($t0)
       	subi $t0, $t0, 1

        #Invierte la cadena
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
        	PRINT_MSG output

        		
        	PRINT_MSG salto  #Agrega un salto de linea
		
        		
##################################### DECIMAL A HEXADECIMAL ################################################		
decimal_Hexadecimal:

    	# Imprimir la etiqueta "Hexadecimal: "
	PRINT_MSG Hexadecimal
	
	
	
    	# Verificar si el número es negativo
    	la $t3, ($t1)
    	bltz $t3, negativoHexadecimal
    	j positivoHexadecimal

negativoHexadecimal:
    	# Imprimir el signo negativo
    	PRINT_MSG signoNegativo

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
    	PRINT_MSG output
    
    	PRINT_MSG salto


##################################### DECIMAL A BINARIO COMPLEMENTO A 2 ################################################		
decimal_binario: 

 	PRINT_MSG Binario
    	
    	li $t0, 17             	# Contador para las 32 posiciones del número binario
    	la $a0, 0        	# Dirección del comienzo del array de salida
    	addi $a0, $a0, 17      	# Mover al final del array de salida
    	sb $zero, output($a0)   	# Poner null terminator al final
    	addi $a0, $a0, -1      	# Retroceder una posición para comenzar desde el final

loop_decimal_binario:
    	beqz $t0, end_loop     # Si el contador llega a 0, salir
    	andi $t2, $t1, 1       # Máscara para obtener el bit menos significativo
    	beqz $t2, write_zero   
    	li $t3, 49             
    	j write_char

write_zero:
    	li $t3, 48

write_char:
    	sb $t3, output($a0)     # Escribir el caracter en la posición actual de $a0
    	srl $t1, $t1, 1        	# Desplazar $t1 un bit a la derecha
    	addi $a0, $a0, -1     	# Actualizar el puntero
    	addi $t0, $t0, -1      	# Restar al contador
    	j loop_decimal_binario 

end_loop:
    	PRINT_MSG output 	#Imprimir resultado de la conversion
    	
	
	
	
	

	
