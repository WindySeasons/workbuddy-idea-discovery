# Novelty Check Report: B-Spline Probe

## Proposed Method
B-Spline Probe: 用B样条事后拟合INR输出，通过分析残差空间分布、控制点振幅变化和局部曲率异常，诊断INR的局部失败模式（Gibbs现象、欠拟合区域）。

## Core Claims Analysis

### Claim 1: 用B样条拟合残差诊断INR失败（事后诊断框架）
- **Novelty**: HIGH
- **Closest prior work**: Yu et al., "Comparing INRs and B-Splines for Continuous Function Fitting" (arXiv 2602.20535, 2026) — 对比两者但未做诊断
- **Key difference**: Yu et al. 在公平条件下对比两种方法的误差性能，**不涉及用B样条作为诊断工具分析INR输出**。B-Spline Probe的核心创新是"事后诊断"——INR已训练完成，B样条仅用于分析其输出质量
- **Search evidence**: 3轮WebSearch（B-spline fitting residual NN diagnosis / spline fitting NN diagnostic quality assessment / 神经网络诊断残差分析）均未找到直接相关工作

### Claim 2: 残差空间分布定位不连续处Gibbs现象
- **Novelty**: HIGH
- **Closest prior work**: "Denoising graph neural network based on zero-shot learning for Gibbs phenomenon in high-order DG applications" (Chinese Journal of Aeronautics, 2024)
- **Key difference**: 该论文用GNN消除CFD中的Gibbs噪声，而B-Spline Probe用B样条残差**定位**INR的Gibbs现象，方法（B样条 vs GNN）、场景（INR vs CFD-DG）、目标（诊断定位 vs 去噪）完全不同
- **Search evidence**: WebSearch "Gibbs phenomenon detection localization neural network spectral wavelet spline" 唯一相关结果是GNN for CFD，无INR+样条+Gibbs的组合

### Claim 3: 控制点震荡指数 + 局部曲率异常作为诊断指标
- **Novelty**: HIGH
- **Closest prior work**: 无直接相关工作
- **Key difference**: 该指标利用B样条控制点的数学性质（局部支撑性、凸包性、变差减小性），这些性质在INR诊断领域的应用尚属空白
- **Search evidence**: WebSearch "control point oscillation B-spline neural network diagnostic" 无结果

## Closest Prior Work

| # | Paper | Year | Venue | Overlap Level | Key Difference | Confidence |
|---|-------|------|-------|--------------|----------------|-----------|
| 1 | Comparing INRs and B-Splines (Yu et al.) | 2026 | arXiv | Low (对比 vs 诊断) | 仅对比误差，未做诊断分析 | HIGH |
| 2 | Physics-Informed Deep B-Spline Networks (Wang et al.) | 2025 | ICLR | Low (PDE求解 vs INR诊断) | B-spline用于求解PDE，非诊断INR | HIGH |
| 3 | Gibbs Phenomenon Denoising via GNN | 2024 | CJA | Low (去噪 vs 诊断) | 用GNN去CFD噪声，非B样条分析INR | HIGH |
| 4 | F-INR: Tensor Decomposition for INR | 2026 | WACV | Low (加速 vs 诊断) | 张量分解用于加速训练，非诊断失败 | HIGH |
| 5 | Residual Analysis in Regression & ML | 2025 | JISEM | Low (通用残差 vs B样条残差) | 传统统计残差分析，非B样条拟合残差 | MEDIUM |

## Overall Novelty Assessment

- **Score**: 9/10
- **Recommendation**: ✅ PROCEED
- **Key differentiator**: 首次将B样条作为INR的**事后诊断工具**，利用样条数学性质（局部支撑、凸包、变差减小）提供空间可解释性
- **Biggest risk**: 审稿人可能认为"用B样条拟合残差"不够创新，需要强调指标设计的理论贡献和实验验证的全面性
- **Concurrent work risk**: LOW — Yu et al. (2026) 刚开始对比B样条与INR，诊断方向尚无人涉及
- **Positioning suggestion**: 定位为"Neural Representation Diagnosis"新方向的首个工作，强调**方法论贡献**（诊断框架+3个指标）+ **实证发现**（INR失败模式的系统分类）

## Search Queries Used
1. WebSearch: "B-spline fitting residual neural network output diagnosis failure localization 2024 2025" — 2026-05-17
2. WebSearch: "spline fitting neural network diagnostic residual analysis quality assessment 2024 2025" — 2026-05-17
3. WebSearch: "Gibbs phenomenon detection localization neural network spectral method wavelet spline 2024 2025" — 2026-05-17
4. WebFetch: Semantic Scholar API "spline fitting neural network diagnosis residual" — 2026-05-17 (429 rate limited)
5. WebFetch: ResearchGate "Comprehensive Framework Residual Analysis Regression ML" — 2026-05-17 (access denied)
6. WebFetch: ScienceDirect "Gibbs phenomenon GNN DG applications" — 2026-05-17 (confirmed no spline overlap)
