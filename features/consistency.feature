Feature: the output produced by the converter is stable


Scenario Outline: conversions to various outputs will produce exactly the same images
  Given an input image <image> without a <converted_image>
  When the <image> is converted by the code to <file_type>
  Then the <converted_image> has the right <md5> hash value
  Examples: images
    | image                       | file_type | converted_image                   | md5                               |
    | x3f_test_files/_SDI8040.X3F | DNG       | x3f_test_files/_SDI8040.X3F.dng   | 4d010dda629d3b429efafb04dcc165f4  |
    | x3f_test_files/_SDI8040.X3F | TIFF      | x3f_test_files/_SDI8040.X3F.tif   | 94154fc31978ce4d4dac2e56d5ef15d5  |
    | x3f_test_files/_SDI8040.X3F | PPM       | x3f_test_files/_SDI8040.X3F.ppm   | 695b71793dd0a0b76106e59b396179fa  |
    | x3f_test_files/_SDI8040.X3F | JPG       | x3f_test_files/_SDI8040.X3F.jpg   | 357f126f6435345642bfbc6171745d00  |
    | x3f_test_files/_SDI8040.X3F | META      | x3f_test_files/_SDI8040.X3F.meta  | 2e81db66465fa97366e64b943324a514  |
    | x3f_test_files/_SDI8040.X3F | RAW       | x3f_test_files/_SDI8040.X3F.raw   | 89582789c24f86aaefd92395bc4f0572  |
    | x3f_test_files/_SDI8040.X3F | PPM-ASCII | x3f_test_files/_SDI8040.X3F.ppm   | 2c911744d7331cf4e0b5fb2275ab8183  |
    | x3f_test_files/_SDI8040.X3F | HISTOGRAM | x3f_test_files/_SDI8040.X3F.csv   | fcdddf2ea9225a53f7e7fde981047280  |
    | x3f_test_files/_SDI8040.X3F | LOGHIST   | x3f_test_files/_SDI8040.X3F.csv   | fcec8870e8c3ee170bbdb9e91b368e20  |

    | x3f_test_files/_SDI8284.X3F | DNG       | x3f_test_files/_SDI8284.X3F.dng   | f33af1b99994ced6983fb9ea5238cba4  |
    | x3f_test_files/_SDI8284.X3F | TIFF      | x3f_test_files/_SDI8284.X3F.tif   | c1225d13b4619da52732318721062477  |
    | x3f_test_files/_SDI8284.X3F | PPM       | x3f_test_files/_SDI8284.X3F.ppm   | 7063975403a605ac231b88f58c0b86ba  |
    | x3f_test_files/_SDI8284.X3F | JPG       | x3f_test_files/_SDI8284.X3F.jpg   | 87cd494d3bc4eab4e481de6afeb058de  |
    | x3f_test_files/_SDI8284.X3F | META      | x3f_test_files/_SDI8284.X3F.meta  | 0a77d95cf4f53acec52c11e756590a28  |
    | x3f_test_files/_SDI8284.X3F | RAW       | x3f_test_files/_SDI8284.X3F.raw   | b9d230401b9822978b49ec244c2f0668  |
    | x3f_test_files/_SDI8284.X3F | PPM-ASCII | x3f_test_files/_SDI8284.X3F.ppm   | ea0165e8c1417ccba3048c472d956e82  |
    | x3f_test_files/_SDI8284.X3F | HISTOGRAM | x3f_test_files/_SDI8284.X3F.csv   | 7a4c86ba602cfde59c4e0b0df566e904  |
    | x3f_test_files/_SDI8284.X3F | LOGHIST   | x3f_test_files/_SDI8284.X3F.csv   | b832f5d61bbf900680403891961cc494  |


Scenario Outline: conversions to various compressed outputs will produce exactly the same images
  Given an input image <image> without a <converted_image>
  When the <image> is converted and compressed by the code to <file_type>
  Then the <converted_image> has the right <md5> hash value
  Examples: images
    | image                       | file_type | converted_image                 | md5                               |
    | x3f_test_files/_SDI8040.X3F | DNG       | x3f_test_files/_SDI8040.X3F.dng | e4ee8fa308b9f2e66d5811938b9c7522  |
    | x3f_test_files/_SDI8040.X3F | TIFF      | x3f_test_files/_SDI8040.X3F.tif | a0c292c2d13ffa4803b12bf7d89de037  |

    | x3f_test_files/_SDI8284.X3F | DNG       | x3f_test_files/_SDI8284.X3F.dng | bd2c7acb21ae1f9f1f88681a7d14fd64  |
    | x3f_test_files/_SDI8284.X3F | TIFF      | x3f_test_files/_SDI8284.X3F.tif | e93956ef0b16d5befef36365ba39fb71  |


