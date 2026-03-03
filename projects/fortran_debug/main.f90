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
    
    print *
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
