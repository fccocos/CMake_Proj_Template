# ==================== 安装路径规范 ====================
# 遵循 GNU 安装目录规范（可通过 -DCMAKE_INSTALL_PREFIX 自定义）
include(GNUInstallDirs)

# ==================== 安装文件 ====================
# 1. 库文件（静态库 .a/.lib，动态库 .so/.dll/.dylib）
install(
    TARGETS ${PROJECT_NAME} ${PROJECT_NAME}_app  # 安装目标
    EXPORT ${PROJECT_NAME}Targets                # 导出目标（供其他项目导入）
    ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}  # 静态库安装路径
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}  # 动态库安装路径（非 Windows）
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}  # 可执行文件/动态库（Windows）
    INCLUDES DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}  # 头文件安装路径
)

# 2. 头文件（按目录结构安装）
install(
    DIRECTORY ${PROJECT_SOURCE_DIR}/include/
    DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}
    FILES_MATCHING PATTERN "*.h" PATTERN "*.hpp"  # 仅安装头文件
)

# 3. 导出目标文件（供其他 CMake 项目 find_package 使用）
install(
    EXPORT ${PROJECT_NAME}Targets
    FILE ${PROJECT_NAME}Targets.cmake
    NAMESPACE ${PROJECT_NAME}::
    DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/${PROJECT_NAME}
)

# 4. 配置文件（让其他项目能通过 find_package 找到本项目）
include(CMakePackageConfigHelpers)

# 生成配置文件（MyProjectConfig.cmake）
configure_package_config_file(
    ${PROJECT_SOURCE_DIR}/cmake/${PROJECT_NAME}Config.cmake.in  # 模板（需手动创建）
    ${PROJECT_BINARY_DIR}/${PROJECT_NAME}Config.cmake
    INSTALL_DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/${PROJECT_NAME}
    PATH_VARS CMAKE_INSTALL_INCLUDEDIR CMAKE_INSTALL_LIBDIR
)

# 生成版本文件（MyProjectConfigVersion.cmake）
write_basic_package_version_file(
    ${PROJECT_BINARY_DIR}/${PROJECT_NAME}ConfigVersion.cmake
    VERSION ${PROJECT_VERSION}
    COMPATIBILITY SameMajorVersion  # 兼容同一主版本
)

# 安装配置文件和版本文件
install(
    FILES
        ${PROJECT_BINARY_DIR}/${PROJECT_NAME}Config.cmake
        ${PROJECT_BINARY_DIR}/${PROJECT_NAME}ConfigVersion.cmake
    DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/${PROJECT_NAME}
)

# 5. 其他文件（许可证、README）
install(
    FILES ${PROJECT_SOURCE_DIR}/LICENSE ${PROJECT_SOURCE_DIR}/README.md
    DESTINATION ${CMAKE_INSTALL_DOCDIR}  # 文档安装路径（默认 share/doc/MyProject）
)