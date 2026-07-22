# Battle 文件说明

```text
Features/Battle/
├── Views/
│   └── BattleMainView.tscn
│       [完整战斗美术页面]
├── Controllers/
│   ├── BattleMainController.gd
│   │   [背景、金币、设置菜单等页面级预览连接]
│   └── BattleBoardController.gd
│       [棋盘演示流程、单位实例化、按钮连接和特效调度]
├── Prefabs/
│   ├── Board/
│   │   [棋盘格与独立棋盘预览组件]
│   ├── Units/
│   │   [战斗单位、状态、交互和阴影]
│   ├── HUD/
│   │   [时钟、回合横幅等战斗界面组件]
│   └── Effects/
│       [伤害数字、元素弹道和咬击特效]
├── Art/
│   ├── Heroes/
│   ├── Units/
│   ├── UI/
│   ├── Tiles/
│   └── Combat/
│       [纯图片资源，不保存业务数据]
├── Preview/
│   [独立棋盘预览场景、控制器和 mock 数据]
└── Legacy/
    [未进入当前运行入口的历史场景]
```

依赖方向：

```text
PreviewData -> Controllers -> Views/Prefabs -> Art
```

`Prefabs` 只放真正可以实例化的 `.tscn` 及其表现脚本。图片、序列帧和图标统一放在 `Art`。
