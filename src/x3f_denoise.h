/* X3F_DENOISE.H
 *
 * Library for denoising of X3F image data.
 *
 * Copyright 2015 - Roland and Erik Karlsson
 * BSD-style - see doc/copyright.txt
 *
 */

#ifndef X3F_DENOISE_H
#define X3F_DENOISE_H

#include "x3f_io.h"

#ifdef __cplusplus
extern "C" {
#endif

extern void x3f_expand_quattro(x3f_area16_t *image,
                               x3f_area16_t *qtop,
                               x3f_area16_t *expanded);

#ifdef __cplusplus
}
#endif

#endif
