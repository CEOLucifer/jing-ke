extends Node


enum ActionState {
	IDLE,
	ATTACKING,
	DASHING,
	ASSASSINATING,
	BOWING,
	DRAWING,
}


const DASH_DISTANCE := 5.0
const DASH_DURATION := 0.22
const DASH_COOLDOWN := 0.95
const ATTACK_RANGE := 5.0
const ASSASSINATE_RANGE := 4.2


@onready var weapon_status_label: Label = $"../WeaponStatusPanel/WeaponStatusMargin/WeaponStatusVBox/WeaponStatusLabel"
@onready var feedback_label: Label = $"../ActionFeedbackLabel"
@onready var scene_fade_overlay: ColorRect = $"../SceneFadeOverlay"
@onready var player: Node3D = $"../../player"
@onready var player_visual: Node3D = $"../../player/Y Bot"
@onready var quest_controller: Node = $"../QuestDemoController"
@onready var camera: Camera3D = get_viewport().get_camera_3d()
@onready var training_dummy: Node3D = get_node_or_null("../../YanCampSet/TrainingArea/TrainingDummy") as Node3D
@onready var assassinate_dummy: Node3D = get_node_or_null("../../YanCampSet/TrainingArea/AssassinationDummy") as Node3D


var current_weapon := "空手"
var has_dagger := false
var is_weapon_drawn := false
var state := ActionState.IDLE
var dash_ready := true
var feedback_tween: Tween
var action_tween: Tween
var dummy_tween: Tween
var camera_tween: Tween
var original_visual_position := Vector3.ZERO
var original_visual_rotation := Vector3.ZERO
var original_visual_scale := Vector3.ONE
var dummy_origins: Dictionary = {}
var slash_material: StandardMaterial3D
var ghost_material: StandardMaterial3D


func _ready() -> void:
	if player_visual == null:
		player_visual = player
	if player_visual != null:
		original_visual_position = player_visual.position
		original_visual_rotation = player_visual.rotation_degrees
		original_visual_scale = player_visual.scale

	_cache_target_origin(training_dummy)
	_cache_target_origin(assassinate_dummy)
	_create_effect_materials()

	feedback_label.visible = false
	_play_scene_fade_in()
	_update_weapon_ui()

	if quest_controller != null and quest_controller.has_signal("dagger_received"):
		quest_controller.dagger_received.connect(_on_dagger_received)
	if quest_controller != null and quest_controller.has_signal("map_received"):
		quest_controller.map_received.connect(_on_map_received)


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
		KEY_SHIFT, KEY_C:
			play_dash_action()
		KEY_T:
			play_assassinate_action()


func _switch_weapon(weapon_name: String) -> void:
	current_weapon = weapon_name
	_update_weapon_ui()
	_show_feedback("已切换武器：%s" % current_weapon)


func _update_weapon_ui() -> void:
	weapon_status_label.text = "当前武器：%s%s" % [current_weapon, "（已出鞘）" if is_weapon_drawn else ""]


func _on_dagger_received() -> void:
	has_dagger = true
	_show_feedback("已获得：徐夫人匕首")


func _on_map_received() -> void:
	_show_feedback("已获得：督亢地图")


func play_bow_animation() -> void:
	_play_bow_action()


func play_draw_weapon_animation() -> void:
	_play_draw_sword_action()


func play_attack_animation() -> void:
	_play_slash_action()


func play_dash_action() -> void:
	_play_dash_action()


func play_assassinate_action() -> void:
	_play_assassinate_action()


func _play_bow_action() -> void:
	if not _begin_action(ActionState.BOWING):
		return

	_show_feedback("荆轲拱手行礼")
	action_tween = create_tween()
	action_tween.set_parallel(true)
	action_tween.tween_property(player_visual, "rotation_degrees:x", original_visual_rotation.x - 16.0, 0.16)
	action_tween.tween_property(player_visual, "scale", original_visual_scale * Vector3(0.97, 0.84, 0.97), 0.16)
	action_tween.chain().tween_interval(0.12)
	action_tween.chain().tween_property(player_visual, "rotation_degrees", original_visual_rotation, 0.2)
	action_tween.parallel().tween_property(player_visual, "scale", original_visual_scale, 0.2)
	action_tween.tween_callback(_finish_action)


func _play_draw_sword_action() -> void:
	if not _begin_action(ActionState.DRAWING):
		return

	is_weapon_drawn = not is_weapon_drawn
	_update_weapon_ui()
	_show_feedback("荆轲缓缓拔剑" if is_weapon_drawn else "荆轲收剑入鞘")
	var target_rotation := original_visual_rotation + Vector3(0.0, 22.0 if is_weapon_drawn else -18.0, 0.0)
	action_tween = create_tween()
	action_tween.set_parallel(true)
	action_tween.tween_property(player_visual, "rotation_degrees", target_rotation, 0.12)
	action_tween.tween_property(player_visual, "scale", original_visual_scale * Vector3(1.1, 1.08, 1.1), 0.12)
	action_tween.chain().tween_property(player_visual, "rotation_degrees", original_visual_rotation, 0.16)
	action_tween.parallel().tween_property(player_visual, "scale", original_visual_scale, 0.16)
	action_tween.tween_callback(_finish_action)


