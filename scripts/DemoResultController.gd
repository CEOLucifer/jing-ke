extends Node


@onready var title_label: Label = $"../CanvasLayer/ResultPanel/ResultMargin/ResultVBox/TitleLabel"
@onready var body_label: Label = $"../CanvasLayer/ResultPanel/ResultMargin/ResultVBox/BodyLabel"
@onready var back_button: Button = $"../CanvasLayer/ResultPanel/ResultMargin/ResultVBox/ButtonRow/BackToMenuButton"
@onready var restart_button: Button = $"../CanvasLayer/ResultPanel/ResultMargin/ResultVBox/ButtonRow/RestartButton"


func _ready() -> void:
	title_label.text = "《荆轲：天命改写》Demo 主流程完成"
	body_label.text = _build_summary()
	back_button.pressed.connect(func() -> void: get_tree().change_scene_to_file("res://MainMenu.tscn"))
	restart_button.pressed.connect(_restart)


func _build_summary() -> String:
	var final_choice := GameState.ending_branch if GameState.ending_branch != "" else "未记录"
	return """流程回顾：
1. 易水受命：接下太子丹托付，取得徐夫人匕首与督亢地图。
2. 密议刺秦：在太子丹府确认计划，取得入秦信物。
3. 入秦关隘：通过秦军盘查，进入秦境。
4. 咸阳献图：递交督亢地图，进入秦王殿。
5. 图穷匕见：展开地图，做出最终抉择。

最终选择：%s

状态变化：
天命值：%d
历史扰动值：%d
太子丹关系：%d

%s""" % [
		final_choice,
		GameState.fate_value,
		GameState.history_disturbance,
		GameState.taizi_relationship,
		GameState.latest_world_message,
	]


func _restart() -> void:
	GameState.reset_demo_state()
	get_tree().change_scene_to_file("res://scene/main.tscn")
