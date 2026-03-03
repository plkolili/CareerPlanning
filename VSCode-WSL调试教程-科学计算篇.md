# VSCode + WSL 调试完全指南 - 科学计算篇 🐧🔬

> 专为科学计算和工程研发人员打造的调试教程，涵盖 Python、C++、Fortran、Julia、CUDA 在 WSL + VSCode 环境下的完整调试配置。

---

## 📋 目录

1. [环境准备：WSL2 + VSCode](#第一部分环境准备wsl2--vscode)
2. [Python 调试](#第二部分python-调试)
3. [C++ 调试](#第三部分c-调试)
4. [Fortran 调试](#第四部分fortran-调试)
5. [Julia 调试](#第五部分julia-调试)
6. [CUDA 调试](#第六部分cuda-调试)
7. [常见问题排查](#第七部分常见问题排查)

---

## 第一部分：环境准备（WSL2 + VSCode）

### 1.1 WSL2 安装检查

首先确认 WSL2 已正确安装：

```bash
# 在 PowerShell 中运行
wsl --version
```

预期输出：
```
WSL 版本：2.x.x
内核版本：5.x.x
```

如果没有安装，以管理员身份打开 PowerShell：

```powershell
# 启用 WSL
wsl --install

# 设置默认版本为 WSL2
wsl --set-default-version 2

# 安装 Ubuntu（推荐）
wsl --install -d Ubuntu-22.04
```

### 1.2 VSCode Remote - WSL 扩展

1. 打开 VSCode
2. 按 `Ctrl+Shift+X` 打开扩展面板
3. 搜索 **"Remote - WSL"**
4. 点击安装（微软官方扩展）

![Remote-WSL 扩展](https://code.visualstudio.com/assets/docs/remote/wsl/wsl-extensions-view.png)

### 1.3 连接 WSL

**方法一：从 VSCode 连接**
- 点击左下角绿色图标 `><`
- 选择 `Connect to WSL`

**方法二：从 WSL 启动**
```bash
# 在 WSL 终端中
code .
```

**方法三：从 Windows 资源管理器**
- 打开 WSL 文件夹
- 地址栏输入 `code .`

### 1.4 文件系统注意事项 ⚠️

| 位置 | Windows 路径 | WSL 路径 | 性能 | 建议 |
|------|-------------|---------|------|------|
| Windows 磁盘 | `C:\Users\name\project` | `/mnt/c/Users/name/project` | 较慢 | 仅在需要共享时使用 |
| Linux 主目录 | `\\wsl$\Ubuntu\home\name` | `~/project` | **快** | **推荐存放项目** |

**最佳实践**：
```bash
# 在 WSL 中创建项目目录
mkdir -p ~/projects
cd ~/projects

# 创建示例项目
mkdir debug_demo
cd debug_demo

# 用 VSCode 打开
code .
```

### 1.5 安装通用调试工具

```bash
# 更新包列表
sudo apt update

# 安装常用调试器
sudo apt install -y gdb gdb-multiarch

# 安装构建工具
sudo apt install -y build-essential cmake make

# 安装其他工具
sudo apt install -y git curl wget
```

---

## 第二部分：Python 调试

### 2.1 环境安装

```bash
# 安装 Python 和 pip
sudo apt install -y python3 python3-pip python3-venv

# 验证安装
python3 --version  # 应显示 3.10+
pip3 --version
```

### 2.2 VSCode Python 扩展

在 WSL 连接的 VSCode 中：
1. 按 `Ctrl+Shift+X`
2. 搜索 **"Python"**（微软官方）
3. 点击安装

> 💡 扩展会自动安装到 WSL 环境

### 2.3 创建示例项目

```bash
mkdir -p ~/projects/python_debug
cd ~/projects/python_debug

# 创建虚拟环境
python3 -m venv venv

# 激活虚拟环境
source venv/bin/activate

# 安装科学计算包
pip install numpy matplotlib debugpy
```

### 2.4 示例代码

创建 `main.py`：

```python
import numpy as np
import matplotlib.pyplot as plt

def matrix_operations():
    """矩阵运算示例"""
    # 创建矩阵
    A = np.array([[1, 2, 3],
                  [4, 5, 6],
                  [7, 8, 9]], dtype=float)
    
    B = np.array([[9, 8, 7],
                  [6, 5, 4],
                  [3, 2, 1]], dtype=float)
    
    print("矩阵 A:")
    print(A)
    print("\n矩阵 B:")
    print(B)
    
    # 矩阵乘法
    C = np.dot(A, B)
    print("\nA × B =")
    print(C)
    
    # 求逆（这里会触发异常，用于演示调试）
    try:
        # 奇异矩阵无法求逆
        A_inv = np.linalg.inv(A)
        print("\nA 的逆矩阵:")
        print(A_inv)
    except np.linalg.LinAlgError as e:
        print(f"\n错误: {e}")
        print("矩阵 A 是奇异的（行列式为0），无法求逆")
    
    # 计算特征值
    eigenvalues = np.linalg.eigvals(A)
    print(f"\nA 的特征值: {eigenvalues}")
    
    return C

def data_analysis():
    """数据分析示例"""
    # 生成随机数据
    np.random.seed(42)
    data = np.random.randn(1000)
    
    # 计算统计量
    mean = np.mean(data)
    std = np.std(data)
    
    print(f"\n数据统计:")
    print(f"均值: {mean:.4f}")
    print(f"标准差: {std:.4f}")
    
    return data, mean, std

if __name__ == "__main__":
    print("=" * 50)
    print("NumPy 矩阵运算演示")
    print("=" * 50)
    
    result = matrix_operations()
    data, mean, std = data_analysis()
    
    print("\n程序执行完成!")
```

### 2.5 配置 launch.json

按 `Ctrl+Shift+D` 打开调试面板，点击"创建 launch.json 文件"，选择 **Python**。

编辑 `.vscode/launch.json`：

```json
{
    "version": "0.2.0",
    "configurations": [
        {
            "name": "Python: 当前文件",
            "type": "debugpy",
            "request": "launch",
            "program": "${file}",
            "console": "integratedTerminal",
            "justMyCode": false,
            "env": {
                "PYTHONPATH": "${workspaceFolder}"
            }
        },
        {
            "name": "Python: 模块",
            "type": "debugpy",
            "request": "launch",
            "module": "main",
            "console": "integratedTerminal",
            "justMyCode": false
        },
        {
            "name": "Python: 带参数",
            "type": "debugpy",
            "request": "launch",
            "program": "${file}",
            "console": "integratedTerminal",
            "args": ["--verbose", "--input", "data.txt"],
            "justMyCode": false
        }
    ]
}
```

### 2.6 调试操作

1. **设置断点**：点击行号左侧（如第 15 行 `A = np.array(...)`）
2. **启动调试**：按 `F5`
3. **常用快捷键**：
   - `F5` - 继续/启动
   - `F10` - 单步跳过
   - `F11` - 单步进入
   - `Shift+F11` - 单步跳出
   - `Shift+F5` - 停止

4. **查看变量**：左侧调试面板显示当前作用域变量

![Python 调试界面](https://code.visualstudio.com/assets/docs/python/debugging/debugging-panel.png)

### 2.7 虚拟环境调试

确保 VSCode 使用正确的 Python 解释器：

1. 按 `Ctrl+Shift+P`
2. 输入 `Python: Select Interpreter`
3. 选择 `./venv/bin/python`

---

## 第三部分：C++ 调试

### 3.1 环境安装

```bash
# 安装 GCC/G++ 和 GDB
sudo apt install -y g++ gdb cmake make

# 验证安装
g++ --version
gdb --version
cmake --version
```

### 3.2 VSCode C++ 扩展

1. 按 `Ctrl+Shift+X`
2. 搜索 **"C/C++"**（微软官方）
3. 安装扩展

### 3.3 单文件项目示例

创建 `~/projects/cpp_debug/single_file/`：

**main.cpp**：
```cpp
#include <iostream>
#include <vector>
#include <cmath>

class Matrix {
public:
    Matrix(int rows, int cols) : rows_(rows), cols_(cols) {
        data_.resize(rows * cols, 0.0);
    }
    
    double& operator()(int i, int j) {
        return data_[i * cols_ + j];
    }
    
    const double& operator()(int i, int j) const {
        return data_[i * cols_ + j];
    }
    
    int rows() const { return rows_; }
    int cols() const { return cols_; }
    
    void print() const {
        for (int i = 0; i < rows_; ++i) {
            for (int j = 0; j < cols_; ++j) {
                std::cout << (*this)(i, j) << " ";
            }
            std::cout << "\n";
        }
    }
    
private:
    int rows_, cols_;
    std::vector<double> data_;
};

Matrix multiply(const Matrix& A, const Matrix& B) {
    if (A.cols() != B.rows()) {
        throw std::runtime_error("矩阵维度不匹配");
    }
    
    Matrix C(A.rows(), B.cols());
    
    for (int i = 0; i < A.rows(); ++i) {
        for (int j = 0; j < B.cols(); ++j) {
            double sum = 0.0;
            for (int k = 0; k < A.cols(); ++k) {
                sum += A(i, k) * B(k, j);
            }
            C(i, j) = sum;
        }
    }
    
    return C;
}

int main() {
    std::cout << "C++ 矩阵运算演示\n";
    std::cout << "================\n\n";
    
    // 创建 3x3 矩阵
    Matrix A(3, 3);
    Matrix B(3, 3);
    
    // 初始化矩阵 A
    double val = 1.0;
    for (int i = 0; i < 3; ++i) {
        for (int j = 0; j < 3; ++j) {
            A(i, j) = val++;
        }
    }
    
    // 初始化矩阵 B
    val = 9.0;
    for (int i = 0; i < 3; ++i) {
        for (int j = 0; j < 3; ++j) {
            B(i, j) = val--;
        }
    }
    
    std::cout << "矩阵 A:\n";
    A.print();
    
    std::cout << "\n矩阵 B:\n";
    B.print();
    
    // 矩阵乘法
    std::cout << "\nA × B =\n";
    Matrix C = multiply(A, B);
    C.print();
    
    // 计算迹（对角线之和）
    double trace = 0.0;
    for (int i = 0; i < C.rows(); ++i) {
        trace += C(i, i);
    }
    std::cout << "\n结果矩阵的迹: " << trace << "\n";
    
    return 0;
}
```

### 3.4 CMake 项目示例

创建多文件项目结构：
```
cpp_debug/
├── CMakeLists.txt
├── include/
│   └── math_utils.hpp
├── src/
│   ├── main.cpp
│   └── math_utils.cpp
└── .vscode/
    ├── launch.json
    └── tasks.json
```

**CMakeLists.txt**：
```cmake
cmake_minimum_required(VERSION 3.10)
project(MathDemo)

set(CMAKE_CXX_STANDARD 14)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_BUILD_TYPE Debug)

include_directories(include)

add_executable(math_demo
    src/main.cpp
    src/math_utils.cpp
)
```

**include/math_utils.hpp**：
```cpp
#ifndef MATH_UTILS_HPP
#define MATH_UTILS_HPP

#include <vector>

namespace math {
    // 向量点积
    double dotProduct(const std::vector<double>& a, const std::vector<double>& b);
    
    // 向量范数
    double norm(const std::vector<double>& v);
    
    // 线性插值
    double lerp(double a, double b, double t);
    
    // 高斯函数
    double gaussian(double x, double mu, double sigma);
}

#endif
```

**src/math_utils.cpp**：
```cpp
#include "math_utils.hpp"
#include <cmath>
#include <stdexcept>

namespace math {
    double dotProduct(const std::vector<double>& a, const std::vector<double>& b) {
        if (a.size() != b.size()) {
            throw std::invalid_argument("向量维度不匹配");
        }
        
        double sum = 0.0;
        for (size_t i = 0; i < a.size(); ++i) {
            sum += a[i] * b[i];
        }
        return sum;
    }
    
    double norm(const std::vector<double>& v) {
        return std::sqrt(dotProduct(v, v));
    }
    
    double lerp(double a, double b, double t) {
        return a + t * (b - a);
    }
    
    double gaussian(double x, double mu, double sigma) {
        double coeff = 1.0 / (sigma * std::sqrt(2.0 * M_PI));
        double exponent = -0.5 * std::pow((x - mu) / sigma, 2);
        return coeff * std::exp(exponent);
    }
}
```

**src/main.cpp**：
```cpp
#include <iostream>
#include <vector>
#include "math_utils.hpp"

int main() {
    std::cout << "数学工具库演示\n";
    std::cout << "==============\n\n";
    
    // 向量操作
    std::vector<double> v1 = {1.0, 2.0, 3.0};
    std::vector<double> v2 = {4.0, 5.0, 6.0};
    
    std::cout << "向量 v1: [";
    for (auto x : v1) std::cout << x << " ";
    std::cout << "]\n";
    
    std::cout << "向量 v2: [";
    for (auto x : v2) std::cout << x << " ";
    std::cout << "]\n";
    
    double dot = math::dotProduct(v1, v2);
    std::cout << "\n点积 v1·v2 = " << dot << "\n";
    
    double n1 = math::norm(v1);
    double n2 = math::norm(v2);
    std::cout << "||v1|| = " << n1 << "\n";
    std::cout << "||v2|| = " << n2 << "\n";
    
    // 插值
    std::cout << "\n线性插值:\n";
    for (double t = 0.0; t <= 1.0; t += 0.25) {
        double result = math::lerp(0.0, 100.0, t);
        std::cout << "  lerp(0, 100, " << t << ") = " << result << "\n";
    }
    
    // 高斯函数
    std::cout << "\n高斯函数 (μ=0, σ=1):\n";
    for (double x = -3.0; x <= 3.0; x += 0.5) {
        double g = math::gaussian(x, 0.0, 1.0);
        std::cout << "  g(" << x << ") = " << g << "\n";
    }
    
    return 0;
}
```

### 3.5 VSCode 配置

**.vscode/tasks.json**（构建任务）：
```json
{
    "version": "2.0.0",
    "tasks": [
        {
            "label": "CMake 配置",
            "type": "shell",
            "command": "cmake",
            "args": [
                "-B", "build",
                "-DCMAKE_BUILD_TYPE=Debug"
            ],
            "group": "build"
        },
        {
            "label": "CMake 构建",
            "type": "shell",
            "command": "cmake",
            "args": [
                "--build", "build"
            ],
            "group": {
                "kind": "build",
                "isDefault": true
            },
            "dependsOn": "CMake 配置"
        },
        {
            "label": "构建单文件",
            "type": "shell",
            "command": "g++",
            "args": [
                "-g",
                "-O0",
                "-std=c++14",
                "${file}",
                "-o",
                "${fileDirname}/${fileBasenameNoExtension}"
            ],
            "group": "build",
            "problemMatcher": ["$gcc"]
        }
    ]
}
```

**.vscode/launch.json**（调试配置）：
```json
{
    "version": "0.2.0",
    "configurations": [
        {
            "name": "C++: CMake 项目",
            "type": "cppdbg",
            "request": "launch",
            "program": "${workspaceFolder}/build/math_demo",
            "args": [],
            "stopAtEntry": false,
            "cwd": "${workspaceFolder}",
            "environment": [],
            "externalConsole": false,
            "MIMode": "gdb",
            "setupCommands": [
                {
                    "description": "为 gdb 启用整齐打印",
                    "text": "-enable-pretty-printing",
                    "ignoreFailures": true
                }
            ],
            "preLaunchTask": "CMake 构建",
            "miDebuggerPath": "/usr/bin/gdb"
        },
        {
            "name": "C++: 单文件",
            "type": "cppdbg",
            "request": "launch",
            "program": "${fileDirname}/${fileBasenameNoExtension}",
            "args": [],
            "stopAtEntry": false,
            "cwd": "${fileDirname}",
            "environment": [],
            "externalConsole": false,
            "MIMode": "gdb",
            "setupCommands": [
                {
                    "description": "为 gdb 启用整齐打印",
                    "text": "-enable-pretty-printing",
                    "ignoreFailures": true
                }
            ],
            "preLaunchTask": "构建单文件",
            "miDebuggerPath": "/usr/bin/gdb"
        }
    ]
}
```

### 3.6 调试步骤

1. **构建项目**：`Ctrl+Shift+B`，选择 "CMake 构建"
2. **设置断点**：在代码左侧点击
3. **启动调试**：按 `F5`，选择配置
4. **查看变量**：左侧变量面板显示局部变量和监视表达式

### 3.7 调试技巧

**条件断点**：
- 右键断点 → "编辑断点"
- 输入条件如 `i == 5 && j == 3`

**监视表达式**：
- 在"监视"面板点击 `+`
- 添加如 `A(1,2)` 或 `v1.size()`

**内存查看**：
- 调试时打开命令面板 `Ctrl+Shift+P`
- 输入 "Debug: Inspect Memory"

---

## 第四部分：Fortran 调试

### 4.1 环境安装

```bash
# 安装 gfortran
sudo apt install -y gfortran gdb

# 验证安装
gfortran --version
```

### 4.2 现代 Fortran 示例

创建 `~/projects/fortran_debug/`：

**main.f90**：
```fortran
program math_demo
    implicit none
    
    integer, parameter :: dp = kind(1.0d0)
    integer, parameter :: n = 3
    
    real(dp) :: A(n, n), B(n, n), C(n, n)
    real(dp) :: vector1(n), vector2(n)
    real(dp) :: dot_product_result
    integer :: i, j
    
    print *, "Fortran 科学计算演示"
    print *, "===================="
    print *
    
    ! 初始化矩阵 A
    A = reshape([ &
        1.0_dp, 4.0_dp, 7.0_dp, &
        2.0_dp, 5.0_dp, 8.0_dp, &
        3.0_dp, 6.0_dp, 9.0_dp  &
    ], [n, n])
    
    ! 初始化矩阵 B
    B = reshape([ &
        9.0_dp, 6.0_dp, 3.0_dp, &
        8.0_dp, 5.0_dp, 2.0_dp, &
        7.0_dp, 4.0_dp, 1.0_dp  &
    ], [n, n])
    
    print *, "矩阵 A:"
    call print_matrix(A, n)
    
    print *, "矩阵 B:"
    call print_matrix(B, n)
    
    ! 矩阵乘法
    C = matmul(A, B)
    print *, "A × B ="
    call print_matrix(C, n)
    
    ! 向量操作
    vector1 = [1.0_dp, 2.0_dp, 3.0_dp]
    vector2 = [4.0_dp, 5.0_dp, 6.0_dp]
    
    print *, "向量 v1:", vector1
    print *, "向量 v2:", vector2
    
    dot_product_result = dot_product(vector1, vector2)
    print *, "点积 v1·v2 =", dot_product_result
    
    ! 调用子程序计算特征值（简化示例）
    call compute_stats(C, n)
    
    print *, 
    print *, "程序执行完成!"
    
contains

    subroutine print_matrix(M, size)
        integer, intent(in) :: size
        real(dp), intent(in) :: M(size, size)
        integer :: i
        
        do i = 1, size
            print *, M(i, :)
        end do
        print *
    end subroutine print_matrix
    
    subroutine compute_stats(M, size)
        integer, intent(in) :: size
        real(dp), intent(in) :: M(size, size)
        real(dp) :: trace, sum_all, avg
        integer :: i
        
        ! 计算迹（对角线之和）
        trace = 0.0_dp
        do i = 1, size
            trace = trace + M(i, i)
        end do
        
        ! 计算总和和平均值
        sum_all = sum(M)
        avg = sum_all / (size * size)
        
        print *, "矩阵统计信息:"
        print *, "  迹 (Trace):", trace
        print *, "  总和:", sum_all
        print *, "  平均值:", avg
        print *
    end subroutine compute_stats

end program math_demo
```

### 4.3 VSCode 配置

**.vscode/tasks.json**：
```json
{
    "version": "2.0.0",
    "tasks": [
        {
            "label": "Fortran 构建",
            "type": "shell",
            "command": "gfortran",
            "args": [
                "-g",
                "-O0",
                "-fcheck=all",
                "-fbacktrace",
                "-ffpe-trap=invalid,zero,overflow",
                "${file}",
                "-o",
                "${fileDirname}/${fileBasenameNoExtension}"
            ],
            "group": {
                "kind": "build",
                "isDefault": true
            },
            "problemMatcher": []
        }
    ]
}
```

**.vscode/launch.json**：
```json
{
    "version": "0.2.0",
    "configurations": [
        {
            "name": "Fortran: 调试",
            "type": "cppdbg",
            "request": "launch",
            "program": "${fileDirname}/${fileBasenameNoExtension}",
            "args": [],
            "stopAtEntry": false,
            "cwd": "${fileDirname}",
            "environment": [],
            "externalConsole": false,
            "MIMode": "gdb",
            "setupCommands": [
                {
                    "description": "启用整齐打印",
                    "text": "-enable-pretty-printing",
                    "ignoreFailures": true
                }
            ],
            "preLaunchTask": "Fortran 构建",
            "miDebuggerPath": "/usr/bin/gdb"
        }
    ]
}
```

### 4.4 Fortran 调试编译选项

| 选项 | 作用 |
|------|------|
| `-g` | 包含调试信息 |
| `-O0` | 禁用优化，保留调试信息 |
| `-fcheck=all` | 启用所有运行时检查 |
| `-fbacktrace` | 出错时打印调用栈 |
| `-ffpe-trap` | 浮点异常时中断 |
| `-Wall` | 显示所有警告 |
| `-Wextra` | 显示额外警告 |

### 4.5 多文件 Fortran 项目

**文件结构**：
```
fortran_debug/
├── main.f90
├── matrix_ops.f90
├── utils.f90
└── Makefile
```

**Makefile**：
```makefile
FC = gfortran
FFLAGS = -g -O0 -fcheck=all -fbacktrace -Wall

SRCS = main.f90 matrix_ops.f90 utils.f90
OBJS = $(SRCS:.f90=.o)
TARGET = math_demo

.PHONY: all clean

all: $(TARGET)

$(TARGET): $(OBJS)
	$(FC) $(FFLAGS) -o $@ $^

%.o: %.f90
	$(FC) $(FFLAGS) -c $<

clean:
	rm -f $(OBJS) $(TARGET)
```

---

## 第五部分：Julia 调试

### 5.1 环境安装

```bash
# 下载并安装 Julia
# 推荐从官网下载最新版本
cd ~/Downloads
wget https://julialang-s3.julialang.org/bin/linux/x64/1.9/julia-1.9.4-linux-x86_64.tar.gz

# 解压
tar -xzf julia-1.9.4-linux-x86_64.tar.gz

# 移动到合适位置
sudo mv julia-1.9.4 /opt/

# 创建软链接
sudo ln -s /opt/julia-1.9.4/bin/julia /usr/local/bin/julia

# 验证
julia --version
```

### 5.2 VSCode Julia 扩展

1. 按 `Ctrl+Shift+X`
2. 搜索 **"Julia"**（julialang 官方）
3. 安装扩展

### 5.3 创建示例项目

```bash
mkdir -p ~/projects/julia_debug
cd ~/projects/julia_debug

# 创建项目环境
julia -e 'using Pkg; Pkg.generate("MathDemo")'

cd MathDemo
```

### 5.4 示例代码

**src/MathDemo.jl**：
```julia
module MathDemo

export matrix_operations, vector_analysis, solve_linear_system

using LinearAlgebra

"""
矩阵运算演示
"""
function matrix_operations()
    println("="^50)
    println("Julia 矩阵运算")
    println("="^50)
    
    # 创建矩阵
    A = [1.0 2.0 3.0;
         4.0 5.0 6.0;
         7.0 8.0 9.0]
    
    B = [9.0 8.0 7.0;
         6.0 5.0 4.0;
         3.0 2.0 1.0]
    
    println("\n矩阵 A:")
    display(A)
    
    println("\n矩阵 B:")
    display(B)
    
    # 矩阵乘法
    C = A * B
    println("\nA × B =")
    display(C)
    
    # 转置
    println("\nA 的转置:")
    display(transpose(A))
    
    # 行列式（注意：A 是奇异的）
    println("\nA 的行列式: ", det(A))
    
    # 特征值
    eigenvals = eigvals(A)
    println("\nA 的特征值:")
    display(eigenvals)
    
    return C
end

"""
向量分析
"""
function vector_analysis()
    println("\n" * "="^50)
    println("向量分析")
    println("="^50)
    
    v1 = [1.0, 2.0, 3.0]
    v2 = [4.0, 5.0, 6.0]
    
    println("\n向量 v1: ", v1)
    println("向量 v2: ", v2)
    
    # 点积
    dot_prod = dot(v1, v2)
    println("\n点积 v1·v2 = ", dot_prod)
    
    # 范数
    norm_v1 = norm(v1)
    norm_v2 = norm(v2)
    println("||v1|| = ", norm_v1)
    println("||v2|| = ", norm_v2)
    
    # 叉积
    cross_prod = cross(v1, v2)
    println("\n叉积 v1×v2 = ", cross_prod)
    
    return v1, v2
end

"""
求解线性方程组 Ax = b
"""
function solve_linear_system()
    println("\n" * "="^50)
    println("求解线性方程组")
    println("="^50)
    
    # 创建一个非奇异矩阵
    A = [2.0 1.0 -1.0;
         -3.0 -1.0 2.0;
         -2.0 1.0 2.0]
    
    b = [8.0, -11.0, -3.0]
    
    println("\n系数矩阵 A:")
    display(A)
    println("\n常数向量 b: ", b)
    
    # 求解
    x = A \ b
    println("\n解 x = ", x)
    
    # 验证
    println("\n验证 Ax = ", A * x)
    println("原 b = ", b)
    
    return x
end

end # module
```

**scripts/demo.jl**：
```julia
# 添加项目到路径
using Pkg
Pkg.activate(joinpath(@__DIR__, ".."))

using MathDemo

# 运行演示
matrix_operations()
vector_analysis()
solve_linear_system()

println("\n所有演示完成!")
```

### 5.5 VSCode 配置

**.vscode/launch.json**：
```json
{
    "version": "0.2.0",
    "configurations": [
        {
            "name": "Julia: 当前文件",
            "type": "julia",
            "request": "launch",
            "program": "${file}",
            "stopOnEntry": false,
            "cwd": "${workspaceFolder}",
            "juliaEnv": "${workspaceFolder}"
        },
        {
            "name": "Julia: 运行脚本",
            "type": "julia",
            "request": "launch",
            "program": "${workspaceFolder}/scripts/demo.jl",
            "stopOnEntry": false,
            "cwd": "${workspaceFolder}",
            "juliaEnv": "${workspaceFolder}"
        }
    ]
}
```

### 5.6 Julia REPL 调试

Julia 强大的 REPL 调试方式：

```julia
# 进入包模式
]
# 激活环境
activate .

# 回到 Julia 模式
# 按 Backspace

# 引入 Debugger
using Debugger

# 包含文件
include("src/MathDemo.jl")

# 使用 @enter 进入函数调试
@enter MathDemo.matrix_operations()

# 在 REPL 中使用调试命令
# n - 下一步
# s - 进入函数
# c - 继续
# q - 退出
```

---

## 第六部分：CUDA 调试

### 6.1 WSL2 CUDA 支持检查

WSL2 现在原生支持 NVIDIA CUDA：

```bash
# 检查 NVIDIA 驱动
nvidia-smi

# 应该显示 GPU 信息，无需在 WSL 内安装驱动
```

### 6.2 安装 CUDA Toolkit

```bash
# 下载 CUDA 安装脚本
wget https://developer.download.nvidia.com/compute/cuda/repos/wsl-ubuntu2204/x86_64/cuda-wsl-ubuntu2204.pin
sudo mv cuda-wsl-ubuntu2204.pin /etc/apt/preferences.d/cuda-repository-pin-600

# 添加仓库
wget https://developer.download.nvidia.com/compute/cuda/12.3.0/local_installers/cuda-repo-wsl-ubuntu-2204-12-3-local_12.3.0-1_amd64.deb
sudo dpkg -i cuda-repo-wsl-ubuntu-2204-12-3-local_12.3.0-1_amd64.deb
sudo cp /var/cuda-repo-wsl-ubuntu-2204-12-3-local/cuda-*-keyring.gpg /usr/share/keyrings/

# 安装
sudo apt update
sudo apt install -y cuda-toolkit-12-3

# 设置环境变量
echo 'export PATH=/usr/local/cuda/bin:$PATH' >> ~/.bashrc
echo 'export LD_LIBRARY_PATH=/usr/local/cuda/lib64:$LD_LIBRARY_PATH' >> ~/.bashrc
source ~/.bashrc

# 验证
nvcc --version
```

### 6.3 安装 CUDA-GDB

```bash
sudo apt install -y cuda-gdb
```

### 6.4 向量加法示例

创建 `~/projects/cuda_debug/`：

**vector_add.cu**：
```cpp
#include <cuda_runtime.h>
#include <device_launch_parameters.h>
#include <iostream>
#include <cmath>

// CUDA 错误检查宏
#define CUDA_CHECK(call) \
    do { \
        cudaError_t error = call; \
        if (error != cudaSuccess) { \
            std::cerr << "CUDA error at " << __FILE__ << ":" << __LINE__ \
                      << " - " << cudaGetErrorString(error) << std::endl; \
            exit(1); \
        } \
    } while(0)

// 向量加法核函数
__global__ void vectorAdd(const float *A, const float *B, float *C, int numElements)
{
    int i = blockDim.x * blockIdx.x + threadIdx.x;
    
    if (i < numElements)
    {
        C[i] = A[i] + B[i];
    }
}

// 初始化向量
void initVector(float *data, int size, float value)
{
    for (int i = 0; i < size; ++i)
    {
        data[i] = value + i * 0.1f;
    }
}

// 验证结果
bool verifyResult(const float *A, const float *B, const float *C, int size)
{
    for (int i = 0; i < size; ++i)
    {
        float expected = A[i] + B[i];
        if (std::abs(C[i] - expected) > 1e-5)
        {
            std::cout << "验证失败在索引 " << i << ": "
                      << C[i] << " != " << expected << std::endl;
            return false;
        }
    }
    return true;
}

int main()
{
    // 向量大小
    int numElements = 50000;
    size_t size = numElements * sizeof(float);
    
    std::cout << "CUDA 向量加法演示" << std::endl;
    std::cout << "=================" << std::endl;
    std::cout << "向量大小: " << numElements << std::endl;
    
    // 分配主机内存
    float *h_A = (float *)malloc(size);
    float *h_B = (float *)malloc(size);
    float *h_C = (float *)malloc(size);
    
    // 初始化输入向量
    initVector(h_A, numElements, 1.0f);
    initVector(h_B, numElements, 2.0f);
    
    // 分配设备内存
    float *d_A, *d_B, *d_C;
    CUDA_CHECK(cudaMalloc((void **)&d_A, size));
    CUDA_CHECK(cudaMalloc((void **)&d_B, size));
    CUDA_CHECK(cudaMalloc((void **)&d_C, size));
    
    // 复制数据到设备
    CUDA_CHECK(cudaMemcpy(d_A, h_A, size, cudaMemcpyHostToDevice));
    CUDA_CHECK(cudaMemcpy(d_B, h_B, size, cudaMemcpyHostToDevice));
    
    // 启动核函数
    int threadsPerBlock = 256;
    int blocksPerGrid = (numElements + threadsPerBlock - 1) / threadsPerBlock;
    
    std::cout << "线程块大小: " << threadsPerBlock << std::endl;
    std::cout << "网格大小: " << blocksPerGrid << std::endl;
    
    vectorAdd<<<blocksPerGrid, threadsPerBlock>>>(d_A, d_B, d_C, numElements);
    CUDA_CHECK(cudaGetLastError());
    CUDA_CHECK(cudaDeviceSynchronize());
    
    // 复制结果回主机
    CUDA_CHECK(cudaMemcpy(h_C, d_C, size, cudaMemcpyDeviceToHost));
    
    // 验证结果
    std::cout << "\n验证结果..." << std::endl;
    if (verifyResult(h_A, h_B, h_C, numElements))
    {
        std::cout << "✓ 验证通过!" << std::endl;
    }
    else
    {
        std::cout << "✗ 验证失败!" << std::endl;
    }
    
    // 打印前 10 个元素
    std::cout << "\n前 10 个结果:" << std::endl;
    for (int i = 0; i < 10 && i < numElements; ++i)
    {
        std::cout << h_A[i] << " + " << h_B[i] << " = " << h_C[i] << std::endl;
    }
    
    // 释放资源
    CUDA_CHECK(cudaFree(d_A));
    CUDA_CHECK(cudaFree(d_B));
    CUDA_CHECK(cudaFree(d_C));
    free(h_A);
    free(h_B);
    free(h_C);
    
    std::cout << "\n程序执行完成!" << std::endl;
    
    return 0;
}
```

### 6.5 VSCode 配置

**.vscode/tasks.json**：
```json
{
    "version": "2.0.0",
    "tasks": [
        {
            "label": "CUDA 构建",
            "type": "shell",
            "command": "nvcc",
            "args": [
                "-g",
                "-G",
                "-O0",
                "${file}",
                "-o",
                "${fileDirname}/${fileBasenameNoExtension}"
            ],
            "group": {
                "kind": "build",
                "isDefault": true
            },
            "problemMatcher": []
        }
    ]
}
```

**.vscode/launch.json**：
```json
{
    "version": "0.2.0",
    "configurations": [
        {
            "name": "CUDA: cuda-gdb 调试",
            "type": "cppdbg",
            "request": "launch",
            "program": "${fileDirname}/${fileBasenameNoExtension}",
            "args": [],
            "stopAtEntry": false,
            "cwd": "${fileDirname}",
            "environment": [
                {
                    "name": "CUDA_LAUNCH_BLOCKING",
                    "value": "1"
                }
            ],
            "externalConsole": false,
            "MIMode": "gdb",
            "miDebuggerPath": "/usr/local/cuda/bin/cuda-gdb",
            "setupCommands": [
                {
                    "description": "启用整齐打印",
                    "text": "-enable-pretty-printing",
                    "ignoreFailures": true
                }
            ],
            "preLaunchTask": "CUDA 构建"
        }
    ]
}
```

### 6.6 CUDA 编译选项

| 选项 | 作用 |
|------|------|
| `-g` | 主机代码调试信息 |
| `-G` | 设备代码调试信息（必须用于调试核函数） |
| `-O0` | 禁用优化 |
| `-lineinfo` | 生成行号信息（用于性能分析） |
| `-arch=sm_70` | 指定 GPU 架构 |

### 6.7 CUDA 调试技巧

**设置核函数断点**：
```gdb
(cuda-gdb) break vectorAdd
(cuda-gdb) break vectorAdd if threadIdx.x == 128
```

**查看 CUDA 特定信息**：
```gdb
(cuda-gdb) info cuda threads
(cuda-gdb) info cuda blocks
(cuda-gdb) info cuda kernels
(cuda-gdb) cuda block 1 thread 128
```

**CUDA 环境变量**：
```bash
# 强制同步执行
export CUDA_LAUNCH_BLOCKING=1

# 设备端断言
export CUDA_DEBUGGER_SOFTWARE_PREEMPTION=1
```

---

## 第七部分：常见问题排查

### 7.1 WSL 相关问题

**问题：VSCode 无法连接到 WSL**
```bash
# 解决方案
wsl --shutdown
# 然后重新在 VSCode 中连接
```

**问题：文件权限错误**
```bash
# 确保项目文件在 Linux 文件系统中，而不是 /mnt/c/
cd ~
mkdir projects
code projects
```

**问题：Windows 防火墙阻止**
- 以管理员身份运行 PowerShell
- 允许 VSCode 通过防火墙

### 7.2 Python 调试问题

**问题：找不到解释器**
```bash
# 在 VSCode 中选择正确的解释器
# Ctrl+Shift+P -> Python: Select Interpreter
# 选择 /usr/bin/python3 或虚拟环境路径
```

**问题：模块找不到**
```json
// 在 launch.json 中添加 PYTHONPATH
"env": {
    "PYTHONPATH": "${workspaceFolder}:${workspaceFolder}/src"
}
```

### 7.3 C++ 调试问题

**问题：无法找到调试符号**
```bash
# 确保使用 -g 编译
g++ -g -O0 program.cpp -o program
```

**问题：GDB 版本不兼容**
```bash
# 安装 gdb-multiarch
sudo apt install gdb-multiarch

# 在 launch.json 中指定
"miDebuggerPath": "/usr/bin/gdb-multiarch"
```

### 7.4 Fortran 调试问题

**问题：数组越界未捕获**
```bash
# 添加运行时检查编译选项
gfortran -g -O0 -fcheck=all -fbacktrace program.f90 -o program
```

### 7.5 Julia 调试问题

**问题：包激活失败**
```julia
# 手动激活
using Pkg
Pkg.activate("/path/to/project")
```

### 7.6 CUDA 调试问题

**问题：cuda-gdb 无法调试核函数**
```bash
# 必须使用 -G 编译
nvcc -g -G program.cu -o program
```

**问题：WSL 中 GPU 不可见**
```bash
# 确保 Windows 已安装 NVIDIA 驱动
# WSL 内不需要单独安装驱动，但需要 CUDA Toolkit
nvidia-smi  # 应该显示 GPU 信息
```

---

## 📎 附录：快速参考卡

### 快捷键速查

| 操作 | 快捷键 |
|------|--------|
| 启动调试 | `F5` |
| 单步跳过 | `F10` |
| 单步进入 | `F11` |
| 单步跳出 | `Shift+F11` |
| 继续运行 | `F5` |
| 停止调试 | `Shift+F5` |
| 切换断点 | `F9` |
| 打开调试面板 | `Ctrl+Shift+D` |
| 打开终端 | `` Ctrl+` `` |
| 构建项目 | `Ctrl+Shift+B` |

### launch.json 模板库

所有语言的基础配置模板已在前文提供，可根据需要复制修改。

### 推荐的 VSCode 扩展清单

| 语言 | 扩展名 |
|------|--------|
| Python | Python (ms-python.python) |
| C/C++ | C/C++ (ms-vscode.cpptools) |
| Fortran | Modern Fortran (fortls.linter-gfortran) |
| Julia | Julia (julialang.language-julia) |
| CUDA | 使用 C/C++ 扩展即可 |

---

## 结语

恭喜！现在你已经掌握了在 WSL + VSCode 环境下调试主流科学计算语言的完整技能。

**记住这些要点**：
1. ✅ 项目放在 `~/projects` 下，不要放在 `/mnt/c/`
2. ✅ 调试前确保使用 `-g -O0` 编译
3. ✅ 善用条件断点和监视表达式
4. ✅ CUDA 调试需要特殊编译选项 `-G`

祝你科研顺利！🎉🔬

---

**参考资源**：
- [VSCode 官方调试文档](https://code.visualstudio.com/docs/editor/debugging)
- [Python debugpy 文档](https://github.com/microsoft/debugpy)
- [GDB 官方文档](https://www.gnu.org/software/gdb/documentation/)
- [Julia 调试指南](https://julialang.org/blog/2019/03/debuggers/)
- [NVIDIA CUDA GDB 文档](https://docs.nvidia.com/cuda/cuda-gdb/)
