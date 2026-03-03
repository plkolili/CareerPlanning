# VASP 6.4.3 稀土铜（La-Cu）晶界热稳定性模拟方法

## 1. 研究背景与目标

### 1.1 实验现象
- **成分**：无氧铜中加入 100 ppm La
- **性能提升**：
  - 980°C 持久强度：从 <100 MPa 提升至 170 MPa
  - 晶粒长大抑制：980°C/3h 热处理后，晶粒尺寸从 mm 级减小至 50 μm
- **关键发现**：SEM/EBSD/TEM/HRTEM/APT 等实验手段**未观察到 La 的位置**

### 1.2 研究目标
不考虑晶界偏聚（Segregation），重点研究：
1. La 在 Cu 基体中的固溶位置（替代位、间隙位、空位处）
2. 晶界迁移势垒的变化
3. 热稳定性提高的原子尺度机制

---

## 2. 理论基础

### 2.1 晶界迁移与晶粒长大
晶界迁移速率由以下因素决定：
```
v = M × F
```
其中：
- `M`：晶界迁移率（mobility）
- `F`：驱动力（曲率驱动、化学势梯度等）

晶界迁移率与原子跳跃频率相关：
```
M ∝ exp(-Q_m / kT)
```
`Q_m` 为晶界迁移激活能。

### 2.2 溶质原子对晶界迁移的影响
溶质原子可通过以下方式影响晶界迁移：
1. **溶质拖曳（Solute Drag）**：溶质原子随晶界移动，增加迁移阻力
2. **钉扎效应（Zener Pinning）**：溶质原子或第二相粒子钉扎晶界
3. **改变迁移势垒**：改变晶界原子重排的能垒

### 2.3 空位-溶质相互作用
La 原子半径（187 pm）远大于 Cu（128 pm），可能：
- 占据空位位置，降低系统应变能
- 与空位形成稳定复合体（Vacancy-La complex）
- 影响空位扩散和晶界迁移

---

## 3. 计算模型构建

### 3.1 Cu 的晶体结构
- **结构**：面心立方（FCC）
- **晶格常数**：a = 3.615 Å（实验值）
- **空间群**：Fm-3m (No. 225)

### 3.2 晶界模型

#### 3.2.1 对称倾侧晶界（Symmetric Tilt Grain Boundary）

| 晶界类型 | 旋转轴 | 旋转角 | 重位点密度 |
|---------|--------|--------|-----------|
| Σ5(310)[001] | [001] | 36.87° | 1/5 |
| Σ5(210)[001] | [001] | 53.13° | 1/5 |
| Σ7(321)[111] | [111] | 38.21° | 1/7 |
| Σ13(510)[001] | [001] | 22.62° | 1/13 |

**推荐模型**：Σ5(310)[001] 晶界
- 结构简单，计算效率高
- 能反映一般晶界特征
- 文献中有充分验证数据

#### 3.2.2 晶界模型构建步骤

1. **创建两个半晶体**
```python
# 使用 pymatgen 或 ASE 构建
from pymatgen.core import Structure, Lattice
from pymatgen.io.vasp import Poscar

# Cu 晶格常数
a = 3.615

# 构建FCC Cu
lattice = Lattice.cubic(a)
cu = Structure(lattice, ["Cu"], [[0, 0, 0]])

# 创建(310)表面超胞
# ... 具体构建代码
```

2. **旋转对接**
   - 两个半晶体分别绕 [001] 轴旋转 +θ/2 和 -θ/2
   - θ = 36.87° for Σ5(310)

3. **构建晶界双晶体**
   - 沿 z 方向堆叠两个半晶体
   - 中间为晶界区域
   - 上下表面加真空层（15-20 Å）

4. **弛豫优化**
   - 固定中间几个原子层模拟体相
   - 弛豫晶界附近原子

#### 3.2.3 超胞尺寸
```
建议尺寸：
- x 方向：~15-20 Å（晶界面内）
- y 方向：~15-20 Å（晶界面内）
- z 方向：~40-50 Å（包含两个晶粒 + 晶界）
- 真空层：15-20 Å（消除周期性相互作用）

总原子数：~200-400 原子
```

