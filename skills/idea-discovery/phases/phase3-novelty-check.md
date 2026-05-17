# Phase 3: 新颖性验证（Novelty Check）

验证方法/思路：**$ARGUMENTS**

## 步骤

### Phase A: 提取核心主张

1. 读取用户的方法描述（从 `$ARGUMENTS` 或 `idea-stage/IDEA_REPORT.md`）
2. 识别 **3-5 个核心技术主张**：
   - 方法是什么？
   - 解决什么问题？
   - 关键创新机制是什么？
   - 与直观基线的区别？

输出结构化主张列表。

### Phase B: 多源文献检索

对**每个**核心主张，使用所有可用来源：

#### 1. WebSearch
每个主张至少 **3 种查询形式**：
- 查询 1：精确技术词 + "paper" / "arXiv" / "2024 2025"
- 查询 2：问题级查询 + 近期会议名
- 查询 3：更广领域 + 关键机制名 + "novel" / "proposed"

包含年份过滤（默认 2023-2026）。

#### 2. arXiv（via WebFetch）
```
WebFetch: https://arxiv.org/search/?query=[URL-encoded terms]&searchtype=all
```
提取 top 10 的标题和摘要。

#### 3. Semantic Scholar（via WebFetch）
```
WebFetch: https://api.semanticscholar.org/graph/v1/paper/search?query=[terms]&limit=10&fields=title,year,venue,abstract,citationCount
```

#### 4. 阅读摘要
对每个潜在重叠论文，用 WebFetch 获取完整摘要页，聚焦：标题/摘要/"related work" 部分。
标记重叠级别：完全相同 / 非常接近 / 同问题不同方案 / 间接相关。

### Phase C: 深度新颖性分析

对每个核心主张评估：

1. **直接命中**：有论文做了完全一样的事吗？
2. **近似命中**：有非常接近的论文吗？差距是什么？
3. **隐含存在**：即使没有论文做完全一样的，这个 idea 是不是审稿人会觉得"显而易见的下一步"？
4. **并发风险**：最近 6 个月的 arXiv 趋势，有人在同时做这个吗？

对整体方法评估：
- 组合是否新颖（即使各部分单独存在）？
- 实验设置/应用领域是否新颖？
- NeurIPS/ICML 审稿人会认为这是"清晰贡献"还是"增量扩展"？

### Phase D: 输出

写入 `idea-stage/NOVELTY_CHECK_[idea_short_name].md`：

```markdown
# 新颖性验证报告

## 拟议方法
[1-2 句描述]

## 核心主张分析

### 主张 1: [文本]
- 新颖性: HIGH / MEDIUM / LOW / NONE
- 最近工作: [论文, 年份, 会议]
- 关键区别: [什么不同]
- 搜索证据: [查询、重叠论文数]

## 最近相关工作

| # | 论文 | 年份 | 会议 | 重叠级别 | 关键区别 | 置信度 |

## 总体新颖性评估
- 评分: X/10
- 建议: PROCEED / PROCEED WITH CAUTION / ABANDON
- 关键差异化点 / 最大风险 / 并发风险
- 定位建议

## 使用的搜索查询
[完整记录，便于复现]
```

## 规则

- **残忍诚实** — 虚假新颖性声明浪费数月研究时间
- "把 X 应用到 Y" 不算新颖（除非揭示令人惊讶的洞察）
- 同时检查方法和实验设置的新颖性
- 如果方法不新但发现会新，明确说明
- 始终检查最近 6 个月 arXiv
- **反幻觉**：报告中的每篇论文必须通过 WebSearch/WebFetch 验证。绝不凭记忆编造 arXiv ID、DOI 或标题。未验证的标记 `[UNVERIFIED]`
- 细粒度评估：不要只给"新颖"/"不新颖"，按主张逐一分析
- 考虑审稿人视角：技术上新颖，目标会议的贡献是否足够？
