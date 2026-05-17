# ARIS → WorkBuddy 迁移实施计划

**目标**：将 ARIS（Auto-Research-In-Sleep）的 `idea-discovery` 全流程迁移到 WorkBuddy，使其能在腾讯 WorkBuddy 环境下运行（使用内置模型或 DeepSeek V4，无需 Claude/GPT）。

**当前状态**：规划阶段，待用户确认后开始实施。

---

## 一、背景与约束

| 约束 | 说明 |
|------|------|
| 运行环境 | 腾讯 WorkBuddy（非 Claude Code，非 OpenClaw） |
| 可用模型 | WorkBuddy 内置模型 + DeepSeek V4（OpenAI-compatible API） |
| 不可用的原依赖 | `mcp__codex__codex`（GPT 调用）、Claude Code slash 命令、`Gemini CLI` |
| 目标 | 跑通"输入研究方向 → 输出排名后的 idea 报告"全流程 |

---

## 二、文件迁移清单

ARIS `idea-discovery` 全流程依赖以下文件，均需迁移并改造：

### 主流程
| 文件 | 作用 | 改造重点 |
|------|------|-----------|
| `skills/idea-discovery/SKILL.md` | 主流程编排（8个 Phase） | 去掉 Codex MCP 调用，改 Skill 工具链式调用，Checkpoint 改 AskUserQuestion |

### 子 Skill（必须）
| 文件 | 作用 | 改造重点 |
|------|------|-----------|
| `skills/research-lit/SKILL.md` | 文献调研 | 去掉 Gemini CLI 依赖，改用 WebSearch/WebFetch |
| `skills/idea-creator/SKILL.md` | 生成 8-12 个想法 | 去掉 `mcp__codex__codex`，改用 WorkBuddy 模型 |
| `skills/novelty-check/SKILL.md` | 新颖性验证 | 去掉 GPT-4.4 依赖，改用 WorkBuddy 内置能力 |
| `skills/research-review/SKILL.md` | 外部评审 | 去掉 GPT-4.4 xhigh，改用 WorkBuddy 模型 |
| `skills/research-refine/SKILL.md` | 方法精化 | 同上，改模型调用 |
| `skills/experiment-plan/SKILL.md` | 实验计划 | 改模型调用 |

### 公共协议文件（shared-references）
| 文件 | 作用 | 是否需改造 |
|------|------|-----------|
| `skills/shared-references/output-versioning.md` | 输出版本管理 | 基本兼容，检查路径 |
| `skills/shared-references/output-manifest.md` | 输出清单 | 基本兼容 |
| `skills/shared-references/output-language.md` | 输出语言控制 | 基本兼容 |

### 模板文件
| 文件 | 作用 | 是否需改造 |
|------|------|-----------|
| `templates/RESEARCH_BRIEF_TEMPLATE.md` | 研究简报模板 | 无需改造 |
| `templates/EXPERIMENT_PLAN_TEMPLATE.md` | 实验计划模板 | 无需改造 |

---

## 三、分阶段实施计划

### 阶段一：基础设施 + 主流程（预计 2-3 小时）

**目标**：跑通 Phase 0 → Phase 1（文献调研 → 输出文献摘要）

```
Step 1: 克隆 ARIS 仓库到本地工作区
  → git clone https://github.com/wanshuiyin/Auto-claude-code-research-in-sleep.git
  → 或者只下载需要的 SKILL.md 文件

Step 2: 创建 WorkBuddy skill 目录结构
  → ~/.workbuddy/skills/idea-discovery/
  → ~/.workbuddy/skills/research-lit/
  → ~/.workbuddy/skills/idea-creator/
  → ~/.workbuddy/skills/shared-references/

Step 3: 改造 idea-discovery/SKILL.md
  → 改 YAML frontmatter（allowed-tools）
  → 改 Phase 0-1 的模型调用和子命令调用方式
  → 改 Checkpoint 为 AskUserQuestion

Step 4: 改造 research-lit/SKILL.md
  → 去掉 Gemini CLI 相关逻辑
  → 改用 WebSearch + WebFetch + WorkBuddy 模型

Step 5: 测试 Phase 0-1
  → 输入一个研究方向，看文献调研是否能跑通
```

---

### 阶段二：想法生成 + 过滤（预计 2-3 小时）

**目标**：跑通 Phase 2（生成 8-12 个想法 → 过滤 → 排名）

```
Step 6: 改造 idea-creator/SKILL.md
  → 去掉 mcp__codex__codex 调用
  → 改用 WorkBuddy Skill 工具或直接用模型能力
  → 保留想法生成 + 过滤 + 排名逻辑

Step 7: 测试 Phase 2
  → 输入研究方向，看是否能生成想法列表
  → 检查 IDEA_REPORT.md 输出格式
```

