# LiNSO ARCHIVE — 站点维护手册

> 本文档描述该博客的运作方式、插件构成与自定义改动，供后期维护者和 AI Agent 阅读。
> 遇到不确定的地方，**先读完第 5 节（主题自定义）再动配置**——这个站点有若干不在主题默认范围内的改动。

---

## 1. 这是什么

| 项 | 值 |
|---|---|
| 站点名 | LiNSO ARCHIVE |
| 副标题 | 数码评测/技术分享/碎碎念 |
| 作者 | 程泠潇（泠潇 / Linso / linsovo） |
| 线上地址 | https://linsovo.github.io |
| 类型 | Hexo 静态博客，托管于 GitHub Pages |
| 时区设置 | `Asia/Singapore`（UTC+8，与上海无差异） |

启动时间：2026-11-22。

---

## 2. 技术栈

| 组件 | 版本 | 说明 |
|---|---|---|
| Node.js | v24.21.0 | 运行时（Hexo 8 要求 ≥18） |
| Hexo | 8.1.2 | 静态站点生成器 |
| hexo-theme-butterfly | 5.7.2 | 主题 |
| 渲染器 | marked / pug / stylus / ejs | Markdown、模板、样式 |
| 部署 | hexo-deployer-git 4.x | 推送到 GitHub |

---

## 3. 目录结构与「哪些文件能动」

```
C:\Blog_v1\
├── _config.yml               ← 【可改】站点主配置
├── _config.butterfly.yml     ← 【可改】主题配置（含本站大量自定义）
├── package.json              ← 【谨慎】依赖声明
├── publish.bat               ← 一键发布脚本
├── preview.bat               ← 一键本地预览脚本
│
├── source/                   ← 【可改】所有内容源文件
│   ├── _posts/               文章（.md）
│   ├── _data/widget.yml      ★ 侧栏自定义卡片（技能/设备/友链）
│   ├── about/index.md        关于页
│   ├── categories/index.md   分类总览页（type: categories）
│   ├── tags/index.md         标签总览页（type: tags）
│   └── img/                  图片资源（头像等）
│
├── public/                   ← 【禁止手改】生成的静态站点
├── .deploy_git/              ← 【禁止手改】部署用的临时 git 仓库
└── node_modules/             ← 【禁止手改】依赖
```

**三条铁律：**

1. `public/` 和 `.deploy_git/` 是构建产物，每次 `hexo g` / `hexo d` 都会重建，手改无效且会被覆盖。
2. **不要在 GitHub 网页上直接编辑 `main` 分支**——那是部署产物，下次部署整份覆盖。
3. 修改已被他人编辑过的文件前，**先 `git commit` 存档**，避免误覆盖（本站曾因此丢失过一次内容，靠 VS Code 本地历史找回）。

---

## 4. 发布流程

### 4.1 日常三件事

```powershell
cd C:\Blog_v1
hexo new my-post-slug   # 文件名=网址，必须英文/拼音；中文标题写进 front-matter 的 title
# 用编辑器写 source/_posts/my-post-slug.md
hexo g -d              # 生成 + 部署上线（1~2 分钟后生效）
```

> 不要 `hexo new "中文标题"`：`new_post_name: :title.md` 会生成中文文件名，网址变成
> `%E4%B8%AD...` 这种编码（见 6.1「网址规则」）。

或用脚本：

| 脚本 | 作用 | 内容 |
|---|---|---|
| `publish.bat` | 一键发布 | `hexo g -d` + `git add/commit/push` 备份源码 |
| `preview.bat` | 一键预览 | 启动 `hexo server -p 4000` 并打开浏览器 |

### 4.2 分支模型

| 分支 | 内容 | 更新方式 |
|---|---|---|
| `source`（默认分支） | 源码：配置、文章、脚本 | `git push origin source` |
| `main` | 生成的静态站点 | 由 `hexo deploy` 自动推送 |

`hexo deploy` 会把 `public/` 的完整内容替换到远端 `main`，因此**删除的文章/文件在线上会同步消失**，不需要手动清理。

### 4.3 发布依赖的网络条件

