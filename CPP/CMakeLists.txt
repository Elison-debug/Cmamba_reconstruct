cmake_minimum_required(VERSION 3.14)
project(cmamba_fixed88 CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

add_library(cmamba_fixed88 STATIC
    src/infer.cpp
)
target_include_directories(cmamba_fixed88 PUBLIC ${CMAKE_CURRENT_SOURCE_DIR}/src)

add_executable(cmamba_demo src/main.cpp)
target_link_libraries(cmamba_demo PRIVATE cmamba_fixed88)

