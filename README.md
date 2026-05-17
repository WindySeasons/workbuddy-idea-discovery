# workbuddy-idea-discovery

> ARIS (Auto-Research-In-Sleep) idea-discovery pipeline 迁移至 WorkBuddy (Tencent)

从 [wanshuiyin/Auto-claude-code-research-in-sleep](https://github.com/wanshuiyin/Auto-claude-code-research-in-sleep) 迁移的科研 idea 发现流水线，适配 WorkBuddy 平台运行。

## 迁移的 Skills

| Phase | Skill | 说明 |
|-------|-------|------|
| Phase 1 | `research-lit` | 文献检索与综述 |
| Phase 1 | `idea-creator` | 研究思路生成与排序 |
| Phase 1 | `idea-discovery` | 完整 Phase 1 编排（research-lit → idea-creator） |
| Phase 2 | `novelty-check` | 新颖性验证 |
| Phase 2 | `research-review` | 模拟审稿 |
| Phase 2 | `research-refine` | 迭代打磨（review → refine 循环） |
| Phase 2 | `experiment-plan` | 实验方案规划 |
| Shared | `shared-references` | 共享引用规范（版本号/目录/语言） |

## 完整流水线

```
research-lit → idea-creator → novelty-check → research-review → research-refine → experiment-plan
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

通过 `scripts/sync-upstream.sh` 定期检查上游更新并自动合并到本地 skills。
