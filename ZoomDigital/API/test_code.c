#include "library.h"
#include <unistd.h>
#include <stdio.h>
#include <stdlib.h>
#include <termios.h>

char getch(void) { // Função apenas para não precisa digitar ENTER
    struct termios oldt, newt;
    char ch;
    tcgetattr(STDIN_FILENO, &oldt);
    newt = oldt;
    newt.c_lflag &= ~(ICANON | ECHO);
    tcsetattr(STDIN_FILENO, TCSANOW, &newt);
    ch = getchar();
    tcsetattr(STDIN_FILENO, TCSANOW, &oldt);
    return ch;
}

// Função de navegação para Vizinho Mais Próximo
void navigate_nearest_neighbor(void) {
    int x, y;
    char key;
    int running = 1;

    // Solicita coordenadas iniciais
    printf("\n=== Vizinho Mais Próximo ===\n");
    printf("Digite a coordenada X inicial (0-160): ");
    scanf("%d", &x);
    printf("Digite a coordenada Y inicial (0-120): ");
    scanf("%d", &y);
    
    // Valida as coordenadas
    if (x < 0) x = 0;
    if (x > 160) x = 160;
    if (y < 0) y = 0;
    if (y > 120) y = 120;
    
    printf("\nIniciando na posição X=%d, Y=%d\n", x, y);
    printf("Use WASD para navegar, Q para sair\n\n");
    
    // Aplica zoom inicial na posição escolhida
    nearest_neighbor((uint8_t)x, (uint8_t)y);
    
    while (running) {
        key = getch();
        
        switch(key) {
            case 'w':
            case 'W': // Sobe (diminui Y)
                if (y > 0) {
                    y--;
                    nearest_neighbor((uint8_t)x, (uint8_t)y);
                    printf("\rPosição atual: X=%d, Y=%d   ", x, y);
                    fflush(stdout);
                } else {
                    fflush(stdout);
                }
                break;
                
            case 's':
            case 'S': // Desce (aumenta Y)
                if (y < 120) {
                    y++;
                    nearest_neighbor((uint8_t)x, (uint8_t)y);
                    printf("\rPosição atual: X=%d, Y=%d   ", x, y);
                    fflush(stdout);
                } else {
                    fflush(stdout);
                }
                break;
                
            case 'd':
            case 'D': // Direita (aumenta X)
                if (x < 160) {
                    x++;
                    nearest_neighbor((uint8_t)x, (uint8_t)y);
                    printf("\rPosição atual: X=%d, Y=%d   ", x, y);
                    fflush(stdout);
                } else {
                    fflush(stdout);
                }
                break;
                
            case 'a':
            case 'A': // Esquerda (diminui X)
                if (x > 0) {
                    x--;
                    nearest_neighbor((uint8_t)x, (uint8_t)y);
                    printf("\rPosição atual: X=%d, Y=%d   ", x, y);
                    fflush(stdout);
                } else {
                    fflush(stdout);
                }
                break;
                
            case 'q':
            case 'Q': // Sair
                running = 0;
                break;
                
            default:
                // Ignora outras teclas
                break;
        }
    }
}

// Função de navegação para Replicação de Pixel
void navigate_pixel_replication(void) {
    int x, y;
    char key;
    int running = 1;
    
    // Solicita coordenadas iniciais
    printf("\n=== Replicação de Pixel ===\n");
    printf("Digite a coordenada X inicial (0-160): ");
    scanf("%d", &x);
    printf("Digite a coordenada Y inicial (0-120): ");
    scanf("%d", &y);
    
    // Valida as coordenadas
    if (x < 0) x = 0;
    if (x > 160) x = 160;
    if (y < 0) y = 0;
    if (y > 120) y = 120;
    
    printf("\nIniciando na posição X=%d, Y=%d\n", x, y);
    printf("Use WASD para navegar, Q para sair\n\n");
    
    // Aplica zoom inicial na posição escolhida
    pixel_replication((uint8_t)x, (uint8_t)y);
    
    while (running) {
        key = getch();
        
        switch(key) {
            case 'w':
            case 'W': // Sobe (diminui Y)
                if (y > 0) {
                    y--;
                    pixel_replication((uint8_t)x, (uint8_t)y);
                    printf("\rPosição atual: X=%d, Y=%d   ", x, y);
                    fflush(stdout);
                } else {
                    fflush(stdout);
                }
                break;
                
            case 's':
            case 'S': // Desce (aumenta Y)
                if (y < 120) {
                    y++;
                    pixel_replication((uint8_t)x, (uint8_t)y);
                    printf("\rPosição atual: X=%d, Y=%d   ", x, y);
                    fflush(stdout);
                } else {
                    fflush(stdout);
                }
                break;
                
            case 'd':
            case 'D': // Direita (aumenta X)
                if (x < 160) {
                    x++;
                    pixel_replication((uint8_t)x, (uint8_t)y);
                    printf("\rPosição atual: X=%d, Y=%d   ", x, y);
                    fflush(stdout);
                } else {
                    fflush(stdout);
                }
                break;
                
            case 'a':
            case 'A': // Esquerda (diminui X)
                if (x > 0) {
                    x--;
                    pixel_replication((uint8_t)x, (uint8_t)y);
                    printf("\rPosição atual: X=%d, Y=%d   ", x, y);
                    fflush(stdout);
                } else {
                    fflush(stdout);
                }
                break;
                
            case 'q':
            case 'Q': // Sair
                running = 0;
                break;
                
            default:
                // Ignora outras teclas
                break;
        }
    }
}

int main(void) {
    char opcao;
    int running = 1;
    
    initialization();  // Inicializa o hardware
    
    while (running) {
        printf("\n=============================================\n");
        printf("        MENU DE PROCESSAMENTO DE IMAGEM\n");
        printf("=============================================\n");
        printf("[1] - Vizinho Mais Próximo (com navegação)\n");
        printf("[2] - Replicação de Pixel (com navegação)\n");
        printf("[3] - Decimação\n");
        printf("[4] - Média de Blocos\n");
        printf("[5] - Abrir Imagem\n");
        printf("[0] - Sair\n");
        printf("\nEscolha uma opção: ");
        
        opcao = getch();
        printf("%c\n", opcao);
        
        switch (opcao) {
            case '1':
                navigate_nearest_neighbor();
                break;
                
            case '2':
                navigate_pixel_replication();
                break;
                
            case '3':
                pixel_decimation();
                printf("\nDecimação aplicada.\n");
                break;
                
            case '4':
                block_average();
                printf("\nMédia de blocos aplicada.\n");
                break;
                
            case '5':
                open_image("Linux.pgm");
                printf("\nImagem carregada.\n");
                break;
                
            case '0':
                running = 0;
                break;
                
            default:
                printf("\nOpção inválida! Escolha de 0 a 5.\n");
                break;
        }
    }
    
    finalization();
    printf("\nSistema finalizado.\n");
    return 0;
}
