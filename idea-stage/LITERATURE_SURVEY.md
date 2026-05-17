# Literature Survey: B样条与INR结合的可解释诊断方法

**Date**: 2026-05-17
**Sources**: Local PDFs (0，无相关论文), arXiv/Web (10 papers analyzed)

---

## Landscape Overview

B样条与INR（隐式神经表示）的交叉领域目前正处于快速发展期。核心矛盾在于：**B样条具有可解释性强、局部控制性好、数学基础扎实的优势，但表达能力受限于基函数的选择；INR通过坐标网络隐式学习基函数，表达能力强但黑箱且缺乏可解释性。**

当前研究主要沿三个方向展开：
1. **直接比较**（Yu et al., 2026）：首次在公平条件下对比B样条与INR，发现INR在oracle超参下误差更低、边缘更锐利
2. **样条神经网络融合**（Wang et al., ICLR 2025）：用NN学习B样条控制点，兼具PDE求解的可解释性与NN的灵活性
3. **INR结构创新**（F-INR, WACV 2026; FM-SIREN/FINER, 2025）：通过张量分解、奈奎斯特频率分配等方式提升INR的表达能力与诊断性

**关键缺口**：目前没有工作系统地实现"用B样条的数学可解释性来诊断INR的训练问题"，也没有工作提出"样条-网格编码融合"的统一框架。

---

## Papers Analyzed

### Directly Related (High Relevance)

| # | Title | Venue/Year | Core Contribution | Relevance |
|---|-------|-------------|-------------------|-----------|
| 1 | Comparing Implicit Neural Representations and B-Splines for Continuous Function Fitting from Sparse Samples | arXiv 2602.20535, 2026 | 首次公平对比positional-encoded INR vs cubic B-spline，INR在oracle选择下NRMSD更低 | **HIGH** — 直接对比，证明INR优于B-spline但缺乏深入分析 |
| 2 | Physics-Informed Deep B-Spline Networks | ICLR 2025 (Wang et al.) | 用NN学习B-spline控制点求解PDE，直接指定ICBCs，万能逼近定理保证 | **HIGH** — B-spline与NN融合的SOTA，但限于PDE求解 |
| 3 | F-INR: Functional Tensor Decomposition for Implicit Neural Representations | WACV 2026 | 用CP/TT/Tucker分解将高维INR分解为轴特定子网络，训练20×加速 | **HIGH** — 张量分解与INR融合，与你的张量分解背景高度匹配 |
| 4 | FM-SIREN & FM-FINER: Nyquist-Informed Frequency Multiplier for INR | arXiv 2509.23438, 2025 | 基于奈奎斯特定理分配神经元特定频率乘子，减少50%特征冗余 | **HIGH** — 频率冗余诊断的新方法，可解释频率分配 |
| 5 | A New Perspective: Domain Manipulation for Multi-resolution Hash Encoding | arXiv 2505.03042, 2025 | 提出"域操控"视角解释hash grid工作原理，揭示线性段倍增机制 | **HIGH** — 为网格编码提供首个原理性解释，诊断价值极高 |

### Tangentially Related (Medium Relevance)

| # | Title | Venue/Year | Core Contribution | Relevance |
|---|-------|-------------|-------------------|-----------|
| 6 | I-INR: Iterative Implicit Neural Representations | AAAI 2026 | 即插即用迭代精化框架，+2.0 PSNR，仅增0.5-2%参数 | MEDIUM — 迭代精化思路，可用于诊断循环 |
| 7 | FINER: Flexible Spectral-bias Tuning in INR by Variable-periodic Activation | CVPR 2024 | 可变周期激活函数调谐谱偏差，支持频率集动态调整 | MEDIUM — 谱偏差控制的基础工作 |
| 8 | Introducing B-spline Basis Functions in Neural Network Approximations | Springer LNCS, 2025 | 将B-spline基函数引入NN近似，系数由NN预测 | MEDIUM — B-spline+NN的具体融合方案 |
| 9 | Adaptive Multi-resolution Hash-encoding Framework for INR-based CBCT | Medical Physics, 2025 | 自适应多分辨率hash编码用于牙科CBCT重建 | MEDIUM — INR在医学影像诊断中的应用 |
| 10 | SL2A-INR: Single-Layer Learnable Activation for INR | ICCV 2025 | 单层可学习激活函数用于INR | MEDIUM — 激活函数可学习的最新进展 |

