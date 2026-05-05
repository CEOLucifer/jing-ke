extends Node


@onready var weapon_status_label: Label = $"../WeaponStatusPanel/WeaponStatusMargin/WeaponStatusVBox/WeaponStatusLabel"
@onready var feedback_label: Label = $"../ActionFeedbackLabel"
@onready var scene_fade_overlay: ColorRect = $"../SceneFadeOverlay"
@onready var player: Node3D = $"../../player"
@onready var quest_controller: Node = $"../QuestDemoController"


var current_weapon := "空手"
var has_dagger := false
var is_weapon_drawn := false
var feedback_tween: Tween


# 初始化武器状态，并监听任务领取匕首事件。
func _ready() -> void:
	feedback_label.visible = false
	_play_scene_fade_in()
	_update_weapon_ui()

	if quest_controller.has_signal("dagger_received"):
		quest_controller.dagger_received.connect(_on_dagger_received)
	if quest_controller.has_signal("map_received"):
		quest_controller.map_received.connect(_on_map_received)


# 检测数字键切换武器，以及 Q/R/F 小动作。
func _input(event: InputEvent) -> void:
	if not (event is InputEventKey and event.pressed and not event.echo):
		return

	match event.keycode:
		KEY_1:
			_switch_weapon("空手")
		KEY_2:
			if has_dagger:
				_switch_weapon("徐夫人匕首")
			else:
				_show_feedback("尚未获得徐夫人匕首")
		KEY_3:
			_switch_weapon("长剑")
		KEY_Q:
			_play_action("荆轲拱手行礼", Vector3(0.96, 0.96, 0.96), 0.16)
		KEY_R:
			is_weapon_drawn = not is_weapon_drawn
			_show_feedback("荆轲缓缓拔剑" if is_weapon_drawn else "荆轲收剑入鞘")
			_tween_player_scale(Vector3(1.06, 1.06, 1.06), 0.12)
		KEY_F:
			_play_action("荆轲挥出一剑", Vector3(1.08, 1.0, 1.08), 0.1)


# 切换当前武器并刷新 UI。
func _switch_weapon(weapon_name: String) -> void:
	current_weapon = weapon_name
	_update_weapon_ui()
	_show_feedback("已切换武器：%s" % current_weapon)


func _update_weapon_ui() -> void:
	weapon_status_label.text = "当前武器：%s" % current_weapon


func _on_dagger_received() -> void:
	has_dagger = true
	_show_feedback("已获得：徐夫人匕首")


func _on_map_received() -> void:
	_show_feedback("已获得：督亢地图")


func _play_action(message: String, scale_target: Vector3, duration: float) -> void:
	_show_feedback(message)
	_tween_player_scale(scale_target, duration)


func _tween_player_scale(scale_target: Vector3, duration: float) -> void:
	if player == null:
		return

	var tween := create_tween()
	tween.tween_property(player, "scale", scale_target, duration)
	tween.tween_property(player, "scale", Vector3.ONE, duration)


func _show_feedback(message: String) -> void:
	if feedback_tween != null and feedback_tween.is_valid():
		feedback_tween.kill()

	feedback_label.text = message
	feedback_label.modulate.a = 1.0
	feedback_label.visible = true
	feedback_tween = create_tween()
	feedback_tween.tween_interval(1.0)
	feedback_tween.tween_property(feedback_label, "modulate:a", 0.0, 0.25)
	feedback_tween.tween_callback(func() -> void: feedback_label.visible = false)


func _play_scene_fade_in() -> void:
	scene_fade_overlay.visible = true
	scene_fade_overlay.modulate.a = 1.0
	var tween := create_tween()
	tween.tween_property(scene_fade_overlay, "modulate:a", 0.0, 0.5)
	tween.tween_callback(func() -> void: scene_fade_overlay.visible = false)
