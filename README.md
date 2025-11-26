# 使用指南
## 1.基础构建（默认静态库，无测试）

```bash
# 创建构建目录（out-of-source 构建，避免污染源码）
mkdir build && cd build

# 配置（默认 Debug 模式）
cmake ..

# 编译（-j 后接核心数，加速编译）
cmake --build . -j$(nproc)

# 运行可执行文件
./bin/myproject
```
## 2.自定义构建选项

```bash
# 动态库 + 测试 + 示例 + 文档
cmake .. \
    -DBUILD_SHARED_LIBS=ON \
    -DBUILD_TESTING=ON \
    -DBUILD_EXAMPLES=ON \
    -DBUILD_DOCS=ON \
    -DCMAKE_BUILD_TYPE=Release \  #  Release 模式
    -DCMAKE_INSTALL_PREFIX=/usr/local  # 安装到 /usr/local

# 编译
cmake --build . -j$(nproc)

# 运行测试
ctest -V  # -V 显示详细测试输出

# 安装（需要管理员权限）
sudo cmake --install .

# 打包（生成 deb/rpm/zip 等）
cmake --build . --target package
```

## 3.其他项目导入该库

```cmake
# 其他项目的 CMakeLists.txt
find_package(MyProject 1.0 REQUIRED)

add_executable(use_myproject main.cpp)
target_link_libraries(use_myproject PRIVATE MyProject::MyProject)
```
## 4.扩展建议
1. 多语言支持：如需支持 C 语言，在 project() 中添加 C 语言，调整 CMAKE_C_STANDARD。

2. 交叉编译：添加 toolchain.cmake 文件，指定交叉编译器（如 ARM-GCC），通过 -DCMAKE_TOOLCHAIN_FILE=toolchain.cmake 启用。

3. 代码格式化：集成 clang-format，在 cmake/Utils.cmake 中添加格式化目标。
静态代码分析：集成 clang-tidy 或 cppcheck，在 CompileOptions.cmake 中添加分析选项。

4. CI/CD 集成：在 GitHub Actions 中添加如下配置（.github/workflows/build.yml），自动构建测试：

```yaml
name: Build
on: [push, pull_request]
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Install dependencies
        run: sudo apt-get install -y doxygen lcov
      - name: Configure CMake
        run: cmake -B build -DBUILD_TESTING=ON -DENABLE_COVERAGE=ON
      - name: Build
        run: cmake --build build -j$(nproc)
      - name: Test
        run: cd build && ctest -V
      - name: Generate coverage
        run: cd build && lcov --capture --directory . --output-file coverage.info
```

## 6.关键设计理念

- 模块化：将配置拆分到不同 .cmake 文件，降低维护成本，便于按需扩展。
- 跨平台兼容：通过 $<CONFIG>、$<CXX_COMPILER_ID> 等生成器表达式，适配不同编译器和系统。
- 最佳实践：采用 out-of-source 构建、命名空间隔离、警告视为错误、语义化版本等工业级规范。
- 用户友好：提供清晰的选项开关，支持自定义安装路径和打包格式，便于集成到现有项目。