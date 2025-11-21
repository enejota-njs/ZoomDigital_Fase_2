#ifndef LIBRARY
#define LIBRARY

#include <stdint.h>

void initialization(void);
void pixel_decimation(void);
void nearest_neighbor(uint8_t x, uint8_t y);
void pixel_replication(uint8_t x, uint8_t y);
void block_average(void);
void open_image(const char *filename);
void finalization(void);

#endif