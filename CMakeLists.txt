cmake_minimum_required(VERSION 3.0.0)

include(GNUInstallDirs)

project(AvrGccToolchain)

set(AVR_TOOLCHAIN_DESTINATIION "${CMAKE_INSTALL_LIBDIR}/cmake/avr-gcc")
message(STATUS "AVR_TOOLCHAIN_DESTINATIION is ${AVR_TOOLCHAIN_DESTINATIION}")

install(
    FILES
        ${CMAKE_CURRENT_SOURCE_DIR}/avr-gcc-config.cmake
        ${CMAKE_CURRENT_SOURCE_DIR}/avr-gcc.cmake
    DESTINATION
        ${AVR_TOOLCHAIN_DESTINATIION}
)

