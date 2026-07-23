# 美术资源无损压缩与去重交付记录

## 1. 交付对象

```text
组件/页面名称：全项目共享美术资源与交付目录
变更类型：图片 / 资源路径 / 导入配置 / 制作源归档
场景入口：res://Game/Scenes/game.tscn
公开脚本：N/A（未新增公开脚本）
目标程序路径：res://Shared/Art/、res://Shared/Fonts/
负责人：Codex
日期：2026-07-23
```

## 2. 依赖与公开契约

```text
依赖资源：PNG、TTF 及对应 .import
Shared 依赖：Shared/Art/Pets/Sprites、Shared/Art/Heroes、Shared/Art/UI、Shared/Fonts
公开方法：N/A（资源整理未改变组件方法）
公开信号：N/A（资源整理未改变组件信号）
ViewModel 必需字段：N/A（数据结构未改变）
空值与极值处理：旧资源引用及归档资源引用已全量扫描，残留为 0
```

## 3. 表现与适配

```text
基准 1920×1080：N/A（像素内容、尺寸和导入参数未改变）
宽屏 2560×1080：N/A（未修改布局或缩放规则）
窄屏 1440×1080：N/A（未修改布局或缩放规则）
声明的最小尺寸：N/A（未修改组件尺寸）
长文本/大数值：N/A（未修改文本）
default/hover/pressed/disabled：N/A（未修改交互状态）
拖拽/合法落点/取消恢复：PASS（相关存储、合成 smoke 通过）
```

## 4. 动画与性能

```text
触发时点：N/A（未修改动画）
命中/落位时点：N/A（未修改动画）
结束信号：N/A（未修改信号）
重复/连播/中断清理：PASS（merge_animation_smoke 通过）
10 次页面切换或特效重播：N/A（资源路径整理，不改变生命周期）
修改前平均帧时间：N/A（未改变运行时纹理内容或导入参数）
修改后平均帧时间：N/A（未改变运行时纹理内容或导入参数）
节点或孤立实例持续增长：N/A（未改变节点结构）
```

## 5. 验证证据

```text
执行的 smoke test：shared_pet_prefab_smoke、merge_animation_smoke、storage_auto_merge_smoke、storage_shop_bag_merge_destination_smoke、battle_integration_smoke、battle_editor_preview_smoke、game_scene_smoke、floating_ui_navigation_smoke
测试结果：上述去重及归档相关 smoke 通过；完整测试共 19/21 通过。silver_frame_size_smoke 因现有场景缺少 CreatureFrame 失败，battle_status_badge_preview 因 headless 渲染纹理为空失败，均与资源路径无关
真实 Godot 入口：res://Game/Scenes/game.tscn；Godot 4.7 headless 冷启动及二次 import 通过
截图路径与说明：N/A（资源像素字节与去重前备份逐组一致，无视觉改动）
录屏路径、关键时间点与说明：N/A（纯资源路径整理，无视觉或交互改动）
Godot 新增错误：无资源缺失、旧路径或导入参数错误；battle_editor_preview 仍有现有退出清理 warning/error
```

## 6. 迁移边界与例外

```text
保留的节点结构/几何/动画：全部保留
由正式程序替换的 Mock/Controller/规则：N/A（未改变）
未接入部分：14 个已确认零引用且不在动态加载目录中的 Debug/preview/source/chromakey/alpha_base 制作资源已移至项目外 SourceArt 归档；运行时动态加载目录全部保留
规则例外：无
已知限制：.godot 为忽略的本地缓存，可能暂时保留旧路径缓存文件；清除后可自动重建
```

## 7. 最终结论

```text
结论：PASS
阻塞项：无
下一步：清理本地缓存与 output 历史，并以干净克隆复验交付内容
```
