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
@onready var go_to_qin_button: Button = $"../DemoResultPanel/ResultMargin/ResultVBox/ResultButtonRow/GoToQinButton"


var quest_started := false
var has_dagger := false
var has_map := false
var quest_ready_to_depart := false


func _ready() -> void:
	quest_panel.visible = false
	result_panel.visible = false
	depart_button.visible = false
	depart_button.text = "前往太子丹府"
	go_to_qin_button.text = "前往秦境关隘"

	if dialogue_panel.has_signal("quest_accepted"):
		dialogue_panel.quest_accepted.connect(start_quest)

	receive_dagger_button.pressed.connect(receive_dagger)
	receive_map_button.pressed.connect(receive_map)
	depart_button.pressed.connect(go_to_prince_mansion)
	close_result_button.pressed.connect(close_result)
	back_to_menu_button.pressed.connect(return_to_main_menu)
	go_to_qin_button.pressed.connect(go_to_qin_checkpoint)

	if GameState.quest_stage != "yan_camp_start":
		start_quest()


func start_quest() -> void:
	if quest_started:
		return

	quest_started = true
	has_dagger = GameState.has_dagger
	has_map = GameState.has_map
	quest_panel.visible = true
	quest_panel.modulate.a = 0.0
	create_tween().tween_property(quest_panel, "modulate:a", 1.0, 0.2)
	refresh_quest_ui()


func receive_dagger() -> void:
	if not quest_started or has_dagger:
		return

	has_dagger = true
	GameState.has_dagger = true
	dagger_received.emit()
	refresh_quest_ui()


func receive_map() -> void:
	if not quest_started or has_map:
		return

	has_map = true
	GameState.has_map = true
	map_received.emit()
	refresh_quest_ui()


func refresh_quest_ui() -> void:
	quest_title_label.text = "任务：刺秦前夜"

	if has_dagger and has_map:
		quest_ready_to_depart = true
		GameState.quest_stage = "to_prince_mansion"
		quest_objective_label.text = "目标：前往太子丹府，确认刺秦计划"
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

	quest_status_label.text = "状态：未完成" if obtained_items.is_empty() else "状态：进行中\n已获得：%s" % "、".join(obtained_items)
	receive_dagger_button.disabled = has_dagger
	receive_map_button.disabled = has_map
	depart_button.visible = false


func go_to_prince_mansion() -> void:
	if not quest_ready_to_depart:
		return

	GameState.current_chapter = 2
	GameState.quest_stage = "prince_mansion_plan"
	GameState.latest_world_message = "荆轲携徐夫人匕首与督亢地图，前往太子丹府确认入秦计划。"
	get_tree().change_scene_to_file("res://scene/prince_mansion.tscn")


func close_result() -> void:
	result_panel.visible = false


func return_to_main_menu() -> void:
	get_tree().change_scene_to_file("res://MainMenu.tscn")


func go_to_qin_checkpoint() -> void:
	GameState.current_chapter = 3
	GameState.quest_stage = "to_qin_checkpoint"
	get_tree().change_scene_to_file("res://scene/qin_checkpoint.tscn")
