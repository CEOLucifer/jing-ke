extends Node3D


var move_speed := 5.0
var player: CharacterBody3D
var camera: Camera3D
var taizi_dan: Node3D
var can_talk_to_taizi := false
var is_entering_dialogue := false

var interaction_prompt_panel: PanelContainer
var interaction_prompt: Label
var hint_label: Label
var world_status_label: Label
var world_message_label: Label


# 初始化 3D 易水河畔灰盒场景。
func _ready() -> void:
	build_world()
	refresh_world_status_hud()


# 每帧更新玩家移动、镜头跟随和交互提示。
func _physics_process(delta: float) -> void:
	update_player_movement(delta)
	update_camera_follow()
	update_interaction_prompt()


# 处理按 E 与太子丹对话。
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_E and can_talk_to_taizi and not is_entering_dialogue:
			enter_dialogue_scene()


# 创建整个灰盒世界。
func build_world() -> void:
	create_ground()
	create_river()
	create_player()
	taizi_dan = create_npc("太子丹", Vector3(0, 0, -7), Color(0.32, 0.48, 0.86, 1.0))
	create_npc("樊於期", Vector3(3.2, 0, -6.2), Color(0.58, 0.50, 0.42, 1.0))
	create_light_and_camera()
	create_hud()


# 创建玩家占位角色。
func create_player() -> void:
	player = CharacterBody3D.new()
	player.name = "JingKe"
	player.position = Vector3(0, 0.9, 0)
	add_child(player)

	var collision := CollisionShape3D.new()
	var capsule_shape := CapsuleShape3D.new()
	capsule_shape.radius = 0.35
	capsule_shape.height = 1.8
	collision.shape = capsule_shape
	player.add_child(collision)

	var mesh_instance := MeshInstance3D.new()
	var capsule_mesh := CapsuleMesh.new()
	capsule_mesh.radius = 0.35
	capsule_mesh.height = 1.8
	mesh_instance.mesh = capsule_mesh
	mesh_instance.material_override = _create_material(Color(0.78, 0.68, 0.45, 1.0))
	player.add_child(mesh_instance)

	_add_label_3d(player, "荆轲", Vector3(0, 1.45, 0))


# 创建 NPC 占位角色。
func create_npc(npc_name: String, npc_position: Vector3, color: Color) -> Node3D:
	var npc := Node3D.new()
	npc.name = npc_name
	npc.position = npc_position
	add_child(npc)

	var body := MeshInstance3D.new()
	var cylinder := CylinderMesh.new()
	cylinder.top_radius = 0.38
	cylinder.bottom_radius = 0.38
	cylinder.height = 1.7
	body.mesh = cylinder
	body.position = Vector3(0, 0.85, 0)
	body.material_override = _create_material(color)
	npc.add_child(body)

	var head := MeshInstance3D.new()
	var sphere := SphereMesh.new()
	sphere.radius = 0.28
	sphere.height = 0.56
	head.mesh = sphere
	head.position = Vector3(0, 1.95, 0)
	head.material_override = _create_material(color.lightened(0.18))
	npc.add_child(head)

	_add_label_3d(npc, npc_name, Vector3(0, 2.45, 0))
	return npc


# 创建土色地面。
func create_ground() -> void:
	var ground := MeshInstance3D.new()
	ground.name = "Ground"
	var mesh := BoxMesh.new()
	mesh.size = Vector3(26, 0.12, 22)
	ground.mesh = mesh
	ground.position = Vector3(0, -0.06, 0)
	ground.material_override = _create_material(Color(0.28, 0.22, 0.15, 1.0))
	add_child(ground)


# 创建蓝灰色易水河面。
func create_river() -> void:
	var river := MeshInstance3D.new()
	river.name = "YiRiver"
	var mesh := BoxMesh.new()
	mesh.size = Vector3(26, 0.04, 3.4)
	river.mesh = mesh
	river.position = Vector3(0, 0.01, -10.2)
	river.material_override = _create_material(Color(0.18, 0.32, 0.42, 0.92))
	add_child(river)