---

### 阶段三：验证 + 评审（预计 2-3 小时）

**目标**：跑通 Phase 3-4（新颖性验证 + 外部评审）

```
Step 8: 改造 novelty-check/SKILL.md
  → 改用 WebSearch/WebFetch 进行文献搜索
  → 用 WorkBuddy 模型做新颖性判断

Step 9: 改造 research-review/SKILL.md
  → 去掉 GPT-4.4 xhigh 依赖
  → 用 WorkBuddy 模型做评审打分

Step 10: 测试 Phase 3-4
  → 检查 novelty-check 是否能正确验证想法新颖性
  → 检查 research-review 是否能输出结构化评审意见
```

---

### 阶段四：精化 + 实验计划（预计 1-2 小时）

**目标**：跑通 Phase 4.5（方法精化 + 实验计划）

```
Step 11: 改造 research-refine/SKILL.md
Step 12: 改造 experiment-plan/SKILL.md
Step 13: 测试 Phase 4.5
```

---

### 阶段五：端到端测试（预计 1-2 小时）

**目标**：完整跑通全流程，输出最终 IDEA_REPORT.md

```
Step 14: 端到端测试
  → 输入："B样条与INR结合的可解释诊断方法"
  → 检查每个 Phase 输出
  → 记录所有 bug 并修复

Step 15: 写使用文档
  → 怎么触发 idea-discovery
  → 参数说明（研究方向、sources、effort 等）
  → 输出文件说明
```

---

## 四、关键技术改造点

### 4.1 模型调用改造

**原版（ARIS / Codex MCP）**：
```markdown
Use mcp__codex__codex with model "gpt-4.4-xhigh" to generate ideas...
```

**WorkBuddy 版**：
```markdown
Use the WorkBuddy configured model (built-in or DeepSeek V4) to generate ideas.
The model should:
1. Read the literature summary from research-lit output
2. Generate 8-12 concrete research ideas
3. Score each idea by novelty/feasibility/impact
4. Output ranked IDEA_REPORT.md
```

### 4.2 子命令调用改造

**原版**：`/research-lit "$ARGUMENTS"`

**WorkBuddy 版**：
```markdown
Invoke the `research-lit` skill using the Skill tool with argument: "$ARGUMENTS"
```

### 4.3 Checkpoint 改造

**原版**：
```markdown
> 🚦 Checkpoint: Present literature landscape. Wait for user approval.
```

**WorkBuddy 版**：
```markdown
Use AskUserQuestion to present the literature landscape summary.
Ask: "Literature survey complete. Proceed to idea generation?"
Options: ["Proceed", "Adjust scope", "Regenerate"]
```

---

## 五、改造后的目录结构

```
~/.workbuddy/skills/
├── idea-discovery/
│   └── SKILL.md          # 主流程（改造后）
├── research-lit/
│   └── SKILL.md          # 文献调研（改造后）
├── idea-creator/
│   └── SKILL.md          # 想法生成（改造后）
├── novelty-check/
│   └── SKILL.md          # 新颖性验证（改造后）
├── research-review/
│   └── SKILL.md          # 外部评审（改造后）
├── research-refine/
│   └── SKILL.md          # 方法精化（改造后）
├── experiment-plan/
│   └── SKILL.md          # 实验计划（改造后）
└── shared-references/
    ├── output-versioning.md
    ├── output-manifest.md
    └── output-language.md
```

---

## 六、风险与应对

| 风险 | 应对方案 |
|------|-----------|
| WorkBuddy 模型能力不足以替代 GPT-4.4 | 接入 DeepSeek V4（OpenAI-compatible），能力相当 |
| 子 Skill 之间数据传递失败 | 用文件作为中间载体（ARIS 原版也是这么做） |
| Checkpoint 交互体验差 | 先用最简单的 AskUserQuestion，后续优化 |
| 文献搜索覆盖不全（去掉 Gemini） | 用 WebSearch + arXiv + Semantic Scholar API 补充 |

---

## 七、验收标准

- [ ] 输入研究方向，能跑完 8 个 Phase（无需人工干预，或仅在 Checkpoint 确认）
- [ ] 输出 `idea-stage/IDEA_REPORT.md`，包含至少 3 个排名后的想法
- [ ] 每个想法包含：描述、新颖性评分、可行性评分、评审意见
- [ ] 能在 WorkBuddy 环境下完整运行（不依赖外部 MCP 或 Claude/GPT）
- [ ] 有简单使用文档

---

*计划版本：v1.0，待用户确认后开始实施*
