#!/usr/bin/env python3
"""
Python 调试示例程序
演示各种调试场景：断点、变量监视、调用堆栈、异常处理等
"""

import argparse
import sys
import numpy as np
import matplotlib.pyplot as plt


def parse_arguments():
    """解析命令行参数"""
    parser = argparse.ArgumentParser(description='Python 调试示例程序')
    parser.add_argument('--mode', type=str, default='normal',
                        help='运行模式: normal, debug, test')
    parser.add_argument('--input', type=str, default='default',
                        help='输入数据名称')
    parser.add_argument('--verbose', action='store_true',
                        help='启用详细输出')
    return parser.parse_args()


def calculate_factorial(n):
    """计算阶乘 - 用于演示递归调用堆栈"""
    # 在此设置断点可观察递归调用过程
    if n <= 1:
        return 1
    result = n * calculate_factorial(n - 1)
    return result


def fibonacci(n, memo=None):
    """斐波那契数列 - 演示带缓存的递归"""
    if memo is None:
        memo = {}
    
    if n in memo:
        return memo[n]
    
    if n <= 1:
        return n
    
    # 在此设置条件断点: n > 10
    memo[n] = fibonacci(n - 1, memo) + fibonacci(n - 2, memo)
    return memo[n]


def matrix_operations(verbose=False):
    """矩阵运算示例"""
    print("\n" + "=" * 50)
    print("矩阵运算演示")
    print("=" * 50)
    
    # 创建矩阵
    A = np.array([[1, 2, 3],
                  [4, 5, 6],
                  [7, 8, 9]], dtype=float)
    
    B = np.array([[9, 8, 7],
                  [6, 5, 4],
                  [3, 2, 1]], dtype=float)
    
    if verbose:
        print("矩阵 A:")
        print(A)
        print("\n矩阵 B:")
        print(B)
    
    # 矩阵乘法
    C = np.dot(A, B)
    print("\nA × B =")
    print(C)
    
    # 计算行列式（这里会触发异常，用于演示调试）
    try:
        det_A = np.linalg.det(A)
        print(f"\n矩阵 A 的行列式: {det_A:.6f}")
        
        if abs(det_A) < 1e-10:
            print("注意: 矩阵 A 接近奇异矩阵")
        
        # 尝试求逆
        A_inv = np.linalg.inv(A)
        print("\nA 的逆矩阵:")
        print(A_inv)
    except np.linalg.LinAlgError as e:
        # 设置异常断点可捕获此处
        print(f"\n错误: {e}")
        print("矩阵 A 是奇异的（行列式为0），无法求逆")
    
    # 计算特征值
    eigenvalues = np.linalg.eigvals(A)
    print(f"\nA 的特征值: {eigenvalues}")
    
    return C


def data_statistics(data, verbose=False):
    """数据统计分析"""
    print("\n" + "=" * 50)
    print("数据统计分析")
    print("=" * 50)
    
    # 在此设置断点可观察 data 变量
    mean = np.mean(data)
    std = np.std(data)
    median = np.median(data)
    min_val = np.min(data)
    max_val = np.max(data)
    
    print(f"数据点数: {len(data)}")
    print(f"均值: {mean:.4f}")
    print(f"标准差: {std:.4f}")
    print(f"中位数: {median:.4f}")
    print(f"最小值: {min_val:.4f}")
    print(f"最大值: {max_val:.4f}")
    
    return {
        'mean': mean,
        'std': std,
        'median': median,
        'min': min_val,
        'max': max_val
    }


def process_data(data, threshold=0.5):
    """数据处理 - 演示条件断点"""
    processed = []
    
    for i, value in enumerate(data):
        # 条件断点示例: i == 50
        if abs(value) > threshold:
            processed.append(value * 2)
        else:
            processed.append(value / 2)
    
    return np.array(processed)


def divide_numbers(a, b):
    """除法运算 - 演示异常处理"""
    try:
        result = a / b
        return result
    except ZeroDivisionError as e:
        print(f"除零错误: {e}")
        return None
    except TypeError as e:
        print(f"类型错误: {e}")
        return None


def outer_function(x):
    """外层函数 - 演示调用堆栈"""
    print(f"\n外层函数被调用，参数 x = {x}")
    intermediate = middle_function(x)
    result = intermediate + 10
    print(f"外层函数返回: {result}")
    return result


def middle_function(x):
    """中间函数"""
    print(f"中间函数被调用，参数 x = {x}")
    inner_result = inner_function(x)
    return inner_result * 2


def inner_function(x):
    """内层函数 - 在此设置断点查看调用堆栈"""
    print(f"内层函数被调用，参数 x = {x}")
    return x ** 2


def main():
    """主函数"""
    args = parse_arguments()
    
    print("=" * 60)
    print("Python 调试示例程序")
    print("=" * 60)
    print(f"运行模式: {args.mode}")
    print(f"输入数据: {args.input}")
    print(f"详细输出: {args.verbose}")
    
    # 1. 递归函数调用堆栈演示
    print("\n" + "-" * 50)
    print("1. 递归调用堆栈演示 (阶乘)")
    print("-" * 50)
    n = 5
    fact_result = calculate_factorial(n)
    print(f"{n}! = {fact_result}")
    
    # 2. 斐波那契数列
    print("\n" + "-" * 50)
    print("2. 斐波那契数列")
    print("-" * 50)
    fib_num = 10
    fib_result = fibonacci(fib_num)
    print(f"Fibonacci({fib_num}) = {fib_result}")
    
    # 3. 矩阵运算（包含异常处理）
    matrix_result = matrix_operations(verbose=args.verbose)
    
    # 4. 数据统计
    np.random.seed(42)
    data = np.random.randn(100)
    stats = data_statistics(data, verbose=args.verbose)
    
    # 5. 数据处理
    processed_data = process_data(data, threshold=0.5)
    print(f"\n处理后数据点数: {len(processed_data)}")
    print(f"处理后均值: {np.mean(processed_data):.4f}")
    
    # 6. 多层函数调用堆栈
    print("\n" + "-" * 50)
    print("6. 多层函数调用堆栈")
    print("-" * 50)
    call_result = outer_function(5)
    
    # 7. 异常处理演示
    print("\n" + "-" * 50)
    print("7. 异常处理演示")
    print("-" * 50)
    print(f"10 / 2 = {divide_numbers(10, 2)}")
    print(f"10 / 0 = {divide_numbers(10, 0)}")
    
    # 8. 调试模式特殊输出
    if args.mode == 'debug':
        print("\n" + "=" * 50)
        print("调试模式激活 - 显示详细信息")
        print("=" * 50)
        print(f"矩阵运算结果形状: {matrix_result.shape}")
        print(f"矩阵运算结果:\n{matrix_result}")
        print(f"\n统计数据详情: {stats}")
    
    print("\n" + "=" * 60)
    print("程序执行完成!")
    print("=" * 60)
    print("\n调试提示:")
    print("- 在函数内部设置断点观察变量")
    print("- 使用条件断点 (如 i == 50)")
    print("- 设置异常断点捕获异常")
    print("- 在 inner_function 设置断点查看调用堆栈")
    print("- 使用调试控制台修改变量值")


if __name__ == "__main__":
    main()