- 需要能访问 `github.com:443`（国内常出现间歇性不通）
- 机器上曾存在失效的本地代理变量（`HTTP_PROXY` 指向 `127.0.0.1:50225`），会导致 `CONNECT tunnel failed, response 502`。用户在 TUN 模式 VPN 下直连可用，此时**执行前先清除代理变量**：

```powershell
Remove-Item Env:HTTP_PROXY,Env:HTTPS_PROXY,Env:http_proxy,Env:https_proxy,Env:ALL_PROXY,Env:all_proxy -ErrorAction SilentlyContinue
```

- 部署报 `Spawn failed` 时，真实原因通常在报错堆栈上方（多为网络），**重试一两次通常即可**。

---

## 5. 主题自定义（重点，非默认配置）

以下改动**不在 Butterfly 默认范围内**，是本站专有的，维护时最容易困惑。

### 5.1 注入的 CSS：`ly-*` 命名空间

位置：`_config.butterfly.yml` → `inject.head` 中的 `<style>` 块。

| 类名 | 用途 |
|---|---|
| `.ly-card` `.ly-sign` `.ly-links` `.ly-row` | 资料卡内部结构（签名、三按钮、信息行） |
| `.ly-sec` `.ly-sec-t` `.ly-tags` `.ly-tag` | 技能卡的分组、标签胶囊 |
| `.ly-dev` `.ly-dev-i` `.ly-dev-n` `.ly-dev-m` | 设备卡的条目 |
| `.ly-flinks` `.ly-flink` | 友链卡的两列网格 |
| `.ly-two-cards` | 技能 + 设备两栏并排容器 |
| `.card-widget.card-info` 相关 | 资料卡横排（CSS Grid：头像左 76px、名字右） |

**注意**：这些样式全部写在 `inject.head` 里（内联进每个页面的 `<head>`），**不在** `public/css/index.css` 中。搜索时要在 HTML 里搜，不是 CSS 文件。

### 5.2 搬卡脚本：`inject.bottom` 中的 JS

位置：`_config.butterfly.yml` → `inject.bottom`。

**存在原因**：Butterfly 的自定义卡片只能渲染在侧栏，没有「正文下方」的插槽。而本站需要把「我的技能」「我的设备」「友情链接」三张卡放到**文章列表下方**。

**逻辑**：

```
页面加载 → 找到 #card-skill / #card-device（侧栏中的卡片）
        → 建一个 .ly-two-cards 容器插入 #recent-posts
        → 把两张卡搬进容器（两栏并排）
        → 把 #card-links 插到容器下方（通栏）
PJAX 跳转时通过 btf.addGlobalFn('pjaxComplete', ...) 重新执行
```

**降级行为（注意，别想当然）**：如果 JS 没执行（禁用 JS、脚本报错、PJAX 没重跑），三张卡会被下面那条 CSS 直接**隐藏**，而不是留在侧栏。也就是说搬卡脚本是这三张卡能否显示的**单点依赖**，改它之前先确认首页能看到。

**配套 CSS**：`#aside-content > .card-skill, .card-device, .card-links { display:none }`
—— 该规则只作用于「侧栏的直接子元素」。卡片被 JS 搬进 `#recent-posts` 后不再是侧栏子元素，隐藏自然失效。实际效果是：**只有首页（存在 `#recent-posts`）显示这三张卡**，文章页、归档、分类、标签、关于页都不显示。

### 5.3 自定义卡片数据：`source/_data/widget.yml`

这是 Butterfly 内置机制 `site.data.widget` 的用法：

- `top:` 列表 → 渲染在资料卡、公告卡之后
- `bottom:` 列表 → 渲染在侧栏最底部

每一项字段：

```yaml
  - class_name: card-skill     # 卡片 CSS 类名（也是选择器依据）
    id_name: card-skill        # DOM id（搬卡脚本依赖它）
    name: 我的技能              # 卡片标题
    icon: fas fa-tools         # FontAwesome 图标
    html: |                    # 卡片内容，原样输出 HTML
      <div class="ly-sec">...</div>
```

**当前包含**：`card-skill`（4 组 18 条技能）、`card-device`（6 台设备）、`card-links`（友链）。
**坑**：`html: |` 后的内容为原样 HTML，缩进必须整块对齐，否则 YAML 解析失败会导致整站构建失败。

