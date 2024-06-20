.data
tablero: .space 48             # Array de 12 enteros (4 bytes cada uno)
tesoros: .space 32             # Array de 8 enteros
chacales: .space 16            # Array de 4 enteros
dinero: .word 0
chacalesEncontrados: .word 0
tesorosEncontrados: .word 0
turnosConsecutivos: .word 0
ultimaCasillaDescubierta: .word -1
casillasDescubiertas: .space 48 # Array de 12 enteros


# Definición de la semilla para generar números aleatorios
seed: .word 12345               # Por ejemplo, puedes inicializar la semilla con un valor

mensajeBienvenida: .asciiz "Bienvenido al Juego de Chacales!\n"
mensajeNuevoTurno: .asciiz "\n=== Nuevo turno ===\n"
mensajeDineroAcumulado: .asciiz "\nDinero acumulado: $"
mensajeChacalesEncontrados: .asciiz "Chacales encontrados: "
mensajeTesorosEncontrados: .asciiz "Tesoros encontrados: "
mensajeOpcion: .asciiz "\n¿Qué desea hacer?\n1. Retirarse (terminar el juego)\n2. Lanzar el dado\nPor favor, ingrese una opcion: "
mensajeRetirarse: .asciiz "\nRetirándose del juego...\n"
mensajeNumeroObtenido: .asciiz "\nEl número obtenido en este lanzamiento es: "
mensajeCasillaYaDescubierta: .asciiz "Esta casilla ya ha sido descubierta. Intente de nuevo.\n"
mensajeTesoroEncontrado: .asciiz "¡Encontraste un tesoro! +$100\n"
mensajeChacalEncontrado: .asciiz "¡Chacal encontrado!\n"
mensajePerdisteNumeroRepetido: .asciiz "Perdiste porque el número apareció 3 veces.\n"
mensajeJuegoTerminado: .asciiz "\n=== Juego terminado ===\n"
mensajeDineroFinal: .asciiz "\nDinero final: $"
mensajePerdidoChacales: .asciiz "¡Has encontrado los 4 chacales! Juego perdido.\n"
mensajeGanadoTesoros: .asciiz "¡Felicidades! Has encontrado los 4 tesoros y ganaste el juego.\n"
mensajePerdisteTurnosConsecutivos: .asciiz "Perdiste porque descubriste la misma casilla 3 veces seguidas.\n"
mensajeTesorosGanados: .asciiz "\nLa cantidad acumulada de tesoros que ganaste es: $"
mensajeGracias: .asciiz "Gracias por jugar.\n"
mensajeInvalida: .asciiz "Opción inválida. Intente de nuevo.\n"
oculto_msg: .asciiz " * "
tesoro_msg: .asciiz " T "
chacal_msg: .asciiz " C "

.text
.globl main

main:
    # Mostrar mensaje de bienvenida
    li $v0, 4
    la $a0, mensajeBienvenida
    syscall

    # Inicializar el tablero con ceros
    la $t0, tablero           # Cargar la dirección de tablero en $t0
    li $t1, 0                 # Cargar 0 en $t1
    li $t2, 12                # Número de casillas

init_loop:
    sw $t1, 0($t0)            # Guardar 0 en la posición actual de tablero
    addi $t0, $t0, 4          # Avanzar a la siguiente posición
    subi $t2, $t2, 1          # Decrementar el contador
    bnez $t2, init_loop       # Repetir hasta que t2 sea 0

    # Inicializar los tesoros y chacales
    jal init_tesoros_chacales

    # Entrar en el bucle principal del juego
    j main_loop

# Función para inicializar tesoros y chacales
init_tesoros_chacales:
    # Inicializar tesoros
    li $t3, 8                # Número de tesoros
init_tesoros:
    li $a0, 12               # Límite superior para random
    jal random               # Llamar a la función random con $a0 = 12
    move $t0, $v0            # Guardar el resultado en $t0
    # Verificar si la posición ya está ocupada
    la $t1, tablero
    sll $t2, $t0, 2          # Calcular el desplazamiento en bytes
    add $t1, $t1, $t2
    lw $t4, 0($t1)
    bnez $t4, init_tesoros   # Si no es 0, repetir
    li $t4, 1                # Marcar la posición con un 1 (tesoro)
    sw $t4, 0($t1)           
    subi $t3, $t3, 1
    bnez $t3, init_tesoros   # Repetir hasta colocar todos los tesoros

    # Inicializar chacales
    li $t3, 4                # Número de chacales
init_chacales:
    li $a0, 12               # Límite superior para random
    jal random               # Llamar a la función random con $a0 = 12
    move $t0, $v0            # Guardar el resultado en $t0
    # Verificar si la posición ya está ocupada
    la $t1, tablero
    sll $t2, $t0, 2          # Calcular el desplazamiento en bytes
    add $t1, $t1, $t2
    lw $t4, 0($t1)
    bnez $t4, init_chacales  # Si no es 0, repetir
    li $t4, 2                # Marcar la posición con un 2 (chacal)
    sw $t4, 0($t1)           
    subi $t3, $t3, 1
    bnez $t3, init_chacales  # Repetir hasta colocar todos los chacales

    jr $ra                   # Retornar a main

