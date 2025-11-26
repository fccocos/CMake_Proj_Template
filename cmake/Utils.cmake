# ==================== 版本检查 ====================
# 检查编译器版本（示例：GCC >= 8.0，Clang >= 7.0，MSVC >= 19.20）
function(check_compiler_version)
    if(CMAKE_CXX_COMPILER_ID MATCHES "GNU")
        if(CMAKE_CXX_COMPILER_VERSION VERSION_LESS "8.0")
            message(FATAL_ERROR "GCC version must be at least 8.0")
        endif()
    elseif(CMAKE_CXX_COMPILER_ID MATCHES "Clang")
        if(CMAKE_CXX_COMPILER_VERSION VERSION_LESS "7.0")
            message(FATAL_ERROR "Clang version must be at least 7.0")
        endif()
    elseif(CMAKE_CXX_COMPILER_ID MATCHES "MSVC")
        if(CMAKE_CXX_COMPILER_VERSION VERSION_LESS "19.20")
            message(FATAL_ERROR "MSVC version must be at least 19.20 (VS 2019)")
        endif()
    endif()
endfunction()

check_compiler_version()

# ==================== 选项开关 ====================
# 构建选项（用户可通过 -DXXX=ON/OFF 控制）
option(BUILD_SHARED_LIBS "Build shared library (ON) or static library (OFF)" OFF)
option(BUILD_TESTING "Build unit tests" OFF)
option(BUILD_EXAMPLES "Build example programs" OFF)
option(BUILD_DOCS "Build documentation (requires Doxygen)" OFF)
option(ENABLE_SANITIZER "Enable address/undefined sanitizer (for debug)" OFF)
option(ENABLE_COVERAGE "Enable code coverage (for debug)" OFF)

# ==================== 路径工具 ====================
# 转换为绝对路径（处理相对路径输入）
function(to_absolute_path path_var input_path)
    if(IS_ABSOLUTE "${input_path}")
        set(${path_var} "${input_path}" PARENT_SCOPE)
    else()
        set(${path_var} "${CMAKE_CURRENT_SOURCE_DIR}/${input_path}" PARENT_SCOPE)
    endif()
endfunction()


# ==================收集库文件=====================

# 函数说明：递归收集指定目录下的库文件，结果变量存入缓存变量并返回
# 参数说明：
#   NAME             [输入]    库名标识，用于生成唯一缓存变量名
#   LIBS_DIR         [输入]    库文件所在根目录（必填）
#   LIB_PATTERN      [输入]    库文件匹配模式（可选，默认自动适配跨平台）
#   COLLECTED_LIBS   [输出]    输出变量，存储收集到的库文件列表（可直接用于链接）
function(collect_libraries)
    # 解析函数参数（POSITIONAL = 位置参数， KEYWORD = 关键参数）
    cmake_parse_arguments(
        ARG                     # 参数前缀
        ""                      # <option>无选项参数（仅开关，无值）
        "NAME;LIBS_DIR;LIB_PATTERN" # 单值参数关键字
        "COLLECTED_LIBS"            # 多值参数
        ${ARGN}                     # 传入所有参数
    )

    # ================= 参数校验（必填参数必须提供） =============
    if(NOT ARG_NAME)
        message(FATAL_ERROR "函数 ${CMAKE_CURRENT_FUNCTION} 必须指定 NAME 参数（如NAME=OpenCV")
    endif()
    if(NOT ARG_LIBS_DIR)
        message(FATAL_ERROR "函数 ${CMAKE_CURRENT_FUNCTION} 必须指定 LIBS_DIR 参数(库文件根目录)")
    endif()

    # ================ 跨平台默认匹配模式（若未指定 LIB_PATTERN) =================
    if(NOT ARG_LIB_PATTERN)
        if(WIN32)
            set(ARG_LIB_PATTERN "*.lib")
        elseif(APPLE)
            set(ARG_LIB_PATTERN "*.dylib;*.a")
        else()
            set(ARG_LIB_PATTERN "*.so;*.a")
        endif()
        message(STATUS "[${ARG_NAME}] 未指定 LIB_PATTERN, 使用跨平台默认值：${ARG_LIB_PATTERN}")
    endif()


    # ================= 递归收集库文件 ==================
    file(GLOB_RECURSE TEMP_LIBS
        LIST_DIRECTORIES FALSE
        ${ARG_LIBS_DIR}/${ARG_LIB_PATTERN}
    )


    # ================ 结果处理（去重+缓存） ================
    # 去重（避免同一库文件被多次收集)
    list(REMOVE_DUPLICATES TEMP_LIBS)

    # 生成唯一缓存变量（如"OpenCV_COLLECTED_LIBS"），避免冲突
    set(CACHE_VAR_NAME "${ARG_NAME}_COLLECTED_LIBS")

    # 将结果存入缓存（FORCE 强制更新，PATH 类型适配路径列表
    set(${CACHE_VAR_NAME} ${TEMP_LIBS} 
        CACHE PATH "[${ARG_NAME}] 递归收集到的库文件列表"
        FORCE
    )

    # =============== 输出结果（通过 COLLECTED_LIBS 返回参数) ================
    set(${ARG_COLLECTED_LIBS} ${${CACHE_VAR_NAME}} PARENT_SCOPE)

    # =============== 日志输出（可选，方便调试） ============================
    if(TEMP_LIBS)
        message(STATUS "[${ARG_NAME}] 成功收集到 ${CMAKE_CURRENT_LIST_LENGTH} 个库文件")
        foreach(lib IN LISTS TEMP_LIBS)
            message(STATUS "${lib}")  
        endforeach()
    else()
        message(WARNING "[${ARG_NAME}] 没有收集到任何库文件! 查找路径：${ARG_LIBS_DIR}/${ARG_LIB_PATTERN}")
    endif()
endfunction()

######################## TESTING ################################

######################## collect_libraries test #################
# collect_libraries(
#     NAME OpenCV
#     LIBS_DIR "C:/Users/28344/Documents/Tools/vcpkg/installed/x64-windows"
#     COLLECTED_LIBS Opencv_LIBS
# )


# message(STATUS "\n\n=================== TESTING =========================\n")

# foreach(lib IN LISTS Opencv_LIBS)
#     message(STATUS "${lib}")    
# endforeach()
##########################END#######################################
