# Idea Discovery Report

**Direction**: B样条与INR结合的可解释诊断方法
**Date**: 2026-05-17
**Pipeline**: research-lit → idea-creator → novelty-check → research-review → research-refine-pipeline

---

## Executive Summary

通过完整的idea-discovery流水线，从文献调研中识别出4个结构缺口，生成10个候选想法，经过过滤和验证，最终推荐 **B-Spline Probe**（用B样条拟合残差诊断INR局部失败模式）作为首要研究方向。新颖性验证 9/10，外部评审 7/10 (Weak Accept)，方法精化后评分 8.2/10。完整的实验计划已制定（14个运行，4个里程碑，20天，1 GPU）。

---

## Literature Landscape

- **10篇论文**分析完成（5高相关 + 5中相关）
- **核心发现**：INR社区缺乏系统的诊断工具；B样条与INR的直接对比刚起步（Yu et al. 2026）；样条-NN融合已有PDE求解应用（ICLR 2025）但无INR诊断应用；张量分解与INR结合已用于加速（F-INR, WACV 2026）但未用于诊断
- **详细综述**: `idea-stage/LITERATURE_SURVEY.md`

---

## Ranked Ideas

### 🏆 Idea 1: B-Spline Probe — 用B样条残差诊断INR局部失败模式 — RECOMMENDED

- **Hypothesis**: INR的失败会在B样条拟合残差中呈现系统性模式
- **Minimum experiment**: 合成信号 + Kodak24，对比小波和梯度分析
- **Novelty**: CONFIRMED (9/10) — 无现有工作用B样条诊断INR
  - Closest: Yu et al. (2026) 对比但未诊断
  - Differentiation: 事后诊断框架 + 3个理论指标
- **Reviewer score**: 7/10 (Weak Accept)
  - R1: 6/10 (Borderline) → R2: 7.25/10 (Weak Accept)
  - 关键改进：理论推导 + baseline对比 + 修复闭环
- **Refine score**: 8.2/10 (after 2 rounds)
- **Next step**: 实现原型 → R001-R003 sanity check → 见 `refine-logs/EXPERIMENT_PLAN.md`

### Idea 2: Slice-Tucker Inspector — 张量分解诊断INR秩不足 — BACKUP
- **Novelty**: 8/10
- **Feasibility**: MEDIUM
- **Why backup**: 需要跟踪训练过程，实现复杂度更高

### Idea 3: SplineGrid — 样条理论指导的可解释网格编码 — WORTH EXPLORING
- **Novelty**: 7/10
- **Feasibility**: MEDIUM
- **Why third**: 需修改Instant-NGP代码，数学推导量大

---

## Eliminated Ideas

| # | Idea | Reason eliminated |
|---|------|-------------------|
| 4 | B-spline激活函数 | FINER/SL2A-INR已覆盖 |
| 5 | Chebfun直接求NTK | 高维不可行 |
| 6 | B-spline解码器(串行) | ICLR 2025已实现 |
| 7 | INR样条压缩 | F-INR已有方案 |
| 8 | Gibbs样条修复 | WIRE/FR-INR已处理 |
| 9 | 样条+网格编码混合 | 合并入Idea 3 |
| 10 | NTK特征值与节点分布 | 过于理论化 |

---

## Refined Proposal

- **Proposal**: `refine-logs/FINAL_PROPOSAL.md`
- **Experiment plan**: `refine-logs/EXPERIMENT_PLAN.md`
- **Tracker**: `refine-logs/EXPERIMENT_TRACKER.md`
- **Score history**: 2 rounds, 7.6 → 8.2/10

---

## Pipeline Test Report

| Phase | Skill | Status | Output | Time |
|-------|-------|--------|--------|------|
| Phase 0 | 环境准备 | ✅ | idea-stage/, refine-logs/ | <1min |
| Phase 1 | research-lit | ✅ | LITERATURE_SURVEY.md | ~15min |
| Phase 2 | idea-creator | ✅ | IDEA_REPORT.md | ~10min |
| Phase 3 | novelty-check | ✅ | NOVELTY_CHECK_B-SPLINE_PROBE.md | ~10min |
| Phase 4 | research-review | ✅ | REVIEW_B-SPLINE_PROBE.md | ~8min |
| Phase 4.5 | research-refine | ✅ | FINAL_PROPOSAL.md | ~10min |
| Phase 4.5 | experiment-plan | ✅ | EXPERIMENT_PLAN.md + TRACKER | ~8min |
| Phase 5 | 最终报告 | ✅ | IDEA_REPORT.md (本文件) | ~3min |

**Total**: ~65 min (无GPU, 纯CPU分析)

**Bugs found**: None

**Notes**:
- arXiv API rate limited during Phase 1，用WebSearch替代成功绕过
- Semantic Scholar API also rate limited，但不影响结果
- Pilot experiments skipped due to no GPU available

---

## Next Steps

- [ ] 实现 R001-R003 sanity check (Day 1-2)
- [ ] 训练 Kodak24 INR (R006, Day 3-5)
- [ ] 运行 B1-B4 核心实验 (Day 6-15)
- [ ] 论文撰写 (Day 16-20)
- [ ] 或调用 `/experiment-plan` 获取更详细的执行指导
