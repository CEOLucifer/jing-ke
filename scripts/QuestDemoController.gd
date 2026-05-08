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
@onready var close_result_button: Button = $"../DemoResultPanel/ResultMargin/ResultVBox/ResultButtonRow/CloseResultButton"
@onready var back_to_menu_button: Button = $"../DemoResultPanel/ResultMargin/ResultVBox/ResultButtonRow/BackToMenuButton"
@onready var go_to_qin_button: Button = $"../DemoResultPanel/ResultMargin/ResultVBox/ResultButtonRow/GoToQinButton"


var quest_started := false
var has_dagger := false
var has_map := false
var quest_ready_to_depart := false
var fade_layer: ColorRect
var feedback_label: Label
var feedback_tween: Tween


func _ready() -> void:
	quest_panel.visible = true
	result_panel.visible = false
	depart_button.visible = false
	depart_button.text = "前往太子丹府"
	go_to_qin_button.text = "前往秦境关隘"
	_create_runtime_layers()
	_play_fade_in()

	if dialogue_panel.has_signal("quest_accepted"):
		dialogue_panel.quest_accepted.connect(start_quest)

	receive_dagger_button.pressed.connect(receive_dagger)
	receive_map_button.pressed.connect(receive_map)
	depart_button.pressed.connect(go_to_prince_mansion)
	close_result_button.pressed.connect(close_result)
	back_to_menu_button.pressed.connect(return_to_main_menu)
	go_to_qin_button.pressed.connect(go_to_qin_checkpoint)

	start_quest()
	_show_feedback("第一幕 易水受命")


func start_quest() -> void:
	if quest_started:
		refresh_quest_ui()
		return

	quest_started = true
	has_dagger = GameState.has_dagger
	has_map = GameState.has_map
	quest_panel.modulate.a = 0.0
	create_tween().tween_property(quest_panel, "modulate:a", 1.0, 0.2)
	refresh_quest_ui()


func receive_dagger() -> void:
	if not quest_started or has_dagger:
		return

	has_dagger = true
	GameState.has_dagger = true
	GameState.quest_stage = "yan_camp_prepare"
	dagger_received.emit()
	_show_feedback("获得：徐夫人匕首")
	refresh_quest_ui()


func receive_map() -> void:
	if not quest_started or has_map:
		return

	has_map = true
	GameState.has_map = true
	GameState.quest_stage = "yan_camp_prepare"
	map_received.emit()
	_show_feedback("获得：督亢地图")
	refresh_quest_ui()


func refresh_quest_ui() -> void:
	quest_title_label.text = "第一幕 易水受命"

	if has_dagger and has_map:
		quest_ready_to_depart = true
		GameState.quest_stage = "to_prince_mansion"
		quest_objective_label.text = "当前目标：前往太子丹府，确认刺秦计划"
		quest_status_label.text = "已获得：徐夫人匕首、督亢地图"
		receive_dagger_button.disabled = true
		receive_map_button.disabled = true
		depart_button.visible = true
		return

	quest_objective_label.text = "当前目标：与太子丹交谈，领取匕首与地图"
	var obtained_items: Array[String] = []
	if has_dagger:
		obtained_items.append("徐夫人匕首")
	if has_map:
		obtained_items.append("督亢地图")

	quest_status_label.text = "状态：未完成" if obtained_items.is_empty() else "已获得：%s" % "、".join(obtained_items)
	receive_dagger_button.disabled = has_dagger
	receive_map_button.disabled = has_map
	depart_button.visible = false


func go_to_prince_mansion() -> void:
	if not quest_ready_to_depart:
		return

	GameState.current_chapter = 2
	GameState.quest_stage = "prince_mansion_plan"
	GameState.latest_world_message = "荆轲携徐夫人匕首与督亢地图，前往太子丹府确认入秦计划。"
	change_scene_with_fade("res://scene/prince_mansion.tscn")


func close_result() -> void:
	result_panel.visible = false


func return_to_main_menu() -> void:
	change_scene_with_fade("res://MainMenu.tscn")


func go_to_qin_checkpoint() -> void:
	GameState.current_chapter = 3
	GameState.quest_stage = "to_qin_checkpoint"
	change_scene_with_fade("res://scene/qin_checkpoint.tscn")


func change_scene_with_fade(path: String) -> void:
	fade_layer.visible = true
	fade_layer.modulate.a = 0.0
	var tween := create_tween()
	tween.tween_property(fade_layer, "modulate:a", 1.0, 0.42)
	tween.tween_callback(func() -> void: get_tree().change_scene_to_file(path))


func _create_runtime_layers() -> void:
	var canvas := get_parent()
	fade_layer = ColorRect.new()
	fade_layer.name = "RuntimeFadeLayer"
	fade_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	fade_layer.set_anchors_preset(Control.PRESET_FULL_RECT)
	fade_layer.color = Color.BLACK
	canvas.add_child(fade_layer)

	feedback_label = Label.new()
	feedback_label.name = "RuntimeFeedbackLabel"
	feedback_label.visible = false
	feedback_label.set_anchors_preset(Control.PRESET_CENTER)
	feedback_label.offset_left = -260
	feedback_label.offset_top = -70
	feedback_label.offset_right = 260
	feedback_label.offset_bottom = -8
	feedback_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	feedback_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	feedback_label.add_theme_font_size_override("font_size", 26)
	canvas.add_child(feedback_label)


func _play_fade_in() -> void:
	fade_layer.visible = true
	fade_layer.modulate.a = 1.0
	var tween := create_tween()
	tween.tween_property(fade_layer, "modulate:a", 0.0, 0.45)
	tween.tween_callback(func() -> void: fade_layer.visible = false)


func _show_feedback(message: String) -> void:
	if feedback_tween != null and feedback_tween.is_valid():
		feedback_tween.kill()

	feedback_label.text = message
	feedback_label.visible = true
	feedback_label.modulate.a = 1.0
	feedback_tween = create_tween()
	feedback_tween.tween_interval(1.3)
	feedback_tween.tween_property(feedback_label, "modulate:a", 0.0, 0.35)
	feedback_tween.tween_callback(func() -> void: feedback_label.visible = false)
