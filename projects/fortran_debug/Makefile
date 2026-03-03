# Fortran 项目 Makefile
FC = gfortran
FFLAGS = -g -O0 -fcheck=all -fbacktrace -Wall -Wextra

# 源文件 - 注意顺序：被依赖的模块必须放在前面
SRCS = matrix_ops.f90 utils.f90 main_multi.f90
OBJS = $(SRCS:.f90=.o)
TARGET = math_demo

.PHONY: all clean debug

all: $(TARGET)

$(TARGET): $(OBJS)
	$(FC) $(FFLAGS) -o $@ $^

%.o: %.f90
	$(FC) $(FFLAGS) -c $<

# 清理编译产物
clean:
	rm -f $(OBJS) $(TARGET) *.mod

# 调试构建（禁用优化，启用更多检查）
debug: FFLAGS += -ffpe-trap=invalid,zero,overflow -fbounds-check
debug: all
