---
name: idea-discovery
description: "科研 idea 全流程发现套件。从研究方向出发，自动完成文献调研→思路生成→新颖性验证→模拟审稿→方案打磨→实验规划。触发词：找idea、idea discovery、科研方向探索、文献调研、brainstorm research ideas、找idea全流程。输入一个研究方向，输出完整的研究方案+实验计划。"
argument-hint: [研究方向]
allowed-tools: Bash, Read, Write, Edit, Grep, Glob, WebSearch, WebFetch, TaskCreate, TaskUpdate, Skill
version: "2.0.0"
---

# Idea Discovery Pipeline（科研思路发现流水线）

研究方向：**$ARGUMENTS**

## 概览

这是一个**一体化的科研思路发现套件**，将 6 个阶段整合在一个 skill 中，一键运行完整流水线：

```
Phase 1: 文献调研 (research-lit)
    ↓
Phase 2: 思路生成 (idea-creator)
    ↓
Phase 3: 新颖性验证 (novelty-check)
    ↓
Phase 4: 模拟审稿 (research-review)
    ↓
Phase 5: 方案打磨 (research-refine)
    ↓
Phase 6: 实验规划 (experiment-plan)
```

每个阶段的详细指令在 `phases/` 子目录中，本文件为编排层。

## 全局常量

- **PILOT_MAX_HOURS = 2** — 单个 pilot 实验最大 GPU 时长
- **PILOT_TIMEOUT_HOURS = 3** — 硬超时
- **MAX_PILOT_IDEAS = 3** — 最多 pilot 测试的 idea 数
- **MAX_TOTAL_GPU_HOURS = 8** — 全部 pilot 总 GPU 预算
- **AUTO_PROCEED = true** — 用户未响应时自动继续
- **OUTPUT_DIR = `idea-stage/`** — Phase 1-4 输出目录
- **REFINE_DIR = `refine-logs/`** — Phase 5-6 输出目录
- **ARXIV_DOWNLOAD = false** — 是否下载 arXiv PDF
- **COMPACT = false** — 生成精简版候选报告
- **REF_PAPER = false** — 参考论文（PDF路径/arXiv URL）
- **REVIEWER_MODEL = built-in** — 使用 WorkBuddy 配置的模型
- **SEARCH_YEAR_RANGE = 2023-2026** — 文献搜索年份范围

> 覆盖常量：`/idea-discovery "方向" --compact: true --arxiv-download --ref-paper: https://arxiv.org/abs/XXXX`

---

## 流水线

### Phase 0: 加载研究简报（可选）

1. 检查 `RESEARCH_BRIEF.md`，提取问题、约束、已有结果
2. 如有参考论文（REF_PAPER），摘要写入 `idea-stage/REF_PAPER_SUMMARY.md`
3. 展示简报摘要，用 AskUserQuestion 确认

---

### Phase 1: 文献调研

**读取详细指令**：用 Read 工具读取 `phases/phase1-research-lit.md`，按其中的 Workflow 执行。

核心流程：
1. 扫描本地论文库（papers/、literature/）
2. arXiv + WebSearch 外部检索
3. 逐篇分析（问题/方法/结果/关联度）
4. 综合分析：按主题分组 → 识别结构缺口 → 构建全景图
5. 输出 `idea-stage/LITERATURE_SURVEY.md`

**检查点**：用 AskUserQuestion 展示文献全景，用户确认后继续。

---

### Phase 2: 思路生成与筛选

**读取详细指令**：用 Read 工具读取 `phases/phase2-idea-creator.md`，按其中的 Workflow 执行。

核心流程：
1. 加载 `idea-stage/LITERATURE_SURVEY.md` 作为上下文
2. 生成 8-12 个具体研究思路（含假设/最小实验/贡献类型/风险）
3. 快速筛选：可行性 + 快速新颖性检查 + 影响评估 → 8-12 缩减到 4-6
4. 深度验证：完整新颖性验证 + 模型魔鬼代言人 → 选出 2-3 个
5. Pilot 实验（可选，有 GPU 时）
6. 输出 `idea-stage/IDEA_REPORT.md`

**检查点**：用 AskUserQuestion 展示排序后的 ideas，用户选择后继续。

---

### Phase 3: 新颖性验证

