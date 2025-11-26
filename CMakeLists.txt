cmake_minimum_required(VERSION 3.15 FATAL_ERROR)

# ==================== 项目基础配置 ====================
project(
    MyProject                  # 项目名称（替换为你的项目名）
    VERSION 1.0.0              # 语义化版本（MAJOR.MINOR.PATCH）
    DESCRIPTION "A high-quality C++ project template"  # 项目描述
    HOMEPAGE_URL "https://github.com/yourname/MyProject"  # 项目主页
    LANGUAGES CXX              # 支持的语言（C/CXX/ASM 等）
)

# 强制要求 C++17（可根据项目调整，如 C++11/C++20）
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)  # 禁用编译器扩展（保证跨平台兼容性）

# 输出目录统一配置（避免编译产物混乱）
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${PROJECT_BINARY_DIR}/lib)  # 静态库
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${PROJECT_BINARY_DIR}/lib)  # 动态库
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${PROJECT_BINARY_DIR}/bin)  # 可执行文件

# 包含模块化配置（按顺序加载）
include(cmake/Utils.cmake)

include(cmake/CompileOptions.cmake)

include(cmake/Dependencies.cmake)



# ==================== 构建目标 ====================
# 1. 核心库（静态/动态可通过 BUILD_SHARED_LIBS 控制）
add_library(${PROJECT_NAME}
    src/core/Version.cpp
    src/core/Calculator.cpp
)

# 库的属性配置
set_target_properties(${PROJECT_NAME} PROPERTIES
    VERSION ${PROJECT_VERSION}          # 库版本
    SOVERSION ${PROJECT_VERSION_MAJOR}  # 主版本（兼容用）
    OUTPUT_NAME "myproject"             # 输出文件名（小写统一）
    EXPORT_NAME ${PROJECT_NAME}         # 导出目标名
)

# 预编译第三方库的引用
# OpenCV库的引用
set(OPENCV_NAME "OpenCV")
set(OPENCV_ROOT "F:/thirdParty/opencv/build")
set(OPENCV_LIBS_PATH "${OPENCV_ROOT}/x64/vc16/lib" )
set(OPENCV_INCLUDE_PATH "${OPENCV_ROOT}/include" )
set(OPENCV_DILL_PATH "${OPENCV_ROOT}/x64/vc16/bin")
message(STATUS "OPENCV_NAME:${OPENCV_NAME}")
message(STATUS "OPENCV_ROOT:${OPENCV_ROOT}")
message(STATUS "OPENCV_LIBS_PATH:${OPENCV_LIBS_PATH}")
message(STATUS "OPENCV_INCLUDE_PATH:${OPENCV_INCLUDE_PATH}")
message(STATUS "OPENCV_DILL_PATH: ${OPENCV_DILL_PATH}")

collect_libraries(
    NAME ${OPENCV_NAME}
    LIBS_DIR ${OPENCV_LIBS_PATH}
    COLLECTED_LIBS OpenCV_LIBS
)

# 头文件路径（PUBLIC：对外暴露；PRIVATE：内部使用）
target_include_directories(${PROJECT_NAME}
    PUBLIC
        $<BUILD_INTERFACE:${PROJECT_SOURCE_DIR}/include>  # 构建时
        $<INSTALL_INTERFACE:include>                      # 安装后
        ${OPENCV_INCLUDE_PATH}
        ${OPENCV_INCLUDE_PATH}/opencv4
    PRIVATE
        ${PROJECT_SOURCE_DIR}/src  # 内部源文件头文件路径
        
)



# 链接依赖（PUBLIC：依赖会传递给使用该库的目标）
target_link_libraries(${PROJECT_NAME}
    PUBLIC
        # 示例：如果依赖 Boost，这里填 Boost::Boost
        ${OpenCV_LIBS}
    PRIVATE
        # 示例：如果依赖 spdlog，这里填 spdlog::spdlog
        
)

# ==================== 应用到目标 ====================
# 对所有目标应用通用编译选项（可在具体目标中覆盖）
set_common_compile_options(${PROJECT_NAME})
if(TARGET ${PROJECT_NAME}_app)
    set_common_compile_options(${PROJECT_NAME}_app)
endif()
# 启用 Sanitizer 和覆盖率（仅调试模式）
enable_sanitizer(${PROJECT_NAME})
if(TARGET ${PROJECT_NAME}_app)
    enable_sanitizer(${PROJECT_NAME}_app)
endif()
enable_coverage(${PROJECT_NAME})

# 添加系统路径中

# 可执行文件（如果是库项目，可注释掉）
add_executable(${PROJECT_NAME}_app src/main.cpp)
set_target_properties(${PROJECT_NAME}_app PROPERTIES
    OUTPUT_NAME "myproject"  # 可执行文件名称
)
target_link_libraries(${PROJECT_NAME}_app PRIVATE ${PROJECT_NAME})

## 将.dll复制到可知文件目录中（运行时能找到）
add_custom_command(
    TARGET ${PROJECT_NAME} POST_BUILD
    COMMAND ${CMAKE_COMMAND} -E copy_if_different 
        ${OPENCV_DILL_PATH}/opencv_world4120.dll
        ${PROJECT_BINARY_DIR}/bin # 目标目录
    COMMENT "copy opencv4_world4120.dll to executable directory"
)

# ==================== 子目录构建 ====================
if(BUILD_TESTING)
    enable_testing()
    add_subdirectory(tests)  # 单元测试
endif()

if(BUILD_EXAMPLES)
    add_subdirectory(examples)  # 示例代码（默认关闭，可通过 -DBUILD_EXAMPLES=ON 启用）
endif()

if(BUILD_DOCS)
    add_subdirectory(docs)  # 文档生成（默认关闭，可通过 -DBUILD_DOCS=ON 启用）
endif()

# ==================== 安装与打包 ====================
include(cmake/InstallConfig.cmake)
include(cmake/PackageConfig.cmake)