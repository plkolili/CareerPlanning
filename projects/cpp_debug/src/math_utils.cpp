#include "math_utils.hpp"
#include <cmath>
#include <stdexcept>

namespace math {
    double dotProduct(const std::vector<double>& a, const std::vector<double>& b) {
        if (a.size() != b.size()) {
            throw std::invalid_argument("向量维度不匹配");
        }
        
        double sum = 0.0;
        for (size_t i = 0; i < a.size(); ++i) {
            sum += a[i] * b[i];
        }
        return sum;
    }
    
    double norm(const std::vector<double>& v) {
        return std::sqrt(dotProduct(v, v));
    }
    
    double lerp(double a, double b, double t) {
        return a + t * (b - a);
    }
    
    double gaussian(double x, double mu, double sigma) {
        double coeff = 1.0 / (sigma * std::sqrt(2.0 * M_PI));
        double exponent = -0.5 * std::pow((x - mu) / sigma, 2);
        return coeff * std::exp(exponent);
    }
}
