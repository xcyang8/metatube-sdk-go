# MetaTube SDK Go

[![Build Status](https://img.shields.io/github/actions/workflow/status/metatube-community/metatube-sdk-go/docker.yml?branch=main&style=flat-square&logo=github-actions)](https://github.com/metatube-community/metatube-sdk-go/actions/workflows/release.yml)
[![Go Report Card](https://goreportcard.com/badge/github.com/metatube-community/metatube-sdk-go?style=flat-square)](https://github.com/metatube-community/metatube-sdk-go)
[![Require Go Version](https://img.shields.io/badge/go-%3E%3D1.25-30dff3?style=flat-square&logo=go)](https://github.com/metatube-community/metatube-sdk-go/blob/main/go.mod)
[![GitHub License](https://img.shields.io/github/license/metatube-community/metatube-sdk-go?color=e4682a&logo=apache&style=flat-square)](https://github.com/metatube-community/metatube-sdk-go/blob/main/LICENSE)
[![Tag](https://img.shields.io/github/v/tag/metatube-community/metatube-sdk-go?color=%23ff8936&logo=fitbit&style=flat-square)](https://github.com/metatube-community/metatube-sdk-go/tags)

Metadata Tube SDK in Golang.

## API 参考

### 概述

| 属性 | 值 |
|------|-----|
| 基础地址 | `http://host:port/v1` |
| 认证方式 | Bearer Token (`Authorization: Bearer <token>`) |
| 响应格式 | JSON |
| 请求方法 | 仅支持 GET |

### 响应格式

所有接口返回统一的 JSON 信封：

```json
{
  "data": { ... },
  "error": null
}
```

出错时：

```json
{
  "data": null,
  "error": {
    "code": 400,
    "message": "错误描述"
  }
}
```

### 接口列表

#### 系统接口（无需认证）

| 方法 | 路径 | 说明 |
|------|------|------|
| GET | `/` | 应用信息（名称、版本号） |
| GET | `/v1/modules` | Go 模块依赖版本列表 |
| GET | `/v1/providers` | 所有支持的演员及电影数据源列表 |

#### 图片接口（无需认证）

| 方法 | 路径 | 说明 |
|------|------|------|
| GET | `/v1/images/primary/:provider/:id` | 主海报/封面图 |
| GET | `/v1/images/thumb/:provider/:id` | 缩略图 |
| GET | `/v1/images/backdrop/:provider/:id` | 背景图 |

查询参数（全部可选）：

| 参数 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `url` | string | — | 自定义图片处理 URL |
| `ratio` | float | 自动 | 宽高裁切比例 |
| `pos` | float | 0.5 | 裁切位置（0.0~1.0） |
| `auto` | bool | false | 自动检测裁切区域 |
| `badge` | string | — | 徽章文字覆盖 |
| `quality` | int | 90 | JPEG 质量（1~100） |

响应头：
- `X-MetaTube-Image-Width`: 图片宽度（像素）
- `X-MetaTube-Image-Height`: 图片高度（像素）

#### 翻译接口（无需认证）

| 方法 | 路径 | 说明 |
|------|------|------|
| GET | `/v1/translate` | 通过外部引擎翻译文本 |

查询参数：

| 参数 | 类型 | 必填 | 默认值 | 说明 |
|------|------|------|--------|------|
| `q` | string | 是 | — | 待翻译文本 |
| `from` | string | 否 | `auto` | 源语言代码 |
| `to` | string | 是 | — | 目标语言代码 |
| `engine` | string | 是 | — | 翻译引擎名称 |

响应示例：

```json
{
  "data": {
    "from": "auto",
    "to": "zh",
    "translated_text": "翻译结果"
  },
  "error": null
}
```

支持的翻译引擎：`baidu`、`deepl`、`google`、`googlefree`、`openai`。

#### 数据库接口（需要认证）

| 方法 | 路径 | 说明 |
|------|------|------|
| GET | `/v1/db/version` | 获取数据库架构版本号 |

#### 演员接口（需要认证）

| 方法 | 路径 | 说明 |
|------|------|------|
| GET | `/v1/actors/:provider/:id` | 根据数据源 ID 获取演员详情 |
| GET | `/v1/actors/search` | 按关键词或 URL 搜索演员 |

**演员详情** — `GET /v1/actors/:provider/:id`

路径参数：
- `provider`: 数据源名称（如 `gfriends`）
- `id`: 该数据源上的演员 ID

查询参数：
- `lazy`（布尔值，默认 `true`）：优先从缓存获取

响应结构参见 [ActorInfo](#actorinfo)。

**演员搜索** — `GET /v1/actors/search`

查询参数：

| 参数 | 类型 | 必填 | 默认值 | 说明 |
|------|------|------|--------|------|
| `q` | string | 是 | — | 搜索关键词或 URL |
| `provider` | string | 否 | — | 限定特定数据源 |
| `fallback` | bool | 否 | `true` | 失败时尝试其他数据源 |

返回 [ActorSearchResult](#actorsearchresult) 数组。

#### 电影接口（需要认证）

| 方法 | 路径 | 说明 |
|------|------|------|
| GET | `/v1/movies/:provider/:id` | 根据数据源 ID 获取电影详情 |
| GET | `/v1/movies/search` | 按关键词或 URL 搜索电影 |

**电影详情** — `GET /v1/movies/:provider/:id`

路径参数：
- `provider`: 数据源名称（如 `javbus`、`fanza`）
- `id`: 该数据源上的电影 ID

查询参数：
- `lazy`（布尔值，默认 `true`）：优先从缓存获取

响应结构参见 [MovieInfo](#movieinfo)。

**电影搜索** — `GET /v1/movies/search`

查询参数：

| 参数 | 类型 | 必填 | 默认值 | 说明 |
|------|------|------|--------|------|
| `q` | string | 是 | — | 搜索关键词或 URL |
| `provider` | string | 否 | — | 限定特定数据源 |
| `fallback` | bool | 否 | `true` | 失败时尝试其他数据源 |

返回 [MovieSearchResult](#moviesearchresult) 数组。

#### 评论接口（需要认证）

| 方法 | 路径 | 说明 |
|------|------|------|
| GET | `/v1/reviews/:provider/:id` | 获取电影评论 |

查询参数：
- `homepage`（字符串，可选）：使用完整数据源 URL 代替 provider+id
- `lazy`（布尔值，默认 `true`）：优先从缓存获取

返回 [MovieReviewDetail](#moviereviewdetail) 数组。

### 数据模型

#### ActorInfo

| 字段 | 类型 | 说明 |
|------|------|------|
| `id` | string | 演员唯一标识 |
| `name` | string | 演员显示名称 |
| `provider` | string | 数据源名称 |
| `homepage` | string | 来源页面 URL |
| `summary` | string | 个人简介 |
| `hobby` | string | 爱好 |
| `skill` | string | 特长 |
| `blood_type` | string | 血型 |
| `cup_size` | string | 罩杯 |
| `measurements` | string | 三围 |
| `nationality` | string | 国籍 |
| `height` | int | 身高（厘米） |
| `aliases` | string[] | 别名列表 |
| `images` | string[] | 图片 URL 列表 |
| `birthday` | date | 生日（YYYY-MM-DD） |
| `debut_date` | date | 出道日期（YYYY-MM-DD） |

#### ActorSearchResult

| 字段 | 类型 | 说明 |
|------|------|------|
| `id` | string | 演员唯一标识 |
| `name` | string | 演员显示名称 |
| `provider` | string | 数据源名称 |
| `homepage` | string | 来源页面 URL |
| `aliases` | string[] | 别名列表 |
| `images` | string[] | 图片 URL 列表 |

#### MovieInfo

| 字段 | 类型 | 说明 |
|------|------|------|
| `id` | string | 电影唯一标识 |
| `number` | string | 番号/发行编号 |
| `title` | string | 电影标题 |
| `summary` | string | 剧情简介 |
| `provider` | string | 数据源名称 |
| `homepage` | string | 来源页面 URL |
| `director` | string | 导演 |
| `actors` | string[] | 演员名单 |
| `thumb_url` | string | 缩略图 URL |
| `big_thumb_url` | string | 大尺寸缩略图 URL |
| `cover_url` | string | 封面图 URL |
| `big_cover_url` | string | 大尺寸封面图 URL |
| `preview_video_url` | string | 预览视频 URL |
| `preview_video_hls_url` | string | HLS 预览视频 URL |
| `preview_images` | string[] | 预览图片 URL 列表 |
| `maker` | string | 制作商 |
| `label` | string | 发行商标 |
| `series` | string | 系列名称 |
| `genres` | string[] | 分类标签 |
| `score` | float | 评分 |
| `runtime` | int | 时长（分钟） |
| `release_date` | date | 发行日期（YYYY-MM-DD） |

#### MovieSearchResult

| 字段 | 类型 | 说明 |
|------|------|------|
| `id` | string | 电影唯一标识 |
| `number` | string | 番号/发行编号 |
| `title` | string | 电影标题 |
| `provider` | string | 数据源名称 |
| `homepage` | string | 来源页面 URL |
| `thumb_url` | string | 缩略图 URL |
| `cover_url` | string | 封面图 URL |
| `score` | float | 评分 |
| `actors` | string[] | 演员名单 |
| `release_date` | date | 发行日期（YYYY-MM-DD） |

#### MovieReviewDetail

| 字段 | 类型 | 说明 |
|------|------|------|
| `title` | string | 评论标题 |
| `author` | string | 评论者 |
| `comment` | string | 评论内容 |
| `score` | float | 评分 |
| `date` | date | 评论日期（YYYY-MM-DD） |

### 重定向快捷方式

任何带有 `?redirect=` 查询参数的请求都会自动重定向到数据源的原始页面：

```
GET /?redirect=javbus,ABC-123
```

服务器会根据 provider ID 查找对应的电影或演员，然后发出 HTTP 302 重定向到来源页面。

### 缓存策略

- **公开接口**（`/v1/images/*`、`/v1/translate`）：`s-maxage=180 天`，适合 CDN 缓存
- **系统接口**（`/v1/modules`、`/v1/providers`）：不缓存（`no-store`）
- **私有接口**：由客户端/CDN 控制

### 认证说明

当配置了访问令牌（通过 `--token` 命令行参数或 `TOKEN` 环境变量）后，所有需要认证的接口都必须携带：

```
Authorization: Bearer <your-token>
```

缺少有效令牌或令牌无效时，请求将收到 HTTP 401 响应。

## Contents

- [MetaTube SDK Go](#metatube-sdk-go)
    - [Contents](#contents)
    - [Features](#features)
    - [Installation](#installation)
    - [API 参考](#api-reference)
    - [Credits](#credits)
    - [License](#license)

## Features

- Supported platforms
    - Linux
    - Darwin
    - Windows
    - BSD(s)
- Supported Databases
    - [SQLite](https://gitlab.com/cznic/sqlite)
    - [PostgreSQL](https://github.com/jackc/pgx)
- Image processing
    - Auto cropping
    - Badge support
    - Face detection
    - Image hashing
- RESTful API
- 20+ providers
- Text translation

## Installation

To install this package, you first need [Go](https://golang.org/) installed (**go1.25+ is required**), then you can use
the below Go command to install SDK.

```sh
go get -u github.com/metatube-community/metatube-sdk-go
```

## Credits

| Library														                                           | Description																						                                                                    |
|-----------------------------------------------------------------|------------------------------------------------------------------------------------------------------|
| [gocolly/colly](https://github.com/gocolly/colly)			            | Elegant Scraper and Crawler Framework for Golang													                                        |
| [gin-gonic/gin](https://github.com/gin-gonic/gin)			            | Gin is a HTTP web framework written in Go															                                             |
| [gorm.io/gorm](https://gorm.io/)								                        | The fantastic ORM library for Golang																                                                 |
| [esimov/pigo](https://github.com/esimov/pigo)				               | Fast face detection, pupil/eyes localization and facial landmark points detection library in pure Go |
| [robertkrimen/otto](https://github.com/robertkrimen/otto)       | A JavaScript interpreter in Go (golang)                                                              |
| [modernc.org/sqlite](https://gitlab.com/cznic/sqlite)		         | Package sqlite is a CGo-free port of SQLite/SQLite3												                                      |
| [corona10/goimagehash](https://github.com/corona10/goimagehash) | Go Perceptual image hashing package																                                                  |
| [antchfx/xpath](https://github.com/antchfx/xpath)			            | XPath package for Golang, supports HTML, XML, JSON document query									                           |
| [gen2brain/jpegli](https://github.com/gen2brain/jpegli)         | Go encoder/decoder for JPEG based on jpegli                                                          |

## License

[Apache-2.0 License](https://github.com/metatube-community/metatube-sdk-go/blob/main/LICENSE)
