# Round 1 Refinement: B-Spline Probe (Revised)

## Problem Anchor (VERBATIM CARRY-FORWARD)

- **Bottom-line problem**: INR在训练完成后缺乏系统的诊断工具来解释其在何处、为何失败（Gibbs现象、欠拟合、频率冗余）。
- **Must-solve bottleneck**: 当前INR用户只能通过全局指标（PSNR/SSIM）判断质量，无法定位具体失败区域或理解失败原因。
- **Non-goals**: 不改进INR架构本身；不做端到端训练改进。
- **Constraints**: 单GPU；2个月；目标ICML/NeurIPS workshop。
- **Success condition**: B-Spline Probe定位精度优于或可比于小波变换和梯度分析，同时提供可解释诊断信息。

### Anchor Check ✅
修订后的方案仍直接攻击原始瓶颈。未发生漂移。

### Simplicity Check ✅
- Dominant contribution不变：诊断框架 + 3个指标
- Baseline从3个减为2个（小波 + 梯度），与FM-SIREN的联系为理论补充而非新贡献
- C3简化为诊断→策略选择→验证

---

## Method Thesis (Updated)

**用B样条事后拟合INR输出，通过3个理论推导的指标（REC, CPOI, LCA）实现可解释的局部失败定位，并与Luo (2025) 的域操控理论建立联系以增强理论深度。**

---

## Proposed Method (Updated)

### 修改点

1. **B样条参数自适应选择**: 基于INR输出的局部频率估计自适应选择节点间距（高频区域密节点、低频区域疏节点），利用FM-SIRER的奈奎斯特思想

2. **与域操控理论的联系**: Luo (2025) 证明hash grid通过"域操控"（创建线性段的倍增）增强表达能力。B-Spline Probe可以验证：当INR的域操控不足（段数不够）时，CPOI升高——这为hash grid和B样条建立了理论桥梁

3. **Baseline减为2个**:
   - 小波变换 (Daubechies-4) 用于Gibbs检测
   - INR输出梯度分析（直接检测梯度不连续）

4. **C3简化**: 诊断→手动选择3种修复策略之一（增加采样、切换激活函数、增加网络深度）→ 验证改善 vs 无诊断的随机修复

### 3个指标定义不变（REC, CPOI, LCA），增加参数选择讨论

---

## Updated Validation

| 声明 | 最小实验 | 决定性指标 |
|------|---------|-----------|
| C1: REC定位Gibbs | 合成信号 (1D方波/锯齿波) | ROC曲线 |
| C2: B样条≥小波/梯度 | Kodak24 | 定位IoU |
| C3: 诊断指导修复 | 诊断→策略→验证 vs 随机修复 | PSNR改善Δ |
| C4: 跨架构通用 | SIREN vs WIRE | 诊断一致性 |
| C5 (NEW): 与域操控理论一致 | 分析CPOI与段数的关系 | 相关系数 |
