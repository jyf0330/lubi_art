# 这个美术项目到底怎么用（大白话版）

## 先用一句话说明

这个项目不是用来决定“游戏怎么算”的，而是用来把“游戏应该怎么显示、怎么动、怎么点”做好。

```text
真实程序项目
└── 像汽车的发动机和电脑
    ├── 决定伤害多少
    ├── 决定金币多少
    ├── 决定谁赢谁输
    ├── 保存和读取存档
    └── 把最终结果交给界面

这个美术项目
└── 像汽车的车身、仪表盘和按钮
    ├── 显示角色和棋盘
    ├── 显示血量、金币和文字
    ├── 播放攻击和受伤动画
    ├── 接收鼠标点击和拖动
    └── 把玩家操作告诉真实程序
```

## `game` 是什么

`game` 是这个美术项目的总展厅，不是正式游戏规则中心。

```text
game
├── 想看主菜单，就摆出 MainMenuView
├── 想看路线、商店和背包，就摆出 ArtistFlowView
└── 想看战斗，就摆出 BattleMainView
```

切换界面时，`game` 做的事情只有：

```text
收起旧页面
└── 实例化新页面
    └── 把演示数据交给新页面
        └── 转发页面发出的操作信号
```

`game` 不应该自己计算攻击、商店价格、战斗胜负，也不应该伸手修改预制体内部很深的按钮和文字。

## 预制体是什么

预制体就是可以整块搬走、重复使用的美术零件。

```text
BattleMainView（完整战斗页面）
├── BattleCell（一个棋盘格）
├── BattleUnit（一个角色或宠物）
├── BattleActionPanel（战斗按钮区）
├── GoldCounterView（金币显示）
├── DamageNumber（伤害数字）
├── ElementBullet（元素弹道）
├── MonsterBiteEffect（咬击特效）
└── RoundBanner（回合横幅）
```

一个合格的预制体应该像一个封装好的电器：外面只需要知道插头和按钮，不需要拆开外壳接内部电线。

```text
外部程序允许做
├── setup(view_model)
├── refresh(view_model)
├── play(animation_data)
└── 监听 xxx_requested 信号

外部程序不应该做
├── 找到预制体第 5 层的 Label 再改文字
├── 找到内部 TextureButton 强行连接事件
├── 依赖某个内部节点必须排在第几个
└── 把正式 GameState 直接塞给美术节点
```

## Controller 是什么

Controller 是真实数据和美术界面之间的转接头。

```text
数据说：
“玩家金币是 15”

Controller 翻译成：
GoldCounterView.setup({"value": 15})

金币预制体负责：
把画面上的数字显示为 15
```

再比如玩家点击“开始行动”：

```text
玩家点击按钮
└── BattleActionPanel 发出 begin_turn_requested
    └── Controller 收到信号
        └── 演示环境调用 Mock 流程
        └── 真实程序调用正式 Battle Command
```

同一个按钮预制体不用知道自己接的是假数据还是真实程序。

## Mock 数据是什么

Mock 数据就是为了让美术项目能单独运行而准备的演示数据。

```text
没有真实程序时
└── MockGameData 提供演示金币、宠物、商店和战斗单位
    └── Controller 把数据传给美术预制体
        └── 美术可以独立检查排版和动画
```

Mock 数据只是一块“演示电池”，不是正式规则。

```text
Mock 可以决定
├── 预览时先显示哪几只宠物
├── 预览金币显示多少
└── 为了看动画临时播放哪次攻击

Mock 不可以变成
├── 正式宠物属性来源
├── 正式伤害计算规则
├── 正式商店价格来源
├── 正式胜负规则
└── 正式存档
```

## 为什么要分目录

目录不是为了看起来专业，而是为了让人一眼知道文件能不能搬、能不能改、归谁负责。

```text
Game/
└── 总展厅和页面切换代码

Features/
├── MainMenu/       主菜单功能
├── ArtistFlow/     路线、商店、背包和队伍展示
└── Battle/         战斗页面和战斗表现

Shared/
└── 多个功能都会用到的按钮、字体、主题、宠物表现和金币栏

PreviewData/
└── 只为独立预览服务的假数据和临时状态

Tests/
└── 检查场景能否加载、接口是否还存在、交互是否接通

Legacy/
└── 暂时不能删除但也不能继续作为新入口的旧文件
```

