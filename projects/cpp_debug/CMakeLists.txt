cmake_minimum_required(VERSION 3.10)
project(MathDemo)

set(CMAKE_CXX_STANDARD 14)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_BUILD_TYPE Debug)

include_directories(include)

add_executable(math_demo
    src/main.cpp
    src/math_utils.cpp
)
