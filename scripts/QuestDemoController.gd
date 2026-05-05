extends Node


signal dagger_received
signal map_received


@onready var dialogue_panel: Node = $"../DialoguePanel"
@onready var quest_panel: PanelContainer = $"../QuestPanel"
@onready var quest_title_label: Label = $"../QuestPanel/QuestMargin/QuestVBox/QuestTitleLabel"
@onready var quest_objective_label: Label = $"../QuestPanel/QuestMargin/QuestVBox/QuestObjectiveLabel"
@onready var quest_status_label: Label = $"../QuestPanel/QuestMargin/QuestVBox/QuestStatusLabel"
@onready var receive_dagger_button: Button = $"../QuestPanel/QuestMargin/QuestVBox/QuestButtonRow/ReceiveDaggerButton"
@onready var receive_map_button: Button = $"../QuestPanel/QuestMargin/QuestVBox/QuestButtonRow/ReceiveMapButton"
@onready var depart_button: Button = $"../QuestPanel/QuestMargin/QuestVBox/DepartButton"
@onready var result_panel: PanelContainer = $"../DemoResultPanel"
@onready var result_stats_label: Label = $"../DemoResultPanel/ResultMargin/ResultVBox/ResultStatsLabel"
@onready var close_result_button: Button = $"../DemoResultPanel/ResultMargin/ResultVBox/ResultButtonRow/CloseResultButton"
@onready var back_to_menu_button: Button = $"../DemoResultPanel/ResultMargin/ResultVBox/ResultButtonRow/BackToMenuButton"


var quest_started := false
var has_dagger := false
var has_map := false
var quest_ready_to_depart := false
var demo_completed := false


# 初始化任务闭环控制器，并绑定任务相关按钮。
func _ready() -> void:
	quest_panel.visible = false
	result_panel.visible = false
	depart_button.visible = false

	if dialogue_panel.has_signal("quest_accepted"):
		dialogue_panel.quest_accepted.connect(start_quest)

	receive_dagger_button.pressed.connect(receive_dagger)
	receive_map_button.pressed.connect(receive_map)
	depart_button.pressed.connect(complete_demo)
	close_result_button.pressed.connect(close_result)
	back_to_menu_button.pressed.connect(return_to_main_menu)


# 接受太子丹托付后启动任务。
func start_quest() -> void:
	if quest_started:
		return

	quest_started = true
	has_dagger = false
	has_map = false
	quest_ready_to_depart = false
	demo_completed = false
	quest_panel.visible = true
	quest_panel.modulate.a = 0.0
	create_tween().tween_property(quest_panel, "modulate:a", 1.0, 0.2)
	refresh_quest_ui()


# 领取徐夫人匕首。
func receive_dagger() -> void:
	if not quest_started or has_dagger:
		return

	has_dagger = true
	dagger_received.emit()
	refresh_quest_ui()


# 领取督亢地图。
func receive_map() -> void:
	if not quest_started or has_map:
		return

	has_map = true
	map_received.emit()
	refresh_quest_ui()


# 根据任务状态刷新任务面板。
func refresh_quest_ui() -> void:
	quest_title_label.text = "任务：刺秦前夜"

	if has_dagger and has_map:
		quest_ready_to_depart = true
		quest_objective_label.text = "目标：启程前往秦国"
		quest_status_label.text = "状态：准备完成\n已获得：徐夫人匕首、督亢地图"
		receive_dagger_button.disabled = true
		receive_map_button.disabled = true
		depart_button.visible = true
		return

	quest_objective_label.text = "目标：领取徐夫人匕首与督亢地图"
	var obtained_items: Array[String] = []
	if has_dagger:
		obtained_items.append("徐夫人匕首")
	if has_map:
		obtained_items.append("督亢地图")

	if obtained_items.is_empty():
		quest_status_label.text = "状态：未完成"
	else:
		quest_status_label.text = "状态：进行中\n已获得：%s" % "、".join(obtained_items)

	receive_dagger_button.disabled = has_dagger
	receive_map_button.disabled = has_map
	depart_button.visible = false


# 启程后显示第一幕完成结算。
func complete_demo() -> void:
	if not quest_ready_to_depart or demo_completed:
		return

	demo_completed = true
	quest_status_label.text = "状态：已启程"
	GameState.fate_value += 10
	GameState.history_disturbance += 15
	GameState.taizi_relationship += 20
	GameState.latest_world_message = "荆轲携徐夫人匕首与督亢地图启程，天命的裂痕已经出现。"

	result_stats_label.text = "天命值：+10\n历史扰动值：+15\n太子丹关系：+20\n获得物品：徐夫人匕首、督亢地图"
	result_panel.visible = true
	result_panel.modulate.a = 0.0
	create_tween().tween_property(result_panel, "modulate:a", 1.0, 0.25)


# 关闭结算面板，留在当前场景继续操作。
func close_result() -> void:
	result_panel.visible = false


# 从结算面板返回主菜单。
func return_to_main_menu() -> void:
	get_tree().change_scene_to_file("res://MainMenu.tscn")
