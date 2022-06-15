#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <stdint.h>
#include "../tp2.h"
#include "../helper/utils.h"

void Broken_c(
    uint8_t *src,
    uint8_t *dst,
    int width,
    int height,
    int src_row_size,
    int dst_row_size)
{
    bgra_t (*src_matrix)[(src_row_size+3)/4] = (bgra_t (*)[(src_row_size+3)/4]) src;
    bgra_t (*dst_matrix)[(dst_row_size+3)/4] = (bgra_t (*)[(dst_row_size+3)/4]) dst;
 
    int32_t a[40] = {0,-4,4,8,4,-4,4,8,0,-4,4,8,-4,0,4,-4,-4,4,16,32,4,0,4,-4,-8,-16,0,8,0,4,-4,0,0,4,0,16,32,16,8,4};

    for (int i = 0; i < height; i++) {
        for (int j = 0; j < width; j++) {
	        dst_matrix[i][j].r = SAT(src_matrix[i][(j+8*width+a[(i+10)%40])%width].r);
	        dst_matrix[i][j].g = SAT(src_matrix[i][(j+8*width+a[(i+20)%40])%width].g);
	        dst_matrix[i][j].b = SAT(src_matrix[i][(j+8*width+a[(i+30)%40])%width].b);
        }
    }
}
