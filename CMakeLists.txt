CMAKE_MINIMUM_REQUIRED(VERSION 3.4)
# TODO: Can cross-compile, but need both arm and x86 libraries installed.
#set(CMAKE_OSX_ARCHITECTURES "arm64;x86_64" CACHE STRING "" FORCE)

Project (x3f)
set(EXECUTABLE_NAME "x3f_extract")

add_definitions(-DVERSION=\"0.58\")
set(CMAKE_VERBOSE_MAKEFILE ON)

set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin)

find_package(OpenCV REQUIRED)
include_directories(${OpenCV_INCLUDE_DIRS})
link_directories(${OpenCV_LIBRARY_DIRS})

find_package(TIFF REQUIRED)
include_directories(${TIFF_INCLUDE_DIRS})
link_directories(${TIFF_LIBRARY_DIRS})

find_package(Iconv REQUIRED)
include_directories(${ICONV_INCLUDE_DIRS})
link_directories(${ICONV_LIBRARY_DIRS})

ADD_EXECUTABLE(${EXECUTABLE_NAME}
  src/x3f_extract.c src/x3f_version.c src/x3f_io.c src/x3f_process.c src/x3f_meta.c src/x3f_image.c
  src/x3f_spatial_gain.c src/x3f_output_dng.c src/x3f_output_tiff.c src/x3f_output_ppm.c
  src/x3f_histogram.c src/x3f_print_meta.c src/x3f_dump.c src/x3f_matrix.c
  src/x3f_dngtags.c src/x3f_denoise.cpp src/x3f_printf.c ${AUXC}
)

target_link_libraries(${EXECUTABLE_NAME} PRIVATE Iconv::Iconv)
target_link_libraries(${EXECUTABLE_NAME} PRIVATE opencv_core opencv_photo opencv_imgproc)
target_link_libraries(${EXECUTABLE_NAME} PRIVATE TIFF::TIFF)

#set(CMAKE_EXE_LINKER_FLAGS "-static")