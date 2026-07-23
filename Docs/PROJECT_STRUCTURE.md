# 美术项目目录与文件职责

第一次看项目时，建议先读 [`PLAIN_LANGUAGE_GUIDE.md`](PLAIN_LANGUAGE_GUIDE.md)。本文件负责精确目录和硬规则，大白话说明负责解释为什么这样分。新增或修改资源、UI 和动效时同时遵守 [`ART_ASSET_RULES.md`](ART_ASSET_RULES.md)。

## 当前结构

```text
项目根目录/
├── Scenes/
│   ├── MainMenu/MainMenuScene.tscn
│   ├── ArtistFlow/ArtistFlowScene.tscn
│   │   [路线、商店、背包、队伍等多个预制体的地点编排场景]
│   └── Battle/BattleScene.tscn
│       [棋盘、操作栏、金币栏等多个预制体的地点编排场景]
│
├── Game/
│   ├── Scenes/game.tscn
│   │   [唯一主场景，无业务数据]
│   └── Controllers/GamePreviewController.gd
│       [有代码：实例化、切换和释放完整美术页面]
│
├── Features/
│   ├── MainMenu/
│   │   ├── Views/
│   │   │   [程序稳定入口；主菜单入口指向根目录 Scenes/MainMenu]
│   │   ├── Prefabs/
│   │   │   ├── Artwork/MainMenuArtSprite.tscn
│   │   │   │   [主菜单角色、背景和标题的可摆位图片实例]
│   │   │   └── Buttons/
│   │   │       [开始按钮与通用菜单操作按钮]
│   │   ├── Controllers/
│   │   │   [菜单预览导航代码]
│   │   ├── Preview/
│   │   │   [按钮样式独立预览]
│   │   └── Art/
│   │       [主菜单纯美术图片]
│   │
│   ├── ArtistFlow/
│   │   ├── Views/ArtistFlowView.tscn
│   │   │   [程序稳定入口；实例化根目录 ArtistFlowScene]
│   │   ├── Controllers/
│   │   │   ├── ArtistFlowPreviewController.gd
│   │   │   │   [有代码：用 mock 数据驱动组合场景]
│   │   │   └── ArtistFlowDebugController.gd
│   │   │       [有代码：调试图片轮换]
│   │   ├── Prefabs/
│   │   │   ├── Effects/MergeBurstView.tscn
│   │   │   ├── Route/RouteOptionsPanelView.tscn
│   │   │   │   └── RouteOptionSlot.tscn × 3
│   │   │   ├── Shop/ShopPanelView.tscn
│   │   │   │   └── ShopSlot.tscn × 5
│   │   │   ├── Inventory/InventoryPanelView.tscn
│   │   │   │   └── BagSlot.tscn × 5
│   │   │   ├── Inventory/BagLauncherView.tscn
│   │   │   ├── Party/PartyBarView.tscn
│   │   │   │   └── PartySlot.tscn × 4
│   │   │   └── Navigation/TopActionBarView.tscn
│   │   └── Art/
│   │       [组合流程使用的图片、宠物、商店人物和生成帧]
│   │
│   └── Battle/
│       ├── Views/BattleMainView.tscn [程序稳定入口；实例化根目录 BattleScene]
│       ├── Controllers/
│       ├── Prefabs/
│       │   ├── Board/
│       │   │   [棋盘、悬停/行动标记、元素陷阱独立表现]
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
│   └── Prefabs/
│       ├── Pet/
│       │   ├── CollectionPetView.tscn
│       │   │   [商店、队伍、背包和拖拽预览统一宠物卡片表现]
│       │   └── SpriteInfoPanel.tscn
│       │       [宠物详情独立预制体及内部布局真相源]
│       └── HUD/GoldCounter/GoldCounterView.tscn
│           [ArtistFlow 与 Battle 共用的金币显示]
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

地点场景与预制体的同步方向固定为：

```text
Prefab                         [内部布局、资源、状态和动画真相源]
└── Scenes/<Location>          [多个 Prefab 在地点中的整体位置]
    └── Features/*/Views       [程序稳定入口]
        └── game               [地点切换与生命周期]
```

在地点场景中试出的预制体内部调整必须同步到独立 Prefab，并清除场景实例的内部覆盖。完整规则见 [`SCENE_PREFAB_WORKFLOW.md`](SCENE_PREFAB_WORKFLOW.md)。

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
不同地点的可编辑组合场景    -> 根目录 Scenes/<地点>
程序使用的稳定页面入口      -> Features/<功能>/Views
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

`Scenes/ArtistFlow/ArtistFlowScene.tscn` 是路线商店地点装配层，不再内嵌商店、背包、队伍、路线和顶部操作栏的完整节点树。这些区域必须继续保持为独立的脚本预制体；地点场景只实例化、定位并编排它们。只有当某一区域发展为独立地点时，才新增根目录 Scene，不能只改文件夹制造已经拆分的假象。
