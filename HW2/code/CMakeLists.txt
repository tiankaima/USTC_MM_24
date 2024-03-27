# include all cpp and h files in the current directory
cmake_minimum_required(VERSION 3.10)
project(USTC_MM_HW2)
set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

set(EIGEN_ROOR_DIR "./Eigen")

set(USTC_MM_HW2_SRC
        main.cpp
)
include_directories(${EIGEN_ROOR_DIR})
include_directories("./")

add_executable(USTC_MM_HW2 ${USTC_MM_HW2_SRC})
#target_include_directories(USTC_MM_HW2 PUBLIC ${EIGEN_ROOR_DIR})
#target_include_directories(USTC_MM_HW2 PUBLIC "./")