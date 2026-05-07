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
@export var portal_name := "下一场景"
@export var next_scene_path := ""
@export var portal_required_field := ""
@export var portal_missing_message := "条件尚未满足。"
@export var portal_quest_stage := ""
@export var portal_chapter := 0
@export var portal_state_field := ""
@export var portal_state_value := true
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


var npc_interacted := false
var prompt_mode := ""
var interaction_distance := 3.2


func _ready() -> void:
	title_label.text = scene_title
	objective_label.text = objective_text
	message_panel.visible = false
	choice_panel.visible = false
	prompt_label.visible = false
	message_button.pressed.connect(_hide_message)
	choice_a.pressed.connect(_finish_demo.bind("立即出手", 12, 20, "刺秦骤起"))
	choice_b.pressed.connect(_finish_demo.bind("等待更近时机", 6, 8, "屏息待发"))
	choice_c.pressed.connect(_finish_demo.bind("放弃刺秦", -10, -5, "天命改道"))
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
	npc_interacted = true
	if npc_state_field != "":
		GameState.set(npc_state_field, npc_state_value)
	if npc_quest_stage != "":
		GameState.quest_stage = npc_quest_stage
	GameState.fate_value += npc_fate_delta
	GameState.history_disturbance += npc_history_delta
	GameState.taizi_relationship += npc_relationship_delta
	_refresh_state_label()

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

	if next_scene_path != "":
		get_tree().change_scene_to_file(next_scene_path)


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
	get_tree().change_scene_to_file("res://scene/demo_result.tscn")


func _refresh_state_label() -> void:
	state_label.text = "章节：%d\n进度：%s\n天命：%d  扰动：%d" % [
		GameState.current_chapter,
		GameState.quest_stage,
		GameState.fate_value,
		GameState.history_disturbance,
	]
