/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.mycompany.chacalesgames;

/**
 *
 * @author Abeni
 */

import java.util.*;

public class ChacalesGame2 {
    public static void main(String[] args) {
        Scanner scanner = new Scanner(System.in);
        Random random = new Random();

        int[] tablero = new int[12]; // Representa el tablero, donde 0 significa casilla oculta
        int[] tesoros = new int[8];  // Arreglo para almacenar las posiciones de los tesoros
        int[] chacales = new int[4]; // Arreglo para almacenar las posiciones de los chacales

        int dinero = 0;              // Dinero acumulado por el jugador
        int chacalesEncontrados = 0; // Contador de chacales encontrados
        int tesorosEncontrados = 0;  // Contador de tesoros encontrados
        int turnosConsecutivos = 0;  // Contador de turnos consecutivos con la misma casilla
        int ultimaCasillaDescubierta = -1; // Última casilla descubierta

        boolean[] casillasDescubiertas = new boolean[12]; // Para llevar registro de las casillas descubiertas

        inicializarTablero(tablero, tesoros, chacales, random);

        System.out.println("Bienvenido al Juego de Chacales!");

        while (tesorosEncontrados < 4 && chacalesEncontrados < 4 && turnosConsecutivos < 3) {
            System.out.println("\n=== Nuevo turno ===");
            mostrarTablero(tablero, casillasDescubiertas);

            System.out.println("\nDinero acumulado: $" + dinero);
            System.out.println("Chacales encontrados: " + chacalesEncontrados);
            System.out.println("Tesoros encontrados: " + tesorosEncontrados);

            System.out.println("\n¿Qué desea hacer?");
            System.out.println("1. Retirarse (terminar el juego)");
            System.out.println("2. Lanzar el dado");
            System.out.print("Por favor, ingrese una opcion: ");
            int opcion = scanner.nextInt();

            if (opcion == 1) {
                System.out.println("\nRetirándose del juego...");
                break;
            } else if (opcion == 2) {
                int numeroAleatorio = random.nextInt(12) + 1; // Número aleatorio entre 1 y 12
                System.out.println("\nEl número obtenido en este lanzamiento es: " + numeroAleatorio);
                int casilla = numeroAleatorio - 1; // Convertimos a índice de array (0 a 11)

                if (casillasDescubiertas[casilla]) {
                    System.out.println("Esta casilla ya ha sido descubierta. Intente de nuevo.");
                    continue;
                }

                casillasDescubiertas[casilla] = true;
                if (tablero[casilla] == 1) {
                    System.out.println("¡Encontraste un tesoro! +$100");
                    dinero += 100;
                    tesorosEncontrados++;
                } else if (tablero[casilla] == 2) {
                    System.out.println("¡Chacal encontrado!");
                    chacalesEncontrados++;
                }

                // Verificar si se han descubierto 3 veces seguidas la misma casilla
                if (casilla == ultimaCasillaDescubierta) {
                    turnosConsecutivos++;
                } else {
                    turnosConsecutivos = 0;
                }

                ultimaCasillaDescubierta = casilla;
            } else {
                System.out.println("Opción inválida. Intente de nuevo.");
                continue;
            }
        }

        // Mostrar resultados finales
        System.out.println("\n=== Juego terminado ===");
        mostrarTablero(tablero, casillasDescubiertas);
        System.out.println("\nDinero final: $" + dinero);
        System.out.println("Chacales encontrados: " + chacalesEncontrados);
        System.out.println("Tesoros encontrados: " + tesorosEncontrados);

        if (chacalesEncontrados >= 4) {
            System.out.println("¡Has encontrado los 4 chacales! Juego perdido.");
        } else if (tesorosEncontrados >= 4) {
            System.out.println("¡Felicidades! Has encontrado los 4 tesoros y ganaste el juego.");
        } else if (turnosConsecutivos >= 3) {
            System.out.println("Perdiste porque descubriste la misma casilla 3 veces seguidas.");
        }

        System.out.println("\nLa cantidad acumulada de tesoros que ganaste es: $" + dinero);
        System.out.println("Gracias por jugar.");

        scanner.close();
    }

    // Método para inicializar el tablero con tesoros y chacales en posiciones aleatorias
    public static void inicializarTablero(int[] tablero, int[] tesoros, int[] chacales, Random random) {
        Arrays.fill(tablero, 0); // Todas las casillas inicialmente están vacías

        // Colocar tesoros aleatoriamente
        for (int i = 0; i < tesoros.length; i++) {
            int posicion;
            do {
                posicion = random.nextInt(12);
            } while (tablero[posicion] != 0);
            tablero[posicion] = 1; // Marcamos la posición del tesoro
            tesoros[i] = posicion; // Guardamos la posición del tesoro en el arreglo
        }

        // Colocar chacales aleatoriamente
        for (int i = 0; i < chacales.length; i++) {
            int posicion;
            do {
                posicion = random.nextInt(12);
            } while (tablero[posicion] != 0);
            tablero[posicion] = 2; // Marcamos la posición del chacal
            chacales[i] = posicion; // Guardamos la posición del chacal en el arreglo
        }
    }

    // Método para mostrar el estado actual del tablero (casillas ocultas y descubiertas)
    public static void mostrarTablero(int[] tablero, boolean[] casillasDescubiertas) {
        System.out.println("\nEstado actual del tablero:");
        for (int i = 0; i < tablero.length; i++) {
            if (casillasDescubiertas[i]) {
                if (tablero[i] == 1) {
                    System.out.print(" T "); // Tesoro descubierto
                } else if (tablero[i] == 2) {
                    System.out.print(" C "); // Chacal descubierto
                }
            } else {
                System.out.print(" * "); // Casilla oculta
            }

            // Espacios para formato
            if (i % 4 == 3) {
                System.out.println();
            }
        }
    }
}