---

## Structural Gaps & Open Problems

### Gap 1: 缺乏B样条诊断INR的系统性框架 ⭐⭐⭐
**现状**: Yu et al. (2026) 证明了INR优于B-spline，但未解释*为什么*、*何时*B-spline会失败。没有工作利用B样条的分析性质（局部支撑性、凸包性、变差减小性）来诊断INR的失败模式。
**谁承认了这个问题**: Yu et al. 明确指出这是"preliminary study"，需要更深入分析；FM-SIREN指出INR的频率冗余问题但仅从神经网络角度解决。

### Gap 2: 样条基函数与INR网格编码的统一理论缺失 ⭐⭐⭐
**现状**: 网格编码（hash grid/multi-resolution grid）本质上是可学习样条的离散近似，但无人将二者在数学上统一。Luo (2025) 的"域操控"视角开始触及这个问题，但仅限于hash grid。
**谁承认了这个问题**: Luo 明确指出"hyperparameters could only be tuned empirically without much heuristics"——缺乏原理性指导。

### Gap 3: 张量分解在INR诊断中的应用空白 ⭐⭐
**现状**: F-INR (WACV 2026) 用张量分解加速训练，但仅用于"压缩"。你的导师背景（Chebfun3, Slice-Tucker, ACA）暗示张量分解可用于*诊断*INR的秩不足、频率耦合等问题。
**谁承认了这个问题**: F-INR 作者提到"fine-grained control over speed-accuracy trade-off via tensor rank"，暗示秩与表达能力的关联，但未深入诊断。

### Gap 4: INR的谱偏差缺乏实时诊断工具 ⭐⭐
**现状**: NTK分析可以解释谱偏差，但计算NTK特征值的成本极高。FM-SIREN/FINER通过架构改进缓解问题，但不提供"诊断→修复"的闭环。缺乏轻量级诊断工具。
**相关承认**: FM-SIREN 指出"hidden feature redundancy"是核心问题，但未提供诊断方法。

---

## Promising Directions

Based on the literature, the most promising research directions are:

1. **B样条解码器作为INR的诊断工具** (Novelty: HIGH, Feasibility: HIGH)
   - 用B样条拟合INR的输出，通过分析拟合残差的空间分布诊断INR的局部失败
   - 利用B样条的凸包性和局部支撑性解释INR在不连续处的Gibbs现象
   - 证据: Yu et al. 证明两者可直接对比; domain manipulation理论提供了分析基础

2. **样条-网格编码统一框架** (Novelty: HIGH, Feasibility: MEDIUM)
   - 将多分辨率B样条与hash grid在数学上统一，提出可解释的网格编码方案
   - 利用样条理论指导网格编码的超参选择（层级数、分辨率、hash冲突处理）
   - 证据: Luo (2025) 的域操控理论提供了起点; Wang et al. (ICLR 2025) 证明了B样条控制点可被NN学习

3. **张量分解诊断INR秩不足** (Novelty: HIGH, Feasibility: MEDIUM)
   - 对INR权重/激活进行Slice-Tucker分解，通过秩分析诊断频率耦合和表达能力瓶颈
   - 结合F-INR的框架，将分解不仅用于加速，更用于诊断
   - 证据: F-INR已证明张量分解与INR兼容; Chebfun3证明了Slice-Tucker对高维函数分析的有效性

---

## Local Papers (Already Have)

本地 `papers/` 目录包含 RISC-V 架构相关论文，与本研究方向无关。
