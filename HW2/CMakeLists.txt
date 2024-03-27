# include all cpp and h files in the current directory
cmake_minimum_required(VERSION 3.10)
project(USTC_MM_HW2)
set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

file(GLOB USTC_MM_HW2_SRC
    "*.h"
    "*.cpp"
)

add_executable(USTC_MM_HW2 ${USTC_MM_HW2_SRC})