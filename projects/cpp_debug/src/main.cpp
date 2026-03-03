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
