extends Node


const FRAME_TEXTURE := preload("res://art/ui/main_menu/Menu_Form/frame1_transparent.png")
const BUTTON_TEXTURE_NORMAL := preload("res://art/ui/main_menu/Menu_Form/button1_transparent.png")
const BUTTON_TEXTURE_HOVER := preload("res://art/ui/main_menu/Menu_Form/button2_transparent.png")
const BUTTON_TEXTURE_PRESSED := preload("res://art/ui/main_menu/Menu_Form/button3_transparent.png")

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
@onready var task_panel: PanelContainer = $"../CanvasLayer/TaskPanel"
@onready var title_label: Label = $"../CanvasLayer/TaskPanel/TaskMargin/TaskVBox/TitleLabel"
@onready var objective_label: Label = $"../CanvasLayer/TaskPanel/TaskMargin/TaskVBox/ObjectiveLabel"
@onready var state_label: Label = $"../CanvasLayer/TaskPanel/TaskMargin/TaskVBox/StateLabel"
@onready var prompt_label: Label = $"../CanvasLayer/PromptLabel"
@onready var message_panel: PanelContainer = $"../CanvasLayer/MessagePanel"
@onready var message_title: Label = $"../CanvasLayer/MessagePanel/MessageMargin/MessageVBox/MessageTitle"
@onready var message_body: Label = $"../CanvasLayer/MessagePanel/MessageMargin/MessageVBox/MessageBody"
@onready var message_button: Button = $"../CanvasLayer/MessagePanel/MessageMargin/MessageVBox/MessageButton"
@onready var canvas_layer: CanvasLayer = $"../CanvasLayer"


var prompt_mode := ""
var interaction_distance := 3.2
var fade_layer: ColorRect
var feedback_panel: PanelContainer
var feedback_label: Label
var decision_overlay: ColorRect
var decision_panel: PanelContainer
var feedback_tween: Tween
var feedback_panel_base_y := 0.0
var decision_locked := false
var task_panel_open := false


func _ready() -> void:
	_apply_ui_theme()
	title_label.text = scene_title
	objective_label.text = objective_text
	task_panel.visible = false
	message_panel.visible = false
	prompt_label.visible = false
	message_button.pressed.connect(_hide_message)
	_create_runtime_layers()
	_play_fade_in()
	_show_feedback(scene_title)
	_refresh_state_label()


func _process(_delta: float) -> void:
	var esc_held := Input.is_key_pressed(KEY_ESCAPE)
	prompt_mode = ""
	var prompt := ""

	if not message_panel.visible and not decision_panel.visible:
		if npc_marker != null and player.global_position.distance_to(npc_marker.global_position) <= interaction_distance:
			prompt_mode = "npc"
			prompt = "按 E 与%s对话" % npc_name
		elif portal_marker != null and player.global_position.distance_to(portal_marker.global_position) <= interaction_distance:
			prompt_mode = "portal"
			prompt = "按 E 前往%s" % portal_name

	if Input.is_action_just_pressed("interact") and not message_panel.visible and not decision_panel.visible:
		if prompt_mode == "npc":
			_interact_with_npc()
		elif prompt_mode == "portal":
			_try_use_portal()
		else:
			task_panel_open = not task_panel_open

	task_panel.visible = task_panel_open and not esc_held and not message_panel.visible and not decision_panel.visible
	_set_hud_buttons_visible(not esc_held and not message_panel.visible and not decision_panel.visible)

	prompt_label.visible = prompt != "" and not esc_held
	prompt_label.text = prompt


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
		_show_final_decision()
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
	print("[SceneTransition] start: ", path)
	if fade_layer == null:
		push_error("[SceneTransition] Fade layer is missing before scene change.")
		_recover_scene_change_failure("转场黑幕缺失，无法切换场景。")
		return

	fade_layer.visible = true
	fade_layer.modulate.a = 0.0
	var tween := create_tween()
	tween.tween_property(fade_layer, "modulate:a", 1.0, 0.36)
	await tween.finished

	if not ResourceLoader.exists(path):
		push_error("[SceneTransition] Target scene does not exist: %s" % path)
		_recover_scene_change_failure("场景不存在：%s" % path)
		return

	var err := get_tree().change_scene_to_file(path)
	print("[SceneTransition] change_scene result: ", err)
	if err != OK:
		push_error("[SceneTransition] Failed to change scene: %s err=%s" % [path, err])
		_recover_scene_change_failure("场景切换失败：%s" % err)


