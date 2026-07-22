# 迁入真实程序项目说明

第一次迁移前先读 [`PLAIN_LANGUAGE_GUIDE.md`](PLAIN_LANGUAGE_GUIDE.md) 的“美术项目和真实程序项目怎么接”，并按 [`ART_ASSET_RULES.md`](ART_ASSET_RULES.md) 选择验证范围、填写 [`DELIVERY_TEMPLATE.md`](DELIVERY_TEMPLATE.md)。

目标程序项目：`/Users/ywh/Documents/godot-latest`

## 路径对应

```text
美术项目
├── Game/Scenes/game.tscn
│   └── 程序项目正式 game 装配壳的视觉参考
│
├── Features/Battle/Views/BattleMainView.tscn
│   └── godot-latest/scenes/ui/battle_flow/battle_ui.tscn
│
├── Features/Battle/Prefabs/Board
│   └── godot-latest/scenes/ui/battle_flow/prefabs/battle_cell.tscn
│
├── Features/Battle/Prefabs/Units
│   └── godot-latest/scenes/ui/battle_flow/prefabs/battle_unit.tscn
│
├── Features/Battle/Prefabs/HUD
│   └── godot-latest/scenes/ui/battle_flow/prefabs/battle_action_panel.tscn
│
├── Features/Battle/Prefabs/Effects
│   └── godot-latest/scenes/ui/battle_flow/prefabs/battle_*.tscn
│
└── Features/ArtistFlow
    └── godot-latest/scenes/ui/artist_flow
```

## 迁移时保留与替换

```text
保留
├── .tscn 节点结构
├── authored 位置和尺寸
├── 图片资源
├── AnimationPlayer 动画
├── 表现脚本
└── 公开方法和信号

替换
├── PreviewData
├── GamePreviewController
├── ArtistFlowPreviewController
└── BattleBoardController 中的演示规则
```

真实程序接管关系：

```text
godot-latest GameSession / Snapshot
└── 程序 Controller / Adapter
    └── 美术 ViewModel
        └── 本项目 View / Prefab
```

禁止将本项目的 mock 数据、预览存档和演示胜负逻辑迁入正式游戏作为真相源。