# Función para generar un número aleatorio
random:
    la $t0, seed
    lw $t1, 0($t0)            # Cargar la semilla
    li $t2, 1103515245        # Constante multiplicativa
    li $t3, 12345             # Constante aditiva

    mult $t1, $t2             # Multiplicar la semilla por la constante multiplicativa
    mflo $t1                  # Guardar el resultado en $t1
    addu $t1, $t1, $t3         # Sumar la constante aditiva a $t1
    sw $t1, 0($t0)            # Guardar la nueva semilla

    andi $t1, $t1, 0x7FFFFFFF # Obtener número positivo

    li $t4, 12                # Límite superior (1 a 12)
    rem $v0, $t1, $t4         # Calcular el resto para obtener un número entre 0 y 11
    addi $v0, $v0, 1          # Ajustar el resultado para que esté entre 1 y 12

    jr $ra                    # Retornar

# Bucle principal del juego
main_loop:
    # Mostrar el tablero
    jal show_board

    # Mostrar mensaje de nuevo turno
    li $v0, 4
    la $a0, mensajeNuevoTurno
    syscall

    # Mostrar dinero acumulado
    li $v0, 4
    la $a0, mensajeDineroAcumulado
    syscall
    li $v0, 1
    lw $a0, dinero
    syscall

    # Mostrar chacales encontrados
    li $v0, 4
    la $a0, mensajeChacalesEncontrados
    syscall
    li $v0, 1
    lw $a0, chacalesEncontrados
    syscall

    # Mostrar tesoros encontrados
    li $v0, 4
    la $a0, mensajeTesorosEncontrados
    syscall
    li $v0, 1
    lw $a0, tesorosEncontrados
    syscall

    # Pedir la entrada del usuario
    li $v0, 4
    la $a0, mensajeOpcion
    syscall

    # Leer la opción del usuario
    li $v0, 5
    syscall
    move $t0, $v0

    # Procesar la opción
    beq $t0, 1, exit_game      # Saltar a exit_game si la opción es 1 (retirarse)
    beq $t0, 2, lanzar_dado    # Saltar a lanzar_dado si la opción es 2 (lanzar el dado)

    # Opción inválida, mostrar mensaje de error
    li $v0, 4
    la $a0, mensajeInvalida
    syscall
    j main_loop                # Volver al inicio del bucle principal

exit_game:
    # Mostrar mensaje de retirada
    li $v0, 4
    la $a0, mensajeRetirarse
    syscall
    j exit_game                # Salir del juego

lanzar_dado:
    # Generar número aleatorio entre 1 y 6
    li $a0, 12
    jal random
    move $t0, $v0              # Guardar el número obtenido en $t0

    # Mostrar el número obtenido
    li $v0, 4
    la $a0, mensajeNumeroObtenido
    syscall
    li $v0, 1
    move $a0, $t0
    syscall

    # Actualizar estado del juego según el número obtenido
    # Por ejemplo, verificar si se encontró un tesoro o un chacal

    j main_loop                # Volver al inicio del bucle principal
    
# Definición de la función show_board
show_board:
    # Aquí debes implementar el código para mostrar el tablero
    # Puedes acceder a tablero, oculto_msg, tesoro_msg, chacal_msg y otras variables
    # Utiliza llamadas al sistema (syscall) para mostrar información por pantalla
    # Asegúrate de seguir la misma estructura de cómo se implementan las llamadas al sistema en tu entorno MIPS
    
    # Ejemplo de cómo mostrar el tablero (ajústalo según tu implementación)
    li $v0, 4               # Cargar el sistema de llamada para imprimir cadena
    la $a0, tablero         # Cargar la dirección base del tablero
    li $t0, 0               # Inicializar contador de casillas
    li $t1, 12              # Número total de casillas

show_loop:
    	lw $t2, 0($a0)          # Cargar el valor de la casilla actual
    	beq $t2, 0, show_hidden # Saltar a mostrar oculto si la casilla está vacía (0)
    	beq $t2, 1, show_treasure   # Saltar a mostrar tesoro si la casilla tiene un tesoro (1)
    	beq $t2, 2, show_jackal     # Saltar a mostrar chacal si la casilla tiene un chacal (2)

    	j continue_show         # Continuar mostrando el tablero

show_hidden:
    	li $v0, 4               # Cargar el sistema de llamada para imprimir cadena
    	la $a0, oculto_msg      # Cargar el mensaje de casilla oculta
    	syscall

    	j continue_show         # Continuar mostrando el tablero

show_treasure:
    		li $v0, 4               # Cargar el sistema de llamada para imprimir cadena
    		la $a0, tesoro_msg      # Cargar el mensaje de tesoro encontrado
    		syscall

    		j continue_show         # Continuar mostrando el tablero

show_jackal:
    		li $v0, 4               # Cargar el sistema de llamada para imprimir cadena
    		la $a0, chacal_msg      # Cargar el mensaje de chacal encontrado
    		syscall

    		j continue_show         # Continuar mostrando el tablero

continue_show:
    		addi $a0, $a0, 4        # Avanzar a la siguiente casilla
    		addi $t0, $t0, 1        # Incrementar contador de casillas mostradas
    		subi $t1, $t1, 1        # Decrementar contador total de casillas
    		bnez $t1, show_loop     # Repetir hasta mostrar todas las casillas

    		jr $ra                  # Retornar a la función que llamó a show_board
