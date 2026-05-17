# Idea Discovery

> WorkBuddy Skill — 科研思路全流程发现套件

一个命令完成从研究方向到实验方案的完整流水线：文献调研 → 思路生成 → 新颖性验证 → 模拟审稿 → 方案打磨 → 实验规划。

基于 [ARIS (Auto-Research-In-Sleep)](https://github.com/wanshuiyin/Auto-claude-code-research-in-sleep) 迁移适配，针对 WorkBuddy 平台重新设计为统一套件架构。

## Quick Start

**安装**

将 `skills/idea-discovery/` 目录复制到 WorkBuddy 的 skill 目录下：

```bash
cp -r skills/idea-discovery ~/.workbuddy/skills/idea-discovery
```

**使用**

在 WorkBuddy 中输入：

```
/idea-discovery B样条+INR 可解释诊断
```

6 个阶段会自动串行执行，每阶段结束后有检查点供你确认和调整。

## Pipeline

```
Phase 1  文献调研        扫描本地论文 + arXiv/WebSearch 外部检索
   ↓
Phase 2  思路生成        8-12 个候选 → 快速筛选 → 深度验证 → 2-3 个
   ↓
Phase 3  新颖性验证      3-5 个核心主张 × 多源交叉搜索
   ↓
Phase 4  模拟审稿        NeurIPS/ICML 级别审稿模拟 + 迭代改进
   ↓
Phase 5  方案打磨        7 维度自审 + 审→改循环 (目标 ≥ 9/10)
   ↓
Phase 6  实验规划        实验故事线 + 规格化 + 里程碑 + 决策门
```

## Project Structure

```
skills/idea-discovery/
├── SKILL.md                          # 入口：流水线编排、全局常量、输出协议
└── phases/
    ├── phase1-research-lit.md        # 文献检索与综述生成
    ├── phase2-idea-creator.md        # 研究思路生成与筛选
    ├── phase3-novelty-check.md       # 新颖性验证
    ├── phase4-research-review.md     # 模拟审稿
    ├── phase5-research-refine.md     # 迭代打磨（含断点恢复）
    └── phase6-experiment-plan.md     # 实验方案规划
```

SKILL.md 是唯一的入口文件，负责阶段调度和全局配置。各阶段的详细 Workflow 指令在对应的 phase 文件中。

## Configuration

通过参数覆盖全局常量：

```
/idea-discovery "研究方向" --compact: true --arxiv-download --ref-paper: https://arxiv.org/abs/XXXX
```

| 常量 | 默认值 | 说明 |
|---|---|---|
| `SEARCH_YEAR_RANGE` | 2023-2026 | 文献搜索年份范围 |
| `AUTO_PROCEED` | true | 检查点超时后自动继续 |
| `ARXIV_DOWNLOAD` | false | 是否下载 arXiv PDF |
| `COMPACT` | false | 生成精简版候选报告 |
| `PILOT_MAX_HOURS` | 2 | 单个 pilot 实验 GPU 时长上限 |
| `MAX_ROUNDS` | 5 | Phase 5 打磨最大迭代轮数 |

## Output Files

流水线运行后产出以下文件：

| 文件 | 阶段 | 内容 |
|---|---|---|
| `idea-stage/LITERATURE_SURVEY.md` | Phase 1 | 文献综述（全景图 + 结构缺口） |
| `idea-stage/IDEA_REPORT.md` | Phase 2 | 候选思路报告（含排序与筛选记录） |
| `idea-stage/NOVELTY_CHECK_*.md` | Phase 3 | 新颖性验证报告 |
| `idea-stage/REVIEW_*.md` | Phase 4 | 模拟审稿意见 + 评分 |
| `refine-logs/FINAL_PROPOSAL.md` | Phase 5 | 最终研究方案 |
| `refine-logs/EXPERIMENT_PLAN.md` | Phase 6 | 实验计划 |
| `refine-logs/EXPERIMENT_TRACKER.md` | Phase 6 | 实验进度追踪表 |

Phase 5 支持断点恢复——通过 `refine-logs/REFINE_STATE.json` 保存打磨状态，中断后可从上次的断点继续。

## Upstream Sync

本项目从 [ARIS](https://github.com/wanshuiyin/Auto-claude-code-research-in-sleep) 迁移，保留了上游同步能力：

- `scripts/sync-upstream.sh` — 手动同步（带冲突检测）
- `scripts/sync-upstream-check.py` — 自动同步（可接入 WorkBuddy 定时任务）

同步策略：无冲突时自动合并，有冲突时暂停并报告。

## Credits

- [ARIS (Auto-Research-In-Sleep)](https://github.com/wanshuiyin/Auto-claude-code-research-in-sleep) — 原始项目
- [WorkBuddy](https://www.codebuddy.cn) — 运行平台

## License

本项目遵循上游 ARIS 项目的许可协议。
