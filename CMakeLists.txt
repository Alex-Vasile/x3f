CMAKE_MINIMUM_REQUIRED(VERSION 3.4)
# TODO: Can cross-compile, but need both arm and x86 libraries installed.
#set(CMAKE_OSX_ARCHITECTURES "arm64;x86_64" CACHE STRING "" FORCE)

Project (x3f)
add_definitions(-DVERSION=\"0.57\")
include(FindPkgConfig)
set(EXECUTABLE_NAME "x3f_extract")
set(CMAKE_CXX_FLAGS_RELEASE "-O2")
#set(CMAKE_VERBOSE_MAKEFILE ON)
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin)
set(FRAMEWORKS_DIRECTOR ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/${EXECUTABLE_NAME}.app/Contents/Frameworks)
list(APPEND CMAKE_MODULE_PATH ${ZSTD_DIR})

find_package(ZSTD REQUIRED)
find_package(Iconv REQUIRED)
#find_library(ICONV_STATIC_LIBRARY           NAMES libiconv.a          libiconv.lib PATHS /opt/homebrew/opt/libiconv/lib)
find_library(LZMA_STATIC_LIBRARY            NAMES liblzma.a           liblzma.lib)
find_library(JPEG_STATIC_LIBRARY            NAMES libjpeg.a           libjpeg.lib)
find_library(TIFF_STATIC_LIBRARY            NAMES libtiff.a           libtiff.lib)
find_package(OpenCV REQUIRED)
find_library(OPENCV_CORE_STATIC_LIBRARY     NAMES libopencv_core.a    libopencv_core.lib)
find_library(OPENCV_PHOTO_STATIC_LIBRARY    NAMES libopencv_photo.a   libopencv_photo.lib)
find_library(OPENCV_IMGPROC_STATIC_LIBRARY  NAMES libopencv_imgproc.a libopencv_imgproc.lib)

find_package(TBB)
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

target_include_directories(${EXECUTABLE_NAME} PRIVATE ${OpenCV_INCLUDE_DIRS})

target_link_libraries(${EXECUTABLE_NAME} Iconv::Iconv)
#target_link_libraries(${EXECUTABLE_NAME} ${ICONV_STATIC_LIBRARY})
target_link_libraries(${EXECUTABLE_NAME} opencv_core opencv_photo opencv_imgproc)
#target_link_libraries(${EXECUTABLE_NAME} ${OPENCV_CORE_STATIC_LIBRARY})
#target_link_libraries(${EXECUTABLE_NAME} ${OPENCV_PHOTO_STATIC_LIBRARY})
#target_link_libraries(${EXECUTABLE_NAME} ${OPENCV_IMGPROC_STATIC_LIBRARY})
target_link_libraries(${EXECUTABLE_NAME} ${TIFF_STATIC_LIBRARY})
target_link_libraries(${EXECUTABLE_NAME} zstd::libzstd_static)
target_link_libraries(${EXECUTABLE_NAME} ${LZMA_STATIC_LIBRARY})
target_link_libraries(${EXECUTABLE_NAME} ${JPEG_STATIC_LIBRARY})

IF (TBB_INCLUDE_DIRS)
  target_link_libraries(${EXECUTABLE_NAME} tbb)
ENDIF (TBB_INCLUDE_DIRS)

# Deal with libraries
if (CMAKE_SYSTEM_NAME MATCHES "Darwin")  # Bundle for macOS
  set(CMAKE_MACOSX_RPATH ON)
#  set(CMAKE_BUILD_WITH_INSTALL_RPATH ON)
#  set(CMAKE_INSTALL_RPATH_USE_LINK_PATH TRUE)

  set_target_properties(${EXECUTABLE_NAME} PROPERTIES
    MACOSX_BUNDLE             TRUE
    MACOSX_BUNDLE_INFO_PLIST  "${CMAKE_SOURCE_DIR}/Info.plist.in"
  )

  # Create the Frameworks directory
  file(MAKE_DIRECTORY ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/${EXECUTABLE_NAME}.app/Contents/Frameworks)

  get_target_property(OPENCV_CORE_LOCATION_RELEASE    opencv_core    IMPORTED_LOCATION_RELEASE)
  get_target_property(OPENCV_PHOTO_LOCATION_RELEASE   opencv_photo   IMPORTED_LOCATION_RELEASE)
  get_target_property(OPENCV_IMGPROC_LOCATION_RELEASE opencv_imgproc IMPORTED_LOCATION_RELEASE)

#  execute_process(
#    COMMAND ${CMAKE_COMMAND} -E copy ${TIFF_LIBRARY}                    ${FRAMEWORKS_DIRECTOR}
#    COMMAND ${CMAKE_COMMAND} -E copy "/usr/lib/libc++.1.dylib"          ${FRAMEWORKS_DIRECTOR}
#    COMMAND ${CMAKE_COMMAND} -E copy ${OPENCV_CORE_LOCATION_RELEASE}    ${FRAMEWORKS_DIRECTOR}
#    COMMAND ${CMAKE_COMMAND} -E copy ${OPENCV_PHOTO_LOCATION_RELEASE}   ${FRAMEWORKS_DIRECTOR}
#    COMMAND ${CMAKE_COMMAND} -E copy ${OPENCV_IMGPROC_LOCATION_RELEASE} ${FRAMEWORKS_DIRECTOR}
#  )

  # Specify the runtime path during linking
#  target_link_options(${EXECUTABLE_NAME} PRIVATE
#      "LINKER:-rpath,@executable_path/../Frameworks"
#      "LINKER:-rpath,@loader_path/../Frameworks"
#  )
#
#  execute_process(COMMAND chmod +w *)

  # TODO: This is not working properly
#  set_target_properties(${EXECUTABLE_NAME} PROPERTIES
#      INSTALL_RPATH "@executable_path/../Frameworks"
#  )
#  set_target_properties(${EXECUTABLE_NAME} PROPERTIES
#    INSTALL_NAME_DIR "@executable_path/../Frameworks"
#  )
#
#  set(CMAKE_INSTALL_RPATH ${FRAMEWORKS_DIRECTOR})
#  set(CMAKE_BUILD_RPATH ${FRAMEWORKS_DIRECTOR})

else ()  # Static for everything else
  set(CMAKE_EXE_LINKER_FLAGS "-static")
endif ()