Scenario Outline: denoised conversions to dng will produce the exact same outputs
  Given an input image <image> without a <converted_image>
  When the <image> is denoised and converted by the code
  Then the <converted_image> has the right <md5> hash value
  Examples: images
    | image                       | converted_image                 | md5                               |
    | x3f_test_files/_SDI8040.X3F | x3f_test_files/_SDI8040.X3F.dng | e1af64f4ab2bdcfbd50e55a782be6676  |
    | x3f_test_files/_SDI8284.X3F | x3f_test_files/_SDI8284.X3F.dng | b89e9512d3f1d4c3a7ce134645866830  |


Scenario Outline: denoised conversions to tiff will produce the exact same outputs
  Given an input image <image> without a <converted_image>
  When the <image> is denoised and converted by the code to a cropped color TIFF
  Then the <converted_image> has the right <md5> hash value
  Examples: images
    | image                       | converted_image                 | md5                               |
    | x3f_test_files/_SDI8040.X3F | x3f_test_files/_SDI8040.X3F.tif | f30ce5c33adddbcee4e14422e878967a  |
    | x3f_test_files/_SDI8284.X3F | x3f_test_files/_SDI8284.X3F.tif | df0f17bf3d8d18c65e456cd5f837db16  |


Scenario Outline: conversions to tiff will produce the exact same outputs
  Given an input image <image> without a <converted_image>
  When the <image> is converted to tiff <output_format>
  Then the <converted_image> has the right <md5> hash value
  Examples: images
    | image                       | output_format       | converted_image                 | md5                               |
    | x3f_test_files/_SDI8040.X3F | CROP                | x3f_test_files/_SDI8040.X3F.tif | e12f2895d23535c4ebd75adbc279ba29  |
    | x3f_test_files/_SDI8040.X3F | UNPROCESSED         | x3f_test_files/_SDI8040.X3F.tif | 6ed59ebfad84c57f2b9eb8531c61d17c  |
    | x3f_test_files/_SDI8040.X3F | COLOR_SRGB          | x3f_test_files/_SDI8040.X3F.tif | aa24e073f96d0f89b1fa582673a1353e  |
    | x3f_test_files/_SDI8040.X3F | COLOR_ADOBE_RGB     | x3f_test_files/_SDI8040.X3F.tif | 03425b228e7c194f8740db05360b1e7a  |
    | x3f_test_files/_SDI8040.X3F | COLOR_PROPHOTO_RGB  | x3f_test_files/_SDI8040.X3F.tif | bfb21343915c7f0032ee585d445c0f00  |

    | x3f_test_files/_SDI8284.X3F | CROP                | x3f_test_files/_SDI8284.X3F.tif | aaf0ec7624ef9811ee45e305f213ef57  |
    | x3f_test_files/_SDI8284.X3F | UNPROCESSED         | x3f_test_files/_SDI8284.X3F.tif | b7215ba5bb0f5a576650512b88f6e199  |
    | x3f_test_files/_SDI8284.X3F | QTOP                | x3f_test_files/_SDI8284.X3F.tif | 5fce6a9990adc4400adb13f102caca3f  |
    | x3f_test_files/_SDI8284.X3F | COLOR_SRGB          | x3f_test_files/_SDI8284.X3F.tif | 51455fe0ea00fd9c34ea914ea00e64a0  |
    | x3f_test_files/_SDI8284.X3F | COLOR_ADOBE_RGB     | x3f_test_files/_SDI8284.X3F.tif | 949bbb992e2c094f1ae29157e2fa2b19  |
    | x3f_test_files/_SDI8284.X3F | COLOR_PROPHOTO_RGB  | x3f_test_files/_SDI8284.X3F.tif | e2ad2a4f11acc30ebe77fa43670a6622  |
