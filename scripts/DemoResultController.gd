extends Node


@onready var title_label: Label = $"../CanvasLayer/ResultPanel/ResultMargin/ResultVBox/TitleLabel"
@onready var body_label: Label = $"../CanvasLayer/ResultPanel/ResultMargin/ResultVBox/BodyLabel"
@onready var back_button: Button = $"../CanvasLayer/ResultPanel/ResultMargin/ResultVBox/ButtonRow/BackToMenuButton"
@onready var restart_button: Button = $"../CanvasLayer/ResultPanel/ResultMargin/ResultVBox/ButtonRow/RestartButton"


func _ready() -> void:
	title_label.text = "Demo 结算：刺秦主流程完成"
	body_label.text = "结局分支：%s\n天命值：%d\n历史扰动值：%d\n太子丹关系：%d\n\n%s" % [
		GameState.ending_branch if GameState.ending_branch != "" else "未记录",
		GameState.fate_value,
		GameState.history_disturbance,
		GameState.taizi_relationship,
		GameState.latest_world_message,
	]
	back_button.pressed.connect(func() -> void: get_tree().change_scene_to_file("res://MainMenu.tscn"))
	restart_button.pressed.connect(_restart)


func _restart() -> void:
	GameState.reset_new_game()
	get_tree().change_scene_to_file("res://scene/main.tscn")
