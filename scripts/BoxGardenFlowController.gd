extends Node


@export var scene_title := "箱庭场景"
@export_multiline var objective_text := "当前目标：探索区域"
@export var npc_name := "NPC"
@export_multiline var npc_dialogue := "对话内容"
@export var npc_state_field := ""
@export var npc_state_value := true
@export var npc_quest_stage := ""
@export var npc_fate_delta := 0
@export var npc_history_delta := 0
@export var npc_relationship_delta := 0
@export var npc_feedback := ""
@export var portal_name := "下一场景"
@export var next_scene_path := ""
@export var portal_required_field := ""
@export var portal_missing_message := "条件尚未满足。"
@export var portal_quest_stage := ""
@export var portal_chapter := 0
@export var portal_state_field := ""
@export var portal_state_value := true
@export var portal_feedback := ""
@export var is_final_scene := false


@onready var player: Node3D = $"../Player"
@onready var npc_marker: Node3D = $"../NpcMarker"
@onready var portal_marker: Node3D = $"../PortalMarker"
@onready var title_label: Label = $"../CanvasLayer/TaskPanel/TaskMargin/TaskVBox/TitleLabel"
@onready var objective_label: Label = $"../CanvasLayer/TaskPanel/TaskMargin/TaskVBox/ObjectiveLabel"
@onready var state_label: Label = $"../CanvasLayer/TaskPanel/TaskMargin/TaskVBox/StateLabel"
@onready var prompt_label: Label = $"../CanvasLayer/PromptLabel"
@onready var message_panel: PanelContainer = $"../CanvasLayer/MessagePanel"
@onready var message_title: Label = $"../CanvasLayer/MessagePanel/MessageMargin/MessageVBox/MessageTitle"
@onready var message_body: Label = $"../CanvasLayer/MessagePanel/MessageMargin/MessageVBox/MessageBody"
@onready var message_button: Button = $"../CanvasLayer/MessagePanel/MessageMargin/MessageVBox/MessageButton"
@onready var choice_panel: PanelContainer = $"../CanvasLayer/ChoicePanel"
@onready var choice_body: Label = $"../CanvasLayer/ChoicePanel/ChoiceMargin/ChoiceVBox/ChoiceBody"
@onready var choice_a: Button = $"../CanvasLayer/ChoicePanel/ChoiceMargin/ChoiceVBox/ChoiceA"
@onready var choice_b: Button = $"../CanvasLayer/ChoicePanel/ChoiceMargin/ChoiceVBox/ChoiceB"
@onready var choice_c: Button = $"../CanvasLayer/ChoicePanel/ChoiceMargin/ChoiceVBox/ChoiceC"


var prompt_mode := ""
var interaction_distance := 3.2
var fade_layer: ColorRect
var feedback_label: Label
var feedback_tween: Tween


func _ready() -> void:
	title_label.text = scene_title
	objective_label.text = objective_text
	message_panel.visible = false
	choice_panel.visible = false
	prompt_label.visible = false
	message_button.pressed.connect(_hide_message)
	choice_a.pressed.connect(_finish_demo.bind("立即出手", 12, 20, "立即出手"))
	choice_b.pressed.connect(_finish_demo.bind("等待更近时机", 6, 8, "等待时机"))
	choice_c.pressed.connect(_finish_demo.bind("放弃刺秦", -10, -5, "放弃刺秦"))
	_create_runtime_layers()
	_play_fade_in()
	_show_feedback(scene_title)
	_refresh_state_label()


func _process(_delta: float) -> void:
	if message_panel.visible or choice_panel.visible:
		return

	prompt_mode = ""
	var prompt := ""

	if npc_marker != null and player.global_position.distance_to(npc_marker.global_position) <= interaction_distance:
		prompt_mode = "npc"
		prompt = "按 E 与%s对话" % npc_name
	elif portal_marker != null and player.global_position.distance_to(portal_marker.global_position) <= interaction_distance:
		prompt_mode = "portal"
		prompt = "按 E 前往%s" % portal_name

	prompt_label.visible = prompt != ""
	prompt_label.text = prompt

	if prompt_mode != "" and Input.is_action_just_pressed("interact"):
		if prompt_mode == "npc":
			_interact_with_npc()
		elif prompt_mode == "portal":
			_try_use_portal()


func _interact_with_npc() -> void:
	if npc_state_field != "":
		GameState.set(npc_state_field, npc_state_value)
	if npc_quest_stage != "":
		GameState.quest_stage = npc_quest_stage
	GameState.fate_value += npc_fate_delta
	GameState.history_disturbance += npc_history_delta
	GameState.taizi_relationship += npc_relationship_delta
	_refresh_state_label()

	if npc_feedback != "":
		_show_feedback(npc_feedback)

	if is_final_scene:
		_show_choices()
	else:
		_show_message(npc_name, npc_dialogue)


func _try_use_portal() -> void:
	if portal_required_field != "" and not bool(GameState.get(portal_required_field)):
		_show_message("尚未完成", portal_missing_message)
		return

	if portal_state_field != "":
		GameState.set(portal_state_field, portal_state_value)
	if portal_quest_stage != "":
		GameState.quest_stage = portal_quest_stage
	if portal_chapter > 0:
		GameState.current_chapter = portal_chapter
	if portal_feedback != "":
		_show_feedback(portal_feedback)

	if next_scene_path != "":
		change_scene_with_fade(next_scene_path)


func change_scene_with_fade(path: String) -> void:
	fade_layer.visible = true
	fade_layer.modulate.a = 0.0
	var tween := create_tween()
	tween.tween_property(fade_layer, "modulate:a", 1.0, 0.42)
	tween.tween_callback(func() -> void: get_tree().change_scene_to_file(path))


func _show_message(title: String, body: String) -> void:
	message_title.text = title
	message_body.text = body
	message_panel.visible = true


func _hide_message() -> void:
	message_panel.visible = false


func _show_choices() -> void:
	choice_body.text = npc_dialogue
	choice_panel.visible = true


func _finish_demo(branch: String, fate_delta: int, disturbance_delta: int, ending: String) -> void:
	GameState.fate_value += fate_delta
	GameState.history_disturbance += disturbance_delta
	GameState.reached_qin_palace = true
	GameState.demo_completed = true
	GameState.ending_branch = ending
	GameState.quest_stage = "demo_completed"
	GameState.latest_world_message = "秦王殿内，荆轲完成了刺秦演示分支：%s。" % branch
	change_scene_with_fade("res://scene/demo_result.tscn")


func _refresh_state_label() -> void:
	state_label.text = "章节：%d\n进度：%s\n天命：%d  扰动：%d" % [
		GameState.current_chapter,
		GameState.quest_stage,
		GameState.fate_value,
		GameState.history_disturbance,
	]


func _create_runtime_layers() -> void:
	var canvas := get_node("../CanvasLayer")

	fade_layer = ColorRect.new()
	fade_layer.name = "RuntimeFadeLayer"
	fade_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	fade_layer.set_anchors_preset(Control.PRESET_FULL_RECT)
	fade_layer.color = Color.BLACK
	fade_layer.modulate.a = 1.0
	canvas.add_child(fade_layer)

	feedback_label = Label.new()
	feedback_label.name = "RuntimeFeedbackLabel"
	feedback_label.visible = false
	feedback_label.set_anchors_preset(Control.PRESET_CENTER)
	feedback_label.offset_left = -220
	feedback_label.offset_top = -58
	feedback_label.offset_right = 220
	feedback_label.offset_bottom = 0
	feedback_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	feedback_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	feedback_label.add_theme_font_size_override("font_size", 24)
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
