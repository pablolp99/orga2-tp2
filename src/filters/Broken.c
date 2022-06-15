#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <stdint.h>
#include "../tp2.h"

void Broken_asm (uint8_t *src, uint8_t *dst, int width, int height,
                      int src_row_size, int dst_row_size);

void Broken_c   (uint8_t *src, uint8_t *dst, int width, int height,
                      int src_row_size, int dst_row_size);

typedef void (Broken_fn_t) (uint8_t*, uint8_t*, int, int, int, int);


void leer_params_Broken(configuracion_t *config, int argc, char *argv[]) {
}

void aplicar_Broken(configuracion_t *config)
{
    Broken_fn_t *Broken = SWITCH_C_ASM( config, Broken_c, Broken_asm );
    buffer_info_t info = config->src;
    Broken(info.bytes, config->dst.bytes, info.width, info.height, 
              info.row_size, config->dst.row_size);
}

void liberar_Broken(configuracion_t *config) {

}

void ayuda_Broken()
{
    printf ( "       * Broken\n" );
    printf ( "           Ejemplo de uso : \n"
             "                         Broken -i c facil.bmp\n" );
}

DEFINIR_FILTRO(Broken,1)