func _show_message(title: String, body: String) -> void:
	message_title.text = title
	message_body.text = body
	message_panel.visible = true
	message_panel.modulate.a = 0.0
	message_panel.scale = Vector2(0.98, 0.98)
	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(message_panel, "modulate:a", 1.0, 0.16)
	tween.tween_property(message_panel, "scale", Vector2.ONE, 0.16)


func _hide_message() -> void:
	message_panel.visible = false


func _show_final_decision() -> void:
	decision_locked = false
	decision_overlay.visible = true
	decision_panel.visible = true
	decision_overlay.modulate.a = 0.0
	decision_panel.modulate.a = 0.0
	decision_panel.scale = Vector2(0.94, 0.94)
	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(decision_overlay, "modulate:a", 1.0, 0.2)
	tween.tween_property(decision_panel, "modulate:a", 1.0, 0.24)
	tween.tween_property(decision_panel, "scale", Vector2.ONE, 0.24).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


func _finish_demo(branch_key: String, fate_delta: int, disturbance_delta: int) -> void:
	if decision_locked:
		return

	decision_locked = true
	print("[FinalChoice] selected branch: ", branch_key)
	GameState.fate_value += fate_delta
	GameState.history_disturbance += disturbance_delta
	GameState.reached_qin_palace = true
	GameState.demo_completed = true
	GameState.ending_branch = branch_key
	GameState.quest_stage = "demo_completed"
	GameState.latest_world_message = "秦王殿内，荆轲完成了刺秦演示分支。"
	print("[FinalChoice] ending_branch: ", GameState.ending_branch)
	print("[FinalChoice] changing scene to demo_result")
	_set_decision_buttons_disabled(true)
	await change_scene_with_fade("res://scene/demo_result.tscn")


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
	fade_layer.z_index = 200
	canvas.add_child(fade_layer)

	feedback_panel = PanelContainer.new()
	feedback_panel.name = "RuntimeFeedbackPanel"
	feedback_panel.visible = false
	feedback_panel.set_anchors_preset(Control.PRESET_CENTER)
	feedback_panel.offset_left = -290
	feedback_panel.offset_top = -82
	feedback_panel.offset_right = 290
	feedback_panel.offset_bottom = -18
	feedback_panel.z_index = 120
	feedback_panel.add_theme_stylebox_override("panel", _make_panel_style(Color(0.07, 0.045, 0.025, 0.9), Color(0.92, 0.66, 0.27, 0.88), 6))
	canvas.add_child(feedback_panel)
	feedback_panel_base_y = feedback_panel.position.y

	var feedback_margin := MarginContainer.new()
	feedback_margin.add_theme_constant_override("margin_left", 20)
	feedback_margin.add_theme_constant_override("margin_top", 10)
	feedback_margin.add_theme_constant_override("margin_right", 20)
	feedback_margin.add_theme_constant_override("margin_bottom", 10)
	feedback_panel.add_child(feedback_margin)

	feedback_label = Label.new()
	feedback_label.name = "RuntimeFeedbackLabel"
	feedback_label.layout_mode = 2
	feedback_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	feedback_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	feedback_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	feedback_label.add_theme_font_size_override("font_size", 24)
	feedback_label.add_theme_color_override("font_color", Color(1.0, 0.88, 0.56))
	feedback_margin.add_child(feedback_label)

	_create_decision_overlay(canvas)


func _create_decision_overlay(canvas: CanvasLayer) -> void:
	decision_overlay = ColorRect.new()
	decision_overlay.name = "AssassinationDecisionDim"
	decision_overlay.visible = false
	decision_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	decision_overlay.color = Color(0.0, 0.0, 0.0, 0.62)
	decision_overlay.z_index = 60
	canvas.add_child(decision_overlay)

	decision_panel = PanelContainer.new()
	decision_panel.name = "AssassinationDecisionPanel"
	decision_panel.visible = false
	decision_panel.set_anchors_preset(Control.PRESET_CENTER)
	decision_panel.offset_left = -330
	decision_panel.offset_top = -205
	decision_panel.offset_right = 330
	decision_panel.offset_bottom = 215
	decision_panel.pivot_offset = Vector2(330, 210)
	decision_panel.z_index = 70
	decision_panel.add_theme_stylebox_override("panel", _make_decision_panel_style())
	canvas.add_child(decision_panel)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 34)
	margin.add_theme_constant_override("margin_top", 28)
	margin.add_theme_constant_override("margin_right", 34)
	margin.add_theme_constant_override("margin_bottom", 30)
	decision_panel.add_child(margin)

	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 14)
	margin.add_child(box)

	var title := Label.new()
	title.text = "图穷匕见"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 34)
	title.add_theme_color_override("font_color", Color(1.0, 0.76, 0.28))
	box.add_child(title)

	var body := Label.new()
	body.text = "秦王展卷而观，督亢地图徐徐展开。\n匕首藏于图穷之处，殿中一瞬寂静。\n\n此刻，你将如何改写天命？"
	body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	body.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	body.add_theme_font_size_override("font_size", 19)
	body.add_theme_color_override("font_color", Color(0.92, 0.86, 0.74))
	box.add_child(body)

	box.add_child(_make_decision_button("立即出手，孤注一掷", "assassinate_now", 20, 30))
	box.add_child(_make_decision_button("等待更近的时机", "wait_for_chance", 10, 15))
	box.add_child(_make_decision_button("收起杀意，放弃刺秦", "abandon_assassination", -5, 5))


