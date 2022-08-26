# Copyright (c) 2022 Vesoft Inc. All rights reserved

#
# This macro adds local file support to the git support in ExternalProject_Add
# If there is an existing archive file, it will use it instead of clone the
# git repo
#
# In addition to all arguments support by ExternalProject_Add git support,
# this macro adds two new arguments
#
#    ARCHIVE_FILE -- The archive file name for the git repo
#    ARCHIVE_MD5  -- The md5sum code of teh archive file
#
macro(ExternalProject_Add_Git proj_name)
    set(oneValueGitArgs GIT_REPOSITORY GIT_TAG GIT_REMOTE_NAME GIT_SHALLOW)
    set(oneValueOtherArgs ARCHIVE_FILE ARCHIVE_MD5
                          PREFIX TMP_DIR STAMP_DIR DOWNLOAD_DIR SOURCE_DIR BINARY_DIR
                          INSTALL_DIR SOURCE_SUBDIR
                          CMAKE_COMMAND CMAKE_GENERATOR CMAKE_GENERATOR_PLATFORM
                          CMAKE_GENERATOR_TOOLSET CMAKE_GENERATOR_INSTANCE
                          UPDATE_DISCONNECTED BUILD_IN_SOURCE BUILD_ALWAYS
                          TEST_BEFORE_INSTALL TEST_EXCLUDE_FROM_MAIN
                          LOG_DOWNLOAD LOG_UPDATE LOG_CONFIGURE LOG_BUILD LOG_INSTALL LOG_TEST
                          EXCLUDE_FROM_ALL LIST_SEPARATOR)
    set(oneValueArgs ${oneValueGitArgs} ${oneValueOtherArgs})
    set(multiValueGitArgs GIT_SUBMODULES GIT_CONFIG)
    set(multiValueOtherArgs UPDATE_COMMAND PATCH_COMMAND CONFIGURE_COMMAND BUILD_COMMAND
                            INSTALL_COMMAND TEST_COMMAND COMMAND
                            CMAKE_ARGS CMAKE_CACHE_ARGS CMAKE_CACHE_DEFAULT_ARGS
                            BUILD_BYPRODUCTS
                            DEPENDS STEP_TARGETS INDEPENDENT_STEP_TARGETS)
    set(multiValueArgs ${multiValueGitArgs} ${multiValueOtherArgs})

    cmake_parse_arguments(EPAG "" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

    if (EPAG_UNPARSED_ARGUMENTS)
        message(FATAL_ERROR "${proj_name} - Unsupported arguments: ${EPAG_UNPARSED_ARGUMENTS}")
    endif()

    set(args ${proj_name})
    set(gitClone FALSE)
    if (EPAG_ARCHIVE_FILE AND EPAG_ARCHIVE_MD5)
        execute_process(
            COMMAND echo "${EPAG_ARCHIVE_MD5}  ${EPAG_ARCHIVE_FILE}"
            OUTPUT_FILE cachelib.md5
            WORKING_DIRECTORY ${DOWNLOAD_DIR}
        )

        execute_process(
            COMMAND md5sum -c cachelib.md5 --status
            RESULT_VARIABLE archiveFound
            WORKING_DIRECTORY ${DOWNLOAD_DIR}
        )

        execute_process(
            COMMAND rm cachelib.md5
            WORKING_DIRECTORY ${DOWNLOAD_DIR}
        )

        if (archiveFound EQUAL 0)
            message(STATUS "${proj_name}: Use archived file")
            execute_process(
                COMMAND
                    mkdir -p ${source_dir}
                COMMAND
                    tar -C ${source_dir} --overwrite
                        -zxf ${EPAG_ARCHIVE_FILE}
                WORKING_DIRECTORY ${DOWNLOAD_DIR}
            )
            list(APPEND args DOWNLOAD_COMMAND ""
                             DOWNLOAD_NAME ${EPAG_ARCHIVE_FILE})
        else()
            set(gitClone TRUE)
        endif()
    else ()
        set(gitClone TRUE)
    endif()

    if (gitClone)
        message(STATUS "${proj_name}: Clone from the repository")
        foreach(arg IN LISTS oneValueGitArgs multiValueGitArgs)
            if (EPAG_${arg})
                list(APPEND args ${arg} ${EPAG_${arg}})
            endif()
        endforeach()
    endif()

    foreach(arg IN LISTS oneValueOtherArgs multiValueOtherArgs)
        if (EPAG_${arg})
            list(APPEND args ${arg} ${EPAG_${arg}})
        endif()
    endforeach()

    ExternalProject_Add(${args})

    if (gitClone)
        ExternalProject_Add_Step(${proj_name} pre-patch
            DEPENDEES update
            DEPENDERS patch
            COMMAND
                git checkout -- *
            WORKING_DIRECTORY ${source_dir}
        )
    endif()
endmacro()