# 创建单个方向光和第三人称俯视镜头。
func create_light_and_camera() -> void:
	var light := DirectionalLight3D.new()
	light.name = "SunLight"
	light.rotation_degrees = Vector3(-48, -35, 0)
	light.light_energy = 1.15
	add_child(light)

	camera = Camera3D.new()
	camera.name = "FollowCamera"
	camera.current = true
	add_child(camera)
	update_camera_follow()

	var world_environment := WorldEnvironment.new()
	var environment := Environment.new()
	environment.background_mode = Environment.BG_COLOR
	environment.background_color = Color(0.08, 0.09, 0.10, 1.0)
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.ambient_light_color = Color(0.38, 0.36, 0.32, 1.0)
	environment.ambient_light_energy = 0.6
	world_environment.environment = environment
	add_child(world_environment)


# 创建 3D 场景 HUD。
func create_hud() -> void:
	var canvas := CanvasLayer.new()
	canvas.name = "HUD"
	add_child(canvas)

	var info_panel := PanelContainer.new()
	info_panel.name = "InfoPanel"
	info_panel.position = Vector2(18, 18)
	info_panel.custom_minimum_size = Vector2(360, 86)
	info_panel.add_theme_stylebox_override("panel", _create_panel_style(Color(0.035, 0.03, 0.028, 0.78)))
	canvas.add_child(info_panel)

	var info_margin := MarginContainer.new()
	info_margin.add_theme_constant_override("margin_left", 12)
	info_margin.add_theme_constant_override("margin_top", 10)
	info_margin.add_theme_constant_override("margin_right", 12)
	info_margin.add_theme_constant_override("margin_bottom", 10)
	info_panel.add_child(info_margin)

	hint_label = Label.new()
	hint_label.text = "易水河畔 · 刺秦前夜\nWASD 移动，靠近 NPC 后按 E 交互"
	hint_label.add_theme_font_size_override("font_size", 18)
	hint_label.add_theme_color_override("font_color", Color(0.88, 0.84, 0.74, 1.0))
	info_margin.add_child(hint_label)

	var back_button := Button.new()
	back_button.name = "BackToMainMenu"
	back_button.text = "返回主菜单"
	back_button.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	back_button.offset_left = -160
	back_button.offset_top = 18
	back_button.offset_right = -18
	back_button.offset_bottom = 60
	back_button.custom_minimum_size = Vector2(140, 42)
	back_button.pressed.connect(return_to_main_menu)
	canvas.add_child(back_button)

	var status_panel := PanelContainer.new()
	status_panel.name = "WorldStatusPanel"
	status_panel.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	status_panel.offset_left = -260
	status_panel.offset_top = 76
	status_panel.offset_right = -18
	status_panel.offset_bottom = 190
	status_panel.add_theme_stylebox_override("panel", _create_panel_style(Color(0.035, 0.03, 0.028, 0.78)))
	canvas.add_child(status_panel)

	var status_margin := MarginContainer.new()
	status_margin.add_theme_constant_override("margin_left", 12)
	status_margin.add_theme_constant_override("margin_top", 10)
	status_margin.add_theme_constant_override("margin_right", 12)
	status_margin.add_theme_constant_override("margin_bottom", 10)
	status_panel.add_child(status_margin)

	world_status_label = Label.new()
	world_status_label.add_theme_font_size_override("font_size", 17)
	world_status_label.add_theme_color_override("font_color", Color(0.88, 0.84, 0.74, 1.0))
	status_margin.add_child(world_status_label)

	var message_panel := PanelContainer.new()
	message_panel.name = "WorldMessagePanel"
	message_panel.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	message_panel.offset_left = 280
	message_panel.offset_top = -88
	message_panel.offset_right = -280
	message_panel.offset_bottom = -24
	message_panel.add_theme_stylebox_override("panel", _create_panel_style(Color(0.035, 0.03, 0.028, 0.78)))
	canvas.add_child(message_panel)

	var message_margin := MarginContainer.new()
	message_margin.add_theme_constant_override("margin_left", 14)
	message_margin.add_theme_constant_override("margin_top", 10)
	message_margin.add_theme_constant_override("margin_right", 14)
	message_margin.add_theme_constant_override("margin_bottom", 10)
	message_panel.add_child(message_margin)

	world_message_label = Label.new()
	world_message_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	world_message_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	world_message_label.add_theme_font_size_override("font_size", 17)
	world_message_label.add_theme_color_override("font_color", Color(0.95, 0.82, 0.48, 1.0))
	message_margin.add_child(world_message_label)
	message_panel.visible = GameState.latest_world_message != ""

	interaction_prompt_panel = PanelContainer.new()
	interaction_prompt_panel.name = "PromptPanel"
	interaction_prompt_panel.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
	interaction_prompt_panel.offset_left = -150
	interaction_prompt_panel.offset_top = -108
	interaction_prompt_panel.offset_right = 150
	interaction_prompt_panel.offset_bottom = -34
	interaction_prompt_panel.add_theme_stylebox_override("panel", _create_panel_style(Color(0.035, 0.03, 0.028, 0.84)))
	canvas.add_child(interaction_prompt_panel)

	interaction_prompt = Label.new()
	interaction_prompt.text = "按 E 与太子丹对话"
	interaction_prompt.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	interaction_prompt.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	interaction_prompt.add_theme_font_size_override("font_size", 20)
	interaction_prompt.add_theme_color_override("font_color", Color(0.95, 0.82, 0.48, 1.0))
	interaction_prompt_panel.add_child(interaction_prompt)
	interaction_prompt_panel.visible = false


