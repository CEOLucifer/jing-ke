extends Node


@onready var prompt_label: Label = $"../InteractionPromptLabel"
@onready var dialogue_panel: Node = $"../DialoguePanel"
@onready var player: Node3D = $"../../player"
@onready var taizi_dan: Node3D = $"../../NavigationRegion3D/OpenWorldDatabase/npc/human2"


var interaction_distance := 4.0
var can_talk := false
var was_can_talk := false


func _ready() -> void:
	prompt_label.add_theme_font_size_override("font_size", 24)
	prompt_label.add_theme_color_override("font_color", Color(1.0, 0.86, 0.45))
	prompt_label.add_theme_stylebox_override("normal", _make_prompt_style())


# 每帧检测玩家与太子丹的距离，并在范围内响应 E 对话。
func _process(_delta: float) -> void:
	if player == null or taizi_dan == null:
		return

	var distance := player.global_position.distance_to(taizi_dan.global_position)
	can_talk = distance <= interaction_distance
	prompt_label.visible = can_talk and not dialogue_panel.visible

	if can_talk != was_can_talk:
		was_can_talk = can_talk
		if can_talk:
			print("[Interaction] player near TaiziDan")

	if can_talk and Input.is_action_just_pressed("interact"):
		print("[Interaction] E pressed")
		open_dialogue()


# 打开太子丹对话面板。
func open_dialogue() -> void:
	if dialogue_panel.visible:
		return

	if dialogue_panel != null and dialogue_panel.has_method("open_dialogue"):
		print("[Interaction] open dialogue")
		dialogue_panel.open_dialogue()


# 备用：如果输入映射异常，仍直接检测物理 E 键。
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_E:
		if can_talk:
			open_dialogue()


func _make_prompt_style() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.04, 0.03, 0.02, 0.78)
	style.border_color = Color(0.84, 0.62, 0.28, 0.76)
	style.set_border_width_all(1)
	style.corner_radius_top_left = 5
	style.corner_radius_top_right = 5
	style.corner_radius_bottom_left = 5
	style.corner_radius_bottom_right = 5
	style.content_margin_left = 14
	style.content_margin_right = 14
	style.content_margin_top = 7
	style.content_margin_bottom = 7
	style.shadow_color = Color(0, 0, 0, 0.36)
	style.shadow_size = 8
	return style
