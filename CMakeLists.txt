cmake_minimum_required(VERSION 3.0.0)

option(BUILD_EXAMPLE "Build an example" OFF)

include(GNUInstallDirs)

project(AvrGccToolchain)

set(AVR_TOOLCHAIN_DESTINATIION "${CMAKE_INSTALL_LIBDIR}/cmake/avr-gcc")
set(AVR_SOURCE ${CMAKE_CURRENT_SOURCE_DIR}/scripts)
message(STATUS "AVR_TOOLCHAIN_DESTINATIION is ${AVR_TOOLCHAIN_DESTINATIION}")

install(
    FILES
        ${AVR_SOURCE}/avr-gcc-config.cmake
        ${AVR_SOURCE}/avr-gcc.cmake
    DESTINATION
        ${AVR_TOOLCHAIN_DESTINATIION}
)

if(BUILD_EXAMPLE)
    message(STATUS "Examples build enabled")
    add_subdirectory(example)
endif()

