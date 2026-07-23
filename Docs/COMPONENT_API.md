# 美术预制体接口说明

如果还不清楚“公开接口”和“不要访问深层节点”是什么意思，先读 [`PLAIN_LANGUAGE_GUIDE.md`](PLAIN_LANGUAGE_GUIDE.md)。

真实程序只通过公开方法和信号操作美术预制体，不直接访问深层子节点。

## game 预览装配入口

```text
GamePreviewController
├── show_main_menu(view_model)
├── show_artist_flow(view_model)
├── show_battle(view_model)
├── show_screen(screen_id, view_model)
├── get_current_screen()
├── get_current_screen_id()
└── signal screen_changed(screen_id, screen)
```

页面预制体统一向 `game` 发出：

```text
signal screen_requested(screen_id, view_model)
```

页面自身不得直接切换 SceneTree。

## 预览数据契约

`MockGameData.snapshot()` 与真实程序项目
`/Users/ywh/Documents/godot-latest` 的 `GameSession.current_snapshot()` 使用同一类公开字段：

```text
phase / stateVersion / stateHash
coins / leaders / units / board
roster / shop_offers / inventory
viewModel
```

`GameDataProvider` 是唯一表现适配入口：

```text
get_snapshot()
set_snapshot(snapshot)
clear_snapshot_override()
get_view_model()
get_battle_units()
get_shop_data()
```

假数据只允许替换字段值，不另创一套业务结构。贴图路径、英文品质 key、
美术项目临时战斗动作等表现适配信息只存在于 Provider，不写回正式 Snapshot。

## ArtistFlow 槽位预制体

```text
CreatureSlotView（商店 / 队伍 / 背包）
├── setup(view_model)
├── refresh(view_model)
├── clear()
├── set_collection_data(data, presentation)
├── clear_collection_data()
├── set_merge_indicator(texture, opacity, visible)
├── get_button()
├── get_view_model()
├── get_collection_presentation_snapshot()
├── signal pressed(slot)
├── signal pointer_entered(slot)
└── signal pointer_exited(slot)

RouteOptionSlotView
├── setup(view_model)
├── refresh(view_model)
├── get_button()
├── get_kind()
└── signal option_requested(kind)
```

## ArtistFlow 组合预制体

```text
BagLauncherView
├── setup(view_model) / refresh(view_model)
├── set_capacity(used, capacity)
├── get_button()
└── signal bag_requested

PartyBarView / RouteOptionsPanelView / ShopPanelView / InventoryPanelView
├── setup(view_model) / refresh(view_model)
└── get_slots()

TopActionBarView
├── setup(view_model) / refresh(view_model)
├── get_back_button() / get_sell_button()
├── set_back_panel_state(visible, position)
├── set_sell_available(available)
├── contains_sell_point(global_point)
└── signal back_requested / sell_requested
```

`ArtistFlowView.tscn` 只实例化以上组合预制体，不重复保存它们的完整节点树。

## BattleUnit

文件：`Features/Battle/Prefabs/Units/BattleUnit/BattleUnit.tscn`

```text
BattleUnit
├── set_battle_data(data, presentation)
├── set_collection_data(data, presentation)
├── clear_collection_data()
├── reset_pet_view()
├── update_hp(value)
├── update_attack(value)
├── show_health_preview(damage, color)
├── show_damage_preview(value, color, alignment)
├── show_death_preview(texture, preview_scale)
├── clear_combat_preview()
├── set_visual_tint(color)
├── set_selected(selected)
├── set_dragging(dragging)
├── get_display_mode()
└── get_display_texture()
```

内部子组件：

```text
PetStatusView
├── bind_battle_data(data)
├── update_hp(value)
├── update_attack(value)
├── show_hp_preview(value, color)
├── show_damage_preview(value, visible, color, alignment)
└── clear_preview()

PetInteraction
├── bind_context(context, side)
├── set_selected(selected)
├── set_dragging(dragging)
└── snapshot()
```

## 宠物收藏表现

```text
CollectionPetView（商店 / 队伍 / 背包 / 拖拽预览）
├── setup(view_model) / refresh(view_model)
├── clear()
├── get_display_texture()
├── set_frame_presentation(frame, topper)
└── set_merge_indicator(texture, opacity, visible)

SpriteInfoPanel
├── display_info(info)
├── clear()
└── 内部预制体
    ├── SpriteInfoHeaderView.refresh(info, rank, art_textures)
    ├── SpriteInfoAttackPatternView.refresh(info, art_textures)
    │   └── SpriteInfoAttackCellView × 21
    └── SpriteInfoStatTableView.refresh(rank, art_textures)
        └── SpriteInfoStatRowView × 6
```

`SpriteInfoPanel.tscn` 保存完整静态布局，并只通过根脚本向内部预制体分发
表现数据。外部程序仍只使用 `display_info(info)` / `clear()`，不得直接操作
Header、AttackPattern、StatTable 或 StatRow 的深层节点。

Controller 不再创建宠物卡片内部的 `TextureRect`、`Sprite2D`、边框和合成箭头。

## 内部表现预制体

以下组件由所属 Feature Controller 通过场景实例化，不向真实业务层暴露深层节点：

```text
MergeBurstView         合成爆发效果
BattleTextureMarkerView 棋盘悬停和行动顺序标记
ElementTrapView         元素陷阱图标及数值
```

## 战斗特效

```text
DamageNumber
├── setup(amount)
└── play()

ElementBullet
├── setup(texture, start_position)
└── play(target_position, duration, min_arc_height, distance_scale)

MonsterBiteEffect
└── play(hit_callback)

RoundBanner
├── setup(round_number, subtitle)
├── play()
└── signal playback_finished
```

## HUD 与棋盘

```text
ClockIndicator
├── setup(total_hours, display_size, animate)
└── set_total_hours(total_hours, animate)

BattleGridView
├── setup(view_model)
└── get_layout_snapshot()

GoldCounterView
├── setup(view_model) / refresh(view_model)
├── set_value(value) / get_value()
└── signal value_changed(value)

BattleActionPanelView
├── setup(view_model) / refresh(view_model)
├── get_auto_arrange_button()
├── get_begin_turn_button()
└── signal auto_arrange_requested / begin_turn_requested
```

## 接口约束

```text
允许传入
├── Dictionary ViewModel
├── Texture2D
├── 数值、颜色、尺寸和时间
└── 与动画相关的表现参数

禁止传入或直接读取
├── 正式 GameState
├── 正式存档对象
├── 服务器连接
├── 伤害计算器
└── 胜负判定规则
```

后续新增组件优先使用统一形式：

```text
setup(view_model)
refresh(view_model)
play(animation_data)
signal requested(action_data)
```
