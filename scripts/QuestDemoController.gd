extends Node


signal dagger_received
signal map_received


const FRAME_TEXTURE := preload("res://art/ui/main_menu/Menu_Form/frame1_transparent.png")
const BUTTON_TEXTURE_NORMAL := preload("res://art/ui/main_menu/Menu_Form/button1_transparent.png")
const BUTTON_TEXTURE_HOVER := preload("res://art/ui/main_menu/Menu_Form/button2_transparent.png")
const BUTTON_TEXTURE_PRESSED := preload("res://art/ui/main_menu/Menu_Form/button3_transparent.png")

@onready var dialogue_panel: Node = $"../DialoguePanel"
@onready var operation_hint_panel: PanelContainer = $"../OperationHintPanel"
@onready var operation_hint_label: Label = $"../OperationHintPanel/OperationHintMargin/OperationHintLabel"
@onready var weapon_status_panel: PanelContainer = $"../WeaponStatusPanel"
@onready var weapon_status_label: Label = $"../WeaponStatusPanel/WeaponStatusMargin/WeaponStatusVBox/WeaponStatusLabel"
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
@onready var talk_to_taizi_button: Button = $"../TalkToTaiziButton"
@onready var return_main_menu_button: Button = $"../ReturnMainMenuButton"


var quest_started := false
var has_dagger := false
var has_map := false
var quest_ready_to_depart := false
var fade_layer: ColorRect
var feedback_label: Label
var feedback_tween: Tween
var hud_open := false


func _ready() -> void:
	_configure_hud_layout()
	operation_hint_panel.visible = false
	quest_panel.visible = false
	result_panel.visible = false
	depart_button.visible = false
	depart_button.text = "前往太子丹府"
	go_to_qin_button.text = "前往秦境关隘"
	_apply_ui_theme()

	await get_tree().process_frame
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


func _configure_hud_layout() -> void:
	operation_hint_panel.custom_minimum_size = Vector2(280, 244)
	operation_hint_panel.position = Vector2(16, 16)
	operation_hint_panel.size = Vector2(280, 244)

	quest_panel.custom_minimum_size = Vector2(390, 292)
	quest_panel.position = Vector2(16, 284)
	quest_panel.size = Vector2(390, 292)
	var quest_margin := quest_panel.get_node_or_null("QuestMargin") as MarginContainer
	if quest_margin != null:
		quest_margin.add_theme_constant_override("margin_left", 58)
		quest_margin.add_theme_constant_override("margin_top", 86)
		quest_margin.add_theme_constant_override("margin_right", 58)
		quest_margin.add_theme_constant_override("margin_bottom", 38)
	var quest_vbox := quest_panel.get_node_or_null("QuestMargin/QuestVBox") as VBoxContainer
	if quest_vbox != null:
		quest_vbox.add_theme_constant_override("separation", 6)

	operation_hint_label.add_theme_font_size_override("font_size", 16)
	operation_hint_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	operation_hint_label.clip_text = true
	quest_objective_label.custom_minimum_size = Vector2(quest_objective_label.custom_minimum_size.x, 34)
	quest_objective_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	quest_objective_label.clip_text = true
	quest_status_label.custom_minimum_size = Vector2(quest_status_label.custom_minimum_size.x, 26)
	quest_status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	quest_status_label.clip_text = true

	for button in [receive_dagger_button, receive_map_button]:
		button.custom_minimum_size = Vector2(132, 36)
	depart_button.custom_minimum_size = Vector2(depart_button.custom_minimum_size.x, 36)


func _process(_delta: float) -> void:
	var esc_held := Input.is_key_pressed(KEY_ESCAPE)
	var modal_open := result_panel.visible or bool(dialogue_panel.get("visible"))
	if Input.is_action_just_pressed("interact") and not modal_open:
		hud_open = not hud_open

	operation_hint_panel.visible = hud_open and not esc_held and not modal_open
	quest_panel.visible = hud_open and not esc_held and not modal_open
	weapon_status_panel.visible = not esc_held and not modal_open
	talk_to_taizi_button.visible = not esc_held and not modal_open
	return_main_menu_button.visible = not esc_held and not modal_open


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
	fade_layer.z_index = 200
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
	feedback_label.add_theme_color_override("font_color", Color(1.0, 0.88, 0.56))
	feedback_label.add_theme_stylebox_override("normal", _make_panel_style(Color(0.07, 0.045, 0.025, 0.9), Color(0.92, 0.66, 0.27, 0.88), 6))
	feedback_label.z_index = 120
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