func _play_slash_action() -> void:
	if not _begin_action(ActionState.ATTACKING):
		return

	_show_feedback("挥砍")
	var forward := _get_forward()
	var slash_position := original_visual_position + player.basis.inverse() * (forward * 0.55)
	var slash_rotation := original_visual_rotation + Vector3(0.0, 0.0, -22.0)
	_spawn_slash_arc(player.global_position + forward * 1.35 + Vector3.UP * 1.25, forward)

	action_tween = create_tween()
	action_tween.set_parallel(true)
	action_tween.tween_property(player_visual, "position", slash_position, 0.09)
	action_tween.tween_property(player_visual, "rotation_degrees", slash_rotation, 0.09)
	action_tween.tween_property(player_visual, "scale", original_visual_scale * Vector3(1.16, 0.96, 1.16), 0.09)
	action_tween.chain().tween_property(player_visual, "position", original_visual_position, 0.16)
	action_tween.parallel().tween_property(player_visual, "rotation_degrees", original_visual_rotation, 0.16)
	action_tween.parallel().tween_property(player_visual, "scale", original_visual_scale, 0.16)
	action_tween.tween_callback(_check_attack_hit)
	action_tween.tween_callback(_finish_action)


func _play_dash_action() -> void:
	if not dash_ready:
		_show_feedback("突进尚在调整气息")
		return
	if not _begin_action(ActionState.DASHING):
		return

	dash_ready = false
	_show_feedback("疾行突进")
	var forward := _get_forward()
	var start := player.global_position
	var end := start + forward * DASH_DISTANCE
	var target := _find_nearest_target(DASH_DISTANCE + 1.0)
	if target != null:
		var to_target := target.global_position - start
		if to_target.length() > 1.4 and to_target.normalized().dot(forward) > 0.25:
			end = target.global_position - to_target.normalized() * 1.4

	_spawn_dash_ghost(start)
	_spawn_dash_ghost(start + forward * 1.25)
	_spawn_dash_ghost(start + forward * 2.5)
	_shake_camera(0.08, 0.08)

	action_tween = create_tween()
	action_tween.tween_property(player, "global_position", end, DASH_DURATION).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	action_tween.tween_callback(_finish_action)
	get_tree().create_timer(DASH_COOLDOWN).timeout.connect(func() -> void: dash_ready = true)


func _play_assassinate_action() -> void:
	var target := _find_nearest_target(ASSASSINATE_RANGE)
	if target == null:
		_show_feedback("附近没有可刺杀目标")
		return
	if not _begin_action(ActionState.ASSASSINATING):
		return

	_show_feedback("刺杀")
	var approach_dir := (target.global_position - player.global_position).normalized()
	if approach_dir.length() < 0.1:
		approach_dir = _get_forward()
	var side_back := target.global_position - approach_dir * 1.05 + Vector3(0.0, 0.0, 0.35)

	action_tween = create_tween()
	action_tween.tween_property(player, "global_position", side_back, 0.16).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	action_tween.tween_callback(func() -> void: player.look_at(target.global_position, Vector3.UP))
	action_tween.tween_callback(func() -> void: _spawn_slash_arc(target.global_position + Vector3.UP * 1.2, _get_forward()))
	action_tween.tween_property(player_visual, "rotation_degrees:z", original_visual_rotation.z - 28.0, 0.1)
	action_tween.parallel().tween_property(player_visual, "scale", original_visual_scale * Vector3(1.12, 0.92, 1.12), 0.1)
	action_tween.tween_callback(func() -> void: _play_target_hit_feedback(target, "刺杀成功"))
	action_tween.tween_interval(0.08)
	action_tween.tween_property(player_visual, "rotation_degrees", original_visual_rotation, 0.16)
	action_tween.parallel().tween_property(player_visual, "scale", original_visual_scale, 0.16)
	action_tween.tween_callback(_finish_action)


func _begin_action(next_state: int) -> bool:
	if player == null or player_visual == null:
		return false
	if state != ActionState.IDLE:
		return false
	if action_tween != null and action_tween.is_valid():
		action_tween.kill()
	_restore_visual_transform()
	state = next_state
	return true


func _finish_action() -> void:
	_restore_visual_transform()
	state = ActionState.IDLE


func _restore_visual_transform() -> void:
	if player_visual == null:
		return
	player_visual.position = original_visual_position
	player_visual.rotation_degrees = original_visual_rotation
	player_visual.scale = original_visual_scale


func _check_attack_hit() -> void:
	var target := _find_nearest_target(ATTACK_RANGE)
	if target == null:
		return
	_play_target_hit_feedback(target, "命中")


