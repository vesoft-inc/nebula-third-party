find_program(Ninja_EXECUTABLE NAMES ninja DOC "Path to the ninja executable")
if (Ninja_EXECUTABLE)
    execute_process(
        OUTPUT_VARIABLE Ninja_VERSION
        OUTPUT_STRIP_TRAILING_WHITESPACE
        COMMAND "ninja" "--version"
    )
endif()

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(Ninja REQUIRED_VARS Ninja_EXECUTABLE
                                  VERSION_VAR Ninja_VERSION)
