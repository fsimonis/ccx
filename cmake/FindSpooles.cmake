find_library(Spooles_LIBRARY spooles)
find_path(Spooles_INCLUDE_DIR SPOOLES.h PATH_SUFFIXES spooles)

set(Spooles_INCLUDE_DIRS ${Spooles_INCLUDE_DIR})
set(Spooles_LIBRARIES ${Spooles_LIBRARY})
mark_as_advanced(Spooles_LIBRARY Spooles_INCLUDE_DIR)

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(Spooles
  REQUIRED_VARS Spooles_LIBRARY Spooles_INCLUDE_DIR)

if(NOT TARGET Spooles::Spooles)
  add_library(Spooles::Spooles UNKNOWN IMPORTED)
  set_target_properties(Spooles::Spooles PROPERTIES
    IMPORTED_LOCATION "${Spooles_LIBRARY}"
    INTERFACE_INCLUDE_DIRECTORIES "${Spooles_INCLUDE_DIR}")
endif()