func _apply_ui_theme() -> void:
	operation_hint_panel.add_theme_stylebox_override("panel", _make_panel_style(Color(0.02, 0.017, 0.014, 0.5), Color(0.8, 0.62, 0.28, 0.42), 6))
	operation_hint_label.add_theme_font_size_override("font_size", 16)
	operation_hint_label.add_theme_color_override("font_color", Color(0.95, 0.9, 0.78, 0.9))
	weapon_status_panel.add_theme_stylebox_override("panel", _make_panel_style(Color(0.025, 0.02, 0.016, 0.62), Color(0.85, 0.64, 0.25, 0.7), 6))
	weapon_status_label.add_theme_color_override("font_color", Color(1.0, 0.88, 0.56))

	quest_panel.add_theme_stylebox_override("panel", _make_panel_style(Color(0.02, 0.017, 0.014, 0.68), Color(0.9, 0.66, 0.25, 0.0), 6))
	_add_frame_texture(quest_panel)
	quest_title_label.add_theme_font_size_override("font_size", 19)
	quest_title_label.add_theme_color_override("font_color", Color(1.0, 0.78, 0.35))
	quest_objective_label.add_theme_font_size_override("font_size", 15)
	quest_objective_label.add_theme_color_override("font_color", Color(0.92, 0.86, 0.74))
	quest_status_label.add_theme_font_size_override("font_size", 15)
	quest_status_label.add_theme_color_override("font_color", Color(0.67, 0.84, 0.78))
	result_panel.add_theme_stylebox_override("panel", _make_panel_style(Color(0.035, 0.027, 0.02, 0.9), Color(0.86, 0.62, 0.26, 0.82), 7))

	for button in [receive_dagger_button, receive_map_button, depart_button, close_result_button, back_to_menu_button, go_to_qin_button, talk_to_taizi_button, return_main_menu_button]:
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
	style.content_margin_left = 10
	style.content_margin_right = 10
	return style


func _add_frame_texture(panel: PanelContainer) -> void:
	if panel.get_node_or_null("BronzeFrameTexture") != null:
		return

	var frame := TextureRect.new()
	frame.name = "BronzeFrameTexture"
	frame.texture = FRAME_TEXTURE
	frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
	frame.set_anchors_preset(Control.PRESET_FULL_RECT)
	frame.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	frame.stretch_mode = TextureRect.STRETCH_SCALE
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
	plate.stretch_mode = TextureRect.STRETCH_SCALE

	var label := button.get_node_or_null("ButtonText") as Label
	if label == null:
		label = Label.new()
		label.name = "ButtonText"
		label.set_anchors_preset(Control.PRESET_FULL_RECT)
		label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		label.clip_text = true
		label.add_theme_font_size_override("font_size", 17)
		label.add_theme_color_override("font_color", Color(0.98, 0.8, 0.42))
		label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.82))
		label.add_theme_constant_override("shadow_offset_x", 2)
		label.add_theme_constant_override("shadow_offset_y", 2)
		button.add_child(label)
	label.offset_left = 18
	label.offset_right = -18
	label.offset_top = 2
	label.offset_bottom = -2
	label.text = original_text

	button.mouse_entered.connect(func() -> void: _set_button_plate(button, BUTTON_TEXTURE_HOVER))
	button.mouse_exited.connect(func() -> void: _set_button_plate(button, BUTTON_TEXTURE_NORMAL))
	button.button_down.connect(func() -> void: _set_button_plate(button, BUTTON_TEXTURE_PRESSED))
	button.button_up.connect(func() -> void: _set_button_plate(button, BUTTON_TEXTURE_HOVER if button.get_global_rect().has_point(button.get_global_mouse_position()) else BUTTON_TEXTURE_NORMAL))


func _set_button_plate(button: Button, texture: Texture2D) -> void:
	var plate := button.get_node_or_null("PlateTexture") as TextureRect
	if plate != null:
		plate.texture = texture
