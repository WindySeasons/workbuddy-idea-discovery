# EXPERIMENT_PLAN: B-Spline Probe

## Claim Map

| Claim | Description | Evidence Needed | Linked Blocks |
|-------|------------|----------------|---------------|
| **C1 (Primary)** | 3个B样条诊断指标（REC, CPOI, LCA）能有效定位INR的局部失败 | 合成信号ROC + 真实图像定位热力图 | B1, B2 |
| **C2 (Primary)** | B样条诊断的定位精度≥小波变换和梯度分析 | Kodak24上的IoU对比 | B2 |
| **C3 (Supporting)** | 诊断结果能指导INR改进（诊断→修复→验证） | PSNR改善 vs 随机修复对照 | B3 |
| **Anti-claim** | "B样条只是换个方式计算残差，没有额外价值" | 指标互补性分析 + 小波对比 | B2 |

---

## Paper Storyline

### Main Paper (必须运行)
| Block | 位置 | 对应声明 |
|-------|------|---------|
| B1: 合成信号验证 | Section 4.1 (Figure 2-3) | C1 |
| B2: 定位精度对比 | Section 4.2 (Table 1, Figure 4-5) | C2, Anti-claim |
| B3: 诊断→修复闭环 | Section 4.3 (Table 2, Figure 6) | C3 |
| B4: 跨架构通用性 | Section 4.4 (Table 3) | C1 (泛化) |

### Appendix (非阻塞)
| Block | 位置 | 对应声明 |
|-------|------|---------|
| B5: 指标互补性分析 | Appendix A | Anti-claim |
| B6: 超参敏感性 | Appendix B | C1 |

### Cut (不运行)
| Block | 原因 |
|-------|------|
| 3D场景验证 | 时间不足，可作为future work |
| 与NTK分析对比 | NTK计算成本过高，作为related work讨论 |

---

## Experiment Blocks (详细规格)

### Block 1: 合成信号验证 (B1)
- **Claim tested**: C1 — REC/CPOI/LCA能检测已知失败模式
- **Dataset**: 1D合成信号 (方波、锯齿波、阶跃函数、频率渐变信号)
- **Systems**: SIREN (3层, 256宽, ω₀=30)
- **Metrics**: ROC AUC, Precision@Recall=0.8, F1
- **Ground truth**: 已知的不连续点位置和类型
- **Setup**:
  - 100个随机频率/相位的合成信号
  - B样条阶数k=3, 节点数自适应选择
  - 阈值扫描确定最优REC/CPOI/LCA阈值
- **Success criterion**: ROC AUC > 0.9
- **Failure interpretation**: 若AUC < 0.7，指标设计需要重新考虑
- **Figure target**: Figure 2 (信号+残差热力图), Figure 3 (ROC曲线)

### Block 2: 定位精度对比 (B2)
- **Claim tested**: C2 — B样条≥小波/梯度; Anti-claim
- **Dataset**: Kodak24 (24张512×512图像)
- **Systems**:
  - Ours: B-Spline Probe (REC + CPOI + LCA)
  - Baseline 1: Daubechies-4 小波变换 (检测小波系数异常)
  - Baseline 2: 梯度幅值分析 (检测INR输出梯度不连续)
- **INR backbone**: SIREN (4层, 256宽, ω₀=30) + WIRE (4层, 256宽)
- **Metrics**: 定位IoU (with PSNR<25dB as ground-truth failure mask)
- **Setup**:
  - 对每张图像训练SIREN和WIRE (500 epochs, Adam, lr=1e-4)
  - 3 seeds
  - B样条: k=3, 节点间距=8 pixels
  - 小波: db4, 3级分解
- **Success criterion**: B-Spline IoU ≥ 小波IoU + 0.05
- **Failure interpretation**: 若B样条不优于小波，讨论各自适用场景
- **Table target**: Table 1 (IoU对比), Figure 4-5 (可视化对比)

### Block 3: 诊断→修复闭环 (B3)
- **Claim tested**: C3 — 诊断指导的修复优于随机修复
- **Dataset**: Kodak24 中的 6 张图像 (PSNR < 28dB 的困难图像)
- **Repair strategies** (基于诊断结果选择):
  - Strategy A: 在REC高区域增加采样密度 (2×)
  - Strategy B: 在CPOI高区域使用WIRE替代SIREN
  - Strategy C: 在LCA高区域增加网络深度 (+2层)
