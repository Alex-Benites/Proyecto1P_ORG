.data
mensaje_bienvenida: .asciiz "¡Bienvenido al Juego de Chacales! Por Nicolás Sierra y Alex Benites\n"
mensaje_elige: .asciiz "\n\n¿Lanzar dado?  1=Si, 0=No :"
mensaje_tesoro: .asciiz "\n¡Encontraste un tesoro! +$100\n"
mensaje_chacal: .asciiz "\n¡Chacal encontrado!\n"
mensaje_descubierta: .asciiz "\nEsta casilla ya ha sido descubierta\n"
mensaje_fin: .asciiz "\n=== Juego terminado ===\n"
mensaje_dinero: .asciiz "\nDinero final: $"
mensaje_chacales: .asciiz "\nChacales encontrados: "
mensaje_tesoros: .asciiz "\nTesoros encontrados: "
nueva_linea: .asciiz "\n"          # Cadena para nueva línea
mensaje_dado: .asciiz "\nNumero del dado: "
mensaje_repetida: .asciiz "\nNumero de repetidas: "
mensaje_dineroActual: .asciiz "\n\nDinero acumulado: $"
raya: .asciiz "--"

.align 2
tablero: .word 0,0,0,0,0,0,0,0,0,0,0,0          # Array para el tablero (12 enteros), 1 es tesoros, 0 es chacales
.align 2
casillasDescubiertas: .word 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 # Arreglo con las casillas descubiertas, 0 es no visitada y 1 es visitada

.align 2
dinero: .word 0                    # Dinero acumulado por el jugador
chacalesEncontrados: .word 0       # Contador de chacales encontrados
tesorosEncontrados: .word 0        # Contador de tesoros encontrados
casillasRepetidas: .word 0
tableroMostrar: .byte'X', 'X', 'X', 'X', 'X', 'X', 'X', 'X', 'X', 'X', 'X', 'X' # El tablero que se muestra en pantalla

.text
main:
    la $a2, tablero                # Cargar la dirección base del tablero en $a2
    la $a3, casillasDescubiertas   # Cargar la dirección base de casillasDescubiertas en $a3
    la $t5, tableroMostrar         # Cargar la dirección base de tableroMostrar en $t5
    li $v0, 4
    la $a0, mensaje_bienvenida
    syscall 
    
    
    jal llenar_tablero_aleatorio   # Llama a la función para llenar el tablero
    
    
jugar:

    lw $t1, casillasRepetidas
    beq $t1, 3, terminar_juego_forzado #Si se han repetido 3 casillas, termina el juego
    
    lw $t1, tesorosEncontrados
    beq $t1, 4, terminar_juego #Si se han encontrado todos los tesoros, termina el juego
    
    lw $t1, chacalesEncontrados
    beq $t1, 4, terminar_juego_forzado #Si se han encontrado todos los chacales, termina el juego
    
    
    
    jal imprimir_tablero           # Llama a la función para imprimir el tablero
    
    
    #Me dice cuanto dinero tengo
    li $v0, 4
    la $a0, mensaje_dineroActual
    syscall
    
    la $t0, dinero    # Cargar la dirección de la variable dinero en el registro $t0
    li $v0, 1  
    lw $a0, 0($t0)    # Cargar el valor actual de dinero en el registro $t1 
    syscall
    
    #Me dice cuantas repetidas tengo
    li $v0, 4
    la $a0, mensaje_repetida
    syscall
    
    la $t0, casillasRepetidas  
    li $v0, 1
    lw $a0, 0($t0)
    syscall
    
    #Me dice cuantos tesoros he encontrado     
    li $v0, 4
    la $a0, mensaje_tesoros
    syscall
    
    la $t0, tesorosEncontrados 
    lw $a0, 0($t0)
    li $v0, 1   
    syscall
    
    #Me dice cuantos chacales he encontrado     
    li $v0, 4
    la $a0, mensaje_chacales
    syscall
    
    la $t0, chacalesEncontrados 
    lw $a0, 0($t0)
    li $v0, 1   
    syscall
    
    
    
    li $v0, 4
    la $a0, mensaje_elige
    syscall
    li $v0, 5
    syscall
    
    beqz $v0, terminar_juego
    
    li $v0, 4
    la $a0, mensaje_dado
    syscall
       
    li $v0, 42                     # Llamada al sistema para número aleatorio en rango
    li $a1, 12                     # Rango (0-12), el valor del numero está en $a0
    syscall
    
    move $t0, $a0	
    addi $a0, $a0, 1		  #El dado va de 0-11, asi que para que se muestre bien le agrego 1
    li $v0, 1			  #Imprime el valor que salio en el dado
    syscall
    
    move $a0, $t0
    
    mul $t4, $a0, 4
    add $t4, $t4, $a3            # Dirección de la posición aleatoria en casillasDescubiertas
    
    lw $t6, 0($t4)                 # Leer el valor actual en la posición
    
    bnez $t6, casilla_ya_encontrada      # Si t6 es diferente de 0, la casilla ya ha salido antes
    
    #Casilla no ha salido antes
    
    li $t6, 1
    sw $t6, 0($t4)   #Le pongo un 1 ya que ya visite esa casilla
    

    
    jal verificar_resultado
      
    
    j jugar
    
    
    
