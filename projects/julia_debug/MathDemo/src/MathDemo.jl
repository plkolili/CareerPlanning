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