### 3.3 空位模型

#### 3.3.1 单空位（Monovacancy）
- 移除一个 Cu 原子
- 计算空位形成能

#### 3.3.2 La-空位复合体
- La 原子占据空位位置
- 计算复合体形成能
- 考虑最近邻、次近邻位置

### 3.4 La 掺杂位置

考虑三种可能位置：
1. **替代位（Substitutional）**：La 替代 Cu 原子
2. **间隙位（Interstitial）**：La 位于间隙位置（八面体间隙、四面体间隙）
3. **空位位（Vacancy Site）**：La 占据空位

---

## 4. VASP 计算参数设置

### 4.1 PAW 赝势

| 元素 | PAW 势文件 | 价电子 |
|-----|-----------|--------|
| Cu | Cu_pv 或 Cu | 17 或 11 |
| La | La | 11 |

**推荐**：
- Cu_pv：包含 3p 半芯态，更精确
- La：标准势

### 4.2 INCAR 参数

#### 4.2.1 结构优化（OPT）
```bash
# 基本参数
SYSTEM = La-Cu GB Structure Optimization
ISTART = 0          # 从头开始计算
ICHARG = 2          # 从原子电荷密度叠加
ENCUT = 450         # 截断能（eV）
PREC = Accurate     # 精度等级

# 电子优化
ALGO = Fast         # 混合算法（RMM-DIIS + CG）
NELM = 100          # 最大电子步数
NELMIN = 4          # 最小电子步数
EDIFF = 1E-6        # 电子收敛标准（eV）

# 离子优化
IBRION = 2          # 共轭梯度法
ISIF = 2            # 优化原子位置，固定晶胞
NSW = 200           # 最大离子步数
EDIFFG = -0.01      # 力收敛标准（eV/Å）

# 并行设置
NCORE = 4           # 每个核的芯数（根据集群调整）
KPAR = 4            # k点并行数

# 其他
ISMEAR = 1          # Methfessel-Paxton展宽
SIGMA = 0.2         # 展宽宽度（eV）
LREAL = Auto        # 实空间投影
LWAVE = .FALSE.     # 不保存WAVECAR
LCHARG = .TRUE.     # 保存CHGCAR
```

#### 4.2.2 静态计算（SCF）
```bash
SYSTEM = La-Cu GB SCF
ISTART = 0
ICHARG = 2
ENCUT = 500         # 提高截断能
PREC = Accurate

ALGO = Normal
NELM = 100
EDIFF = 1E-7        # 更严格的收敛标准

IBRION = -1         # 不优化
NSW = 0

ISMEAR = -5         # Tetrahedron方法（金属推荐）
# 或
ISMEAR = 1
SIGMA = 0.1

LORBIT = 11         # 输出DOS
NEDOS = 3001        # DOS点数
EMIN = -20
EMAX = 20

LWAVE = .FALSE.
LCHARG = .TRUE.
```

#### 4.2.3 NEB 计算（迁移势垒）
```bash
SYSTEM = La-Cu GB Migration Barrier
ISTART = 0
ICHARG = 2
ENCUT = 450
PREC = Normal       # NEB可用Normal加快计算

ALGO = Fast
EDIFF = 1E-5        # NEB可放宽电子收敛

# NEB参数
IBRION = 3          # 快速准牛顿法
IOPT = 1            # 优化算法（1=最速下降）
POTIM = 0.0         # 时间步长（IOPT>0时）

# 弹簧常数
SPRING = -5         # 负值使用优化方法

IMAGES = 7          # 中间镜像数
LCLIMB = .TRUE.     #  climbing image NEB
LTANGENTOLD = .FALSE.
LNEBCELL = .FALSE.

EDIFFG = -0.05      # NEB力收敛标准（比结构优化宽松）
NSW = 500           # 更多步数

ISMEAR = 1
SIGMA = 0.2
```

