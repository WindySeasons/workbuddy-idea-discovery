# FINAL_PROPOSAL: B-Spline Probe

## B-Spline Probe: 用B样条残差诊断隐式神经表示的局部失败模式

---

### 问题

INR（隐式神经表示）在训练完成后缺乏系统的诊断工具。用户只能通过全局指标（PSNR/SSIM）判断质量，无法定位具体失败区域或理解失败原因。

### 方法论声明

用B样条事后拟合INR输出，通过3个理论驱动的诊断指标（REC, CPOI, LCA）实现可解释的局部失败定位和原因分类，并与域操控理论建立理论联系。

### 核心贡献

1. **B-Spline Probe诊断框架**：首个利用B样条数学性质（局部支撑性、凸包性、变差减小性）诊断INR失败的方法
2. **3个理论推导的指标**：残差能量集中度(REC)、控制点震荡指数(CPOI)、局部曲率异常度(LCA)
3. **INR失败模式分类**：基于指标组合的4类失败模式分类（Gibbs/欠拟合/频率冗余/正常）

### Pipeline

```
INR输出 → B样条拟合(自适应节点) → 3指标计算 → 失败分类 → 诊断热力图
                                                              ↓
                                                     修复策略建议
                                                              ↓
                                                     修复验证(PSNR↑)
```

### 诊断指标

| 指标 | 定义 | 检测目标 | 理论依据 |
|------|------|---------|---------|
| REC | 空间窗口内残差能量占比 | 任意局部异常 | Gibbs理论 |
| CPOI | 控制点符号交替频率 | Gibbs/不连续 | de Boor逼近理论 |
| LCA | 二阶导数局部峰值/中位数 | 过冲/欠冲 | Trefethen 2000 |

### 实验计划

| 实验 | 数据 | 对比 | 关键指标 |
|------|------|------|---------|
| 合成信号验证 | 1D方波/锯齿波 | — | ROC AUC |
| 定位精度对比 | Kodak24 | 小波/梯度 | IoU |
| 诊断→修复验证 | 2D图像 | 随机修复 | ΔPSNR |
| 跨架构通用 | SIREN vs WIRE | — | 诊断一致性 |

### 计算需求

- 分析部分：无需GPU
- 修复验证：1 GPU × 8h
- 总计：~20天

### 文件

- `idea-stage/LITERATURE_SURVEY.md` — 文献综述
- `idea-stage/IDEA_REPORT.md` — 想法排名
- `idea-stage/NOVELTY_CHECK_B-SPLINE_PROBE.md` — 新颖性验证 (9/10)
- `idea-stage/REVIEW_B-SPLINE_PROBE.md` — 外部评审 (7/10)
- `refine-logs/round-0-initial-proposal.md` — 初始方案
- `refine-logs/round-1-review.md` — R1自评审
- `refine-logs/round-1-refinement.md` — R1修订
- `refine-logs/round-2-review.md` — R2再评估
