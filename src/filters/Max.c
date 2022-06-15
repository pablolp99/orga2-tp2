#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <stdint.h>
#include "../tp2.h"

void Max_asm (uint8_t *src, uint8_t *dst, int width, int height,
                      int src_row_size, int dst_row_size);

void Max_c   (uint8_t *src, uint8_t *dst, int width, int height,
                      int src_row_size, int dst_row_size);

typedef void (Max_fn_t) (uint8_t*, uint8_t*, int, int, int, int);


void leer_params_Max(configuracion_t *config, int argc, char *argv[]) {
}

void aplicar_Max(configuracion_t *config)
{
    Max_fn_t *Max = SWITCH_C_ASM( config, Max_c, Max_asm );
    buffer_info_t info = config->src;
    Max(info.bytes, config->dst.bytes, info.width, info.height, 
              info.row_size, config->dst.row_size);
}

void liberar_Max(configuracion_t *config) {

}

void ayuda_Max()
{
    printf ( "       * Max\n" );
    printf ( "           Ejemplo de uso : \n"
             "                         Max -i c facil.bmp\n" );
}

DEFINIR_FILTRO(Max,1)


