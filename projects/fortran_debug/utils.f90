! 工具模块
module utils
    implicit none
    
    integer, parameter :: dp = kind(1.0d0)
    
contains
    
    ! 打印矩阵
    subroutine print_matrix(M, n, name)
        integer, intent(in) :: n
        real(dp), intent(in) :: M(n, n)
        character(*), intent(in), optional :: name
        integer :: i
        
        if (present(name)) then
            print *, name // ":"
        end if
        
        do i = 1, n
            print '(3F10.4)', M(i, :)
        end do
        print *
    end subroutine print_matrix
    
    ! 打印向量
    subroutine print_vector(v, n, name)
        integer, intent(in) :: n
        real(dp), intent(in) :: v(n)
        character(*), intent(in), optional :: name
        
        if (present(name)) then
            print *, name // ":", v
        else
            print *, v
        end if
    end subroutine print_vector
    
    ! 计算向量范数
    function vector_norm(v, n) result(norm)
        integer, intent(in) :: n
        real(dp), intent(in) :: v(n)
        real(dp) :: norm
        integer :: i
        
        norm = 0.0_dp
        do i = 1, n
            norm = norm + v(i) * v(i)
        end do
        norm = sqrt(norm)
    end function vector_norm
    
    ! 计算向量点积
    function vector_dot(v1, v2, n) result(dot)
        integer, intent(in) :: n
        real(dp), intent(in) :: v1(n), v2(n)
        real(dp) :: dot
        integer :: i
        
        dot = 0.0_dp
        do i = 1, n
            dot = dot + v1(i) * v2(i)
        end do
    end function vector_dot
    
    ! 计算矩阵统计信息
    subroutine compute_matrix_stats(M, n, trace, sum_all, avg, max_val, min_val)
        integer, intent(in) :: n
        real(dp), intent(in) :: M(n, n)
        real(dp), intent(out), optional :: trace, sum_all, avg, max_val, min_val
        integer :: i, j
        
        if (present(trace)) then
            trace = 0.0_dp
            do i = 1, n
                trace = trace + M(i, i)
            end do
        end if
        
        if (present(sum_all) .or. present(avg) .or. present(max_val) .or. present(min_val)) then
            if (present(sum_all)) sum_all = sum(M)
            if (present(avg)) avg = sum(M) / (n * n)
            if (present(max_val)) max_val = maxval(M)
            if (present(min_val)) min_val = minval(M)
        end if
    end subroutine compute_matrix_stats
    
    ! 初始化单位矩阵
    subroutine identity_matrix(M, n)
        integer, intent(in) :: n
        real(dp), intent(out) :: M(n, n)
        integer :: i
        
        M = 0.0_dp
        do i = 1, n
            M(i, i) = 1.0_dp
        end do
    end subroutine identity_matrix
    
end module utils
