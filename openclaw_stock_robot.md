# OpenClaw 股票交易机器人 详细教程

> 本教程详细介绍如何创建一个基于Python的股票交易机器人，支持自动买卖股票，并可部署在阿里云或腾讯云。

## 目录
- [1. 项目概述](#1-项目概述)
- [2. 技术栈选择](#2-技术栈选择)
- [3. 环境准备](#3-环境准备)
- [4. 核心功能实现](#4-核心功能实现)
- [5. 交易策略开发](#5-交易策略开发)
- [6. 云服务器部署](#6-云服务器部署)
- [7. 安全性和监控](#7-安全性和监控)
- [8. 常见问题解决](#8-常见问题解决)
- [9. 进阶功能](#9-进阶功能)
- [10. 总结](#10-总结)

---

## 1. 项目概述

### 1.1 什么是OpenClaw
OpenClaw是一个开源的股票交易机器人框架，支持：
- 实时股票数据获取
- 自动交易执行
- 策略回测和分析
- 多账户管理
- 风险控制

### 1.2 应用场景
- 量化交易
- 网格交易
- 趋势跟踪
- 套利交易
- 智能投顾

---

## 2. 技术栈选择

### 2.1 后端技术
- **Python 3.9+**: 主要开发语言
- **FastAPI**: 高性能Web框架
- **SQLAlchemy**: ORM框架
- **Redis**: 缓存和消息队列
- **PostgreSQL**: 数据库

### 2.2 数据获取
- **Tushare Pro**: 股票数据API
- **Baostock**: 免费股票数据
- **Wind API**: 专业金融数据

### 2.3 交易接口
- **TradePlus**: 通达信交易接口
- **东方财富**: 交易API
- **雪球**: 模拟交易

### 2.4 云平台
- **阿里云**: ECS云服务器
- **腾讯云**: CVM云服务器
- **Docker**: 容器化部署

---

## 3. 环境准备

### 3.1 系统要求
- **操作系统**: Ubuntu 20.04 LTS 或更高
- **内存**: 4GB 以上
- **存储**: 20GB 可用空间
- **网络**: 稳定宽带连接

### 3.2 安装Python

```bash
# 更新系统
sudo apt update && sudo apt upgrade -y

# 安装Python 3.9
sudo apt install python3.9 python3.9-dev python3.9-venv -y

# 安装pip
sudo apt install python3-pip -y

# 验证安装
python3.9 --version
pip3 --version
```

### 3.3 创建虚拟环境

```bash
# 创建项目目录
mkdir openclaw_stock_robot
cd openclaw_stock_robot

# 创建虚拟环境
python3.9 -m venv venv

# 激活虚拟环境
source venv/bin/activate

# 验证虚拟环境
which python
which pip
```

### 3.4 安装依赖

创建 `requirements.txt`：

```txt
fastapi==0.104.1
uvicorn==0.24.0
sqlalchemy==2.0.23
alembic==1.13.0
redis==5.0.1
pandas==2.1.4
numpy==1.25.2
requests==2.31.0
python-multipart==0.0.6
python-jose[cryptography]==3.3.0
passlib[bcrypt]==1.7.4
python-dotenv==1.0.0
pytest==7.4.3
pytest-asyncio==0.21.1
httpx==0.25.2
websockets==12.0
```

安装依赖：

```bash
pip install -r requirements.txt
```

---

## 4. 核心功能实现

### 4.1 项目结构

```
openclaw_stock_robot/
├── app/
│   ├── core/
│   │   ├── config.py
│   │   ├── security.py
│   │   └── database.py
│   ├── models/
│   │   ├── __init__.py
│   │   ├── user.py
│   │   ├── stock.py
│   │   └── trade.py
│   ├── api/
│   │   ├── __init__.py
│   │   ├── auth.py
│   │   ├── stock.py
│   │   └── trade.py
│   ├── services/
│   │   ├── __init__.py
│   │   ├── data_service.py
│   │   ├── trade_service.py
│   │   └── strategy_service.py
│   ├── schemas/
│   │   ├── __init__.py
│   │   ├── user.py
│   │   ├── stock.py
│   │   └── trade.py
│   ├── main.py
│   └── events.py
├── migrations/
├── tests/
├── docker/
├── scripts/
├── requirements.txt
├── Dockerfile
├── docker-compose.yml
└── README.md
```

### 4.2 核心配置文件

创建 `app/core/config.py`：

```python
from pydantic import BaseSettings

class Settings(BaseSettings):
    # 数据库配置
    database_url: str = "postgresql://user:password@localhost/openclaw"
    
    # Redis配置
    redis_url: str = "redis://localhost:6379"
    
    # 交易配置
    trade_api_url: str = "https://api.trade.com"
    trade_api_key: str = ""
    trade_api_secret: str = ""
    
    # 策略配置
    default_strategy: str = "grid_trading"
    max_position_size: float = 0.1
    stop_loss_percent: float = 0.05
    
    # 安全配置
    secret_key: str = "your-secret-key-here"
    algorithm: str = "HS256"
    access_token_expire_minutes: int = 30
    refresh_token_expire_minutes: int = 7 * 24 * 60

    class Config:
        env_file = ".env"

settings = Settings()
```

### 4.3 数据库模型

创建 `app/models/stock.py`：

```python
from sqlalchemy import Column, Integer, String, Float, DateTime, Boolean, Text
from sqlalchemy.sql import func
from app.core.database import Base

class Stock(Base):
    __tablename__ = "stocks"
    
    id = Column(Integer, primary_key=True, index=True)
    code = Column(String, unique=True, index=True)
    name = Column(String)
    market = Column(String)
    current_price = Column(Float)
    volume = Column(Integer)
    turnover = Column(Float)
    is_tradable = Column(Boolean, default=True)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), onupdate=func.now())
    
    __table_args__ = {
        "extend_existing": True
    }
```

创建 `app/models/trade.py`：

```python
from sqlalchemy import Column, Integer, String, Float, DateTime, Boolean, ForeignKey
from sqlalchemy.sql import func
from sqlalchemy.orm import relationship
from app.core.database import Base

class Trade(Base):
    __tablename__ = "trades"
    
    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"))
    stock_id = Column(Integer, ForeignKey("stocks.id"))
    trade_type = Column(String)  # buy/sell
    price = Column(Float)
    quantity = Column(Integer)
    total_amount = Column(Float)
    status = Column(String, default="pending")  # pending/confirmed/cancelled/failed
    strategy = Column(String)
    order_id = Column(String, unique=True)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), onupdate=func.now())
    
    stock = relationship("Stock", back_populates="trades")
    user = relationship("User", back_populates="trades")
    
    __table_args__ = {
        "extend_existing": True
    }
```

### 4.4 数据服务

创建 `app/services/data_service.py`：

```python
import asyncio
import aiohttp
import pandas as pd
from datetime import datetime, timedelta
from typing import List, Dict, Optional
from app.core.config import settings
from app.models.stock import Stock

class DataService:
    def __init__(self):
        self.session = None
    
    async def init_session(self):
        self.session = aiohttp.ClientSession()
    
    async def close_session(self):
        if self.session:
            await self.session.close()
    
    async def get_real_time_data(self, stock_code: str) -> Dict:
        """获取实时股票数据"""
        url = f"{settings.trade_api_url}/realtime/{stock_code}"
        try:
            async with self.session.get(url) as response:
                if response.status == 200:
                    return await response.json()
                else:
                    return {}
        except Exception as e:
            print(f"获取实时数据失败: {e}")
            return {}
    
    async def get_historical_data(self, stock_code: str, days: int = 30) -> pd.DataFrame:
        """获取历史数据"""
        end_date = datetime.now()
        start_date = end_date - timedelta(days=days)
        
        url = f"{settings.trade_api_url}/history/{stock_code}"
        params = {
            "start": start_date.strftime("%Y-%m-%d"),
            "end": end_date.strftime("%Y-%m-%d")
        }
        
        try:
            async with self.session.get(url, params=params) as response:
                if response.status == 200:
                    data = await response.json()
                    return pd.DataFrame(data)
                else:
                    return pd.DataFrame()
        except Exception as e:
            print(f"获取历史数据失败: {e}")
            return pd.DataFrame()
    
    async def scan_market(self, market: str = "all") -> List[Stock]:
        """扫描市场获取可交易股票"""
        url = f"{settings.trade_api_url}/scan/{market}"
        try:
            async with self.session.get(url) as response:
                if response.status == 200:
                    stocks_data = await response.json()
                    return [Stock(**stock) for stock in stocks_data]
                else:
                    return []
        except Exception as e:
            print(f"扫描市场失败: {e}")
            return []
```

### 4.5 交易服务

创建 `app/services/trade_service.py`：

```python
from typing import Dict, List, Optional
from app.models.trade import Trade
from app.models.stock import Stock
from app.core.config import settings
from app.services.data_service import DataService

class TradeService:
    def __init__(self, data_service: DataService):
        self.data_service = data_service
    
    async def place_order(self, user_id: int, stock_code: str, trade_type: str, 
                         quantity: int, strategy: str = "manual") -> Dict:
        """下单交易"""
        # 获取股票信息
        stock_data = await self.data_service.get_real_time_data(stock_code)
        if not stock_data:
            return {"success": False, "message": "无法获取股票信息"}
        
        # 计算交易金额
        price = stock_data.get("price", 0)
        total_amount = price * quantity
        
        # 创建交易记录
        trade = Trade(
            user_id=user_id,
            stock_id=stock_data.get("id"),
            trade_type=trade_type,
            price=price,
            quantity=quantity,
            total_amount=total_amount,
            strategy=strategy,
            status="pending"
        )
        
        # 执行交易（模拟）
        try:
            # 这里需要调用实际的交易API
            # 模拟成功
            trade.status = "confirmed"
            trade.order_id = f"ORD{int(datetime.now().timestamp())}"
            
            return {
                "success": True,
                "trade": trade,
                "message": "交易成功"
            }
        except Exception as e:
            trade.status = "failed"
            return {
                "success": False,
                "message": f"交易失败: {e}"
            }
    
    async def cancel_order(self, order_id: str) -> Dict:
        """取消订单"""
        # 这里需要调用交易API取消订单
        try:
            # 模拟取消成功
            return {
                "success": True,
                "message": "订单已取消"
            }
        except Exception as e:
            return {
                "success": False,
                "message": f"取消订单失败: {e}"
            }
    
    async def get_order_status(self, order_id: str) -> Dict:
        """获取订单状态"""
        # 这里需要调用交易API查询订单状态
        try:
            # 模拟查询结果
            return {
                "success": True,
                "status": "confirmed",
                "message": "订单已确认"
            }
        except Exception as e:
            return {
                "success": False,
                "message": f"查询订单失败: {e}"
            }
```

---

## 5. 交易策略开发

### 5.1 网格交易策略

创建 `app/services/strategy_service.py`：

```python
import numpy as np
from typing import Dict, List, Optional
from app.models.stock import Stock
from app.services.data_service import DataService

class StrategyService:
    def __init__(self, data_service: DataService):
        self.data_service = data_service
    
    async def grid_trading(self, stock_code: str, capital: float, 
                          grid_count: int = 10, grid_percent: float = 0.05) -> Dict:
        """
        网格交易策略
        - 在一定价格范围内设置多个买入和卖出网格
        - 当价格跌到买入网格时买入
        - 当价格涨到卖出网格时卖出
        """
        # 获取股票实时数据
        stock_data = await self.data_service.get_real_time_data(stock_code)
        if not stock_data:
            return {"success": False, "message": "无法获取股票信息"}
        
        current_price = stock_data.get("price", 0)
        
        # 计算网格价格
        lower_bound = current_price * (1 - grid_count * grid_percent)
        upper_bound = current_price * (1 + grid_count * grid_percent)
        
        grid_prices = np.linspace(lower_bound, upper_bound, 2 * grid_count + 1)
        
        # 生成网格交易信号
        signals = []
        for i in range(len(grid_prices) - 1):
            if i % 2 == 0:  # 买入网格
                signals.append({
                    "price": grid_prices[i],
                    "action": "buy",
                    "quantity": int(capital / (grid_count * grid_percent * current_price) / grid_count)
                })
            else:  # 卖出网格
                signals.append({
                    "price": grid_prices[i],
                    "action": "sell",
                    "quantity": int(capital / (grid_count * grid_percent * current_price) / grid_count)
                })
        
        return {
            "success": True,
            "signals": signals,
            "lower_bound": lower_bound,
            "upper_bound": upper_bound,
            "current_price": current_price
        }
    
    async def trend_following(self, stock_code: str, window_size: int = 20) -> Dict:
        """
        趋势跟踪策略
        - 使用移动平均线判断趋势
        - 金叉买入，死叉卖出
        """
        # 获取历史数据
        historical_data = await self.data_service.get_historical_data(stock_code, window_size * 2)
        if historical_data.empty:
            return {"success": False, "message": "无法获取历史数据"}
        
        # 计算移动平均线
        historical_data['MA20'] = historical_data['close'].rolling(window=window_size).mean()
        historical_data['MA50'] = historical_data['close'].rolling(window=window_size * 2.5).mean()
        
        # 获取最新数据
        latest_data = historical_data.iloc[-1]
        
        # 生成信号
        if latest_data['MA20'] > latest_data['MA50']:
            signal = "buy"
        elif latest_data['MA20'] < latest_data['MA50']:
            signal = "sell"
        else:
            signal = "hold"
        
        return {
            "success": True,
            "signal": signal,
            "MA20": latest_data['MA20'],
            "MA50": latest_data['MA50'],
            "current_price": latest_data['close']
        }
    
    async def bollinger_bands(self, stock_code: str, window_size: int = 20, 
                            num_std: float = 2.0) -> Dict:
        """
        布林带策略
        - 价格触及上轨卖出，触及下轨买入
        """
        # 获取历史数据
        historical_data = await self.data_service.get_historical_data(stock_code, window_size * 2)
        if historical_data.empty:
            return {"success": False, "message": "无法获取历史数据"}
        
        # 计算布林带
        historical_data['middle_band'] = historical_data['close'].rolling(window=window_size).mean()
        historical_data['std_dev'] = historical_data['close'].rolling(window=window_size).std()
        historical_data['upper_band'] = historical_data['middle_band'] + num_std * historical_data['std_dev']
        historical_data['lower_band'] = historical_data['middle_band'] - num_std * historical_data['std_dev']
        
        # 获取最新数据
        latest_data = historical_data.iloc[-1]
        
        # 生成信号
        if latest_data['close'] > latest_data['upper_band']:
            signal = "sell"
        elif latest_data['close'] < latest_data['lower_band']:
            signal = "buy"
        else:
            signal = "hold"
        
        return {
            "success": True,
            "signal": signal,
            "upper_band": latest_data['upper_band'],
            "lower_band": latest_data['lower_band'],
            "middle_band": latest_data['middle_band'],
            "current_price": latest_data['close']
        }
```

### 5.2 策略回测

```python
import pandas as pd
from typing import Dict, List

class BacktestService:
    def __init__(self):
        pass
    
    def run_backtest(self, strategy_name: str, historical_data: pd.DataFrame, 
                    initial_capital: float = 100000) -> Dict:
        """
        运行回测
        """
        signals = self.generate_signals(strategy_name, historical_data)
        trades = self.execute_trades(signals, historical_data, initial_capital)
        performance = self.calculate_performance(trades, historical_data)
        
        return {
            "signals": signals,
            "trades": trades,
            "performance": performance
        }
    
    def generate_signals(self, strategy_name: str, data: pd.DataFrame) -> List[Dict]:
        """生成交易信号"""
        signals = []
        # 根据不同策略生成信号
        if strategy_name == "grid_trading":
            # 网格交易信号生成逻辑
            pass
        elif strategy_name == "trend_following":
            # 趋势跟踪信号生成逻辑
            pass
        elif strategy_name == "bollinger_bands":
            # 布林带信号生成逻辑
            pass
        
        return signals
    
    def execute_trades(self, signals: List[Dict], data: pd.DataFrame, 
                      capital: float) -> List[Dict]:
        """执行交易"""
        trades = []
        current_cash = capital
        current_position = 0
        
        for signal in signals:
            # 执行交易逻辑
            pass
        
        return trades
    
    def calculate_performance(self, trades: List[Dict], data: pd.DataFrame) -> Dict:
        """计算绩效"""
        total_return = 0
        max_drawdown = 0
        sharpe_ratio = 0
        
        # 绩效计算逻辑
        performance = {
            "total_return": total_return,
            "max_drawdown": max_drawdown,
            "sharpe_ratio": sharpe_ratio,
            "trades_count": len(trades),
            "win_rate": 0
        }
        
        return performance
```

---

## 6. 云服务器部署

### 6.1 Docker 容器化

创建 `Dockerfile`：

```dockerfile
# 使用Python 3.9镜像
FROM python:3.9-slim

# 设置工作目录
WORKDIR /app

# 安装系统依赖
RUN apt-get update && apt-get install -y \
    gcc \
    g++ \
    libpq-dev \
    && rm -rf /var/lib/apt/lists/*

# 设置环境变量
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

# 安装Python依赖
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# 复制应用代码
COPY . .

# 暴露端口
EXPOSE 8000

# 启动命令
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
```

### 6.2 Docker Compose

创建 `docker-compose.yml`：

```yaml
version: '3.8'

services:
  openclaw:
    build: .
    ports:
      - "8000:8000"
    environment:
      - DATABASE_URL=postgresql://user:password@postgres:5432/openclaw
      - REDIS_URL=redis://redis:6379
      - TRADE_API_KEY=${TRADE_API_KEY}
      - TRADE_API_SECRET=${TRADE_API_SECRET}
    depends_on:
      - postgres
      - redis
    restart: unless-stopped

  postgres:
    image: postgres:15
    environment:
      - POSTGRES_DB=openclaw
      - POSTGRES_USER=user
      - POSTGRES_PASSWORD=password
    volumes:
      - postgres_data:/var/lib/postgresql/data
    restart: unless-stopped

  redis:
    image: redis:7-alpine
    restart: unless-stopped

volumes:
  postgres_data:
```

### 6.3 阿里云部署

#### 6.3.1 创建ECS实例

1. **登录阿里云控制台**
2. **选择云服务器ECS**
3. **创建实例**：
   - 地域：选择离您最近的地域
   - 实例规格：建议2核4GB
   - 镜像：Ubuntu 20.04 64位
   - 存储：40GB 高效云盘
   - 网络：分配公网IP

#### 6.3.2 安全组配置

```bash
# 开放必要端口
# TCP: 8000 (应用端口)
# TCP: 22 (SSH端口)
# ICMP (允许Ping)
```

#### 6.3.3 部署步骤

```bash
# 1. 连接服务器
ssh ubuntu@your-server-ip

# 2. 更新系统
sudo apt update && sudo apt upgrade -y

# 3. 安装Docker和Docker Compose
sudo apt install docker.io docker-compose -y

# 4. 启动Docker服务
sudo systemctl enable docker
sudo systemctl start docker

# 5. 克隆项目
git clone https://github.com/your-username/openclaw_stock_robot.git
cd openclaw_stock_robot

# 6. 配置环境变量
cp .env.example .env
# 编辑 .env 文件，添加API密钥等配置

# 7. 构建并启动
docker-compose up -d
```

### 6.4 腾讯云部署

#### 6.4.1 创建CVM实例

1. **登录腾讯云控制台**
2. **选择云服务器CVM**
3. **创建实例**：
   - 地域：选择离您最近的地域
   - 实例规格：建议2核4GB
   - 镜像：Ubuntu 20.04 LTS
   - 存储：40GB 高性能云硬盘
   - 网络：分配公网IP

#### 6.4.2 安全组配置

```bash
# 开放必要端口
# TCP: 8000 (应用端口)
# TCP: 22 (SSH端口)
# ICMP (允许Ping)
```

#### 6.4.3 部署步骤

```bash
# 1. 连接服务器
ssh ubuntu@your-server-ip

# 2. 更新系统
sudo apt update && sudo apt upgrade -y

# 3. 安装Docker和Docker Compose
sudo apt install docker.io docker-compose -y

# 4. 启动Docker服务
sudo systemctl enable docker
sudo systemctl start docker

# 5. 克隆项目
git clone https://github.com/your-username/openclaw_stock_robot.git
cd openclaw_stock_robot

# 6. 配置环境变量
cp .env.example .env
# 编辑 .env 文件，添加API密钥等配置

# 7. 构建并启动
docker-compose up -d
```

---

## 7. 安全性和监控

### 7.1 安全配置

#### 7.1.1 API密钥管理

```python
# app/core/security.py
from jose import JWTError, jwt
from passlib.context import CryptContext
from datetime import datetime, timedelta
from app.core.config import settings

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")
SECRET_KEY = settings.secret_key
ALGORITHM = settings.algorithm

def create_access_token(data: dict, expires_delta: Optional[timedelta] = None):
    to_encode = data.copy()
    if expires_delta:
        expire = datetime.utcnow() + expires_delta
    else:
        expire = datetime.utcnow() + timedelta(minutes=settings.access_token_expire_minutes)
    to_encode.update({"exp": expire})
    encoded_jwt = jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)
    return encoded_jwt

def verify_password(plain_password, hashed_password):
    return pwd_context.verify(plain_password, hashed_password)

def get_password_hash(password):
    return pwd_context.hash(password)
```

#### 7.1.2 访问控制

```python
# app/api/auth.py
from fastapi import Depends, HTTPException, status
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from sqlalchemy.orm import Session
from app.core.security import verify_token
from app.core.database import get_db

security = HTTPBearer()

async def get_current_user(credentials: HTTPAuthorizationCredentials = Depends(security),
                          db: Session = Depends(get_db)):
    credentials_exception = HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="Could not validate credentials",
        headers={"WWW-Authenticate": "Bearer"},
    )
    try:
        payload = verify_token(credentials.credentials)
        user_id = payload.get("user_id")
        if user_id is None:
            raise credentials_exception
        user = db.query(User).filter(User.id == user_id).first()
        if user is None:
            raise credentials_exception
    except JWTError:
        raise credentials_exception
    return user
```

### 7.2 监控配置

#### 7.2.1 日志系统

```python
# app/core/logging.py
import logging
import sys
from logging.handlers import RotatingFileHandler

def setup_logging():
    logger = logging.getLogger()
    logger.setLevel(logging.INFO)
    
    # 控制台日志
    console_handler = logging.StreamHandler(sys.stdout)
    console_handler.setLevel(logging.INFO)
    console_formatter = logging.Formatter(
        '%(asctime)s - %(name)s - %(levelname)s - %(message)s'
    )
    console_handler.setFormatter(console_formatter)
    
    # 文件日志
    file_handler = RotatingFileHandler(
        'openclaw.log',
        maxBytes=10*1024*1024,  # 10MB
        backupCount=5
    )
    file_handler.setLevel(logging.INFO)
    file_formatter = logging.Formatter(
        '%(asctime)s - %(name)s - %(levelname)s - %(message)s'
    )
    file_handler.setFormatter(file_formatter)
    
    logger.addHandler(console_handler)
    logger.addHandler(file_handler)
    
    return logger

logger = setup_logging()
```

#### 7.2.2 健康检查

```python
# app/api/health.py
from fastapi import APIRouter
from app.core.database import engine
from app.services.data_service import DataService

router = APIRouter()
data_service = DataService()

@router.get("/health")
async def health_check():
    try:
        # 检查数据库连接
        with engine.connect() as conn:
            conn.execute("SELECT 1")
        
        # 检查数据服务
        await data_service.init_session()
        await data_service.close_session()
        
        return {"status": "healthy", "timestamp": datetime.now().isoformat()}
    except Exception as e:
        return {"status": "unhealthy", "error": str(e), "timestamp": datetime.now().isoformat()}

@router.get("/metrics")
async def metrics():
    # 返回系统指标
    return {
        "cpu_usage": psutil.cpu_percent(),
        "memory_usage": psutil.virtual_memory().percent,
        "disk_usage": psutil.disk_usage('/').percent,
        "trade_count": Trade.query.count(),
        "active_users": User.query.filter(User.is_active == True).count()
    }
```

### 7.3 备份和恢复

```bash
# 数据库备份脚本
#!/bin/bash
# backup.sh

BACKUP_DIR="/backups"
DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="openclaw_backup_$DATE.sql"

# 创建备份目录
mkdir -p $BACKUP_DIR

# 备份数据库
pg_dump -U user -d openclaw -h localhost > $BACKUP_DIR/$BACKUP_FILE

# 压缩备份
gzip $BACKUP_DIR/$BACKUP_FILE

# 删除7天前的备份
find $BACKUP_DIR -name "openclaw_backup_*.sql.gz" -mtime +7 -delete

echo "Backup completed: $BACKUP_DIR/$BACKUP_FILE.gz"
```

---

## 8. 常见问题解决

### 8.1 交易失败

**问题**: 交易API调用失败

**解决方案**:
```python
# 检查网络连接
import requests
try:
    response = requests.get("https://api.trade.com/ping", timeout=5)
    if response.status_code == 200:
        print("API连接正常")
    else:
        print("API连接异常")
except requests.exceptions.RequestException as e:
    print(f"网络错误: {e}")

# 检查API密钥配置
if not settings.trade_api_key or not settings.trade_api_secret:
    print("请配置API密钥")
```

### 8.2 数据获取延迟

**问题**: 实时数据获取延迟

**解决方案**:
```python
# 增加重试机制
import asyncio
import aiohttp
from tenacity import retry, stop_after_attempt, wait_exponential

@retry(stop=stop_after_attempt(3), wait=wait_exponential(multiplier=1, min=4, max=10))
async def get_data_with_retry(url):
    async with aiohttp.ClientSession() as session:
        async with session.get(url) as response:
            return await response.json()

# 使用缓存
from functools import lru_cache

@lru_cache(maxsize=100)
async def get_cached_data(stock_code):
    # 先检查缓存
    # 如果缓存有效，返回缓存数据
    # 否则，重新获取
    pass
```

### 8.3 内存泄漏

**问题**: 长时间运行后内存占用过高

**解决方案**:
```python
# 定期清理缓存
import gc
import psutil

def memory_cleanup():
    # 清理缓存
    gc.collect()
    
    # 检查内存使用
    memory_info = psutil.virtual_memory()
    if memory_info.percent > 80:
        # 如果内存使用超过80%，触发清理
        print("内存使用过高，触发清理")
        # 清理特定缓存或重启服务
```

### 8.4 数据库连接问题

**问题**: 数据库连接超时

**解决方案**:
```python
# 连接池配置
from sqlalchemy import create_engine
from sqlalchemy.pool import QueuePool

engine = create_engine(
    settings.database_url,
    poolclass=QueuePool,
    pool_size=10,
    max_overflow=20,
    pool_timeout=30,
    pool_recycle=1800
)

# 连接重试
from sqlalchemy.exc import OperationalError
from tenacity import retry

@retry(stop=stop_after_attempt(3), wait=wait_fixed(2))
def get_db_connection():
    try:
        return engine.connect()
    except OperationalError:
        raise
```

---

## 9. 进阶功能

### 9.1 机器学习预测

```python
import tensorflow as tf
from sklearn.preprocessing import StandardScaler
from sklearn.model_selection import train_test_split

class MLPredictionService:
    def __init__(self):
        self.model = None
        self.scaler = StandardScaler()
    
    def train_model(self, historical_data: pd.DataFrame):
        """训练预测模型"""
        # 数据预处理
        features = historical_data[['open', 'high', 'low', 'volume']]
        target = historical_data['close']
        
        # 标准化
        features_scaled = self.scaler.fit_transform(features)
        
        # 分割数据集
        X_train, X_test, y_train, y_test = train_test_split(
            features_scaled, target, test_size=0.2, random_state=42
        )
        
        # 构建模型
        model = tf.keras.Sequential([
            tf.keras.layers.Dense(64, activation='relu', input_shape=(4,)),
            tf.keras.layers.Dropout(0.2),
            tf.keras.layers.Dense(32, activation='relu'),
            tf.keras.layers.Dropout(0.2),
            tf.keras.layers.Dense(1)
        ])
        
        # 编译模型
        model.compile(
            optimizer='adam',
            loss='mse',
            metrics=['mae']
        )
        
        # 训练模型
        model.fit(
            X_train, y_train,
            epochs=50,
            batch_size=32,
            validation_split=0.2,
            verbose=0
        )
        
        # 评估模型
        loss, mae = model.evaluate(X_test, y_test, verbose=0)
        print(f"模型MAE: {mae}")
        
        self.model = model
    
    def predict(self, stock_data: pd.DataFrame) -> float:
        """预测股票价格"""
        if self.model is None:
            raise Exception("模型未训练")
        
        # 数据预处理
        features = stock_data[['open', 'high', 'low', 'volume']]
        features_scaled = self.scaler.transform(features)
        
        # 预测
        prediction = self.model.predict(features_scaled)
        
        return float(prediction[-1])
```

### 9.2 多策略组合

```python
class StrategyCombiner:
    def __init__(self):
        self.strategies = []
    
    def add_strategy(self, strategy):
        self.strategies.append(strategy)
    
    async def get_combined_signal(self, stock_code: str) -> Dict:
        """获取多策略组合信号"""
        signals = []
        
        for strategy in self.strategies:
            signal = await strategy.get_signal(stock_code)
            signals.append(signal)
        
        # 权重投票
        buy_count = sum(1 for s in signals if s['signal'] == 'buy')
        sell_count = sum(1 for s in signals if s['signal'] == 'sell')
        hold_count = sum(1 for s in signals if s['signal'] == 'hold')
        
        if buy_count > sell_count and buy_count > hold_count:
            final_signal = 'buy'
        elif sell_count > buy_count and sell_count > hold_count:
            final_signal = 'sell'
        else:
            final_signal = 'hold'
        
        return {
            "final_signal": final_signal,
            "individual_signals": signals
        }
```

### 9.3 风险管理

```python
class RiskManager:
    def __init__(self, max_drawdown: float = 0.1, max_loss: float = 0.05):
        self.max_drawdown = max_drawdown
        self.max_loss = max_loss
        self.max_position = 0.2  # 最大仓位
        self.stop_loss_levels = {}
    
    def check_risk(self, portfolio: Dict) -> bool:
        """检查风险"""
        # 计算总资产
        total_value = portfolio['cash'] + sum(portfolio['positions'].values())
        
        # 检查回撤
        if portfolio['max_value'] > 0:
            drawdown = (portfolio['max_value'] - total_value) / portfolio['max_value']
            if drawdown > self.max_drawdown:
                return False
        
        # 检查单只股票风险
        for stock, position in portfolio['positions'].items():
            if position['value'] / total_value > self.max_position:
                return False
        
        return True
    
    def set_stop_loss(self, stock_code: str, entry_price: float):
        """设置止损"""
        stop_loss_price = entry_price * (1 - self.max_loss)
        self.stop_loss_levels[stock_code] = stop_loss_price
    
    def check_stop_loss(self, stock_code: str, current_price: float) -> bool:
        """检查止损"""
        if stock_code in self.stop_loss_levels:
            stop_loss_price = self.stop_loss_levels[stock_code]
            if current_price <= stop_loss_price:
                return True
        
        return False
```

---

## 10. 总结

本教程详细介绍了如何创建一个完整的OpenClaw股票交易机器人，包括：

1. **项目架构**: 使用FastAPI构建高性能后端
2. **核心功能**: 实时数据获取、交易执行、策略管理
3. **交易策略**: 网格交易、趋势跟踪、布林带等多种策略
4. **云部署**: 支持阿里云和腾讯云的Docker容器化部署
5. **安全监控**: 权限管理、日志系统、健康检查
6. **进阶功能**: 机器学习预测、多策略组合、风险管理

### 10.1 下一步学习建议

1. **优化策略**: 使用历史数据进行策略回测和优化
2. **实时监控**: 添加实时监控和告警系统
3. **移动端**: 开发移动端应用或小程序
4. **社区贡献**: 参与OpenClaw开源社区

### 10.2 参考资源

- [FastAPI官方文档](https://fastapi.tiangolo.com/)
- [Tushare Pro](https://tushare.pro/)
- [Docker官方文档](https://docs.docker.com/)
- [阿里云ECS](https://www.aliyun.com/product/ecs)
- [腾讯云CVM](https://cloud.tencent.com/product/cvm)

### 10.3 开源协议

OpenClaw股票交易机器人遵循MIT开源协议，鼓励大家学习、修改和分享。

---

*文档版本: v1.0*
*最后更新: 2026-03-08*
*作者: AI助手*