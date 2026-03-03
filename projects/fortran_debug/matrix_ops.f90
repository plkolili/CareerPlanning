! 矩阵操作模块
module matrix_ops
    implicit none
    
    integer, parameter :: dp = kind(1.0d0)
    
contains
    
    ! 矩阵乘法
    function matrix_multiply(A, B, n) result(C)
        integer, intent(in) :: n
        real(dp), intent(in) :: A(n, n), B(n, n)
        real(dp) :: C(n, n)
        integer :: i, j, k
        
        C = 0.0_dp
        do i = 1, n
            do j = 1, n
                do k = 1, n
                    C(i, j) = C(i, j) + A(i, k) * B(k, j)
                end do
            end do
        end do
    end function matrix_multiply
    
    ! 矩阵转置
    function matrix_transpose(A, n) result(At)
        integer, intent(in) :: n
        real(dp), intent(in) :: A(n, n)
        real(dp) :: At(n, n)
        integer :: i, j
        
        do i = 1, n
            do j = 1, n
                At(j, i) = A(i, j)
            end do
        end do
    end function matrix_transpose
    
    ! 计算迹（对角线之和）
    function matrix_trace(A, n) result(trace)
        integer, intent(in) :: n
        real(dp), intent(in) :: A(n, n)
        real(dp) :: trace
        integer :: i
        
        trace = 0.0_dp
        do i = 1, n
            trace = trace + A(i, i)
        end do
    end function matrix_trace
    
    ! 矩阵与标量乘法
    function matrix_scalar_mult(A, scalar, n) result(B)
        integer, intent(in) :: n
        real(dp), intent(in) :: A(n, n), scalar
        real(dp) :: B(n, n)
        integer :: i, j
        
        do i = 1, n
            do j = 1, n
                B(i, j) = A(i, j) * scalar
            end do
        end do
    end function matrix_scalar_mult
    
end module matrix_ops
