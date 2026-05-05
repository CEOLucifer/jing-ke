extends Node


@onready var prompt_label: Label = $"../InteractionPromptLabel"
@onready var dialogue_panel: Node = $"../DialoguePanel"
@onready var player: Node3D = $"../../player"
@onready var taizi_dan: Node3D = $"../../NavigationRegion3D/OpenWorldDatabase/npc/human2"


var interaction_distance := 4.0
var can_talk := false


# 每帧检测玩家与太子丹的距离，控制交互提示显示。
func _process(_delta: float) -> void:
	if player == null or taizi_dan == null:
		return

	var distance := player.global_position.distance_to(taizi_dan.global_position)
	can_talk = distance <= interaction_distance
	prompt_label.visible = can_talk and not dialogue_panel.visible


# 在交互范围内按 E 打开太子丹对话。
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_E:
		if can_talk and dialogue_panel.has_method("open_dialogue"):
			dialogue_panel.open_dialogue()