#### 4.2.4 有限温度 AIMD（验证高温稳定性）
```bash
SYSTEM = La-Cu GB AIMD 980C
ISTART = 0
ICHARG = 2
ENCUT = 400         # MD可降低截断能
PREC = Normal

ALGO = Fast
EDIFF = 1E-4        # MD可放宽电子收敛

# MD参数
IBRION = 0          # MD
MDALGO = 2          # Nose-Hoover thermostat
SMASS = 0           # Nose-Hoover质量参数
TEBEG = 1253        # 起始温度（K）= 980°C
TEEND = 1253        # 结束温度（K）
POTIM = 1.0         # 时间步长（fs）
NSW = 5000          # MD步数（5ps）

# 初始速度
# VEL = ...         # 可选：从已有速度开始

ISMEAR = 1
SIGMA = 0.2

LWAVE = .FALSE.
LCHARG = .FALSE.
```

### 4.3 KPOINTS 设置

#### 4.3.1 结构优化
```
Automatic mesh
0              # 自动生成
Gamma          # Gamma中心
3 3 1          # k点网格（晶界沿z方向，取1）
0 0 0          # 偏移
```

#### 4.3.2 静态计算
```
Automatic mesh
0
Gamma
5 5 1          # 更密的k点
0 0 0
```

#### 4.3.3 原理
- 晶界模型在 z 方向有大量真空层，k 点取 1
- x、y 方向（晶界面内）需要足够密的 k 点
- 测试 k 点收敛性：3×3×1 → 5×5×1 → 7×7×1

### 4.4 POTCAR 准备

```bash
# 获取赝势文件（VASP 5.4+ 或 6.x）
# 假设 VASP 赝势在 $VASP_PP_PATH

# 复制所需势文件
cp $VASP_PP_PATH/potpaw_PBE/Cu_pv/POTCAR ./POTCAR_Cu
cp $VASP_PP_PATH/potpaw_PBE/La/POTCAR ./POTCAR_La

# 合并（按 POSCAR 中元素顺序）
cat POTCAR_Cu POTCAR_La > POTCAR
```

---

## 5. 计算流程

### 5.1 流程概览

```
步骤 1: 纯 Cu 晶界结构优化
   ↓
步骤 2: 完美 Cu 超胞优化（参考态）
   ↓
步骤 3: 空位形成能计算
   ↓
步骤 4: La 不同位置的形成能计算
   - 替代位
   - 间隙位（八面体、四面体）
   - 空位位
   ↓
步骤 5: 晶界迁移 NEB 计算
   - 纯 Cu 晶界迁移
   - 含 La 晶界迁移
   ↓
步骤 6: 有限温度 AIMD 验证
   - 纯 Cu 晶界 980°C 稳定性
   - 含 La 晶界 980°C 稳定性
```

### 5.2 详细步骤

#### 步骤 1：纯 Cu 晶界结构优化

1. 准备输入文件：
   - `POSCAR`：晶界初始结构
   - `INCAR.opt`：优化参数
   - `KPOINTS`：3×3×1
   - `POTCAR`：Cu_pv

2. 提交计算：
```bash
mpirun -np 32 vasp_std > vasp.out 2>&1
```

3. 检查收敛：
```bash
tail -20 OSZICAR
grep "reached required accuracy" OUTCAR
grep "energy without entropy" OUTCAR | tail -1
```

4. 提取优化后结构：
```bash
cp CONTCAR POSCAR_opt
```

#### 步骤 2：完美 Cu 超胞优化（参考态）

用于计算形成能的参考能量。

1. 构建完美 FCC Cu 超胞（与晶界模型相同原子数）
2. 优化结构
3. 记录总能量 `E_Cu_bulk`

#### 步骤 3：空位形成能计算

1. 在优化后的完美超胞中移除一个 Cu 原子
2. 固定晶胞，优化原子位置（ISIF=2）
3. 计算空位形成能：

```
E_vacancy = E_supercell_with_vacancy - (N-1)/N × E_perfect_supercell
```

