! 多文件项目主程序
program math_demo_multi
    ! 使用 only 子句避免导入 dp 造成冲突
    use matrix_ops, only: matrix_multiply, matrix_transpose, &
                          matrix_trace, matrix_scalar_mult
    use utils, only: print_matrix, print_vector, vector_norm, &
                     vector_dot, compute_matrix_stats, identity_matrix
    implicit none
    
    ! 自己定义 dp
    integer, parameter :: dp = kind(1.0d0)
    integer, parameter :: n = 3
    
    real(dp) :: A(n, n), B(n, n), C(n, n)
    real(dp) :: vector1(n), vector2(n)
    real(dp) :: trace_val, sum_val, avg_val, max_val, min_val
    real(dp) :: norm_val, dot_val
    
    print *, "Fortran 多文件项目演示"
    print *, "======================="
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
    
    ! 使用 utils 模块打印矩阵
    call print_matrix(A, n, "矩阵 A")
    call print_matrix(B, n, "矩阵 B")
    
    ! 使用 matrix_ops 模块进行矩阵乘法
    C = matrix_multiply(A, B, n)
    call print_matrix(C, n, "A × B (手动计算)")
    
    ! 使用内置 matmul 验证
    C = matmul(A, B)
    call print_matrix(C, n, "A × B (matmul)")
    
    ! 矩阵转置
    C = matrix_transpose(A, n)
    call print_matrix(C, n, "A 的转置")
    
    ! 计算迹
    trace_val = matrix_trace(C, n)
    print *, "A 转置的迹:", trace_val
    print *
    
    ! 标量乘法
    C = matrix_scalar_mult(A, 2.0_dp, n)
    call print_matrix(C, n, "2 × A")
    
    ! 向量操作
    vector1 = [1.0_dp, 2.0_dp, 3.0_dp]
    vector2 = [4.0_dp, 5.0_dp, 6.0_dp]
    
    call print_vector(vector1, n, "向量 v1")
    call print_vector(vector2, n, "向量 v2")
    
    ! 计算向量范数
    norm_val = vector_norm(vector1, n)
    print *, "||v1|| =", norm_val
    
    ! 计算向量点积
    dot_val = vector_dot(vector1, vector2, n)
    print *, "v1·v2 =", dot_val
    print *
    
    ! 计算矩阵统计信息
    call compute_matrix_stats(A, n, trace=trace_val, sum_all=sum_val, &
                             avg=avg_val, max_val=max_val, min_val=min_val)
    
    print *, "矩阵 A 统计信息:"
    print *, "  迹:", trace_val
    print *, "  总和:", sum_val
    print *, "  平均值:", avg_val
    print *, "  最大值:", max_val
    print *, "  最小值:", min_val
    print *
    
    ! 单位矩阵
    call identity_matrix(C, n)
    call print_matrix(C, n, "3×3 单位矩阵")
    
    print *, "程序执行完成!"
    
end program math_demo_multi