func _make_decision_panel_style() -> StyleBoxFlat:
	return _make_panel_style(Color(0.035, 0.028, 0.02, 0.94), Color(0.78, 0.56, 0.23, 0.92), 8)


func _make_decision_button(text: String, branch_key: String, fate_delta: int, disturbance_delta: int) -> Button:
	var button := Button.new()
	button.text = text
	button.custom_minimum_size = Vector2(0, 48)
	button.add_theme_font_size_override("font_size", 19)
	button.add_theme_color_override("font_color", Color(0.98, 0.84, 0.46))
	_register_plate_button(button)
	button.pressed.connect(_finish_demo.bind(branch_key, fate_delta, disturbance_delta))
	button.mouse_entered.connect(func() -> void:
		var tween := create_tween()
		tween.tween_property(button, "scale", Vector2(1.025, 1.025), 0.08)
	)
	button.mouse_exited.connect(func() -> void:
		var tween := create_tween()
		tween.tween_property(button, "scale", Vector2.ONE, 0.08)
	)
	return button


func _make_button_style(color: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = color
	style.border_color = Color(0.74, 0.54, 0.22, 0.86)
	style.set_border_width_all(1)
	style.corner_radius_top_left = 5
	style.corner_radius_top_right = 5
	style.corner_radius_bottom_left = 5
	style.corner_radius_bottom_right = 5
	style.content_margin_top = 8
	style.content_margin_bottom = 8
	return style


func _set_decision_buttons_disabled(disabled: bool) -> void:
	if decision_panel == null:
		return

	for child in decision_panel.find_children("*", "Button", true, false):
		var button := child as Button
		if button != null:
			button.disabled = disabled


func _recover_scene_change_failure(message: String) -> void:
	if fade_layer != null:
		fade_layer.modulate.a = 0.0
		fade_layer.visible = false
	decision_locked = false
	_set_decision_buttons_disabled(false)
	if feedback_label != null:
		_show_feedback(message)
	else:
		push_warning("[SceneTransition] %s" % message)


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
	feedback_panel.visible = true
	feedback_panel.modulate.a = 0.0
	feedback_panel.position.y = feedback_panel_base_y + 8
	feedback_tween = create_tween()
	feedback_tween.set_parallel(true)
	feedback_tween.tween_property(feedback_panel, "modulate:a", 1.0, 0.16)
	feedback_tween.tween_property(feedback_panel, "position:y", feedback_panel_base_y, 0.16)
	feedback_tween.chain().tween_interval(1.35)
	feedback_tween.tween_property(feedback_panel, "modulate:a", 0.0, 0.32)
	feedback_tween.tween_callback(func() -> void: feedback_panel.visible = false)


func _apply_ui_theme() -> void:
	task_panel.add_theme_stylebox_override("panel", _make_panel_style(Color(0.03, 0.025, 0.02, 0.5), Color(0.9, 0.66, 0.25, 0.62), 6))
	_add_frame_overlay(task_panel)
	title_label.add_theme_font_size_override("font_size", 23)
	title_label.add_theme_color_override("font_color", Color(1.0, 0.78, 0.35))
	objective_label.add_theme_font_size_override("font_size", 16)
	objective_label.add_theme_color_override("font_color", Color(0.92, 0.86, 0.74))
	state_label.add_theme_font_size_override("font_size", 15)
	state_label.add_theme_color_override("font_color", Color(0.67, 0.84, 0.78))

	prompt_label.add_theme_font_size_override("font_size", 24)
	prompt_label.add_theme_color_override("font_color", Color(1.0, 0.86, 0.45))
	prompt_label.add_theme_stylebox_override("normal", _make_panel_style(Color(0.035, 0.028, 0.02, 0.62), Color(0.84, 0.62, 0.28, 0.62), 5))

	message_panel.add_theme_stylebox_override("panel", _make_panel_style(Color(0.035, 0.027, 0.02, 0.9), Color(0.86, 0.62, 0.26, 0.82), 7))
	message_title.add_theme_font_size_override("font_size", 26)
	message_title.add_theme_color_override("font_color", Color(1.0, 0.78, 0.35))
	message_body.add_theme_font_size_override("font_size", 19)
	message_body.add_theme_color_override("font_color", Color(0.93, 0.87, 0.76))
	message_body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	message_button.add_theme_font_size_override("font_size", 18)
	message_button.add_theme_color_override("font_color", Color(1.0, 0.86, 0.48))
	_register_plate_button(message_button)

	for child in canvas_layer.get_children():
		var button := child as Button
		if button != null:
			_register_plate_button(button)


func _make_panel_style(bg_color: Color, border_color: Color, radius: int) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = bg_color
	style.border_color = border_color
	style.set_border_width_all(1)
	style.corner_radius_top_left = radius
	style.corner_radius_top_right = radius
	style.corner_radius_bottom_left = radius
	style.corner_radius_bottom_right = radius
	style.shadow_color = Color(0, 0, 0, 0.38)
	style.shadow_size = 10
	return style


func _set_hud_buttons_visible(is_visible: bool) -> void:
	for child in canvas_layer.get_children():
		var button := child as Button
		if button != null:
			button.visible = is_visible


func _add_frame_overlay(panel: PanelContainer) -> void:
	if panel.get_node_or_null("BronzeFrameOverlay") != null:
		return

	var frame := NinePatchRect.new()
	frame.name = "BronzeFrameOverlay"
	frame.texture = FRAME_TEXTURE
	frame.draw_center = false
	frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
	frame.set_anchors_preset(Control.PRESET_FULL_RECT)
	frame.patch_margin_left = 86
	frame.patch_margin_top = 70
	frame.patch_margin_right = 86
	frame.patch_margin_bottom = 70
	panel.add_child(frame)
	panel.move_child(frame, 0)


func _register_plate_button(button: Button) -> void:
	var original_text := button.text
	button.text = ""
	button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	var empty_style := StyleBoxEmpty.new()
	for state in ["normal", "hover", "pressed", "focus", "disabled"]:
		button.add_theme_stylebox_override(state, empty_style)

	var plate := button.get_node_or_null("PlateTexture") as TextureRect
	if plate == null:
		plate = TextureRect.new()
		plate.name = "PlateTexture"
		plate.set_anchors_preset(Control.PRESET_FULL_RECT)
		plate.mouse_filter = Control.MOUSE_FILTER_IGNORE
		plate.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		plate.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
		button.add_child(plate)
		button.move_child(plate, 0)
	plate.texture = BUTTON_TEXTURE_NORMAL

	var label := button.get_node_or_null("ButtonText") as Label
	if label == null:
		label = Label.new()
		label.name = "ButtonText"
		label.set_anchors_preset(Control.PRESET_FULL_RECT)
		label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		label.add_theme_font_size_override("font_size", 17)
		label.add_theme_color_override("font_color", Color(0.98, 0.8, 0.42))
		label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.82))
		label.add_theme_constant_override("shadow_offset_x", 2)
		label.add_theme_constant_override("shadow_offset_y", 2)
		button.add_child(label)
	if original_text != "":
		label.text = original_text

	button.mouse_entered.connect(func() -> void: _set_button_plate(button, BUTTON_TEXTURE_HOVER))
	button.mouse_exited.connect(func() -> void: _set_button_plate(button, BUTTON_TEXTURE_NORMAL))
	button.button_down.connect(func() -> void: _set_button_plate(button, BUTTON_TEXTURE_PRESSED))
	button.button_up.connect(func() -> void: _set_button_plate(button, BUTTON_TEXTURE_HOVER if button.get_global_rect().has_point(button.get_global_mouse_position()) else BUTTON_TEXTURE_NORMAL))


func _set_button_plate(button: Button, texture: Texture2D) -> void:
	var plate := button.get_node_or_null("PlateTexture") as TextureRect
	if plate != null:
		plate.texture = texture
