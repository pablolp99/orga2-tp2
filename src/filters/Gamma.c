#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <stdint.h>
#include "../tp2.h"

void Gamma_asm (uint8_t *src, uint8_t *dst, int width, int height,
                      int src_row_size, int dst_row_size);

void Gamma_c   (uint8_t *src, uint8_t *dst, int width, int height,
                      int src_row_size, int dst_row_size);

typedef void (Gamma_fn_t) (uint8_t*, uint8_t*, int, int, int, int);


void leer_params_Gamma(configuracion_t *config, int argc, char *argv[]) {
}

void aplicar_Gamma(configuracion_t *config)
{
    Gamma_fn_t *Gamma = SWITCH_C_ASM( config, Gamma_c, Gamma_asm );
    buffer_info_t info = config->src;
    Gamma(info.bytes, config->dst.bytes, info.width, info.height, 
              info.row_size, config->dst.row_size);
}

void liberar_Gamma(configuracion_t *config) {

}

void ayuda_Gamma()
{
    printf ( "       * Gamma\n" );
    printf ( "           Ejemplo de uso : \n"
             "                         Gamma -i c facil.bmp\n" );
}

DEFINIR_FILTRO(Gamma,1)


