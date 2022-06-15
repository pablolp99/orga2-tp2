#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <stdint.h>
#include "../tp2.h"
#include "../helper/utils.h"

void Max_c(
    uint8_t *src,
    uint8_t *dst,
    int width,
    int height,
    int src_row_size,
    int dst_row_size)
{
	bgra_t (*src_matrix)[(src_row_size+3)/4] = (bgra_t (*)[(src_row_size+3)/4]) src;
	bgra_t (*dst_matrix)[(dst_row_size+3)/4] = (bgra_t (*)[(dst_row_size+3)/4]) dst;

	for (int i = 0; i < height-2; i=i+2) {
		for (int j = 0; j < width-2; j=j+2) {
		
			uint8_t r = 0, g = 0, b = 0;
			int max = 0;

			for (int ii = i; ii < i+4; ii++) {
				for (int jj = j; jj < j+4; jj++) {
					int newMax = (src_matrix[ii][jj].r + src_matrix[ii][jj].g + src_matrix[ii][jj].b);
					if( max < newMax) {
						max = newMax;
						r = src_matrix[ii][jj].r;
						g = src_matrix[ii][jj].g;
						b = src_matrix[ii][jj].b;
					}
				}
			}

			for (int ii = i+1; ii < i+3; ii++) {
				for (int jj = j+1; jj < j+3; jj++) {
					dst_matrix[ii][jj].r = r;
					dst_matrix[ii][jj].g = g;
					dst_matrix[ii][jj].b = b;
				}
			}
		}
	}
    utils_paintBorders32(dst, width, height, src_row_size, 1, 0xFFFFFFFF);    
}
