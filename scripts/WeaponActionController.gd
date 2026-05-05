extends Node


@onready var weapon_status_label: Label = $"../WeaponStatusPanel/WeaponStatusMargin/WeaponStatusVBox/WeaponStatusLabel"
@onready var feedback_label: Label = $"../ActionFeedbackLabel"
@onready var scene_fade_overlay: ColorRect = $"../SceneFadeOverlay"
@onready var player: Node3D = $"../../player"
@onready var player_visual: Node3D = $"../../player/Y Bot"
@onready var quest_controller: Node = $"../QuestDemoController"
@onready var training_dummy: Node3D = get_node_or_null("../../YanCampSet/TrainingArea/TrainingDummy") as Node3D


var current_weapon := "空手"
var has_dagger := false
var is_weapon_drawn := false
var feedback_tween: Tween
var action_tween: Tween
var dummy_tween: Tween
var is_action_playing := false
var original_visual_position := Vector3.ZERO
var original_visual_rotation := Vector3.ZERO
var original_visual_scale := Vector3.ONE
var original_dummy_position := Vector3.ZERO
var original_dummy_rotation := Vector3.ZERO
var original_dummy_scale := Vector3.ONE


# 初始化武器状态，并监听任务领取匕首事件。
func _ready() -> void:
	if player_visual == null:
		player_visual = player
	if player_visual != null:
		original_visual_position = player_visual.position
		original_visual_rotation = player_visual.rotation_degrees
		original_visual_scale = player_visual.scale
	if training_dummy != null:
		original_dummy_position = training_dummy.position
		original_dummy_rotation = training_dummy.rotation_degrees
		original_dummy_scale = training_dummy.scale

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
			play_bow_animation()
		KEY_R:
			play_draw_weapon_animation()
		KEY_F:
			play_attack_animation()


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


# 后续接入真实骨骼动画时，优先在这些入口里播放 AnimationPlayer。
# 当前没有动作资源时，继续使用 Tween 作为演示 fallback。
func play_bow_animation() -> void:
	_play_bow_action()


func play_draw_weapon_animation() -> void:
	_play_draw_sword_action()


func play_attack_animation() -> void:
	_play_slash_action()


func _play_bow_action() -> void:
	if not _can_play_action():
		return

	_show_feedback("荆轲拱手行礼")
	is_action_playing = true
	action_tween = create_tween()
	action_tween.set_parallel(true)
	action_tween.tween_property(player_visual, "rotation_degrees:x", original_visual_rotation.x - 14.0, 0.14)
	action_tween.tween_property(player_visual, "scale", original_visual_scale * Vector3(0.95, 0.82, 0.95), 0.14)
	action_tween.chain().tween_property(player_visual, "rotation_degrees", original_visual_rotation, 0.18)
	action_tween.parallel().tween_property(player_visual, "scale", original_visual_scale, 0.18)
	action_tween.tween_callback(_finish_action)


func _play_draw_sword_action() -> void:
	if not _can_play_action():
		return

	is_weapon_drawn = not is_weapon_drawn
	_show_feedback("荆轲缓缓拔剑" if is_weapon_drawn else "荆轲收剑入鞘")
	is_action_playing = true
	var target_rotation := original_visual_rotation + Vector3(0.0, 20.0 if is_weapon_drawn else -20.0, 0.0)
	action_tween = create_tween()
	action_tween.set_parallel(true)
	action_tween.tween_property(player_visual, "rotation_degrees", target_rotation, 0.12)
	action_tween.tween_property(player_visual, "scale", original_visual_scale * Vector3(1.12, 1.12, 1.12), 0.12)
	action_tween.chain().tween_property(player_visual, "rotation_degrees", original_visual_rotation, 0.16)
	action_tween.parallel().tween_property(player_visual, "scale", original_visual_scale, 0.16)
	action_tween.tween_callback(_finish_action)


func _play_slash_action() -> void:
	if not _can_play_action():
		return

	_show_feedback("荆轲挥出一剑")
	is_action_playing = true
	var slash_position := original_visual_position + Vector3(0.0, 0.0, 0.65)
	var slash_rotation := original_visual_rotation + Vector3(0.0, 0.0, -18.0)
	action_tween = create_tween()
	action_tween.set_parallel(true)
	action_tween.tween_property(player_visual, "position", slash_position, 0.1)
	action_tween.tween_property(player_visual, "rotation_degrees", slash_rotation, 0.1)
	action_tween.tween_property(player_visual, "scale", original_visual_scale * Vector3(1.18, 0.96, 1.18), 0.1)
	action_tween.chain().tween_property(player_visual, "position", original_visual_position, 0.16)
	action_tween.parallel().tween_property(player_visual, "rotation_degrees", original_visual_rotation, 0.16)
	action_tween.parallel().tween_property(player_visual, "scale", original_visual_scale, 0.16)
	action_tween.tween_callback(_check_attack_hit)
	action_tween.tween_callback(_finish_action)


func _can_play_action() -> bool:
	if player_visual == null or is_action_playing:
		return false

	if action_tween != null and action_tween.is_valid():
		action_tween.kill()
	_restore_visual_transform()
	return true


func _finish_action() -> void:
	_restore_visual_transform()
	is_action_playing = false


func _restore_visual_transform() -> void:
	if player_visual == null:
		return

	player_visual.position = original_visual_position
	player_visual.rotation_degrees = original_visual_rotation
	player_visual.scale = original_visual_scale


# 简化攻击判定：训练木桩在玩家附近时视为命中，用于演示挥砍反馈。
func _check_attack_hit() -> void:
	if training_dummy == null or player == null:
		return

	if player.global_position.distance_to(training_dummy.global_position) > 5.0:
		return

	_show_feedback("命中训练木桩")
	_play_dummy_hit_feedback()


func _play_dummy_hit_feedback() -> void:
	if training_dummy == null:
		return

	if dummy_tween != null and dummy_tween.is_valid():
		dummy_tween.kill()

	training_dummy.position = original_dummy_position
	training_dummy.rotation_degrees = original_dummy_rotation
	training_dummy.scale = original_dummy_scale

	dummy_tween = create_tween()
	dummy_tween.set_parallel(true)
	dummy_tween.tween_property(training_dummy, "position", original_dummy_position + Vector3(0.18, 0.0, 0.0), 0.08)
	dummy_tween.tween_property(training_dummy, "rotation_degrees", original_dummy_rotation + Vector3(0.0, 0.0, 8.0), 0.08)
	dummy_tween.tween_property(training_dummy, "scale", original_dummy_scale * Vector3(1.08, 0.92, 1.08), 0.08)
	dummy_tween.chain().tween_property(training_dummy, "position", original_dummy_position, 0.14)
	dummy_tween.parallel().tween_property(training_dummy, "rotation_degrees", original_dummy_rotation, 0.14)
	dummy_tween.parallel().tween_property(training_dummy, "scale", original_dummy_scale, 0.14)


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
