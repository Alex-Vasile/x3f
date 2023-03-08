/* X3F_DENOISE.CPP
 *
 * Library for denoising of X3F image data.
 *
 * Copyright 2015 - Roland and Erik Karlsson
 * BSD-style - see doc/copyright.txt
 *
 */

#include <assert.h>
#include <inttypes.h>

#include "x3f_denoise.h"
#include "x3f_io.h"

namespace {

static const int INTER_RESIZE_COEF_BITS = 11;
static const int INTER_RESIZE_COEF_SCALE = 1 << INTER_RESIZE_COEF_BITS;

static inline int clamp_int(int value, int low, int high)
{
  if (value < low) return low;
  if (value > high) return high;
  return value;
}

static void interpolate_cubic(float x, short coeffs[4])
{
  const float A = -0.75f;
  float cb[4];
  int isum;

  cb[0] = ((A*(x + 1.0f) - 5.0f*A)*(x + 1.0f) + 8.0f*A)*(x + 1.0f) - 4.0f*A;
  cb[1] = ((A + 2.0f)*x - (A + 3.0f))*x*x + 1.0f;
  cb[2] = ((A + 2.0f)*(1.0f - x) - (A + 3.0f))*(1.0f - x)*(1.0f - x) + 1.0f;
  cb[3] = 1.0f - cb[0] - cb[1] - cb[2];

  coeffs[0] = (short)(cb[0] * INTER_RESIZE_COEF_SCALE);
  coeffs[1] = (short)(cb[1] * INTER_RESIZE_COEF_SCALE);
  coeffs[2] = (short)(cb[2] * INTER_RESIZE_COEF_SCALE);
  isum = coeffs[0] + coeffs[1] + coeffs[2];
  coeffs[3] = (short)(INTER_RESIZE_COEF_SCALE - isum);
}

static void resize_cubic_u16c3(const x3f_area16_t *src, x3f_area16_t *dst)
{
  short xcoeffs[4], ycoeffs[4];
  const int channels = 3;
  int dx, dy, sx, sy, k, c;

  assert(src->channels == channels);
  assert(dst->channels == channels);

  for (dy = 0; dy < (int)dst->rows; dy++) {
    const float fy = ((dy + 0.5f) * (float)src->rows / (float)dst->rows) - 0.5f;
    int64_t sum;

    sy = (int)fy;
    if ((float)sy > fy) sy--;
    interpolate_cubic(fy - sy, ycoeffs);

    for (dx = 0; dx < (int)dst->columns; dx++) {
      const float fx = ((dx + 0.5f) * (float)src->columns / (float)dst->columns) - 0.5f;
      int row_value[4][3];

      sx = (int)fx;
      if ((float)sx > fx) sx--;
      interpolate_cubic(fx - sx, xcoeffs);

      for (k = 0; k < 4; k++) {
        const int src_y = clamp_int(sy + k - 1, 0, (int)src->rows - 1);
        const uint16_t *src_row = src->data + src->row_stride * src_y;

        for (c = 0; c < channels; c++) {
          int hx = 0;
          int xk;

          for (xk = 0; xk < 4; xk++) {
            const int src_x = clamp_int(sx + xk - 1, 0, (int)src->columns - 1);
            hx += src_row[src_x * channels + c] * xcoeffs[xk];
          }

          row_value[k][c] = hx;
        }
      }

      for (c = 0; c < channels; c++) {
        uint16_t *dst_px = dst->data + dst->row_stride * dy + dx * channels + c;

        sum = 0;
        for (k = 0; k < 4; k++) sum += (int64_t)row_value[k][c] * ycoeffs[k];

        sum = (sum + (1 << (INTER_RESIZE_COEF_BITS * 2 - 1))) >>
          (INTER_RESIZE_COEF_BITS * 2);

        if (sum < 0) *dst_px = 0;
        else if (sum > UINT16_MAX) *dst_px = UINT16_MAX;
        else *dst_px = (uint16_t)sum;
      }
    }
  }
}

static inline uint16_t sat_mul4_u16(uint16_t value)
{
  return value > UINT16_MAX / 4 ? UINT16_MAX : (uint16_t)(value * 4);
}

}

// NOTE: active has to be a subarea of image, i.e. they have to share
//       the same data area.
// NOTE: image, active and qtop will be destructively modified in place.
void x3f_expand_quattro(x3f_area16_t *image, x3f_area16_t *qtop, x3f_area16_t *expanded)
{
  int row, col;

  assert(image->channels == 3);
  assert(qtop->channels == 1);
  assert(qtop->rows == expanded->rows);
  assert(qtop->columns == expanded->columns);
  assert(expanded->channels == 3);

  resize_cubic_u16c3(image, expanded);

  for (row = 0; row < (int)qtop->rows; row++) {
    const uint16_t *src_row = qtop->data + qtop->row_stride * row;
    uint16_t *dst_row = expanded->data + expanded->row_stride * row;

    for (col = 0; col < (int)qtop->columns; col++)
      dst_row[expanded->channels * col] = sat_mul4_u16(src_row[col]);
  }
}
