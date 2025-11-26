# ==================== 通用编译选项 ====================
function(set_common_compile_options projectName)
    target_compile_options(${projectName} PRIVATE
        # 警告配置（严格模式，警告视为错误）
        $<$<OR:$<CXX_COMPILER_ID:GNU>,$<CXX_COMPILER_ID:Clang>>:
            -Wall -Wextra -Wpedantic -Werror
            -Wshadow -Wunused -Wconversion -Wsign-conversion
            -Wnon-virtual-dtor -Wold-style-cast -Woverloaded-virtual
        >
        $<$<CXX_COMPILER_ID:MSVC>:
            /W4 /WX  # MSVC 警告等级4，警告视为错误
            /wd4251  # 禁用“导出类使用未导出成员”警告（DLL 项目常用）
        >
    )

    # 优化选项（按构建类型区分）
    target_compile_options(${projectName} PRIVATE
        $<$<CONFIG:Debug>:
            $<$<OR:$<CXX_COMPILER_ID:GNU>,$<CXX_COMPILER_ID:Clang>>:-O0 -g>
            $<$<CXX_COMPILER_ID:MSVC>:/Od /Zi>
        >
        $<$<CONFIG:Release>:
            $<$<OR:$<CXX_COMPILER_ID:GNU>,$<CXX_COMPILER_ID:Clang>>:-O3 -DNDEBUG>
            $<$<CXX_COMPILER_ID:MSVC>:/O2 /DNDEBUG>
        >
        $<$<CONFIG:RelWithDebInfo>:
            $<$<OR:$<CXX_COMPILER_ID:GNU>,$<CXX_COMPILER_ID:Clang>>:-O2 -g -DNDEBUG>
            $<$<CXX_COMPILER_ID:MSVC>:/O2 /Zi /DNDEBUG>
        >
    )

    # 架构特定选项（示例：ARM 架构优化）
    if(CMAKE_SYSTEM_PROCESSOR MATCHES "arm|aarch64")
        target_compile_options(${projectName} PRIVATE
            $<$<OR:$<CXX_COMPILER_ID:GNU>,$<CXX_COMPILER_ID:Clang>>:-march=native -mtune=native>
        )
    endif()
endfunction()

# ==================== Sanitizer 配置（调试用） ====================
function(enable_sanitizer projectName)
    if(ENABLE_SANITIZER AND CMAKE_BUILD_TYPE MATCHES Debug)
        target_compile_options(${projectName} PRIVATE
            $<$<OR:$<CXX_COMPILER_ID:GNU>,$<CXX_COMPILER_ID:Clang>>:
                -fsanitize=address,undefined
                -fno-omit-frame-pointer
            >
        )
        target_link_options(${projectName} PRIVATE
            $<$<OR:$<CXX_COMPILER_ID:GNU>,$<CXX_COMPILER_ID:Clang>>:
                -fsanitize=address,undefined
            >
        )
        message(STATUS "Enabled sanitizer for target: ${projectName}")
    endif()
endfunction()

# ==================== 代码覆盖率（调试用） ====================
function(enable_coverage projectName)
    if(ENABLE_COVERAGE AND CMAKE_BUILD_TYPE MATCHES Debug)
        if(NOT CMAKE_CXX_COMPILER_ID MATCHES "GNU|Clang")
            message(WARNING "Coverage only supported by GCC/Clang")
            return()
        endif()
        target_compile_options(${projectName} PRIVATE --coverage)
        target_link_options(${projectName} PRIVATE --coverage)
        message(STATUS "Enabled code coverage for target: ${projectName}")
    endif()
endfunction()

