CMAKE_MINIMUM_REQUIRED(VERSION 3.4)
# TODO: Can cross-compile, but need both arm and x86 libraries installed.
#set(CMAKE_OSX_ARCHITECTURES "arm64;x86_64" CACHE STRING "" FORCE)

Project (x3f)
add_definitions(-DVERSION=\"0.57\")
include(FindPkgConfig)
set(EXECUTABLE_NAME "x3f_extract")
set(CMAKE_CXX_FLAGS_RELEASE "-O2")
set(CMAKE_CXX_STANDARD 11)
#set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -static-libstdc++")
#set(CMAKE_VERBOSE_MAKEFILE ON)
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin)
set(FRAMEWORKS_DIRECTOR ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/${EXECUTABLE_NAME}.app/Contents/Frameworks)
list(APPEND CMAKE_MODULE_PATH ${ZSTD_DIR})

find_package(ZSTD REQUIRED)
find_package(ZLIB REQUIRED)
find_package(Iconv REQUIRED)
find_package(LAPACK REQUIRED)
find_package(OpenCL REQUIRED)
find_package(OpenCV REQUIRED)
find_library(LZMA_STATIC_LIBRARY            NAMES liblzma.a           liblzma.lib)
find_library(JPEG_STATIC_LIBRARY            NAMES libjpeg.a           libjpeg.lib)
find_library(TIFF_STATIC_LIBRARY            NAMES libtiff.a           libtiff.lib)
find_library(TBB_STATIC_LIBRARY             NAMES libtbb.a            libtbb.lib)
find_library(OPENCV_CORE_STATIC_LIBRARY     NAMES libopencv_core.a    libopencv_core.lib)
find_library(OPENCV_PHOTO_STATIC_LIBRARY    NAMES libopencv_photo.a   libopencv_photo.lib)
find_library(OPENCV_IMGPROC_STATIC_LIBRARY  NAMES libopencv_imgproc.a libopencv_imgproc.lib)

find_package(TBB REQUIRED)
get_target_property(TBB_INCLUDE_DIRS TBB::tbb INTERFACE_INCLUDE_DIRECTORIES)
IF (TBB_INCLUDE_DIRS)
  include_directories(${TBB_INCLUDE_DIRS})
  link_directories(${TBB_LIBRARY_DIRS})
ENDIF (TBB_INCLUDE_DIRS)

ADD_EXECUTABLE(${EXECUTABLE_NAME}
  src/x3f_extract.c src/x3f_version.c src/x3f_io.c src/x3f_process.c src/x3f_meta.c src/x3f_image.c
  src/x3f_spatial_gain.c src/x3f_output_dng.c src/x3f_output_tiff.c src/x3f_output_ppm.c
  src/x3f_histogram.c src/x3f_print_meta.c src/x3f_dump.c src/x3f_matrix.c
  src/x3f_dngtags.c src/x3f_denoise_utils.cpp src/x3f_denoise_aniso.cpp
  src/x3f_denoise.cpp src/x3f_printf.c ${AUXC}
)


#target_include_directories(${EXECUTABLE_NAME} PRIVATE ${OpenCV_INCLUDE_DIRS})

include_directories(${OpenCL_INCLUDE_DIRS})
include_directories(${OpenCV_INCLUDE_DIRS})


target_link_libraries(${EXECUTABLE_NAME} Iconv::Iconv)

target_link_libraries(${EXECUTABLE_NAME} opencv_core opencv_photo opencv_imgproc)
#target_link_libraries(${EXECUTABLE_NAME} ${OPENCV_CORE_STATIC_LIBRARY})
#target_link_libraries(${EXECUTABLE_NAME} ${OPENCV_PHOTO_STATIC_LIBRARY})
#target_link_libraries(${EXECUTABLE_NAME} ${OPENCV_IMGPROC_STATIC_LIBRARY})
target_link_libraries(${EXECUTABLE_NAME} ${LAPACK_LIBRARIES})
target_link_libraries(${EXECUTABLE_NAME} ${OpenCL_LIBRARY})
target_link_libraries(${EXECUTABLE_NAME} ${TBB_STATIC_LIBRARY})

target_link_libraries(${EXECUTABLE_NAME} ${TIFF_STATIC_LIBRARY})
target_link_libraries(${EXECUTABLE_NAME} ${LZMA_STATIC_LIBRARY})
target_link_libraries(${EXECUTABLE_NAME} ${JPEG_STATIC_LIBRARY})
target_link_libraries(${EXECUTABLE_NAME} ${ZLIB_LIBRARIES})
target_link_libraries(${EXECUTABLE_NAME} zstd::libzstd_static)

# Deal with libraries
if (CMAKE_SYSTEM_NAME MATCHES "Darwin")

else ()  # Static for everything else
  set(CMAKE_EXE_LINKER_FLAGS "-static")
endif ()