每个 Feature 内部继续这样看：

```text
Views/
└── 一整张页面，例如完整战斗界面

Controllers/
└── 给页面接数据、接信号、编排演示流程

Prefabs/
└── 可以单独搬走和重复实例化的组件

Art/
└── PNG、序列帧、图标等纯美术资源

Preview/
└── 不进入正式流程的独立预览场景
```

## 美术项目和真实程序项目怎么接

真实程序项目是：

`/Users/ywh/Documents/godot-latest`

接入时不是把整个美术项目覆盖过去，而是搬走已经封装好的页面和预制体，再让正式 Controller 接管。

```text
本项目 BattleMainView
└── 搬到 godot-latest 的正式 BattleUI 位置
    ├── 保留节点层级
    ├── 保留位置和尺寸
    ├── 保留图片
    ├── 保留动画
    ├── 保留表现脚本
    └── 保留公开方法和信号
```

然后替换驱动它的部分：

```text
美术项目驱动方式
MockGameData
└── Preview Controller
    └── BattleMainView

真实程序驱动方式
GameSession / Snapshot
└── 正式 Controller / Adapter
    └── BattleMainView
```

换的是数据来源和连接代码，不是重做美术页面。

## 用战斗按钮举一个完整例子

美术项目里：

```text
BattleActionPanel
├── AutoArrangeButton
└── BeginTurnButton

玩家点击 AutoArrangeButton
└── 发出 auto_arrange_requested
    └── Preview Controller 使用 Mock 数据演示自动布置
```

迁入真实程序后：

```text
玩家点击 AutoArrangeButton
└── 发出 auto_arrange_requested
    └── 正式 BattleController 收到信号
        └── GameSession.submit_command(AUTO_POSITION_HEROES)
            └── 正式规则计算站位
                └── 返回新 Snapshot
                    └── BattleMainView.refresh(view_model)
```

按钮图片、位置、按下反馈都不需要重做。

## 新增东西时怎么判断放哪里

```text
是一整张页面吗？
├── 是 -> Features/<功能>/Views
└── 否
    └── 能单独重复使用吗？
        ├── 是 -> Features/<功能>/Prefabs
        └── 否
            └── 只是 PNG、图标、序列帧吗？
                ├── 是 -> Features/<功能>/Art
                └── 否
                    └── 是接数据和信号的代码吗？
                        ├── 是 -> Features/<功能>/Controllers
                        └── 否 -> 先确认职责，不要随便堆进主场景
```

跨商店、背包、队伍和战斗都会用到的组件，放到 `Shared`。

## 哪些现象说明又开始混乱了

看到下面情况就应该停下来拆分：

```text
危险信号
├── 一个 Controller 同时管商店、背包、战斗和存档
├── game 里直接堆了多个完整页面的内部节点
├── Prefabs 文件夹里只有 PNG，没有 .tscn
├── 美术预制体直接读取正式存档
├── 按钮脚本自己计算伤害和胜负
├── 为换一张界面图片必须修改核心规则
├── 为换真实数据必须重做预制体节点
└── 外部代码大量使用 $A/B/C/D 找预制体深层节点
```

## 做完一个组件后怎么自查

```text
组件完成
├── 能不能单独实例化？
├── 没有真实程序时能不能用 Mock 预览？
├── 换成真实 Snapshot 后是否不用改节点结构？
├── 外部是否只通过公开方法和信号操作？
├── 图片、动画和常用参数是否容易替换？
├── 组件是否完全不知道存档和服务器？
└── 真实 Godot 窗口里是否已经验证？
```

全部回答“能”或“是”，这个组件才算真正方便程序接入。

## 最后记住这四句话

```text
game 负责摆页面，不负责算规则。
Controller 负责接线，不负责重画美术。
Prefab 负责表现，不负责决定结果。
Mock 负责演示，不负责成为真相源。
```

需要精确文件位置时读 `PROJECT_STRUCTURE.md`；新增资源、UI 或动效时读 `ART_ASSET_RULES.md`；需要精确方法和信号时读 `COMPONENT_API.md`；准备迁入真实程序时读 `PROGRAM_INTEGRATION.md`，并复制 `DELIVERY_TEMPLATE.md` 填写验收结果。
