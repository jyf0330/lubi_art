# 美术预制体接口说明

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

## ArtistFlow 槽位预制体

```text
CreatureSlotView（商店 / 队伍 / 背包）
├── setup(view_model)
├── refresh(view_model)
├── clear()
├── get_button()
├── get_view_model()
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
└── show_damage_preview(value, visible)

PetInteraction
├── bind_context(context, side)
├── set_selected(selected)
├── set_dragging(dragging)
└── snapshot()
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
