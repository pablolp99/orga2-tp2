#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <stdint.h>
#include "../tp2.h"
#include "../helper/utils.h"

void Gamma_c(
    uint8_t *src,
    uint8_t *dst,
    int width,
    int height,
    int src_row_size,
    int dst_row_size
    )
{
    bgra_t (*src_matrix)[(src_row_size+3)/4] = (bgra_t (*)[(src_row_size+3)/4]) src;
    bgra_t (*dst_matrix)[(dst_row_size+3)/4] = (bgra_t (*)[(dst_row_size+3)/4]) dst;

    for (int i = 0; i < height; i++) {
        for (int j = 0; j < width; j++) {	        
	        dst_matrix[i][j].r = sqrt(((double)src_matrix[i][j].r) / 255.0 ) * 255.0 ;
	        dst_matrix[i][j].g = sqrt(((double)src_matrix[i][j].g) / 255.0 ) * 255.0 ;
	        dst_matrix[i][j].b = sqrt(((double)src_matrix[i][j].b) / 255.0 ) * 255.0 ;
        }
    }
}