cmake_minimum_required(VERSION 3.15)

# 单元测试可执行文件
add_executable(${PROJECT_NAME}_tests
    unit/CalculatorTest.cpp
)

# 链接依赖
target_link_libraries(${PROJECT_NAME}_tests
    PRIVATE
        ${PROJECT_NAME}
        Catch2::Catch2WithMain  # Catch2 主函数（无需手动写 main）
)

# 应用编译选项
set_common_compile_options(${PROJECT_NAME}_tests)
enable_sanitizer(${PROJECT_NAME}_tests)
enable_coverage(${PROJECT_NAME}_tests)

# 注册测试（Catch2 自动发现测试用例）
include(Catch)
catch_discover_tests(${PROJECT_NAME}_tests)