或使用化学势：
```
E_vacancy = E_supercell_with_vacancy - E_perfect_supercell + μ_Cu
```

其中 μ_Cu 是 Cu 的化学势（取 FCC Cu 单原子能量）。

#### 步骤 4：La 掺杂形成能计算

##### 4.1 替代位 La（La_substitutional）

1. 在超胞中用一个 La 替代一个 Cu
2. 结构优化
3. 计算形成能：

```
E_form(La_sub) = E(Cu_{N-1}La_1) - E(Cu_N) + μ_Cu - μ_La
```

##### 4.2 间隙位 La（La_interstitial）

FCC 中有两种间隙位置：
- **八面体间隙**：坐标 (0.5, 0.5, 0.5)
- **四面体间隙**：坐标 (0.25, 0.25, 0.25)

1. 在间隙位置插入 La 原子
2. 结构优化（注意：可能需要逐步弛豫）
3. 计算形成能：

```
E_form(La_int) = E(Cu_N La_1) - E(Cu_N) - μ_La
```

##### 4.3 空位位 La（La_vacancy）

1. 先创建空位，然后在空位位置放置 La
2. 结构优化
3. 计算形成能：

```
E_form(La_vac) = E(Cu_{N-1}La_1) - E(Cu_N) + μ_Cu - μ_La
```

##### 4.4 形成能比较

| 位置 | 形成能（eV） | 是否稳定 |
|-----|-------------|---------|
| 替代位 | E_form_sub | |
| 八面体间隙 | E_form_oct | |
| 四面体间隙 | E_form_tet | |
| 空位位 | E_form_vac | |

**形成能越低，位置越稳定。**

#### 步骤 5：晶界迁移 NEB 计算

##### 5.1 纯 Cu 晶界迁移

模拟晶界从一个位置迁移到相邻位置的过程。

1. **确定初态（Initial）**：
   - 优化后的晶界结构
   - `POSCAR_initial`

2. **构建末态（Final）**：
   - 将晶界沿迁移方向平移一个原子层间距
   - 重新优化
   - `POSCAR_final`

3. **生成中间镜像**：
```bash
# 使用 VASP 的 nebmovie.pl 或 pymatgen
nebmake.pl POSCAR_initial POSCAR_final 7
```

生成 00 到 08 共 9 个文件夹（00=初态，08=末态，01-07=中间镜像）。

4. **准备 NEB 计算**：
   - 复制 `INCAR.neb` 到每个文件夹
   - 复制 `KPOINTS`、`POTCAR`

5. **提交计算**：
```bash
mpirun -np 64 vasp_std > vasp.neb.out 2>&1
```

6. **分析结果**：
```bash
# 查看迁移势垒
nebefs.pl

# 绘制能垒图
nebbarrier.pl > barrier.dat
gnuplot -e "plot 'barrier.dat' with linespoints"
```

##### 5.2 含 La 的晶界迁移

1. 在晶界附近引入 La（根据步骤4的最稳定位置）
2. 重复 5.1 的 NEB 计算
3. 比较迁移势垒变化

**迁移势垒提高 → 晶界迁移受阻 → 晶粒长大抑制**

#### 步骤 6：有限温度 AIMD 验证

##### 6.1 目的
- 验证 980°C（1253 K）下晶界稳定性
- 观察 La 原子的热运动
- 验证高温下晶界是否保持完整性

##### 6.2 设置

1. 从优化后的结构开始
2. 设置温度 1253 K（980°C）
3. 运行 5-10 ps AIMD
4. 轨迹分析

##### 6.3 分析

```python
# 使用 ASE 或 OVITO 分析
from ase.io import read
import matplotlib.pyplot as plt

# 读取轨迹
trajectory = read('XDATCAR', index=':')

# 计算均方位移（MSD）
# 计算径向分布函数（RDF）
# 可视化结构演变
```

---

## 6. 结果分析方法

### 6.1 形成能计算总结

