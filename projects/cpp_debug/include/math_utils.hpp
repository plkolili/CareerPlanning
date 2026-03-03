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