func _play_target_hit_feedback(target: Node3D, message: String) -> void:
	if target == null:
		return

	_cache_target_origin(target)
	if dummy_tween != null and dummy_tween.is_valid():
		dummy_tween.kill()

	var origin: Dictionary = dummy_origins[target]
	target.position = origin.position
	target.rotation_degrees = origin.rotation
	target.scale = origin.scale
	_show_feedback(message)
	_spawn_floating_text(message, target.global_position + Vector3.UP * 2.5)
	_shake_camera(0.12, 0.08)

	dummy_tween = create_tween()
	dummy_tween.set_parallel(true)
	dummy_tween.tween_property(target, "position", origin.position + Vector3(0.22, 0.0, 0.0), 0.07)
	dummy_tween.tween_property(target, "rotation_degrees", origin.rotation + Vector3(0.0, 0.0, 10.0), 0.07)
	dummy_tween.tween_property(target, "scale", origin.scale * Vector3(1.08, 0.9, 1.08), 0.07)
	dummy_tween.chain().tween_property(target, "position", origin.position, 0.15)
	dummy_tween.parallel().tween_property(target, "rotation_degrees", origin.rotation, 0.15)
	dummy_tween.parallel().tween_property(target, "scale", origin.scale, 0.15)


func _find_nearest_target(range: float) -> Node3D:
	var candidates: Array[Node3D] = []
	if training_dummy != null:
		candidates.append(training_dummy)
	if assassinate_dummy != null:
		candidates.append(assassinate_dummy)

	var nearest: Node3D
	var nearest_distance := INF
	for candidate in candidates:
		var distance := player.global_position.distance_to(candidate.global_position)
		if distance <= range and distance < nearest_distance:
			nearest = candidate
			nearest_distance = distance
	return nearest


func _get_forward() -> Vector3:
	if player == null:
		return Vector3.FORWARD
	var forward := -player.global_transform.basis.z
	forward.y = 0.0
	if forward.length() < 0.01:
		return Vector3.FORWARD
	return forward.normalized()


func _cache_target_origin(target: Node3D) -> void:
	if target == null or dummy_origins.has(target):
		return
	dummy_origins[target] = {
		"position": target.position,
		"rotation": target.rotation_degrees,
		"scale": target.scale,
	}


func _create_effect_materials() -> void:
	slash_material = StandardMaterial3D.new()
	slash_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	slash_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	slash_material.albedo_color = Color(1.0, 0.78, 0.34, 0.68)
	slash_material.emission_enabled = true
	slash_material.emission = Color(1.0, 0.58, 0.16, 1)
	slash_material.emission_energy_multiplier = 1.45
	slash_material.cull_mode = BaseMaterial3D.CULL_DISABLED

	ghost_material = StandardMaterial3D.new()
	ghost_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	ghost_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	ghost_material.albedo_color = Color(0.85, 0.72, 0.45, 0.22)
	ghost_material.cull_mode = BaseMaterial3D.CULL_DISABLED


func _spawn_slash_arc(position: Vector3, forward: Vector3) -> void:
	var arc := MeshInstance3D.new()
	var mesh := QuadMesh.new()
	mesh.size = Vector2(2.1, 0.55)
	var material := slash_material.duplicate() as StandardMaterial3D
	arc.mesh = mesh
	arc.material_override = material
	get_tree().current_scene.add_child(arc)
	arc.global_position = position
	arc.look_at(position + forward, Vector3.UP)
	arc.rotation_degrees.x -= 18.0
	arc.rotation_degrees.z = -26.0

	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(arc, "scale", Vector3(1.35, 1.35, 1.35), 0.16)
	tween.tween_property(material, "albedo_color:a", 0.0, 0.18)
	tween.chain().tween_callback(arc.queue_free)


func _spawn_dash_ghost(position: Vector3) -> void:
	var ghost := MeshInstance3D.new()
	var mesh := CapsuleMesh.new()
	mesh.radius = 0.35
	mesh.height = 1.55
	var material := ghost_material.duplicate() as StandardMaterial3D
	ghost.mesh = mesh
	ghost.material_override = material
	get_tree().current_scene.add_child(ghost)
	ghost.global_position = position + Vector3.UP * 0.8

	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(ghost, "scale", Vector3(1.15, 1.15, 1.15), 0.22)
	tween.tween_property(material, "albedo_color:a", 0.0, 0.24)
	tween.chain().tween_callback(ghost.queue_free)


func _spawn_floating_text(text: String, position: Vector3) -> void:
	var label := Label3D.new()
	label.text = text
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.font_size = 28
	label.modulate = Color(1.0, 0.78, 0.34, 1)
	get_tree().current_scene.add_child(label)
	label.global_position = position

	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(label, "global_position", position + Vector3.UP * 0.75, 0.6)
	tween.tween_property(label, "modulate:a", 0.0, 0.6)
	tween.chain().tween_callback(label.queue_free)


func _shake_camera(amount: float, duration: float) -> void:
	if camera == null:
		return
	if camera_tween != null and camera_tween.is_valid():
		camera_tween.kill()

	var original_position := camera.position
	camera_tween = create_tween()
	camera_tween.tween_property(camera, "position", original_position + Vector3(amount, amount * 0.5, 0.0), duration * 0.5)
	camera_tween.tween_property(camera, "position", original_position, duration * 0.5)


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
