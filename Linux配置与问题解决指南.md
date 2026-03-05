# Linux配置与问题解决指南

## WSL Ubuntu 18.04 配置

### 卸载

```
wsl --unregister Ubuntu-18.04
```

### Python 配置

将 Python 默认指向 Python3：

```Python
sudo rm -rf /usr/bin/python
sudo ln -s /usr/bin/python3 /usr/bin/python
```

### NVIDIA 驱动与 CUDA

安装 NVIDIA CUDA 工具包：

```
sudo apt install nvidia-cuda-toolkit
```

验证安装：

```
nvidia-smi
nvcc --version
```

### GPUMD 安装

进入 src 目录后执行 make 命令进行编译安装。

## Linux 常见问题解决

### 问题1：Conda 权限错误

**错误信息：**
```
The current user does not have write permissions to the target environment. 
environment location: /home/lgy/Deps/conda uid: 1000 gid: 1000
```

**解决方案：**
```
# Change ownership of the entire conda directory to your user
sudo chown -R $USER:$USER /home/lgy/Deps/conda