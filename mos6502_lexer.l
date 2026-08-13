%{

#include <stdio.h>
#define NA -1

enum mne_type {
    LDA, STA, BRK
};

enum modo_type {
    INM, ZP, ABS
};

enum mne_type mne = NA;
enum modo_type modo = NA;

// INM, ZP, ABS
unsigned char opcodes[3][3] = {
              {0xa9, 0xa5, 0xad}, //LDA
              {NA, 0x85, 0x8d},  //STA
              {0x0, 0x0, 0x0},  //BRK
            };

void imprimir_linea();
int decodificar(enum mne_type mne, enum modo_type modo);

%}

/* Opciones para que no generes funciones no utilizadas y evitar warnings */
%option noinput nounput

DECIMAL	[0-9]+
HEXA $[0-9A-Fa-f]+
BINARIO %[01]+

NUM HEXA|DECIMAL|BINARIO

%%

{HEXA}  { if (yyleng <= 3) { modo = ZP; printf("Modo ZP %d", modo); } else { modo = ABS; printf("Modo ABS %d", modo); } }
{DECIMAL} { printf("Es decimal %02X", atoi(yytext)); }
{BINARIO} { printf("Es binario %02X", (int)(strtol(yytext, NULL, 2))); }

BRK { printf("00\tBRK\n"); }

(?i:LDA)  { mne = LDA; }
(?i:STA)  { mne = STA; }

#{HEXA}  { modo = INM; }
\n  { imprimir_linea(); }

[ \t]+  { }
;.* { }

%%

void imprimir_linea() {
    int opcode = decodificar(mne, modo);
    if (opcode == NA)
        fprintf(stderr, "Error: combinacion invalida de mnemonico y modo\n");
    else printf("%02X %d\n", opcode, modo); 

    modo = NA; 
    mne = NA;
}

int decodificar(enum mne_type mne, enum modo_type modo) {
    if (mne == NA) return NA;
    return opcodes[mne][modo];
}

int yywrap(void) { 
    return 1; 
}

int main(int argc, char **argv) {
    if (argc > 1) {
        FILE *f = fopen(argv[1], "r");
        if (!f) { 
            perror("No se pudo abrir el archivo"); 
            return 1; 
        }
        yyin = f;
    }
    /* Si no se pasa el archivo lee de la entrada estandar (stdin) */
    
    yylex();
    return 0;
}