```python
# Python 脚本示例
def calculate_formation_energy(E_total, n_Cu, n_La, E_Cu_bulk, E_La_bulk):
    """
    计算形成能
    
    参数：
        E_total: 体系总能量（eV）
        n_Cu: Cu 原子数
        n_La: La 原子数
        E_Cu_bulk: FCC Cu 单原子能量（eV）
        E_La_bulk: HCP La 单原子能量（eV）
    """
    E_form = E_total - n_Cu * E_Cu_bulk - n_La * E_La_bulk
    return E_form

# 参考能量（从单独计算获得）
E_Cu_bulk = -3.7  # eV/atom，示例值
E_La_bulk = -4.9  # eV/atom，示例值

# 计算各种构型的形成能
E_perfect = -740.0  # 200个Cu原子的超胞
E_substitutional = -743.2  # 199 Cu + 1 La
E_interstitial = -744.8    # 200 Cu + 1 La (间隙)
E_vacancy_site = -745.5    # 199 Cu + 1 La (空位)

E_form_sub = E_substitutional - 199*E_Cu_bulk - 1*E_La_bulk
E_form_int = E_interstitial - 200*E_Cu_bulk - 1*E_La_bulk
E_form_vac = E_vacancy_site - 199*E_Cu_bulk - 1*E_La_bulk
```

### 6.2 晶界能计算

```
E_GB = (E_supercell - N × E_bulk) / (2 × A)
```

其中：
- `E_supercell`：含晶界的超胞总能量
- `N`：原子数
- `E_bulk`：体相单原子能量
- `A`：晶界面积
- 除以 2 是因为超胞中有两个晶界（周期性边界）

### 6.3 迁移势垒分析

```python
import numpy as np
import matplotlib.pyplot as plt

# 读取 NEB 结果
data = np.loadtxt('barrier.dat')
reaction_coordinate = data[:, 0]
energy = data[:, 1]

# 找到能垒峰值（过渡态）
E_barrier = np.max(energy) - energy[0]

print(f"迁移势垒: {E_barrier:.3f} eV")

# 绘图
plt.plot(reaction_coordinate, energy, 'o-')
plt.xlabel('Reaction Coordinate')
plt.ylabel('Energy (eV)')
plt.title(f'GB Migration Barrier: {E_barrier:.3f} eV')
plt.savefig('neb_barrier.png', dpi=300)
```

### 6.4 电子结构分析

#### 6.4.1 差分电荷密度

```bash
# 计算差分电荷密度
# ρ_diff = ρ(La-Cu) - ρ(Cu) - ρ(La)

# VASP 计算时设置：
# LAECHG = .TRUE.
# LCHARG = .TRUE.

# 使用 vaspkit 或 pymatgen 处理
vaspkit -task 311  # 2D 差分电荷密度
```

#### 6.4.2 态密度（DOS）

```bash
# 从计算结果提取 DOS
vaspkit -task 111  # TDOS
vaspkit -task 113  # PDOS

# 或使用 pymatgen
from pymatgen.io.vasp import Vasprun
vrun = Vasprun('vasprun.xml')
dos = vrun.tdos
```

### 6.5 键长与配位数分析

```python
from ase import Atom, Atoms
from ase.io import read
from ase.neighborlist import NeighborList

# 读取结构
atoms = read('CONTCAR')

# 计算 La 的配位数
cutoffs = [3.0] * len(atoms)  # 截断半径 3 Å
nl = NeighborList(cutoffs, self_interaction=False, bothways=True)
nl.update(atoms)

# 找到 La 原子
la_indices = [i for i, atom in enumerate(atoms) if atom.symbol == 'La']

for la_idx in la_indices:
    indices, offsets = nl.get_neighbors(la_idx)
    coordination = len(indices)
    print(f"La atom {la_idx}: CN = {coordination}")
    
    # 键长分析
    for neighbor_idx in indices:
        distance = atoms.get_distance(la_idx, neighbor_idx, mic=True)
        print(f"  - {atoms[neighbor_idx].symbol}: {distance:.3f} Å")
```

---

