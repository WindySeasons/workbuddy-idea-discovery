# Phase 5: 方案打磨（Research Refine）

打磨对象：**$ARGUMENTS**

## 四大原则

1. **不要丢失原始问题** — 冻结不可变的 Problem Anchor，每轮复用
2. **最小充分机制胜出** — 优先最小干预直接修复瓶颈
3. **一篇论文，一个主导贡献** — 一个核心主张 + 至多一个辅助贡献
4. **现代技术是先验不是装饰** — LLM/VLM/Diffusion/RL 自然契合时才用

## 常量

- MAX_ROUNDS = 5，SCORE_THRESHOLD = 9
- OUTPUT_DIR = `refine-logs/`
- MAX_CORE_EXPERIMENTS = 3，MAX_PRIMARY_CLAIMS = 2，MAX_NEW_TRAINABLE = 2

## 状态持久化

`refine-logs/REFINE_STATE.json` 支持断点恢复。字段：phase/round/last_score/last_verdict/status/timestamp。

- 不存在 → 全新开始
- completed → 全新开始
- in_progress + 超过 24 小时 → 全新开始
- in_progress + 24 小时内 → 恢复

## 工作流

### 初始化

检查 `refine-logs/REFINE_STATE.json`，决定全新开始还是恢复。恢复时读取所有 round-*.md。

### Phase 0: 冻结问题锚点

写入：
- 底线问题：必须解决什么技术问题？
- 必须解决的瓶颈：当前方法的什么弱点不可接受？
- 非目标：明确不做什么？
- 约束：算力/数据/时间/工具/会议/部署限制
- 成功条件：什么证据能让用户说"是的，这个方法解决了实际问题"？

Checkpoint: 写 REFINE_STATE.json `{"phase": "anchor", "round": 0, ...}`

### Phase 1: 构建初始方案

#### 1.1 扫描基础材料
读取 `papers/`、`literature/`、`idea-stage/`，不够则 WebSearch 补充。

#### 1.2 识别技术缺口
- 当前管线故障点
- 朴素修复为何不够
- 最小充分干预是什么
- 核心技术主张是什么
- 需要什么证据来辩护

#### 1.3 选择最优路线
比较：
- Route A: 优雅最小路线
- Route B: 前沿原生路线（仅当更清晰/更强时）

#### 1.4 具体化方法
覆盖：方法论题/贡献聚焦/复杂度预算/系统图/表示设计/训练配方/推理路径/为什么小/前沿组件角色/失败处理/新颖性论证

#### 1.5 设计最小主张驱动验证
每个核心主张 → 最小强实验（主张/基线/决定性指标/预期方向）

#### 1.6 写入 `refine-logs/round-0-initial-proposal.md`

Checkpoint: `{"phase": "proposal", "round": 0, ...}`

### Phase 2: 自审（Round 1）

7 维度评分（1-10）：

1. **问题忠实度** (15%) — 方法是否仍攻击原始瓶颈？
2. **方法具体性** (25%) — 接口/表示/损失/训练阶段/推理路径是否足够具体？
3. **贡献质量** (25%) — 是否有一个主导的机制级贡献？有无贡献蔓延？
4. **前沿利用** (15%) — 是否适当地使用了基础模型时代的技术？
5. **可行性** (10%) — 能在给定资源下训练和集成吗？
6. **验证聚焦** (5%) — 实验是否最小但充分？
7. **会议准备度** (5%) — 够锐利和及时吗？

总分加权计算。每个 <7 的维度提供：具体弱点 + 方法级修复 + 优先级（CRITICAL/IMPORTANT/MINOR）。

附加：简化机会 / 现代化机会 / 漂移警告
判定：READY (≥9) / REVISE / RETHINK

写入 `refine-logs/round-1-review.md`。Checkpoint: `{"phase": "review", "round": 1, ...}`

### Phase 3: 解析反馈并修订

#### 3.1 解析审稿
提取所有分数/判定/漂移警告/简化机会/现代化机会/行动项。
更新 `refine-logs/score-history.md`。

**停止条件**：总分 ≥ 9 且无未解决漂移 → 跳到 Phase 5。

#### 3.2 锚点检查 + 简化检查 + 修订

修订前：
1. 逐字复制 Problem Anchor
2. 锚点检查：原始瓶颈？方法仍解决？哪些建议会造成漂移？
3. 简化检查：主导贡献？可删除/合并/冻结什么？

处理反馈：有效→改进；有争议→修订并解释；错误/漂移/过度复杂→用证据反驳。

写入 `refine-logs/round-N-refinement.md`（包含完整修订方案）。Checkpoint: `{"phase": "refine", "round": N, ...}`

### Phase 4: 重新评估（Round 2+）

同一 7 维度 rubric，与上轮对比。写入 `refine-logs/round-N-review.md`。

循环 Phase 3-4 直到：总分 ≥ 9 或 MAX_ROUNDS = 5。

### Phase 5: 最终报告

- `refine-logs/REVIEW_SUMMARY.md`
- `refine-logs/FINAL_PROPOSAL.md`（干净版）
- `refine-logs/REFINEMENT_REPORT.md`（完整历史）
- `refine-logs/score-history.md`

Checkpoint: `{"phase": "done", "status": "completed", ...}`

## 规则

- 每轮先锚点检查
- 一篇论文一个主导贡献
- 最小充分机制胜出
- 优先复用而非发明
- 现代技术是先验不是装饰
- 反馈造成漂移或过度复杂时要推回
- 不要编造结果
- 大文件处理：Write 失败时用 Bash 分块写入
