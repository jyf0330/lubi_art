# 美术项目目录与文件职责

## 当前结构

```text
项目根目录/
├── Game/
│   ├── Scenes/game.tscn
│   │   [唯一主场景，无业务数据]
│   └── Controllers/GamePreviewController.gd
│       [有代码：实例化、切换和释放完整美术页面]
│
├── Features/
│   ├── MainMenu/
│   │   ├── Views/
│   │   │   [主菜单、设置、存档和弹窗场景]
│   │   ├── Controllers/
│   │   │   [菜单预览导航代码]
│   │   ├── Preview/
│   │   │   [按钮样式独立预览]
│   │   └── Art/
│   │       [主菜单纯美术图片]
│   │
│   ├── ArtistFlow/
│   │   ├── Views/ArtistFlowView.tscn
│   │   │   [三选、商店、背包、队伍的现有组合美术场景]
│   │   ├── Controllers/
│   │   │   ├── ArtistFlowPreviewController.gd
│   │   │   │   [有代码：用 mock 数据驱动组合场景]
│   │   │   └── ArtistFlowDebugController.gd
│   │   │       [有代码：调试图片轮换]
│   │   ├── Prefabs/
│   │   │   ├── Route/RouteOptionSlot.tscn
│   │   │   ├── Shop/ShopSlot.tscn
│   │   │   ├── Inventory/BagSlot.tscn
│   │   │   └── Party/PartySlot.tscn
│   │   └── Art/
│   │       [组合流程使用的图片、宠物、商店人物和生成帧]
│   │
│   └── Battle/
│       ├── Views/BattleMainView.tscn
│       ├── Controllers/
│       ├── Prefabs/
│       │   ├── Board/
│       │   ├── Units/
│       │   ├── HUD/
│       │   └── Effects/
│       ├── Art/
│       ├── Preview/
│       └── Legacy/
│
├── Shared/
│   ├── Art/Shadows/
│   ├── Fonts/
│   ├── Shaders/
│   ├── Themes/
│   ├── UI/Buttons/
│   └── Prefabs/Pet/
│       [跨战斗、队伍和背包复用的宠物表现资源]
│
├── PreviewData/
│   ├── Mock/MockGameData.gd
│   │   [集中假数据]
│   ├── Providers/GameDataProvider.gd
│   │   [预览数据读取入口]
│   └── State/GameSessionStore.gd
│       [预览流程临时状态]
│
├── Tests/
│   ├── Prefabs/
│   ├── Views/
│   └── Integration/
│
├── Legacy/
│   [历史场景与配置备份，不作为新代码入口]
│
├── Docs/
├── output/
└── project.godot
```

## 固定依赖方向

```text
PreviewData
└── Preview Controller
    └── View
        └── Prefab
            └── Art / Shared
```

运行时页面切换也遵循单向关系：

```text
View / Prefab 发出 screen_requested
└── game 接收请求
    └── 实例化、切换和释放完整页面预制体
```

任何 Feature View 都不得自行调用 `change_scene_to_file()`；独立预览场景
可以接收信号后选择路由，但正式主流程的页面生命周期只属于 `game`。

禁止反向依赖：

```text
Art          不读取脚本状态
Prefab       不直接读取存档或全局业务状态
View         不决定正式游戏规则
MockData     不写进美术预制体
game         不访问预制体深层节点
```

## 文件放置判断

```text
完整页面                    -> Features/<功能>/Views
页面连接和预览流程代码      -> Features/<功能>/Controllers
可重复实例化的 .tscn        -> Features/<功能>/Prefabs
跨功能复用的组件            -> Shared
PNG、序列帧、图标           -> Art
假数据                      -> PreviewData
独立美术演示                -> Preview
旧版本但暂时不能删除        -> Legacy
```

所有可交互 Prefab 必须有同目录或 Shared 中的表现脚本，至少提供
`setup(view_model)` / `refresh(view_model)` 与语义信号。页面 Controller
不得把 TextureButton、Label 等深层节点当成跨组件接口。

`ArtistFlow` 当前仍是一个组合大场景，所以保持为一个真实功能目录。将来商店、背包、队伍、路线被拆成独立完整页面后，再分别迁入独立 Feature，不能只改文件夹制造已经拆分的假象。
