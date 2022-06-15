#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <stdint.h>
#include "../tp2.h"
#include "../helper/utils.h"

void Funny_c(
    uint8_t *src,
    uint8_t *dst,
    int width,
    int height,
    int src_row_size,
    int dst_row_size)
{
    bgra_t (*src_matrix)[(src_row_size+3)/4] = (bgra_t (*)[(src_row_size+3)/4]) src;
    bgra_t (*dst_matrix)[(dst_row_size+3)/4] = (bgra_t (*)[(dst_row_size+3)/4]) dst;
 
    for (int i = 0; i < height; i++) {
        for (int j = 0; j < width; j++) {
		
			uint8_t funny_r = 100 * sqrt((float)(abs(j-i)));
			uint8_t funny_g = (float)(abs(i-j)*10) / ((float)(j+i+1)/100);
			uint8_t funny_b = 10 * ( sqrt((float)((i*2+100)*(j*2+100))) );
							
	        dst_matrix[i][j].r = SAT(funny_r/2 + src_matrix[i][j].r/2 );
	        dst_matrix[i][j].g = SAT(funny_g/2 + src_matrix[i][j].g/2 );
	        dst_matrix[i][j].b = SAT(funny_b/2 + src_matrix[i][j].b/2 );
        }
    }
}
