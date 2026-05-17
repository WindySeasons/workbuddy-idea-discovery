# Phase 1: 文献调研（Research Literature Review）

研究主题：**$ARGUMENTS**

## 步骤

### Step 0: 解析参数

从 `$ARGUMENTS` 提取研究主题和任何覆盖标志（`--arxiv-download`、`--local-only`、`--web-only`、`--max-download:N`）。

### Step 1: 扫描本地论文库

1. 搜索路径：`papers/**/*.pdf`、`literature/**/*.pdf`、`pdfs/**/*.pdf`
2. 按文件名和首页内容匹配相关性
3. 每篇读前 3 页，提取：标题/作者/年份/核心贡献/关联度
4. 输出 `idea-stage/LITERATURE_LOCAL_SUMMARY.md`（如有本地论文）

### Step 2: 搜索外部来源

#### 2a: arXiv（主要）

用 WebFetch 获取：`https://export.arxiv.org/api/query?search_query=all:[QUERY]&max_results=10&sortBy=submittedDate&sortOrder=descending`

提取：arXiv ID、标题、作者、摘要、提交日期。

#### 2b: WebSearch（补充）

搜索近 2 年论文、survey 论文、Open Review 讨论。

#### 2c: 去重

合并本地和外部结果，按标题相似度去重。优先级：本地 PDF > arXiv > web。

### Step 3: 逐篇分析（最多 15 篇）

每篇提取：
- **Problem**: 解决什么 gap？
- **Method**: 核心技术贡献（1-2 句）
- **Results**: 关键数据/结论
- **Relevance**: High / Medium / Low
- **Year/Venue**

### Step 4: 综合分析

1. 按方法/主题分组 → 识别方法集群
2. 识别结构缺口：未解决的问题 / 失败的尝试 / 作者承认的局限
3. 构建全景图：核心问题 → 现有方法 → 局限 → 开放缺口

### Step 5: 输出

写入 `idea-stage/LITERATURE_SURVEY.md`：

```markdown
# 文献调研：$ARGUMENTS

**日期**: [today]
**来源**: 本地 PDF ([N]), arXiv ([N]), Web ([N])

## 全景概述
[2-3 段：主要方法、前景方向、开放问题]

## 分析的论文

### 直接相关
| # | 标题 | 会议/年份 | 核心贡献 | 关联度 |

### 间接相关
| # | 标题 | 会议/年份 | 核心贡献 | 关联度 |

## 结构缺口与开放问题
1. [缺口 1]: [为什么是缺口？哪些论文承认了它？]
2. [缺口 2]: ...

## 有前景的方向
1. [方向 1]: [为什么有前景？哪些论文指向这里？]
2. [方向 2]: ...
```

### Step 5.5: 更新研究 Wiki（可选）

如 `research-wiki/` 存在，为每篇顶级论文添加条目。

## 规则

- 激进去重，不要分析同一篇论文两次
- 优先近 2 年工作（除非是基础性工作）
- 区分预印本和已发表
- 诚实面对局限性——文献稀疏就直说
- `LITERATURE_SURVEY.md` 是 Phase 2 的基础，务必保存完整

## 检查点

用 AskUserQuestion 展示：
```
📚 文献调研完成。
- 来源：本地 [N] / arXiv [N] / Web [N]
- 全景摘要：[2-3 句]
- 最有前景方向：[2-3 个]
```
选项：`["继续", "调整范围", "换个聚焦点"]`