**读取详细指令**：用 Read 工具读取 `phases/phase3-novelty-check.md`，按其中的 Instructions 执行。

核心流程：
1. 提取 3-5 个核心技术主张
2. 每个主张：≥3 种查询 × 4 种数据源（WebSearch/arXiv/Semantic Scholar/WebFetch）
3. 深度新颖性分析：直接命中/近似/隐含存在/并发风险
4. 输出 `idea-stage/NOVELTY_CHECK_[idea_name].md`
5. 淘汰已发表的想法

**反幻觉规则**：所有引用的论文必须通过 WebSearch/WebFetch 验证。未验证的标记 `[UNVERIFIED]`。

---

### Phase 4: 模拟审稿

**读取详细指令**：用 Read 工具读取 `phases/phase4-research-review.md`，按其中的 Workflow 执行。

核心流程：
1. 汇总研究上下文（IDEA_REPORT + NOVELTY_CHECK + LITERATURE_SURVEY）
2. 模型扮演高级审稿人（NeurIPS/ICML 级别）
3. 评分：新颖性/重要性/可靠性/清晰度 → 总分 + 建议
4. 迭代改进（最多 3 轮）
5. 输出 `idea-stage/REVIEW_[idea_name].md`

---

### Phase 5: 方案打磨

**读取详细指令**：用 Read 工具读取 `phases/phase5-research-refine.md`，按其中的 Workflow 执行。

核心流程：
1. 冻结问题锚点（Problem Anchor）
2. 扫描基础文献 → 识别技术缺口 → 选择最优路线
3. 自审（7 维度评分：问题忠实度/方法具体性/贡献质量/前沿利用/可行性/验证聚焦/会议准备度）
4. 迭代打磨（审→改循环，直到总分 ≥ 9 或达 MAX_ROUNDS=5）
5. 输出 `refine-logs/FINAL_PROPOSAL.md` + 各轮记录

**状态持久化**：`refine-logs/REFINE_STATE.json` 支持断点恢复。

**检查点**：用 AskUserQuestion 展示打磨后方案摘要。

---

### Phase 6: 实验规划

**读取详细指令**：用 Read 工具读取 `phases/phase6-experiment-plan.md`，按其中的 Workflow 执行。

核心流程：
1. 加载 FINAL_PROPOSAL + 审稿反馈
2. 冻结论文主张（1 主 + 1 辅）
3. 设计实验故事线（5 个默认 block，按需裁剪）
4. 每个实验 block 完整规格化（数据集/基线/指标/成功标准/失败解读）
5. 生成执行顺序 + 里程碑 + 决策门
6. 输出 `refine-logs/EXPERIMENT_PLAN.md` + `refine-logs/EXPERIMENT_TRACKER.md`

---

### Phase 7: 最终报告

汇总所有阶段信息，写入 `idea-stage/IDEA_REPORT.md`（完整版）+ 可选 `idea-stage/IDEA_CANDIDATES.md`（精简版，~30 行）。

---

## 输出协议

### 版本化协议

写入覆盖文件时，先写时间戳版本 `{NAME}_{YYYYMMDD_HHmmss}.md`，再复制到固定名 `{NAME}.md`。下游始终读固定名。

### 语言协议

- 用户最近消息为中文 → 中文输出
- 默认英文
- 不本地化：代码/文件路径/论文标题/JSON 键名/技术术语

---

## 关键规则

- **不要跳过阶段** — 每个阶段都有过滤/验证，跳过会浪费后续精力
- **阶段之间要有检查点** — 简要汇报结果，用 AskUserQuestion 与用户交互
- **尽早淘汰坏想法** — 在 Phase 3 淘汰 10 个坏想法比实现 1 个失败强
- **实证信号 > 理论吸引力** — 有正面 pilot 的 idea 优先于"听起来很好"的
- **诚实面对审稿** — 包含负面结果和失败 pilot
- **大文件处理**：Write 失败时立即用 Bash `cat << 'EOF' > file` 分块写入，不要问用户
- **不要编造结果** — 只描述预期证据和计划的实验
- **记录一切** — 死胡同和成功一样有价值

---

## 恢复与继续

- `refine-logs/REFINE_STATE.json` 记录 Phase 5 打磨状态，支持断点恢复
- 各阶段输出文件固定命名，下一阶段直接读取
- 时间戳文件保留完整历史