verificar_resultado:
    li $t4, 0 
    
    mul $t4, $a0, 4
    add $t4, $t4, $a2            # Dirección de la posición aleatoria en el tablero
    
    lw $t6, 0($t4)                 # Leer el valor actual en la posición en el tablero
    
    
    beqz $t6, tesoro_encontrado  #Se encontro un tesoro
    
    jal chacal_encontrado
    

    
    
tesoro_encontrado:
    la $t5, tableroMostrar
    add $t5, $t5, $a0		#Le agrego al tablero mostrar lo que acabo de descubrir
    li $t7, 'T'
    sb $t7, 0($t5)
    li $v0, 4
    la $a0, mensaje_tesoro
    syscall
    
    la $t0, dinero    # Cargar la dirección de la variable dinero en el registro $t0  
    lw $t1, 0($t0)    # Cargar el valor actual de dinero en el registro $t1  
    add $t1, $t1, 100 # Incrementar el valor en $t1 por 100
    sw $t1, 0($t0)    # Almacenar el valor actualizado de vuelta en la variable dinero
    
    la $t0, tesorosEncontrados    
    lw $t1, 0($t0)    
    add $t1, $t1, 1 
    sw $t1, 0($t0)    
    
    j jugar
    
    
chacal_encontrado:
    la $t5, tableroMostrar
    add $t5, $t5, $a0		#Le agrego al tablero mostrar lo que acabo de descubrir
    li $t7, 'C'
    sb $t7, 0($t5)
    li $v0, 4
    la $a0, mensaje_chacal
    syscall
    
    
    la $t0, chacalesEncontrados   
    lw $t1, 0($t0)    
    add $t1, $t1, 1 
    sw $t1, 0($t0)    
    
    j jugar
    
    
casilla_ya_encontrada:
    li $v0, 4
    la $a0, mensaje_descubierta
    syscall
    
    la $t0, casillasRepetidas 
    lw $t1, 0($t0)    
    addi $t1, $t1, 1 
    sw $t1, 0($t0)
    
    j jugar
    

    # Terminar el programa
terminar_juego:
    li $v0, 4
    la $a0, mensaje_fin
    syscall
    
    la $a0, mensaje_dinero
    syscall
    
    li $v0, 1
    lw $a0, dinero
    syscall
    
    li $v0, 4
    la $a0, mensaje_chacales
    syscall
    
    li $v0, 1
    lw $a0, chacalesEncontrados
    syscall
    
    li $v0, 4
    la $a0, mensaje_tesoros
    syscall
    
    li $v0, 1
    lw $a0, tesorosEncontrados
    syscall
    
    li $v0, 10                     # Llamada al sistema para terminar el programa (exit)
    syscall
    
    
terminar_juego_forzado:
    li $v0, 4
    la $a0, mensaje_fin
    syscall
    
    la $a0, mensaje_dinero
    syscall
    
    li $v0, 1
    la $a0, 0
    syscall
    
    
    li $v0, 4
    la $a0, mensaje_tesoros
    syscall
    
    li $v0, 1
    lw $a0, tesorosEncontrados
    syscall
    
    li $v0, 4
    la $a0, mensaje_chacales
    syscall
    
    li $v0, 1
    lw $a0, chacalesEncontrados
    syscall
    
    
    
    
    
    li $v0, 10                     # Llamada al sistema para terminar el programa (exit)
    syscall
    

# Llenar el tablero con tesoros de manera aleatoria
llenar_tablero_aleatorio:
    li $t2, 8                      # Contador de tesoros

    # Llenar el tablero con 8 tesoros
llenar_tesoros:
    beqz $t2, fin_llenar_tablero   # Si no hay más tesoros por agregar, finalizar
    
    li $v0, 42                     # Llamada al sistema para número aleatorio en rango
    li $a1, 11                     # Rango (0-11)
    syscall			   #El valor aleatorio se guarda en a0
    
    mul $t3, $a0, 4
    add $t3, $t3, $a2            # Dirección de la posición aleatoria
    
    lw $t4, 0($t3)                 # Leer el valor actual en la posición
    
    bnez $t4, llenar_tesoros       # Si no está vacío (0), intentar otra posición
    
    li $t4, 1                      # Valor 1 para tesoro
    sw $t4, 0($t3)                 # Almacenar tesoro en la posición aleatoria
    
    addi $t2, $t2, -1              # Decrementar contador de tesoros
    j llenar_tesoros               # Repetir el ciclo

fin_llenar_tablero:
    jr $ra                         # Retornar de la función

# Imprimir el contenido del tableroMostrar
imprimir_tablero:
    la $t0, tableroMostrar         # Dirección base del tableroMostrar
    li $t1, 12                     # Número de caracteres en el tableroMostrar

imprimir_loop:
    beqz $t1, fin_imprimir         # Si t1 es 0, salir del ciclo
    lb $a0, 0($t0)                 # Cargar el caracter del tableroMostrar en $a0
    li $v0, 11                     # Llamada al sistema para print_char
    syscall
    li $v0, 4
    la $a0, raya
    syscall
    addi $t0, $t0, 1               # Avanzar a la siguiente posición
    subi $t1, $t1, 1               # Decrementar contador
    j imprimir_loop                # Repetir el ciclo

fin_imprimir:
    li $v0, 4                      # Llamada al sistema para print_string
    la $a0, nueva_linea            # Imprimir nueva línea al final
    jr $ra                         # Retornar de la función
