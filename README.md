# 西游美术组件项目

这是供真实游戏程序接入的 Godot 美术组件项目。项目可以使用集中 mock 数据独立预览，但不保存正式战斗规则、经济规则或正式存档状态。

本地说明入口：

- `Docs/PROJECT_STRUCTURE.md`：目录树、文件职责和代码归属。
- `Docs/COMPONENT_API.md`：预制体公开方法、信号和接入约束。
- `Docs/PROGRAM_INTEGRATION.md`：迁入 `/Users/ywh/Documents/godot-latest` 的对应路径。
- `Features/Battle/README.md`：战斗功能内部文件说明。

运行入口：

```text
project.godot
└── Game/Scenes/game.tscn
    └── Game/Controllers/GamePreviewController.gd
        ├── MainMenuView
        ├── ArtistFlowView
        └── BattleMainView
```