# 更新玩家在 XZ 平面的移动。
func update_player_movement(delta: float) -> void:
	if player == null:
		return

	var input_direction := Vector3.ZERO
	if Input.is_key_pressed(KEY_W):
		input_direction.z -= 1.0
	if Input.is_key_pressed(KEY_S):
		input_direction.z += 1.0
	if Input.is_key_pressed(KEY_A):
		input_direction.x -= 1.0
	if Input.is_key_pressed(KEY_D):
		input_direction.x += 1.0

	if input_direction.length() > 0.0:
		input_direction = input_direction.normalized()
		player.look_at(player.global_position + input_direction, Vector3.UP)

	player.velocity = input_direction * move_speed
	player.move_and_slide()


# 更新第三人称俯视镜头位置。
func update_camera_follow() -> void:
	if player == null or camera == null:
		return

	var target := player.global_position
	camera.global_position = target + Vector3(0, 8.0, 8.0)
	camera.look_at(target + Vector3(0, 0.8, 0), Vector3.UP)


# 根据玩家与太子丹距离更新交互提示。
func update_interaction_prompt() -> void:
	if player == null or taizi_dan == null or interaction_prompt_panel == null:
		return

	var distance := player.global_position.distance_to(taizi_dan.global_position)
	can_talk_to_taizi = distance < 3.0
	interaction_prompt.text = "按 E 与太子丹对话\n太子丹关系值：%d" % GameState.taizi_relationship
	interaction_prompt_panel.visible = can_talk_to_taizi


# 刷新 3D 场景中的世界状态 HUD。
func refresh_world_status_hud() -> void:
	if world_status_label == null:
		return

	world_status_label.text = "天命值：%d\n历史扰动：%d\n太子丹关系：%d" % [
		GameState.fate_value,
		GameState.history_disturbance,
		GameState.taizi_relationship
	]

	if world_message_label != null:
		world_message_label.text = GameState.latest_world_message
		var message_panel := world_message_label.get_parent().get_parent() as Control
		message_panel.visible = GameState.latest_world_message != ""


# 进入已有 2D 对话系统场景。
func enter_dialogue_scene() -> void:
	is_entering_dialogue = true
	GameState.last_scene_path = "res://WorldScene.tscn"
	GameState.dialogue_target = "太子丹"
	GameState.entered_from_world = true
	get_tree().change_scene_to_file("res://DemoScene.tscn")


# 返回主菜单。
func return_to_main_menu() -> void:
	get_tree().change_scene_to_file("res://MainMenu.tscn")


# 给角色添加可识别的 3D 标签。
func _add_label_3d(parent: Node3D, text: String, label_position: Vector3) -> void:
	var label := Label3D.new()
	label.name = "%sLabel" % text
	label.text = text
	label.position = label_position
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.font_size = 32
	label.modulate = Color(0.96, 0.86, 0.58, 1.0)
	parent.add_child(label)


# 创建简单纯色材质。
func _create_material(color: Color) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = 0.85
	return material


# 创建 HUD 半透明面板样式。
func _create_panel_style(color: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = color
	style.border_color = Color(0.55, 0.40, 0.18, 0.85)
	style.set_border_width_all(1)
	style.set_corner_radius_all(6)
	return style
