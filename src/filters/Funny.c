#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <stdint.h>
#include "../tp2.h"

void Funny_asm (uint8_t *src, uint8_t *dst, int width, int height,
                      int src_row_size, int dst_row_size);

void Funny_c   (uint8_t *src, uint8_t *dst, int width, int height,
                      int src_row_size, int dst_row_size);

typedef void (Funny_fn_t) (uint8_t*, uint8_t*, int, int, int, int);


void leer_params_Funny(configuracion_t *config, int argc, char *argv[]) {
}

void aplicar_Funny(configuracion_t *config)
{
    Funny_fn_t *Funny = SWITCH_C_ASM( config, Funny_c, Funny_asm );
    buffer_info_t info = config->src;
    Funny(info.bytes, config->dst.bytes, info.width, info.height, 
              info.row_size, config->dst.row_size);
}

void liberar_Funny(configuracion_t *config) {

}

void ayuda_Funny()
{
    printf ( "       * Funny\n" );
    printf ( "           Ejemplo de uso : \n"
             "                         Funny -i c facil.bmp\n" );
}

DEFINIR_FILTRO(Funny,1)