## 7. 低浓度（100 ppm）模拟策略

### 7.1 100 ppm 的物理意义

```
100 ppm La in Cu = 0.01 at%
= 1 La atom per 10,000 Cu atoms
```

### 7.2 模拟方法

**挑战**：直接模拟 10,000 原子超胞计算量太大。

**解决方案**：

1. **单个 La 原子效应**
   - 使用 200-400 原子超胞
   - 含 1 个 La 原子
   - 浓度约 0.25-0.5%（高于实际，但可研究单原子效应）

2. **周期性边界条件的处理**
   - 确保超胞足够大，使 La-La 镜像间距 > 15 Å
   - 避免周期性相互作用

3. **平均场近似**
   - 计算单个 La 原子的效应
   - 外推到 100 ppm 浓度

4. **远程应变效应**
   - La 原子引起局域应变
   - 应变场可能影响远距离的晶界行为

### 7.3 建议超胞大小

```
对于 100 ppm 效应研究：
- 最小超胞：~400 个 Cu 原子 + 1 个 La
- 实际浓度：~0.25%
- La-La 镜像距离：~20 Å

更精确的浓度模拟：
- 使用 4000 原子超胞 + 1 个 La
- 或 2000 原子 + 1 个 La
- 需要更大的计算资源
```

---

## 8. 数据汇总与讨论框架

### 8.1 数据记录表格

| 计算项目 | 能量（eV） | 形成能（eV） | 备注 |
|---------|-----------|-------------|-----|
| FCC Cu（单原子） | | - | 参考态 |
| HCP La（单原子） | | - | 参考态 |
| 完美 Cu 超胞 | | - | |
| Cu 单空位 | | E_vac | |
| Σ5 晶界 | | E_GB | |
| La 替代位 | | E_form_sub | |
| La 八面体间隙 | | E_form_oct | |
| La 四面体间隙 | | E_form_tet | |
| La 空位位 | | E_form_vac | |
| 纯 Cu 晶界迁移势垒 | | Q_m_pure | |
| 含 La 晶界迁移势垒 | | Q_m_La | |

### 8.2 机理解释框架

1. **La 位置确定**
   - 哪种位置的形成能最低？
   - 是否与实验未观察到 La 一致？

2. **晶界迁移机制**
   - La 如何提高迁移势垒？
   - 溶质拖曳 vs 钉扎效应？

3. **热稳定性解释**
   - 高温下 La 的稳定性
   - 与空位的相互作用

4. **浓度效应**
   - 单原子效应如何外推到 100 ppm？
   - 是否足以解释实验现象？

---

## 9. 计算脚本示例

### 9.1 批量提交脚本（SLURM）

```bash
#!/bin/bash
#SBATCH -J La_Cu_GB
#SBATCH -N 2
#SBATCH --ntasks-per-node=32
#SBATCH -p normal
#SBATCH -o vasp_%j.out
#SBATCH -e vasp_%j.err

module load intel/2021
module load vasp/6.4.3

# 设置环境
export VASP_PP_PATH=/path/to/potpaw

# 运行 VASP
mpirun vasp_std > vasp.out 2>&1

# 检查收敛
if grep -q "reached required accuracy" OUTCAR; then
    echo "Calculation converged successfully!"
else
    echo "Warning: Calculation may not have converged!"
fi
```

### 9.2 自动化工作流脚本（Python）

