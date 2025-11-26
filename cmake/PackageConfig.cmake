# ==================== CPack 打包配置 ====================
include(CPack)

# 基础信息
set(CPACK_PACKAGE_NAME ${PROJECT_NAME})
set(CPACK_PACKAGE_VERSION ${PROJECT_VERSION})
set(CPACK_PACKAGE_DESCRIPTION_SUMMARY ${PROJECT_DESCRIPTION})
set(CPACK_PACKAGE_HOMEPAGE_URL ${PROJECT_HOMEPAGE_URL})
set(CPACK_PACKAGE_LICENSE "MIT")  # 替换为你的许可证
set(CPACK_PACKAGE_MAINTAINER "Your Name <your.email@example.com>")  # 维护者信息
set(CPACK_PACKAGE_CONTACT ${CPACK_PACKAGE_MAINTAINER})

# 打包类型（根据系统自动选择）
if(WIN32)
    set(CPACK_GENERATOR "ZIP;NSIS")  # Windows：ZIP 压缩包 + NSIS 安装程序
    set(CPACK_NSIS_DISPLAY_NAME ${PROJECT_NAME})
    set(CPACK_NSIS_PACKAGE_NAME ${PROJECT_NAME})
    set(CPACK_NSIS_CONTACT ${CPACK_PACKAGE_MAINTAINER})
elseif(UNIX)
    if(CMAKE_SYSTEM_NAME MATCHES "Linux")
        set(CPACK_GENERATOR "DEB;RPM;TGZ")  # Linux：deb + rpm + tar 包
        # DEB 包配置
        set(CPACK_DEBIAN_PACKAGE_DEPENDS "libc6 (>= 2.27)")  # 依赖库（根据实际调整）
        set(CPACK_DEBIAN_PACKAGE_SECTION "devel")
        set(CPACK_DEBIAN_PACKAGE_ARCHITECTURE ${CMAKE_SYSTEM_PROCESSOR})
        # RPM 包配置
        set(CPACK_RPM_PACKAGE_REQUIRES "glibc >= 2.27")
        set(CPACK_RPM_PACKAGE_GROUP "Development/Libraries")
    else()
        set(CPACK_GENERATOR "TGZ")  # macOS：tar 包（可添加 DragNDrop 生成器）
    endif()
endif()

# 打包文件列表（自动包含安装目录下的所有文件）
set(CPACK_INSTALL_CMAKE_PROJECTS ${PROJECT_BINARY_DIR} ${PROJECT_NAME} ALL .)
set(CPACK_PACKAGE_FILE_NAME "${PROJECT_NAME}-${PROJECT_VERSION}-${CMAKE_SYSTEM_NAME}-${CMAKE_SYSTEM_PROCESSOR}")