### 5.4 深色模式：默认深色

主题原生逻辑是「浅色起步，用户手动切换」。本站通过 `inject.head` 中的一段脚本改为**首次访问即深色**：

```javascript
if (localStorage.getItem('theme') === null && btf.activateDarkMode) {
  localStorage.setItem('theme', JSON.stringify({ value: 'dark' } ))
  btf.activateDarkMode()
}
```

用户点击切换后选择会被记住（写入 localStorage），不会每次刷新跳回深色。
**恢复默认浅色**：删除 `inject.head` 中该 `<script>`。

### 5.5 其他非默认设置

| 配置 | 值 | 位置 |
|---|---|---|
| 首页横幅高度 | `320px`（默认 100vh 满屏） | `index_top_img_height` |
| 文章摘要方式 | `method: 2`（description 优先，无则截断） | `index_post_content` |
| 代码块配色 | `darker`（适配深色页面） | `code_blocks.theme` |
| 侧栏分类卡 | 关闭 | `card_categories.enable: false` |
| 侧栏标签卡 | 关闭 | `card_tags.enable: false` |
| 侧栏最新文章 | 3 篇 | `card_recent_post.limit: 3` |
| 首页文章数 | 10 篇/页（与归档一致） | `_config.yml` → `index_generator.per_page` |
| 站内搜索 | 本地搜索（`local_search`） | `search.use` + `hexo-generator-searchdb` |
| 访问统计 | 不蒜子 | `busuanzi`（默认开启） |

---

## 6. 写作规范

### 6.1 网址规则（重要）

```yaml
permalink: posts/:title/        # _config.yml
```

- 网址 = `/posts/` + **文件名**，**与日期无关**
- 改文章日期 → 网址不变
- 改文件名 → 网址变（旧链接失效）
- 单篇可覆盖：front-matter 加 `permalink: 自定义名/`

**因此文件名请用英文或拼音**，避免中文文件名导致 URL 变成 `%E4%B8%AD...` 编码。

### 6.2 front-matter 标准结构

```yaml
---
title: 文章标题
date: 2026-11-23 12:00:00
tags:
  - 随笔
categories:
  - 碎碎念
description: 首页卡片上显示的一句话摘要
---
```

- `description` 为空时，首页摘要会退化为「正文前 500 字且**剥离所有格式**」
- 需要**带格式**的摘要，改用 `postDesc:` 字段（原样输出 HTML）
- `date` 缺失或为 `1970-01-01` 会导致排序异常（本站首篇的 `2005-12-05` 是作者有意设定，因 permalink 已与日期解耦，不影响网址）

### 6.3 引用站内文章

用标签，**不要硬编码网址**：

```
{% post_link 文件名 %}
```

会渲染成 `<a href="/posts/文件名/">文章标题</a>`，网址结构变化时自动跟随。

### 6.4 可用的自定义标签（Butterfly 内置）

| 标签 | 用途 |
|---|---|
| `{% note primary/success/info/warning/danger %}` | 提示框（风格可选 simple/modern/flat） |
| `{% label %}` | 行内小标签 |
| `{% tabs %}` | 多标签切换 |
| `{% hide %}` | 折叠块 |
| `{% timeline %}` | 时间线 |
| `{% flink %}` | 友链列表（独立页面用） |
| `{% mermaid %}` `{% chartjs %}` | 图表 |

`note` 示例：

```
{% note info fa-solid fa-lightbulb flat %}
提示内容，支持 Markdown
{% endnote %}
```

### 6.5 图片

- 统一放 `source/img/`，引用写 `/img/文件名.jpg`
- 封面：front-matter `cover:`（首页卡片缩略图）
- 文章页顶部大图：front-matter `top_img:`
- **体积红线**：头像 ≤ 100KB，横幅/背景 ≤ 200KB，文章配图 ≤ 100KB

---

## 7. 插件清单

