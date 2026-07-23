# 根目录地点场景与独立预制体交付记录

## 1. 交付对象

```text
组件/页面名称：MainMenu、ArtistFlow、Battle 根目录地点场景
变更类型：目录 / 布局编排 / 预制体边界 / 稳定入口
场景入口：res://Scenes/MainMenu/MainMenuScene.tscn、res://Scenes/ArtistFlow/ArtistFlowScene.tscn、res://Scenes/Battle/BattleScene.tscn
公开脚本：沿用各地点原 Controller；本次未新增地点业务脚本
目标程序路径：Features/*/Views 原路径继续可用
负责人：Codex
日期：2026-07-23
```

## 2. 依赖与公开契约

```text
依赖资源：Features/*/Prefabs、Shared/Prefabs、各 Feature/Art
Shared 依赖：GoldCounter、既有 Theme、按钮与宠物表现组件
公开方法：沿用三个原 View/Controller 的 setup()/refresh() 等接口
公开信号：沿用 screen_requested 及各页面既有语义信号
ViewModel 必需字段：未改变
空值与极值处理：未改变
```

## 3. 表现与适配

```text
基准 1920×1080：PASS（三个根场景均直接启动并在真实 Godot 窗口检查）
宽屏 2560×1080：N/A（本次迁移未改变项目既有页面适配策略）
窄屏 1440×1080：N/A（本次迁移未改变项目既有页面适配策略）
声明的最小尺寸：沿用项目 1920×1080 逻辑画布
长文本/大数值：PASS（全量既有回归测试通过）
default/hover/pressed/disabled：PASS（原主菜单和页面交互 smoke 通过）
拖拽/合法落点/取消恢复：PASS（既有 ArtistFlow/Battle 回归测试通过）
```

## 4. 动画与性能

```text
触发时点：沿用各独立 Prefab
命中/落位时点：沿用各独立 Prefab
结束信号：沿用各独立 Prefab
重复/连播/中断清理：PASS（既有合成、合成标记和战斗预览 smoke 通过）
10 次页面切换或特效重播：N/A（本次为场景引用迁移，未新增运行时循环）
修改前平均帧时间：N/A
修改后平均帧时间：N/A
节点或孤立实例持续增长：无新增
```

## 5. 验证证据

```text
执行的 smoke test：21 个无头 smoke、battle_status_badge_preview、battle_editor_preview_smoke
测试结果：PASS（23/23）
真实 Godot 入口：三个 res://Scenes/<Location>/<Location>Scene.tscn 均直接启动
截图路径与说明：N/A（本次用桌面实窗逐一检查，未新增静态截图文件）
录屏路径、关键时间点与说明：N/A（目录和引用边界改造，无新增交互动效）
Godot 新增错误：无；battle_editor_preview 退出时仍有原测试既存 RID/ObjectDB 清理警告，不影响退出码和本次场景结果
```

## 6. 迁移边界与例外

```text
保留的节点结构/几何/动画：三个原页面的 authored 位置、尺寸、层级和资源；主菜单画面拆成可摆位 Prefab 实例
由正式程序替换的 Mock/Controller/规则：未改变
未接入部分：SettingsOverlay 等历史子页面保持现有稳定 View 路径，后续实际修改时再按新规范渐进拆分
规则例外：无
已知限制：Godot 不会把 Editable Children 的内部覆盖自动反向写入源 Prefab；必须应用到独立 Prefab 并清除实例覆盖，自动测试负责阻止带覆盖交付
```

## 7. 最终结论

```text
结论：PASS
阻塞项：无
下一步：新增地点继续放在根目录 Scenes；新增可见组件先做 Prefab，再拖入地点场景摆位
```
