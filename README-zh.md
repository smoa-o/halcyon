# Halcyon操作系统

语言: [中文](./README-zh.md) [English](./README.md)

[![star](https://gitee.com/smoa-new/halcyon/badge/star.svg?theme=dark)](https://gitee.com/smoa-new/halcyon/stargazers)
[![fork](https://gitee.com/smoa-new/halcyon/badge/fork.svg?theme=dark)](https://gitee.com/smoa-new/halcyon/members)
[![Fork me on Gitee](https://gitee.com/smoa-new/halcyon/widgets/widget_6.svg)](https://gitee.com/smoa-new/halcyon)

## 项目简介

Halcyon操作系统是一个完全独立的操作系统，集成了操作系统内核以及基础API。

## 特性

1. 独立: Halcyon作为一个完全独立的操作系统，不依赖于任何目前存在的任何操作系统平台。

2. 开发: Halcyon32 API作为系统内置的API，且用户可自主扩展。

3. 兼容: 可运行任何DOS时代的可执行文件 (扩展名.com)

4. 新颖: 不使用Windows的.exe，然后是自主开发一个Halcyon可执行文件 (.vexe)

## 目录结构说明

### 未安装前

A:\IVT\IVT.COM - 启动时运行一次，设置IVT

A:\IVT\LDR.COM - 由IVT.COM启动，用于加载

A:\SYSCMD\     - 系统内置命令

### 安装后 (新增)

A:\CONFIG\    - 每个应用程序的配置文件夹

A:\EXTCMD\    - 系统扩展命令

### 特殊 (默认不存在)

A:\AUTOEXEC.BAT - 每次显示 `A:\>` 前运行

## 联系我们

邮箱: [sauthm_2015@qq.com](mailto:sauthm_2015@qq.com)

QQ群: 183241333
移动端点这里便捷进入: [183241333](mqqapi://card/show_pslcard?src_type=internal&version=1&uin=183241333&card_type=group)
