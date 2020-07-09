find_library(ARPACK_LIBRARY arpack)

find_package(LAPACK REQUIRED)

set(ARPACK_LIBRARIES ${ARPACK_LIBRARY})

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(ARPACK
  REQUIRED_VARS ARPACK_LIBRARY)

if(NOT TARGET ARPACK::ARPACK)
  add_library(ARPACK::ARPACK UNKNOWN IMPORTED)
  set_target_properties(ARPACK::ARPACK PROPERTIES
    IMPORTED_LOCATION "${ARPACK_LIBRARY}"
    INTERFACE_LINK_LIBRARIES "${LAPACK_LIBRARIES}"
    )
endif()
