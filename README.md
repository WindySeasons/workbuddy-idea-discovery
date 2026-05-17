# workbuddy-idea-discovery

> ARIS (Auto-Research-In-Sleep) idea-discovery pipeline 迁移至 WorkBuddy (Tencent)

从 [wanshuiyin/Auto-claude-code-research-in-sleep](https://github.com/wanshuiyin/Auto-claude-code-research-in-sleep) 迁移的科研 idea 发现流水线，适配 WorkBuddy 平台运行。

## 一个命令，完整流水线

```
/idea-discovery "B样条+INR 可解释诊断"
```

6 个阶段自动串行执行：

```
文献调研 → 思路生成 → 新颖性验证 → 模拟审稿 → 方案打磨 → 实验规划
```

## 统一套件结构

**之前**：7 个独立 skill 散落在 50+ 个其他 skill 中，无人知道它们是一套的。

**之后**：1 个统一 skill，内含 6 个 phase 子文件：

```
skills/idea-discovery/
├── SKILL.md                          # 唯一入口（流水线编排 + 全局常量 + 规则）
└── phases/
    ├── phase1-research-lit.md        # 文献检索与综述
    ├── phase2-idea-creator.md        # 研究思路生成与筛选
    ├── phase3-novelty-check.md       # 新颖性验证
    ├── phase4-research-review.md     # 模拟审稿
    ├── phase5-research-refine.md     # 迭代打磨（review→refine 循环）
    └── phase6-experiment-plan.md     # 实验方案规划
```

## 端到端测试

2026-05-17 使用 **B样条+INR 可解释诊断** 方向完成全流程测试：

- 文献调研：10 篇论文，4 个结构缺口
- 思路生成：10 → 6 → 3 (筛选后)
- 新颖性验证：9/10
- 模拟审稿：6/10 → 7.25/10 (改进后)
- 迭代打磨：8.2/10 (Strong Accept)
- 实验规划：4 个实验模块，14 个运行，20 天计划

详细结果见 `idea-stage/` 和 `refine-logs/` 目录。

## 上游同步

上游仓库：`wanshuiyin/Auto-claude-code-research-in-sleep`

- `scripts/sync-upstream.sh` — 手动同步脚本
- `scripts/sync-upstream-check.py` — 自动同步脚本（WorkBuddy 定时任务每天 9:00 执行）
- `.sync-state.json` — 记录上次同步的上游 commit
- 有冲突时暂停通知用户，无冲突时自动合并并推送
