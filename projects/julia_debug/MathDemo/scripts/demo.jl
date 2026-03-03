# 添加项目到路径
using Pkg
Pkg.activate(joinpath(@__DIR__, ".."))

# 直接包含模块文件
include(joinpath(@__DIR__, "..", "src", "MathDemo.jl"))
using .MathDemo

# 运行演示
matrix_operations()
vector_analysis()
solve_linear_system()

println("\n所有演示完成!")
