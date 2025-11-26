# ==================== 依赖管理策略 ====================
# 优先使用系统安装的依赖，其次通过 FetchContent 下载（CMake 3.11+）
include(FetchContent)
FetchContent_Declare(
    Catch2
    GIT_REPOSITORY https://github.com/catchorg/Catch2.git
    GIT_TAG v3.4.0  # 锁定版本
)

# ==================== 第三方依赖 ====================
# 1. 单元测试框架（Catch2，仅测试时依赖）
if(BUILD_TESTING)
    FetchContent_MakeAvailable(Catch2)
    list(APPEND CMAKE_MODULE_PATH ${catch2_SOURCE_DIR}/extras)
endif()



# 2. 示例：依赖 Boost（系统安装）
# find_package(Boost 1.70 REQUIRED COMPONENTS filesystem)
# if(Boost_FOUND)
#     target_link_libraries(${PROJECT_NAME} PUBLIC Boost::filesystem)
# endif()

# 3. 示例：依赖 spdlog（FetchContent 下载）
# FetchContent_Declare(
#     spdlog
#     GIT_REPOSITORY https://github.com/gabime/spdlog.git
#     GIT_TAG v1.12.0
# )
# FetchContent_MakeAvailable(spdlog)
# target_link_libraries(${PROJECT_NAME} PRIVATE spdlog::spdlog)