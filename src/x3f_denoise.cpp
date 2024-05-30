/* X3F_DENOISE.CPP
 *
 * Library for denoising of X3F image data.
 *
 * Copyright 2015 - Roland and Erik Karlsson
 * BSD-style - see doc/copyright.txt
 *
 */

#include <cinttypes>

#include <opencv2/core.hpp>
#include <opencv2/imgproc.hpp>

#include "x3f_denoise.h"
#include "x3f_io.h"

using namespace cv;


// NOTE: active has to be a subarea of image, i.e. they have to share
//       the same data area.
// NOTE: image, active and qtop will be destructively modified in place.
void x3f_expand_quattro(x3f_area16_t *image,
                        x3f_area16_t *qtop,
                        x3f_area16_t *expanded)
{
    assert(image->channels == 3);
    assert(qtop->channels == 1);

    Mat img(image->rows, image->columns, CV_16UC3,
            image->data, sizeof(uint16_t) * image->row_stride);
    Mat qt(qtop->rows, qtop->columns, CV_16U,
           qtop->data, sizeof(uint16_t) * qtop->row_stride);
    Mat exp(expanded->rows, expanded->columns, CV_16UC3,
            expanded->data, sizeof(uint16_t) * expanded->row_stride);

    assert(qt.size() == exp.size());

    // TODO: Does this still work?
    resize(img, exp, exp.size(), 0.0, 0.0, INTER_CUBIC);
    qt *= 4;
    int from_to[] = {0, 0};
    mixChannels(&qt, 1, &exp, 1, from_to, 1);
}