| 插件 | 作用 | 可否移除 |
|---|---|---|
| `hexo-deployer-git` | 推送部署到 GitHub | 否（核心） |
| `hexo-generator-index` | 生成首页分页 | 否 |
| `hexo-generator-archive` | 生成归档页 | 否 |
| `hexo-generator-category` | 生成**每个分类**的页面 | 否 |
| `hexo-generator-tag` | 生成**每个标签**的页面 | 否 |
| `hexo-generator-searchdb` | 生成 `search.xml`，供本地搜索 | 可（关掉站内搜索时） |
| `hexo-renderer-marked` | Markdown 渲染 | 否 |
| `hexo-renderer-pug` | 主题模板 | 否 |
| `hexo-renderer-stylus` | 主题样式 | 否 |
| `hexo-server` | 本地预览 | 可（不用本地预览时） |
| `hexo-theme-landscape` | Hexo 默认主题，**未使用** | 可 |

> 注意：`hexo-generator-category` / `-tag` **只生成单分类/单标签页（如 `/categories/碎碎念/`），不生成总览页**。总览页 `/categories/` `/tags/` 需要 `source/categories/index.md`（`type: categories`）和 `source/tags/index.md`（`type: tags`）这两个页面文件才会生成。删掉这两个文件，导航栏的「分类」「标签」就会 404。

---

## 8. 故障排查

| 现象 | 原因 | 处理 |
|---|---|---|
| 整站 404，显示 "Site not found" | 仓库被改名（不再是 `用户名.github.io`） | 改回 `linsovo.github.io`，或修改 `url`/`root` 迁到子路径 |
| 页面能开但无样式/无图 | `url` 与 `root` 与实际部署路径不匹配 | 检查 `_config.yml` 的 `url` / `root` |
| 部署报 `CONNECT tunnel failed, 502` | 本地残留失效代理，或 VPN 未开 | 清除代理变量 / 开启 VPN |
| 部署报 `Spawn failed` | 多为网络问题 | 重试；查看堆栈上方的 git 原始报错 |
| 部署提交信息变成 `YYYY-11-2026年11月…` | `deploy.message` 用了 Moment 的 token，而 deployer 用 Luxon 格式化 | 用 `yyyy-MM-dd HH:mm:ss`（已修好，见 `_config.yml`） |
| 改了 `.yml` 不生效 | 配置只在启动时读取 | 重启 `hexo server` / 重新 `hexo g` |
| 导航「分类」「标签」404 | 缺少总览页文件 | 见第 7 节末尾说明 |
| 文章链接失效 | 改了文件名或（旧配置下的）日期 | 引用处改用 `{% post_link %}` |
| YAML 解析报错，整站白屏 | `widget.yml` 或配置文件缩进错误 | 检查 `|` 块的缩进对齐 |

---

## 9. 未完成 / 可选项

| 项 | 状态 | 备注 |
|---|---|---|
| 自定义域名 | 未做 | `linsovo.com` 经查可注册；绑定后需改 `url` 并在 `source/` 放 `CNAME` 文件 |
| 评论系统 | 未做 | Twikoo / Waline 均可，需部署云端函数 |
| 图床 | 未做 | 图片目前存仓库，数量多后建议迁至对象存储 |
| 独立友链页 `/links/` | 未做 | 友链现有 1 条，达到 5 条后建议建独立页（`type: link` + `{% flink %}`） |
| 归档页样式 | 默认 | — |

---

## 10. 变更记录

| 日期 | 变更 |
|---|---|
| 2026-11-22 | 建站：Hexo 8 + Butterfly 5.7.2，配置站点信息、主题、部署，上线 |
| 2026-11-22 | 增加站内搜索、关于页、访问统计；资料卡改横排；深色模式默认开启 |
| 2026-11-22 | 新增「我的技能」「我的设备」「友情链接」三张自定义卡片，移到正文下方 |
| 2026-11-22 | 关闭侧栏分类/标签卡片；补建分类、标签总览页 |
| 2026-11-22 | 文章网址改为 `posts/:title/`，与日期解耦；站内引用改用 `post_link` |
| 2026-11-23 | 撰写本维护手册 |
| 2026-11-23 | 修复：favicon 404（补 `source/img/favicon.png`，由头像缩放生成）；部署提交信息乱码（`now()` 改用 Luxon token）；首篇 3 处未闭合 `<span>`；代码块语言标注 |
| 2026-11-23 | 按实况修正手册：首页 10 篇/页、Node v24、卡片降级行为、`hexo new` 用法、PowerShell 清代理命令 |