- **Control**: 随机选择修复策略 (不使用诊断)
- **Metrics**: ΔPSNR (修复后 - 修复前), ΔSSIM
- **Setup**:
  - 原始INR: SIREN (4层, 256宽)
  - 修复后INR: 按策略修改后重新训练 (500 epochs)
  - 3 seeds
- **Success criterion**: 诊断指导的修复 ΔPSNR > 随机修复 ΔPSNR + 0.5dB
- **Failure interpretation**: 若无显著差异，讨论诊断的局限性
- **Table target**: Table 2 (修复效果对比), Figure 6 (修复前后可视化)

### Block 4: 跨架构通用性 (B4)
- **Claim tested**: C1 泛化性
- **Dataset**: Kodak24 (same as B2)
- **INR architectures**: SIREN, WIRE, FINER (各训练500 epochs)
- **Metrics**: 诊断一致性 (各架构在同一图像上的失败区域是否重叠)
- **Setup**: 复用B2训练数据
- **Success criterion**: Jaccard index > 0.6 between SIREN and WIRE diagnosis
- **Table target**: Table 3

---

## Run Order and Milestones

### M0: Sanity (Day 1-2)
| Run ID | Purpose | Priority | GPU? |
|--------|---------|----------|------|
| R001 | B样条拟合scipy验证 (已知信号) | MUST | No |
| R002 | REC/CPOI/LCA指标计算验证 | MUST | No |
| R003 | 可视化pipeline端到端 | MUST | No |
| **Gate**: 指标计算正确，可视化合理 | | |

### M1: Baseline (Day 3-5)
| Run ID | Purpose | Priority | GPU? |
|--------|---------|----------|------|
| R004 | 小波变换Gibbs检测实现 | MUST | No |
| R005 | 梯度分析实现 | MUST | No |
| R006 | Kodak24 INR训练 (SIREN+WIRE) | MUST | 1 GPU × 12h |
| **Gate**: Baseline方法可运行，INR训练收敛 | | |

### M2: Main Method (Day 6-10)
| Run ID | Purpose | Priority | GPU? |
|--------|---------|----------|------|
| R007 | B1: 合成信号实验 (100 signals) | MUST | No |
| R008 | B2: Kodak24定位对比 | MUST | No |
| R009 | B4: 跨架构通用性 | MUST | No |
| **Gate**: C1和C2验证通过 (ROC AUC > 0.9, IoU优势显著) | | |

### M3: Decision (Day 11-15)
| Run ID | Purpose | Priority | GPU? |
|--------|---------|----------|------|
| R010 | B3: 诊断→修复闭环 (6 images) | MUST | 1 GPU × 8h |
| R011 | 指标互补性分析 (Appendix) | NICE | No |
| **Gate**: C3验证通过 (诊断修复 > 随机修复 +0.5dB) | | |

### M4: Polish (Day 16-20)
| Run ID | Purpose | Priority | GPU? |
|--------|---------|----------|------|
| R012 | 可视化图表制作 | MUST | No |
| R013 | 超参敏感性分析 (Appendix) | NICE | No |
| R014 | 论文撰写 | MUST | No |

---

## Compute & Data Budget

| Item | Estimate |
|------|----------|
| GPU time | 1 GPU × 20h |
| Storage | ~5 GB (Kodak24 + checkpoints) |
| Data | Kodak24 (公开), 合成信号 (生成) |
| Dependencies | scipy, numpy, pytorch, matplotlib |

---

## Risks & Mitigations

| Risk | Probability | Impact | Mitigation |
|------|------------|--------|-----------|
| B样条指标区分度不够 | Medium | High | 增加自适应阈值 + 组合指标 |
| INR训练不收敛 | Low | High | 使用已验证的SIREN/WIRE超参 |
| 小波baseline过强 | Medium | Medium | 强调B样条的可解释性优势 |
| 修复闭环因果不显著 | Medium | Medium | 增加样本量 + 改用配对检验 |

---

## Final Checklist

- [ ] B1: 合成信号 ROC AUC > 0.9
- [ ] B2: B样条 IoU > 小波 IoU + 0.05
- [ ] B3: 诊断修复 ΔPSNR > 随机修复 ΔPSNR + 0.5dB
- [ ] B4: 跨架构诊断 Jaccard > 0.6
- [ ] Table 1: 定位精度对比
- [ ] Table 2: 修复效果对比
- [ ] Table 3: 跨架构一致性
- [ ] Figure 2-3: 合成信号 + ROC
- [ ] Figure 4-5: 可视化对比
- [ ] Figure 6: 修复前后
- [ ] Appendix: 指标互补性 + 超参敏感性
