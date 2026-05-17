# Round 0: Initial Proposal — B-Spline Probe

## Problem Anchor (IMMUTABLE)

- **Bottom-line problem**: INR在训练完成后缺乏系统的诊断工具来解释其在何处、为何失败（Gibbs现象、欠拟合、频率冗余）。
- **Must-solve bottleneck**: 当前INR用户只能通过全局指标（PSNR/SSIM）判断质量，无法定位具体失败区域或理解失败原因。"知其败而不知其所以败"。
- **Non-goals**: 不改进INR架构本身（如新激活函数、新编码方式）；不做端到端的训练改进。
- **Constraints**: 计算资源有限（单GPU）；时间窗口约2个月；目标venue为ICML/NeurIPS workshop或主流会议。
- **Success condition**: B-Spline Probe能在INR输出上定位失败区域，且定位精度优于或可比于小波变换和梯度分析，同时提供B样条控制点层面的可解释诊断信息。

---

## Technical Gap

1. **Current pipeline failure point**: INR训练完成后，用户只能看到全局误差指标，无法：
   - 定位哪些空间区域质量差
   - 理解失败是Gibbs现象、欠拟合还是其他原因
   - 根据诊断结果指导下一步改进

2. **Why naive fixes are insufficient**:
   - PSNR/SSIM是全局指标，无法定位局部问题
   - 逐像素误差图噪声太大，缺乏结构化解释
   - NTK分析理论深刻但计算成本极高（$O(n^2)$ 复杂度）

3. **Smallest adequate intervention**: 事后B样条拟合——一个不修改INR、不需要GPU的分析工具

4. **Core technical claim**: B样条的局部支撑性和凸包性使其天然适合INR输出的空间诊断，且其控制点行为提供频率域的诊断信息

5. **Required evidence**:
   - 在合成信号上验证指标与已知失败模式的对应关系
   - 在真实图像上验证定位精度
   - 与baseline方法对比
   - 诊断→修复闭环验证实用性

---

## Method Thesis

**用B样条事后拟合INR输出，通过3个理论驱动的诊断指标实现可解释的局部失败定位和原因分类。**

---

## Contribution Focus

1. **Dominant contribution**: B-Spline Probe诊断框架 + 3个理论推导的指标（REC, CPOI, LCA）
2. **Supporting contribution**: INR失败模式的系统分类（基于3个指标的模式识别）

---

## Proposed Method

### Pipeline

```
INR训练完成 → 采样INR输出 → B样条拟合 → 计算3个指标 → 空间热力图 + 失败分类
                                              ↓
                                        诊断报告
                                              ↓
                                    修复建议 → 验证改善
```

### Step 1: B样条拟合

给定INR输出 $f_{INR}: \mathbb{R}^d \to \mathbb{R}$（对每个通道独立处理），用B样条拟合：

$$\hat{f}(x) = \sum_i c_i \cdot B_i(x)$$

其中 $c_i$ 是控制点，$B_i(x)$ 是B样条基函数。拟合通过最小二乘完成，阶数默认为cubic ($k=3$)。

### Step 2: 诊断指标计算

**指标1: 残差能量集中度 (REC, Residual Energy Concentration)**

$$REC(x, r) = \frac{\sum_{y \in B(x,r)} |f_{INR}(y) - \hat{f}(y)|^2}{\sum_y |f_{INR}(y) - \hat{f}(y)|^2}$$

- $B(x,r)$ 是以 $x$ 为中心、$r$ 为半径的空间窗口
- **理论依据**: Gibbs现象的残差能量在跳跃点附近约占总能量的 $\mathcal{O}(\log N)$ 倍集中（经典Gibbs理论，Jiang & Zhou 2022）
- 高REC → 该区域存在INR拟合异常

**指标2: 控制点震荡指数 (CPOI, Control Point Oscillation Index)**

$$CPOI = \frac{1}{n-1} \sum_{i=1}^{n-1} \mathbf{1}[sign(c_{i+1} - c_i) \neq sign(c_i - c_{i-1})]$$

- 统计控制点值符号交替的频率
- **理论依据**: 不连续函数的B样条逼近在跳跃点附近控制点必然高频震荡（de Boor 2001, Theorem 12.3）
- 高CPOI → 该区域存在不连续性/Gibbs现象

**指标3: 局部曲率异常度 (LCA, Local Curvature Anomaly)**

$$LCA(x) = \frac{|\hat{f}''(x)|}{\text{median}(|\hat{f}''|)}$$

- B样条二阶导数的局部极大值与全局中位数之比
- **理论依据**: Gibbs过冲在曲率上表现为尖峰（Gibbs现象的数学描述，Trefethen 2000）
- 高LCA → 该区域存在过冲/欠冲

### Step 3: 失败分类

基于3个指标的模式组合：
| REC | CPOI | LCA | 诊断结果 |
|-----|------|-----|---------|
| 高  | 高   | 高  | Gibbs现象（不连续处） |
| 高  | 低   | 高  | 欠拟合（表达能力不足） |
| 高  | 低   | 低  | 频率冗余（高频区域被过度拟合） |
| 低  | 低   | 低  | 正常区域 |

---

## Claim-Driven Validation Sketch

| 核心声明 | 最小实验 | 决定性指标 |
|---------|---------|-----------|
| C1: REC能定位Gibbs现象 | 合成1D方波/锯齿波 + SIREN | 检测率 vs 虚警率 |
| C2: B样条优于小波/梯度分析 | 2D图像 (Kodak24) | 定位精度 (IoU) |
| C3: 诊断结果能指导改进 | 诊断→增加采样→重训练 | PSNR改善幅度 |
| C4: 跨INR架构通用 | SIREN vs WIRE vs FINER | 诊断一致性 |

---

## Compute & Timeline Estimate

| 阶段 | 时间 | GPU需求 |
|------|------|---------|
| 指标实现 + 合成信号验证 | 3天 | 无 |
| 2D图像实验 + Baseline对比 | 5天 | 无 |
| 诊断→修复闭环实验 | 4天 | 1 GPU, 8h |
| 多架构对比 + 可视化 | 3天 | 无 |
| 论文撰写 | 5天 | 无 |
| **总计** | **~20天** | **1 GPU** |
