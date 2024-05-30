import hashlib
import os.path
import subprocess
import os
import time
from behave import *


def get_dist_name():
    release_exe = "../cmake-build-release/x3f_extract"
    debug_exe   = "../cmake-build-debug/x3f_extract"
    if os.path.exists(release_exe):
        executable = release_exe
    elif os.path.exists(debug_exe):
        executable = debug_exe
    else:
        raise IOError("Couldn't find x3f_extract")
    # print statements are only executed by behave when the behavior fails,
    # so this print is usually silenced if all is well
    print(executable)
    return executable


def run_conversion(args):
    print(args)
    running_proc = subprocess.Popen(args, stdout=subprocess.PIPE, stderr=subprocess.PIPE)  # suppressing output
    while running_proc.poll() is None:
        time.sleep(0.1)
    assert running_proc.returncode == 0


@given(u'an input image {image} without a {converted_image}')
def step_impl(context, image, converted_image):
    assert os.path.isfile(image)
    if os.path.isfile(converted_image):
        os.chmod(converted_image, 0o666)
        os.remove(converted_image)


@when(u'the {image} is converted by the code to {file_type}')
def step_impl(context, image, file_type):
    found_executable = get_dist_name()
    file_flag = ''.join(('-', file_type.lower()))  # being lazy here, letting file type match the switch
    args = [found_executable, file_flag, "-color", "none", "-no-crop", image]
    run_conversion(args)


@when(u'the {image} is converted and compressed by the code to {file_type}')
def step_impl(context, image, file_type):
    found_executable = get_dist_name()
    file_flag = ''.join(('-', file_type.lower()))  # being lazy here, letting file type match the switch
    args = [found_executable, file_flag, "-color", "none", "-compress", "-no-crop", image]
    run_conversion(args)


@when(u'the {image} is converted by the code')
def step_impl(context, image):
    found_executable = get_dist_name()
    args = [found_executable, '-dng', image]
    run_conversion(args)


@when(u'the {image} is converted by the code to a cropped color TIFF')
def step_impl(context, image):
    found_executable = get_dist_name()
    args = [found_executable, '-tiff', '-color', 'AdobeRGB', image]
    run_conversion(args)


@when(u'the {image} is converted to tiff {output_format}')
def step_impl(context, image, output_format):
    found_executable = get_dist_name()
    args = ['-color', 'none']
    print(output_format)
    if output_format == 'UNPROCESSED':
        args = args + ['-unprocessed']
    if output_format == 'QTOP':
        args = args + ['-qtop']
    if output_format == 'COLOR_SRGB':
        args = ['-color', 'sRGB']
    if output_format == 'COLOR_ADOBE_RGB':
        args = ['-color', 'AdobeRGB']
    if output_format == 'COLOR_PROPHOTO_RGB':
        args = ['-color', 'ProPhotoRGB']
    if output_format != 'CROP':
        args = args + ['-no-crop']
    args = args + ['-tiff']
    args = [found_executable] + args + [image]
    run_conversion(args)


@then(u'the {converted_image} has the right {md5} hash value')
def step_impl(context, converted_image, md5):
    assert os.path.isfile(converted_image)
    md5_found = hashlib.md5()
    with open(converted_image, 'rb') as file:
        # Read ing 4K chunks rather than loading whole file in memory.
        # Costs ~5% is speed, but significantly reduces memory requirements.
        for block in iter(lambda: file.read(4096), b""):
            md5_found.update(block)
    md5_found = md5_found.hexdigest()
    if md5_found != md5:
        print("found_hash: ", md5_found, " expected_hash: ", md5)
        assert False
    os.chmod(converted_image, 0o666)
    os.remove(converted_image)  # normally, I'd remove this file in the environment
    # however, if these files should always be removed, then remove them immediately after
    # the test should be sufficient.  This should be the last 'then' statement
    # if more tests are later made.
