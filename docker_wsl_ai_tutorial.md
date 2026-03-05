# Docker Desktop + WSL2 详细教学文档
## 以AI学习为例子的完整实战指南

> 本文档基于官方文档和实战经验编写，涵盖从环境搭建到AI应用部署的完整流程

### 目录
- [1. 环境准备](#1-环境准备)
- [2. Docker Desktop 安装](#2-docker-desktop-安装)
- [3. WSL2 配置](#3-wsl2-配置)
- [4. Docker 基础操作](#4-docker-基础操作)
- [5. AI 应用实战](#5-ai-应用实战)
- [6. 常见问题解决](#6-常见问题解决)
- [7. 性能优化](#7-性能优化)
- [8. 大陆网络环境配置](#8-大陆网络环境配置)

---

## 1. 环境准备

### 1.1 系统要求
- **操作系统**: Windows 10 1903 或更高版本 / Windows 11
- **内存**: 建议 8GB 以上
- **存储**: 至少 20GB 可用空间
- **虚拟化**: BIOS 中启用虚拟化技术（VT-x/AMD-V）

### 1.2 检查系统兼容性

```powershell
# 检查 Windows 版本
systeminfo | findstr /B /C:"OS Name" /C:"OS Version"

# 检查虚拟化是否启用
systeminfo | findstr /C:"Hyper-V Requirements"

# 检查 WSL 支持
wsl --list --verbose
```

### 1.3 安装前准备
- 确保网络连接正常
- 关闭其他虚拟机软件（VMware、VirtualBox等）
- 以管理员身份运行 PowerShell
- 备份重要数据

---

## 2. Docker Desktop 安装

### 2.1 下载安装包
访问 [Docker Desktop 官网](https://www.docker.com/products/docker-desktop/) 下载安装包

### 2.2 安装步骤

#### 方式一：图形界面安装
1. 双击 `Docker Desktop Installer.exe`
2. 选择安装路径（默认：`C:\Program Files\Docker\Docker`）
3. 勾选以下选项：
   - ✅ **Use WSL 2 instead of Hyper-V**
   - ✅ **Add shortcut to desktop**
   - ✅ **Start Docker Desktop when you log in**

#### 方式二：命令行安装
```powershell
# 以管理员身份运行
Start-Process 'Docker Desktop Installer.exe' -Wait install

# 自定义安装路径
Start-Process 'Docker Desktop Installer.exe' -Wait -ArgumentList 'install', '--installation-dir=D:\Docker'
```

### 2.3 首次启动配置
安装完成后，Docker Desktop 会自动启动，首次启动需要：
1. 接受服务条款
2. 选择用户类型（个人/企业）
3. 配置 WSL2 后端
4. 等待初始化完成

---

## 3. WSL2 配置

### 3.1 WSL2 简介
WSL2 (Windows Subsystem for Linux 2) 是微软开发的 Linux 子系统，相比 WSL1 具有：
- 完整的 Linux 内核
- 更好的文件系统性能
- 完全的系统调用兼容性

### 3.2 安装 WSL2

```powershell
# 以管理员身份运行 PowerShell
# 启用 WSL 功能
dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart

# 启用虚拟机功能
dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart

# 重启计算机
Restart-Computer

# 设置 WSL2 为默认版本
wsl --set-default-version 2

# 安装 Ubuntu 22.04 LTS（推荐）
wsl --install -d Ubuntu-22.04
```

### 3.3 WSL2 更新

```powershell
# 更新 WSL2
wsl --update

# 检查 WSL2 版本
wsl --version

# 查看已安装的分发版
wsl --list --verbose
```

### 3.4 WSL2 常用命令

```powershell
# 查看 WSL 状态
wsl --status

# 关闭所有 WSL 实例
wsl --shutdown

# 设置默认分发版
wsl --set-default Ubuntu-22.04

# 注销分发版
wsl --unregister Ubuntu-22.04

# 从 PowerShell 运行特定分发版
wsl --distribution Ubuntu-22.04 --user root
```

---

## 4. Docker 基础操作

### 4.1 验证安装

```powershell
# 检查 Docker 版本
docker --version
docker-compose --version

# 检查 Docker 信息
docker info

# 运行测试容器
docker run hello-world
```

### 4.2 基本概念

#### 镜像（Image）
- 只读模板，包含运行应用所需的所有内容
- 类似于虚拟机的快照

#### 容器（Container）
- 镜像的运行实例
- 轻量级、可移植的执行环境

#### 仓库（Registry）
- 存储和分发镜像的服务
- Docker Hub 是官方公共仓库

### 4.3 常用命令

```powershell
# 镜像操作
docker images                    # 列出本地镜像
docker pull ubuntu:22.04         # 拉取镜像
docker rmi ubuntu:22.04          # 删除镜像
docker search nginx              # 搜索镜像

# 容器操作
docker ps                        # 列出运行中的容器
docker ps -a                     # 列出所有容器
docker run -it ubuntu:22.04      # 运行容器
docker stop container_id         # 停止容器
docker start container_id        # 启动容器
docker rm container_id           # 删除容器

# 其他操作
docker logs container_id         # 查看容器日志
docker exec -it container_id bash  # 进入容器
docker system prune              # 清理未使用的资源
```

---

## 5. AI 应用实战

### 5.1 场景介绍
我们将部署一个基于 Python 的机器学习应用，包含：
- Jupyter Notebook 环境
- TensorFlow 深度学习框架
- 自定义数据处理脚本

### 5.2 创建项目目录

```powershell
# 创建项目目录
mkdir ai-learning-project
cd ai-learning-project

# 创建子目录
mkdir notebooks data models scripts
```

### 5.3 编写 Dockerfile

创建 `Dockerfile`：

```dockerfile
# 使用官方 Python 运行时作为基础镜像
FROM python:3.11-slim

# 设置工作目录
WORKDIR /app

# 安装系统依赖
RUN apt-get update && apt-get install -y \
    gcc \
    g++ \
    && rm -rf /var/lib/apt/lists/*

# 复制 requirements.txt 并安装 Python 依赖
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# 复制应用代码
COPY . .

# 暴露端口
EXPOSE 8888 5000

# 设置环境变量
ENV PYTHONPATH=/app

# 启动命令
CMD ["jupyter", "lab", "--ip=0.0.0.0", "--port=8888", "--no-browser", "--allow-root"]
```

### 5.4 创建依赖文件

创建 `requirements.txt`：

```txt
jupyterlab==4.2.0
pandas==2.1.4
numpy==1.25.2
matplotlib==3.8.0
seaborn==0.12.2
scikit-learn==1.3.2
tensorflow==2.15.0
torch==2.1.0
torchvision==0.16.0
flask==2.3.3
joblib==1.3.2
```

### 5.5 创建示例 Notebook

创建 `notebooks/ai_demo.ipynb`：

```json
{
 "cells": [
  {
   "cell_type": "markdown",
   "metadata": {},
   "source": [
    "# AI 学习演示\n",
    "这是一个简单的机器学习演示项目"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": null,
   "metadata": {},
   "outputs": [],
   "source": [
    "import pandas as pd\n",
    "import numpy as np\n",
    "import matplotlib.pyplot as plt\n",
    "import seaborn as sns\n",
    "from sklearn.model_selection import train_test_split\n",
    "from sklearn.linear_model import LinearRegression\n",
    "from sklearn.metrics import mean_squared_error, r2_score\n",
    "\n",
    "# 设置中文字体\n",
    "plt.rcParams['font.sans-serif'] = ['SimHei']\n",
    "plt.rcParams['axes.unicode_minus'] = False"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": null,
   "metadata": {},
   "outputs": [],
   "source": [
    "# 生成示例数据\n",
    "np.random.seed(42)\n",
    "n_samples = 1000\n",
    "\n",
    "# 特征：房屋面积、房间数量、年龄\n",
    "area = np.random.normal(100, 30, n_samples)\n",
    "rooms = np.random.randint(1, 6, n_samples)\n",
    "age = np.random.randint(0, 50, n_samples)\n",
    "\n",
    "# 目标变量：房价（基于特征的线性组合加上噪声）\n",
    "price = (area * 500 + rooms * 10000 - age * 500 + np.random.normal(0, 10000, n_samples))\n",
    "\n",
    "# 创建 DataFrame\n",
    "data = pd.DataFrame({\n",
    "    'area': area,\n",
    "    'rooms': rooms,\n",
    "    'age': age,\n",
    "    'price': price\n",
    "})\n",
    "\n",
    "print(\"数据集信息：\")\n",
    "print(data.describe())"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": null,
   "metadata": {},
   "outputs": [],
   "source": [
    "# 数据可视化\n",
    "fig, axes = plt.subplots(2, 2, figsize=(15, 10))\n",
    "\n",
    "# 房价分布\n",
    "axes[0, 0].hist(data['price'], bins=30, alpha=0.7, color='skyblue')\n",
    "axes[0, 0].set_title('房价分布')\n",
    "axes[0, 0].set_xlabel('价格')\n",
    "axes[0, 0].set_ylabel('频数')\n",
    "\n",
    "# 房价 vs 面积\n",
    "axes[0, 1].scatter(data['area'], data['price'], alpha=0.6, color='orange')\n",
    "axes[0, 1].set_title('房价 vs 房屋面积')\n",
    "axes[0, 1].set_xlabel('面积')\n",
    "axes[0, 1].set_ylabel('价格')\n",
    "\n",
    "# 房价 vs 房间数\n",
    "axes[1, 0].boxplot([data[data['rooms']==i]['price'] for i in range(1, 6)],\n",
    "                  labels=['1', '2', '3', '4', '5'])\n",
    "axes[1, 0].set_title('房价 vs 房间数量')\n",
    "axes[1, 0].set_xlabel('房间数')\n",
    "axes[1, 0].set_ylabel('价格')\n",
    "\n",
    "# 特征相关性热力图\n",
    "correlation_matrix = data.corr()\n",
    "sns.heatmap(correlation_matrix, annot=True, cmap='coolwarm', ax=axes[1, 1])\n",
    "axes[1, 1].set_title('特征相关性')\n",
    "\n",
    "plt.tight_layout()\n",
    "plt.show()"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": null,
   "metadata": {},
   "outputs": [],
   "source": [
    "# 机器学习模型训练\n",
    "# 准备数据\n",
    "X = data[['area', 'rooms', 'age']]\n",
    "y = data['price']\n",
    "\n",
    "# 分割训练集和测试集\n",
    "X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)\n",
    "\n",
    "# 训练线性回归模型\n",
    "model = LinearRegression()\n",
    "model.fit(X_train, y_train)\n",
    "\n",
    "# 预测\n",
    "y_pred = model.predict(X_test)\n",
    "\n",
    "# 评估模型\n",
    "mse = mean_squared_error(y_test, y_pred)\n",
    "r2 = r2_score(y_test, y_pred)\n",
    "\n",
    "print(f\"均方误差 (MSE): {mse:.2f}\")\n",
    "print(f\"决定系数 (R²): {r2:.4f}\")\n",
    "print(\"\\n模型系数:\")\n",
    "for feature, coef in zip(X.columns, model.coef_):\n",
    "    print(f\"{feature}: {coef:.2f}\")\n",
    "print(f\"截距: {model.intercept_:.2f}\")"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": null,
   "metadata": {},
   "outputs": [],
   "source": [
    "# 预测结果可视化\n",
    "plt.figure(figsize=(12, 6))\n",
    "\n",
    "plt.subplot(1, 2, 1)\n",
    "plt.scatter(y_test, y_pred, alpha=0.6, color='green')\n",
    "plt.plot([y_test.min(), y_test.max()], [y_test.min(), y_test.max()], 'r--', lw=2)\n",
    "plt.xlabel('实际值')\n",
    "plt.ylabel('预测值')\n",
    "plt.title('预测值 vs 实际值')\n",
    "\n",
    "plt.subplot(1, 2, 2)\n",
    "residuals = y_test - y_pred\n",
    "plt.scatter(y_pred, residuals, alpha=0.6, color='purple')\n",
    "plt.axhline(y=0, color='r', linestyle='--')\n",
    "plt.xlabel('预测值')\n",
    "plt.ylabel('残差')\n",
    "plt.title('残差图')\n",
    "\n",
    "plt.tight_layout()\n",
    "plt.show()"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": null,
   "metadata": {},
   "outputs": [],
   "source": [
    "# 使用模型进行预测\n",
    "def predict_house_price(area, rooms, age):\n",
    "    \"\"\"预测房价\"\"\"\n",
    "    features = np.array([[area, rooms, age]])\n",
    "    prediction = model.predict(features)[0]\n",
    "    return prediction\n",
    "\n",
    "# 示例预测\n",
    "example_area = 120\n",
    "example_rooms = 3\n",
    "example_age = 5\n",
    "\n",
    "predicted_price = predict_house_price(example_area, example_rooms, example_age)\n",
    "print(f\"\\n预测示例:\")\n",
    "print(f\"房屋面积: {example_area} 平方米\")\n",
    "print(f\"房间数量: {example_rooms} 间\")\n",
    "print(f\"房屋年龄: {example_age} 年\")\n",
    "print(f\"预测价格: ¥{predicted_price:,.2f}\")"
   ]
  }
 ],
 "metadata": {
  "kernelspec": {
   "display_name": "Python 3",
   "language": "python",
   "name": "python3"
  },
  "language_info": {
   "codemirror_mode": {
    "name": "ipython",
    "version": 3
   },
   "file_extension": ".py",
   "mimetype": "text/x-python",
   "name": "python",
   "nbconvert_exporter": "python",
   "pygments_lexer": "ipython3",
   "version": "3.11.0"
  }
 },
 "nbformat": 4,
 "nbformat_minor": 4
}
```

### 5.6 创建 Docker Compose 文件

创建 `docker-compose.yml`：

```yaml
version: '3.8'

services:
  ai-learning:
    build: .
    ports:
      - "8888:8888"
    volumes:
      - ./notebooks:/app/notebooks
      - ./data:/app/data
      - ./models:/app/models
      - ./scripts:/app/scripts
    environment:
      - JUPYTER_ENABLE_LAB=yes
      - JUPYTER_TOKEN=ai-learning-token
    command: jupyter lab --ip=0.0.0.0 --port=8888 --no-browser --allow-root
    restart: unless-stopped

  # 可选：添加 Redis 作为缓存
  redis:
    image: redis:7-alpine
    ports:
      - "6379:6379"
    volumes:
      - redis_data:/data
    restart: unless-stopped

volumes:
  redis_data:
```

### 5.7 构建和运行

```powershell
# 构建镜像
docker build -t ai-learning:latest .

# 运行容器
docker run -d -p 8888:8888 -v ${PWD}/notebooks:/app/notebooks ai-learning:latest

# 或者使用 Docker Compose
docker-compose up -d
```

### 5.8 访问 Jupyter Notebook

1. 打开浏览器访问 `http://localhost:8888`
2. 输入 token: `ai-learning-token`
3. 进入 Jupyter Lab 界面

### 5.9 部署 TensorFlow 模型

创建 `scripts/train_model.py`：

```python
import tensorflow as tf
import numpy as np
import pandas as pd
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import StandardScaler
import joblib

# 生成更复杂的数据集
def generate_data(n_samples=5000):
    np.random.seed(42)
    
    # 特征
    area = np.random.normal(100, 30, n_samples)
    rooms = np.random.randint(1, 6, n_samples)
    age = np.random.randint(0, 50, n_samples)
    location_score = np.random.uniform(0, 10, n_samples)
    
    # 复杂的非线性关系
    price = (
        area * 500 + 
        rooms * 15000 - 
        age * 800 + 
        location_score * 20000 +
        area * location_score * 100 +
        np.random.normal(0, 5000, n_samples)
    )
    
    return pd.DataFrame({
        'area': area,
        'rooms': rooms,
        'age': age,
        'location_score': location_score,
        'price': price
    })

# 准备数据
data = generate_data()
X = data[['area', 'rooms', 'age', 'location_score']]
y = data['price']

# 数据预处理
scaler = StandardScaler()
X_scaled = scaler.fit_transform(X)

# 分割数据
X_train, X_test, y_train, y_test = train_test_split(
    X_scaled, y, test_size=0.2, random_state=42
)

# 构建神经网络模型
model = tf.keras.Sequential([
    tf.keras.layers.Dense(64, activation='relu', input_shape=(4,)),
    tf.keras.layers.Dropout(0.3),
    tf.keras.layers.Dense(32, activation='relu'),
    tf.keras.layers.Dropout(0.3),
    tf.keras.layers.Dense(16, activation='relu'),
    tf.keras.layers.Dense(1)
])

# 编译模型
model.compile(
    optimizer='adam',
    loss='mse',
    metrics=['mae']
)

# 训练模型
history = model.fit(
    X_train, y_train,
    epochs=100,
    batch_size=32,
    validation_split=0.2,
    verbose=1
)

# 评估模型
test_loss, test_mae = model.evaluate(X_test, y_test, verbose=0)
print(f"测试集 MAE: {test_mae:.2f}")

# 保存模型和预处理器
model.save('/app/models/house_price_model.h5')
joblib.dump(scaler, '/app/models/scaler.pkl')

print("模型训练完成并已保存！")
```

### 5.10 创建模型推理服务

创建 `scripts/predict_service.py`：

```python
from flask import Flask, request, jsonify
import tensorflow as tf
import joblib
import numpy as np

app = Flask(__name__)

# 加载模型和预处理器
model = tf.keras.models.load_model('/app/models/house_price_model.h5')
scaler = joblib.load('/app/models/scaler.pkl')

@app.route('/predict', methods=['POST'])
def predict():
    try:
        # 获取请求数据
        data = request.json
        
        # 提取特征
        features = np.array([[[
            data['area'],
            data['rooms'],
            data['age'],
            data['location_score']
        ]]])
        
        # 预处理
        features_scaled = scaler.transform(features)
        
        # 预测
        prediction = model.predict(features_scaled)[0][0]
        
        return jsonify({
            'success': True,
            'prediction': float(prediction),
            'currency': 'CNY'
        })
    
    except Exception as e:
        return jsonify({
            'success': False,
            'error': str(e)
        }), 400

@app.route('/health', methods=['GET'])
def health():
    return jsonify({'status': 'healthy', 'model_loaded': True})

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=False)
```

### 5.11 更新 requirements.txt

```txt
jupyterlab==4.2.0
pandas==2.1.4
numpy==1.25.2
matplotlib==3.8.0
seaborn==0.12.2
scikit-learn==1.3.2
tensorflow==2.15.0
torch==2.1.0
torchvision==0.16.0
flask==2.3.3
joblib==1.3.2
```

---

## 6. 常见问题解决

### 6.1 Docker Desktop 启动失败

**问题**: Docker Desktop 无法启动，提示 WSL2 相关错误

**解决方案**:
```powershell
# 重置 WSL
wsl --shutdown
wsl --unregister docker-desktop
wsl --unregister docker-desktop-data

# 重新安装
wsl --install -d docker-desktop
wsl --install -d docker-desktop-data
```

### 6.2 端口被占用

**问题**: 端口 8888 已被占用

**解决方案**:
```powershell
# 查找占用端口的进程
netstat -ano | findstr :8888

# 杀死进程
taskkill /PID <进程ID> /F

# 或者修改 Docker Compose 中的端口映射
# ports:
#   - "8889:8888"
```

### 6.3 镜像拉取失败

**问题**: 无法从 Docker Hub 拉取镜像

**解决方案**:
```powershell
# 配置镜像加速器
# 在 Docker Desktop 设置中添加：
# https://docker.mirrors.ustc.edu.cn
# https://hub-mirror.c.163.com
# https://mirror.baidubce.com
```

### 6.4 容器无法访问网络

**问题**: 容器内无法访问外网

**解决方案**:
```powershell
# 检查 WSL 网络配置
ipconfig /all

# 重启 WSL
wsl --shutdown
```

---

## 7. 性能优化

### 7.1 Docker Desktop 设置优化

1. **资源分配**:
   - CPU: 4-8 核
   - 内存: 4-8 GB
   - 磁盘: 60 GB

2. **WSL2 设置**:
   - 启用 WSL2 集成
   - 配置资源限制

### 7.2 容器优化

```dockerfile
# 多阶段构建
FROM python:3.11-slim as builder
RUN pip install --user --no-cache-dir -r requirements.txt

FROM python:3.11-slim
COPY --from=builder /root/.local /root/.local
COPY . .
```

### 7.3 数据卷优化

```yaml
# 使用命名卷提高性能
volumes:
  app_data:
    driver: local
  model_data:
    driver: local
```

### 7.4 监控和调试

```powershell
# 查看容器资源使用
docker stats

# 查看容器日志
docker logs container_id

# 进入容器调试
docker exec -it container_id bash
```

---

## 8. 大陆网络环境配置

### 8.1 Docker Hub 镜像加速

#### 方式一：Docker Desktop 设置
1. 打开 Docker Desktop 设置
2. 选择 Docker Engine
3. 添加镜像加速器配置：

```json
{
  "registry-mirrors": [
    "https://docker.mirrors.ustc.edu.cn",
    "https://hub-mirror.c.163.com",
    "https://mirror.baidubce.com"
  ]
}
```

#### 方式二：配置文件
创建或修改 `~/.docker/daemon.json`：

```json
{
  "registry-mirrors": [
    "https://docker.mirrors.ustc.edu.cn",
    "https://hub-mirror.c.163.com",
    "https://mirror.baidubce.com"
  ]
}
```

### 8.2 国内镜像源

#### pip 源配置
创建或修改 `~/.pip/pip.conf`：

```ini
[global]
index-url = https://pypi.tuna.tsinghua.edu.cn/simple
trusted-host = pypi.tuna.tsinghua.edu.cn
```

#### conda 源配置
```bash
# 添加清华源
conda config --add channels https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/free/
conda config --add channels https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/main/
conda config --set show_channel_urls yes
```

### 8.3 网络优化

#### 使用 cnpm 替代 npm
```bash
npm install -g cnpm --registry=https://registry.npm.taobao.org
```

#### 配置 git 代理
```bash
git config --global http.proxy http://127.0.0.1:1080
git config --global https.proxy http://127.0.0.1:1080
```

---

## 总结

本教程详细介绍了如何在 Windows 环境下使用 Docker Desktop + WSL2 搭建 AI 学习环境。通过这个环境，您可以：

1. **快速部署**: 一键启动完整的 AI 开发环境
2. **环境隔离**: 避免依赖冲突，保持系统清洁
3. **易于分享**: 通过 Dockerfile 和 docker-compose.yml 分享完整环境
4. **可扩展性**: 轻松添加新的服务和组件

### 下一步学习建议

1. 学习 Docker 网络和存储卷的高级用法
2. 了解 Kubernetes 容器编排
3. 探索 CI/CD 与 Docker 的集成
4. 学习容器安全最佳实践

### 参考资料

- [Docker 官方文档](https://docs.docker.com/)
- [WSL2 官方文档](https://learn.microsoft.com/zh-cn/windows/wsl/)
- [TensorFlow 官方教程](https://www.tensorflow.org/tutorials)
- [Jupyter Notebook 文档](https://jupyter-notebook.readthedocs.io/)

---

*文档版本: v2.0*
*最后更新: 2026-03-03*
*作者: AI 助手*