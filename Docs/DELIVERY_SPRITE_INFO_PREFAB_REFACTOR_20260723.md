# 宠物详情预制体组件化交付记录

## 1. 交付对象

```text
组件/页面名称：SpriteInfoPanel、BattleUnit 内部脚本组件
变更类型：布局 / 接口 / 预制体组件化
场景入口：res://Shared/Prefabs/Pet/SpriteInfoPanel.tscn
位置验收场景：res://Features/ArtistFlow/Preview/SpriteInfoPanelPreview.tscn
公开脚本：res://Shared/Prefabs/Pet/SpriteInfoPanel.gd
目标程序路径：N/A（本次只重构美术项目，未写入 /Users/ywh/Documents/godot-latest）
负责人：Codex
日期：2026-07-23
```

## 2. 依赖与公开契约

```text
依赖资源：Shared/Prefabs/Pet/SpriteInfo/Art、Shared/Fonts/fusion-pixel-10px-monospaced-zh_hans.ttf
Shared 依赖：SpriteInfoData、SpriteRankStats
公开方法：display_info(info)、clear()
公开信号：N/A（只读信息组件，不接收玩家操作）
ViewModel 必需字段：SpriteInfoData 及其当前 SpriteRankStats
空值与极值处理：null 隐藏；恢复有效数据后重新显示；攻击索引裁剪；长数值自动缩小字号
```

## 3. 表现与适配

```text
基准 1920×1080：PASS（项目逻辑视口，真实 Godot 预览可见通过）
宽屏 2560×1080：N/A（固定 348×531 组件，本次未改页面级锚点）
窄屏 1440×1080：N/A（固定 348×531 组件，本次未改页面级锚点）
声明的最小尺寸：348×531
长文本/大数值：PASS（sprite_info_panel_prefab_smoke 覆盖 9 位攻击数值）
default/hover/pressed/disabled：N/A（只读信息组件无按钮状态）
拖拽/合法落点/取消恢复：N/A（只读信息组件不负责拖拽）
```

## 4. 动画与性能

```text
触发时点：调用 display_info(info) 时立即刷新
命中/落位时点：N/A（无战斗结算或落点逻辑）
结束信号：N/A（无异步动画）
重复/连播/中断清理：PASS（连续刷新 10 次，攻击格始终为 21）
10 次页面切换或特效重播：PASS（以 10 次组件刷新覆盖本组件生命周期）
修改前平均帧时间：N/A（没有持续处理或新增重型渲染资源）
修改后平均帧时间：N/A（没有持续处理或新增重型渲染资源）
节点或孤立实例持续增长：无
```

## 5. 验证证据

```text
执行的 smoke test：Godot editor import、location_scene_prefab_sync_smoke、sprite_info_panel_prefab_smoke、art_architecture_boundaries_smoke、shared_pet_prefab_smoke、battle_editor_preview_smoke，以及其余项目回归 smoke
测试结果：PASS（21/21 无头测试；2/2 渲染/编辑器测试；合计 23/23）
真实 Godot 入口：res://Features/ArtistFlow/Preview/SpriteInfoPanelPreview.tscn
截图路径与说明：output/sprite_info_panel_prefab_20260723.jpg；真实 Godot 窗口中的钻石品质、土属性、21 格攻击范围和六项数值
录屏路径、关键时间点与说明：N/A（组件没有交互或动画，真实窗口截图与 10 次刷新 smoke 足以覆盖本次变更）
Godot 新增错误：无
```

## 6. 迁移边界与例外

```text
保留的节点结构/几何/动画：保留 348×531、280 宽内容区、54 高 Header、150 高攻击面板、214 高属性表及现有图片资源；内部 authored 几何继续由独立 Prefab 保存
由正式程序替换的 Mock/Controller/规则：SpriteInfoPanelPreview.gd 中的演示 SpriteInfoData
未接入部分：未迁入 godot-latest；未改变正式 Snapshot 或宠物规则
规则例外：无
已知限制：原始水属性图片文件名为历史字符“ˮ.png”，根脚本提供“水”别名兼容，不在本次擅自重命名历史资源
```

## 7. 最终结论

```text
结论：PASS
阻塞项：无
下一步：迁入正式程序时保留子预制体结构，只由正式 Adapter 调用根组件公开方法
```