```python
#!/usr/bin/env python3
"""
La-Cu 晶界计算自动化工作流
"""

import os
import shutil
from pathlib import Path
import subprocess

class LaCuGBWorkflow:
    def __init__(self, working_dir):
        self.working_dir = Path(working_dir)
        self.vasp_exec = "vasp_std"
        
    def create_input_files(self, calculation_type, poscar_content):
        """创建 VASP 输入文件"""
        
        incar_params = {
            'opt': self._get_opt_incar(),
            'scf': self._get_scf_incar(),
            'neb': self._get_neb_incar(),
            'aimd': self._get_aimd_incar()
        }
        
        # 写入文件
        with open('INCAR', 'w') as f:
            f.write(incar_params[calculation_type])
        
        with open('POSCAR', 'w') as f:
            f.write(poscar_content)
            
        # KPOINTS, POTCAR...
        
    def run_calculation(self):
        """运行计算"""
        result = subprocess.run(
            ['mpirun', '-np', '32', self.vasp_exec],
            capture_output=True,
            text=True
        )
        return result.returncode == 0
    
    def extract_energy(self):
        """提取能量"""
        with open('OSZICAR', 'r') as f:
            lines = f.readlines()
            for line in reversed(lines):
                if 'F=' in line:
                    energy = float(line.split()[2])
                    return energy
        return None
    
    def _get_opt_incar(self):
        return """SYSTEM = La-Cu GB OPT
ISTART = 0
ENCUT = 450
PREC = Accurate
ALGO = Fast
EDIFF = 1E-6
IBRION = 2
ISIF = 2
NSW = 200
EDIFFG = -0.01
ISMEAR = 1
SIGMA = 0.2
"""

# 使用示例
workflow = LaCuGBWorkflow("./calculation")
```

---

## 10. 常见问题与解决方案

### 10.1 收敛问题

| 问题 | 可能原因 | 解决方案 |
|-----|---------|---------|
| 电子步不收敛 | 初始猜测差 | 增加 NELMIN，调整 MIXING |
| 离子步震荡 | 力计算不准 | 降低 POTIM，使用 IBRION=1 |
| NEB 不收敛 | 镜像数不足 | 增加 IMAGES，调整 SPRING |

### 10.2 赝势选择

- **Cu**：Cu_pv（更精确，含 3p）vs Cu（更快）
- **La**：标准 La 势即可

### 10.3 k 点测试

```bash
# 自动化 k 点收敛测试
for k in 3 4 5 6 7; do
    mkdir k_${k}x${k}
    cd k_${k}x${k}
    cat > KPOINTS << EOF
Automatic mesh
0
Gamma
$k $k 1
0 0 0
EOF
    cp ../INCAR ../POSCAR ../POTCAR .
    mpirun vasp_std > vasp.out
    grep "energy  without" OUTCAR | tail -1 >> ../kpoint_convergence.dat
    cd ..
done
```

---

## 11. 参考文献

1. VASP 官方手册：https://www.vasp.at/wiki/index.php/The_VASP_Manual
2. NEB 方法：G. Henkelman et al., J. Chem. Phys. 113, 9978 (2000)
3. 晶界理论：Sutton & Balluffi, "Interfaces in Crystalline Materials"
4. 溶质-晶界相互作用：M. P. Seah, J. Vac. Sci. Technol. 17, 16 (1980)
5. 稀土在铜中的行为：相关实验文献

---

## 12. 附录

### 12.1 常用命令速查

```bash
# 检查计算状态
tail -f OSZICAR
grep "F=" OSZICAR | tail -20

# 提取能量
grep "energy  without entropy" OUTCAR | tail -1

# 提取力
grep "TOTAL-FORCE" OUTCAR -A 300 | tail -n +2 | head -n 200

# 可视化结构
ase gui CONTCAR

# NEB 分析
nebefs.pl
nebbarrier.pl > barrier.dat
nebmovie.pl

# 使用 vaspkit
vaspkit -task 0  # 查看所有功能
```

### 12.2 建议计算时间估算

| 计算任务 | 原子数 | k点 | 核数 | 预估时间 |
|---------|-------|-----|-----|---------|
| 结构优化 | 200 | 3×3×1 | 32 | 2-4 小时 |
| SCF 计算 | 200 | 5×5×1 | 32 | 30 分钟 |
| NEB (7 images) | 200×7 | 3×3×1 | 64 | 12-24 小时 |
| AIMD (5 ps) | 200 | 1×1×1 | 32 | 24-48 小时 |

---

**文档版本**：1.0  
**适用 VASP 版本**：6.4.3  
**创建日期**：2026-02-12  
**作者**：AI Assistant
