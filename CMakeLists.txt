cmake_minimum_required(VERSION 3.10)


#
# Setup options
#

option(64BitIntegers "Default to 64bit integers." OFF)
option(MultiThreaded "Build the multi-threaded version." OFF)
option(BUILD_TESTING "Build the testing tree." OFF)
set(ARCH "Linux" CACHE STRING "The target architecture.")
set_property(CACHE ARCH PROPERTY STRINGS Linux HP IRIX IRIX64)
set(CMAKE_BUILD_TYPE "Release" CACHE STRING "Choose the type of build, options are: None Debug Release RelWithDebInfo MinSizeRel ...")
set_property(CACHE CMAKE_BUILD_TYPE PROPERTY STRINGS None Debug Release RelWithDebInfo MinSizeRel)


project(CalculiX VERSION 2.16 LANGUAGES C Fortran)

#
# Find dependencies
#

set(CMAKE_MODULE_PATH ${CalculiX_SOURCE_DIR}/cmake)

find_package(Threads REQUIRED)
find_package(ARPACK REQUIRED)
find_package(Spooles REQUIRED)
find_package(OpenMP REQUIRED)

#
# Setup libcalculix
#

# Load sources from src/sources.cmake and add src/ prefix to them
include(${CalculiX_SOURCE_DIR}/src/sources.cmake)
set(CCX_SOURCES "")
foreach(source ${_ccx_sources})
  set(CCX_SOURCES ${CCX_SOURCES} src/${source})
endforeach(source)

add_library(libcalculix STATIC ${CCX_SOURCES})
target_include_directories(libcalculix PUBLIC src)
set_target_properties(libcalculix PROPERTIES OUTPUT_NAME calculix)
target_link_libraries(
  libcalculix PUBLIC
  Threads::Threads
  OpenMP::OpenMP_C
  Spooles::Spooles
  ARPACK::ARPACK
)

# GFORTRAN >10 does not allow argument mismatch
if(CMAKE_Fortran_COMPILER_ID STREQUAL "GNU" AND CMAKE_Fortran_COMPILER_VERSION VERSION_GREATER_EQUAL 10)
  target_compile_options(
    libcalculix PRIVATE
    $<$<COMPILE_LANGUAGE:Fortran>:-fallow-argument-mismatch>
  )
endif()

target_compile_definitions(
  libcalculix PUBLIC
  ARCH=Linux
  SPOOLES
  ARPACK
  MATRIXSTORAGE
)

if(64BitIntegers)
  target_compile_options(
    libcalculix PRIVATE
    $<$<COMPILE_LANGUAGE:Fortran>:-fdefault-integer-8>
  )
  target_compile_definitions(
    libcalculix PUBLIC
    $<$<COMPILE_LANGUAGE:C>:LONGLONG>
  )
endif()

if(MultiThreaded)
  target_compile_definitions(
    libcalculix PUBLIC
    $<$<COMPILE_LANGUAGE:C>:USE_MT=1>
  )
endif()

#
# Setup the calculix binary
#

add_executable(calculix src/ccx_${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}.c)
target_link_libraries(calculix PRIVATE libcalculix)

#
# Setup installation
#

include(GNUInstallDirs)
install(TARGETS calculix RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR})

#
# Setup Tests
#

if(BUILD_TESTING)
  include(CTest)

  # Detect test cases
  set(_test_dir "${CalculiX_SOURCE_DIR}/test")
  file(GLOB _test_cases "${_test_dir}/*.inp")
  list(LENGTH _test_cases _num_test_cases)
  message(STATUS "Found ${_num_test_cases} test cases")

  # Register test cases as tests
  set(_test_run_dir "${CalculiX_BINARY_DIR}/test")
  file(MAKE_DIRECTORY ${_test_run_dir})
  foreach(_case IN LISTS _test_cases)
    get_filename_component(_case_name ${_case} NAME_WE)
    set(_test_name "ccx.${_case_name}")
    message(STATUS "Adding test case ${_test_name}")
    add_test(
      NAME ${_test_name}
      COMMAND $<TARGET_FILE:calculix> -i ${_test_dir}/${_case_name}
      FAIL_REGULAR_EXPRESSION "ERROR;Error"
      WORKING_DIRECTORY ${_run_dir}
    )
  endforeach()
endif()
