extends Control


const BUTTON_TEXTURE_NORMAL := preload("res://art/ui/main_menu/Menu_Form/button1_transparent.png")
const BUTTON_TEXTURE_HOVER := preload("res://art/ui/main_menu/Menu_Form/button2_transparent.png")
const BUTTON_TEXTURE_PRESSED := preload("res://art/ui/main_menu/Menu_Form/button3_transparent.png")


@onready var title_area: VBoxContainer = $CanvasLayer/RootControl/TitleArea
@onready var left_menu_panel: PanelContainer = $CanvasLayer/RootControl/LeftMenuPanel
@onready var lore_dialog_card: Control = $CanvasLayer/RootControl/LoreDialogCard
@onready var right_lore_frame: TextureRect = $CanvasLayer/RootControl/LoreDialogCard/RightMainPanelReliefFrame
@onready var right_lore_panel: Control = $CanvasLayer/RootControl/LoreDialogCard/RightLorePanel
@onready var start_button: Button = $CanvasLayer/RootControl/LeftMenuPanel/MenuMargin/ButtonInsetPanel/ButtonInsetMargin/ButtonVBox/StartButton
@onready var story_demo_button: Button = $CanvasLayer/RootControl/LeftMenuPanel/MenuMargin/ButtonInsetPanel/ButtonInsetMargin/ButtonVBox/StoryDemoButton
@onready var continue_button: Button = $CanvasLayer/RootControl/LeftMenuPanel/MenuMargin/ButtonInsetPanel/ButtonInsetMargin/ButtonVBox/ContinueButton
@onready var load_button: Button = $CanvasLayer/RootControl/LeftMenuPanel/MenuMargin/ButtonInsetPanel/ButtonInsetMargin/ButtonVBox/LoadButton
@onready var settings_button: Button = $CanvasLayer/RootControl/LeftMenuPanel/MenuMargin/ButtonInsetPanel/ButtonInsetMargin/ButtonVBox/SettingsButton
@onready var exit_button: Button = $CanvasLayer/RootControl/LeftMenuPanel/MenuMargin/ButtonInsetPanel/ButtonInsetMargin/ButtonVBox/ExitButton
@onready var close_lore_button: Button = $CanvasLayer/RootControl/LoreDialogCard/CloseLoreButton
@onready var show_lore_button: Button = $CanvasLayer/RootControl/ShowLoreButton
@onready var message_dialog: AcceptDialog = $MessageDialog
@onready var styled_message_overlay: Control = $CanvasLayer/RootControl/StyledMessageOverlay
@onready var styled_message_panel: Control = $CanvasLayer/RootControl/StyledMessageOverlay/DialogCard
@onready var styled_message_confirm_button: Button = $CanvasLayer/RootControl/StyledMessageOverlay/DialogCard/DialogPanel/DialogMargin/DialogVBox/ConfirmButton
@onready var dialog_vbox: VBoxContainer = $CanvasLayer/RootControl/StyledMessageOverlay/DialogCard/DialogPanel/DialogMargin/DialogVBox


var menu_buttons: Array[Button] = []
var lore_panel_visible := false
var lore_dialog_position := Vector2.ZERO
var lore_tween: Tween
var message_tween: Tween
var setting_sliders: Dictionary = {}
var setting_value_labels: Dictionary = {}
var subtitle_checkbox: CheckBox
var window_mode_option: OptionButton


func _ready() -> void:
	menu_buttons = [
		start_button,
		story_demo_button,
		continue_button,
		load_button,
		settings_button,
		exit_button,
	]

	start_button.pressed.connect(_on_start_pressed)
	story_demo_button.pressed.connect(_on_story_demo_pressed)
	continue_button.pressed.connect(_on_continue_pressed)
	load_button.pressed.connect(_on_load_pressed)
	settings_button.pressed.connect(_on_settings_pressed)
	exit_button.pressed.connect(_on_quit_pressed)
	close_lore_button.pressed.connect(_hide_lore_panel)
	show_lore_button.pressed.connect(_show_lore_panel)
	styled_message_confirm_button.pressed.connect(_hide_message)

	_register_plate_button(styled_message_confirm_button)
	for button in menu_buttons:
		_register_plate_button(button)

	call_deferred("_prepare_pivots_and_intro")


func _prepare_pivots_and_intro() -> void:
	for button in menu_buttons:
		button.pivot_offset = button.size * 0.5
	close_lore_button.pivot_offset = close_lore_button.size * 0.5
	show_lore_button.pivot_offset = show_lore_button.size * 0.5
	styled_message_panel.pivot_offset = styled_message_panel.size * 0.5
	lore_dialog_position = lore_dialog_card.position
	lore_dialog_card.visible = false
	right_lore_frame.visible = true
	right_lore_panel.visible = true
	close_lore_button.visible = true
	show_lore_button.visible = true
	styled_message_overlay.visible = false
	_play_intro_animation()


func _play_intro_animation() -> void:
	var title_y := title_area.position.y
	var left_x := left_menu_panel.position.x

	title_area.modulate.a = 0.0
	left_menu_panel.modulate.a = 0.0
	show_lore_button.modulate.a = 0.0
	title_area.position.y = title_y - 22.0
	left_menu_panel.position.x = left_x - 44.0

	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(title_area, "modulate:a", 1.0, 0.45)
	tween.tween_property(title_area, "position:y", title_y, 0.45).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(left_menu_panel, "modulate:a", 1.0, 0.45).set_delay(0.08)
	tween.tween_property(left_menu_panel, "position:x", left_x, 0.45).set_delay(0.08).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(show_lore_button, "modulate:a", 1.0, 0.35).set_delay(0.24)


func _animate_button_scale(button: Button, target_scale: Vector2, duration: float) -> void:
	var tween := create_tween()
	tween.tween_property(button, "scale", target_scale, duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)


func _register_plate_button(button: Button) -> void:
	_set_button_plate(button, BUTTON_TEXTURE_NORMAL)
	button.mouse_entered.connect(_on_button_hovered.bind(button))
	button.mouse_exited.connect(_on_button_unhovered.bind(button))
	button.button_down.connect(_on_button_pressed.bind(button))
	button.button_up.connect(_on_button_released.bind(button))


func _on_button_hovered(button: Button) -> void:
	_set_button_plate(button, BUTTON_TEXTURE_HOVER)
	_animate_button_scale(button, Vector2(1.035, 1.035), 0.1)


func _on_button_unhovered(button: Button) -> void:
	_set_button_plate(button, BUTTON_TEXTURE_NORMAL)
	_animate_button_scale(button, Vector2.ONE, 0.12)


func _on_button_pressed(button: Button) -> void:
	_set_button_plate(button, BUTTON_TEXTURE_PRESSED)
	_animate_button_scale(button, Vector2(0.97, 0.97), 0.06)


func _on_button_released(button: Button) -> void:
	var mouse_inside := button.get_global_rect().has_point(get_global_mouse_position())
	_set_button_plate(button, BUTTON_TEXTURE_HOVER if mouse_inside else BUTTON_TEXTURE_NORMAL)
	_animate_button_scale(button, Vector2(1.02, 1.02) if mouse_inside else Vector2.ONE, 0.08)


func _set_button_plate(button: Button, texture: Texture2D) -> void:
	var plate_texture := button.get_node_or_null("PlateTexture") as TextureRect
	if plate_texture != null:
		plate_texture.texture = texture


func _hide_lore_panel() -> void:
	if not lore_panel_visible:
		return

	lore_panel_visible = false
	if lore_tween != null and lore_tween.is_valid():
		lore_tween.kill()

	show_lore_button.visible = true
	show_lore_button.modulate.a = 0.0
	lore_tween = create_tween()
	lore_tween.set_parallel(true)
	lore_tween.tween_property(lore_dialog_card, "position:x", lore_dialog_position.x + 72.0, 0.22).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	lore_tween.tween_property(lore_dialog_card, "modulate:a", 0.0, 0.18)
	lore_tween.tween_property(show_lore_button, "modulate:a", 1.0, 0.18).set_delay(0.12)
	lore_tween.chain().tween_callback(_finish_hide_lore_panel)


func _finish_hide_lore_panel() -> void:
	lore_dialog_card.visible = false


func _show_lore_panel() -> void:
	if lore_panel_visible:
		return

	lore_panel_visible = true
	if lore_tween != null and lore_tween.is_valid():
		lore_tween.kill()

	lore_dialog_card.visible = true
	lore_dialog_card.position.x = lore_dialog_position.x + 72.0
	lore_dialog_card.modulate.a = 0.0
	lore_tween = create_tween()
	lore_tween.set_parallel(true)
	lore_tween.tween_property(show_lore_button, "modulate:a", 0.0, 0.12)
	lore_tween.tween_property(lore_dialog_card, "position:x", lore_dialog_position.x, 0.24).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	lore_tween.tween_property(lore_dialog_card, "modulate:a", 1.0, 0.2).set_delay(0.04)
	lore_tween.chain().tween_callback(_finish_show_lore_panel)


func _finish_show_lore_panel() -> void:
	show_lore_button.visible = false


func _on_start_pressed() -> void:
	get_tree().change_scene_to_file("res://scene/main.tscn")


func _on_story_demo_pressed() -> void:
	get_tree().change_scene_to_file("res://WorldScene.tscn")


func _on_continue_pressed() -> void:
	_show_message("天命回声", "尚无可延续的命运记录。")


func _on_load_pressed() -> void:
	_show_load_panel()


func _on_settings_pressed() -> void:
	_show_settings_panel()


func _on_quit_pressed() -> void:
	_show_exit_confirm()


func _clear_dialog_content() -> void:
	for child in dialog_vbox.get_children():
		dialog_vbox.remove_child(child)
		child.queue_free()
	setting_sliders.clear()
	setting_value_labels.clear()


func _open_dialog() -> void:
	styled_message_overlay.visible = true
	styled_message_overlay.modulate.a = 0.0
	styled_message_panel.scale = Vector2(0.96, 0.96)

	if message_tween != null and message_tween.is_valid():
		message_tween.kill()

	message_tween = create_tween()
	message_tween.set_parallel(true)
	message_tween.tween_property(styled_message_overlay, "modulate:a", 1.0, 0.16)
	message_tween.tween_property(styled_message_panel, "scale", Vector2.ONE, 0.18).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)


func _make_label(text: String, font_size: int, color: Color, align := HORIZONTAL_ALIGNMENT_CENTER) -> Label:
	var label := Label.new()
	label.text = text
	label.horizontal_alignment = align
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.76))
	label.add_theme_constant_override("shadow_offset_x", 2)
	label.add_theme_constant_override("shadow_offset_y", 2)
	return label


func _make_bronze_button(text: String, width := 170.0) -> Button:
	var button := Button.new()
	button.custom_minimum_size = Vector2(width, 52)
	button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	button.text = ""
	var empty_style := StyleBoxEmpty.new()
	button.add_theme_stylebox_override("normal", empty_style)
	button.add_theme_stylebox_override("hover", empty_style)
	button.add_theme_stylebox_override("pressed", empty_style)
	button.add_theme_stylebox_override("focus", empty_style)

	var plate := TextureRect.new()
	plate.name = "PlateTexture"
	plate.set_anchors_preset(Control.PRESET_FULL_RECT)
	plate.mouse_filter = Control.MOUSE_FILTER_IGNORE
	plate.texture = BUTTON_TEXTURE_NORMAL
	plate.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	plate.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	button.add_child(plate)

	var label := Label.new()
	label.name = "ButtonText"
	label.set_anchors_preset(Control.PRESET_FULL_RECT)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.text = text
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 18)
	label.add_theme_color_override("font_color", Color(0.96, 0.78, 0.43, 1))
	label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.82))
	label.add_theme_constant_override("shadow_offset_x", 2)
	label.add_theme_constant_override("shadow_offset_y", 2)
	button.add_child(label)

	_register_plate_button(button)
	return button


func _make_button_row(buttons: Array) -> HBoxContainer:
	var row := HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", 12)
	for button in buttons:
		row.add_child(button)
	return row


func _show_message(title: String, message: String, confirm_text := "确认") -> void:
	_clear_dialog_content()
	dialog_vbox.add_theme_constant_override("separation", 18)
	dialog_vbox.add_child(_make_label(title, 28, Color(1.0, 0.76, 0.3, 1)))
	dialog_vbox.add_child(_make_label(message, 20, Color(0.9, 0.84, 0.72, 1)))

	var confirm_button := _make_bronze_button(confirm_text, 190)
	confirm_button.pressed.connect(_hide_message)
	dialog_vbox.add_child(_make_button_row([confirm_button]))
	call_deferred("_refresh_dialog_button_pivots")
	_open_dialog()


func _show_confirm(title: String, message: String, confirm_text: String, cancel_text: String, on_confirm: Callable) -> void:
	_clear_dialog_content()
	dialog_vbox.add_theme_constant_override("separation", 18)
	dialog_vbox.add_child(_make_label(title, 28, Color(1.0, 0.76, 0.3, 1)))
	dialog_vbox.add_child(_make_label(message, 20, Color(0.9, 0.84, 0.72, 1)))

	var cancel_button := _make_bronze_button(cancel_text, 170)
	var confirm_button := _make_bronze_button(confirm_text, 190)
	cancel_button.pressed.connect(_hide_message)
	confirm_button.pressed.connect(func() -> void:
		_hide_message()
		on_confirm.call()
	)
	dialog_vbox.add_child(_make_button_row([cancel_button, confirm_button]))
	cancel_button.call_deferred("grab_focus")
	call_deferred("_refresh_dialog_button_pivots")
	_open_dialog()


func _show_load_panel() -> void:
	_clear_dialog_content()
	dialog_vbox.add_theme_constant_override("separation", 12)
	dialog_vbox.add_child(_make_label("命运卷宗", 28, Color(1.0, 0.76, 0.3, 1)))
	dialog_vbox.add_child(_make_label("选择一份命运记录，回到曾经的抉择之处。", 17, Color(0.86, 0.8, 0.68, 1)))

	var list_area := PanelContainer.new()
	list_area.custom_minimum_size = Vector2(0, 110)
	list_area.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var list_style := StyleBoxFlat.new()
	list_style.bg_color = Color(0.04, 0.035, 0.026, 0.62)
	list_style.border_color = Color(0.76, 0.55, 0.24, 0.5)
	list_style.set_border_width_all(1)
	list_area.add_theme_stylebox_override("panel", list_style)

	var list_vbox := VBoxContainer.new()
	list_vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	list_vbox.add_theme_constant_override("separation", 6)
	list_vbox.add_child(_make_label("暂无存档", 21, Color(0.98, 0.78, 0.42, 1)))
	list_vbox.add_child(_make_label("尚未发现可读取的命运记录。\n请先在游戏中完成一次保存。", 16, Color(0.82, 0.78, 0.68, 1)))
	list_area.add_child(list_vbox)
	dialog_vbox.add_child(list_area)

	var read_button := _make_bronze_button("读取", 128)
	var delete_button := _make_bronze_button("删除", 128)
	var back_button := _make_bronze_button("返回", 128)
	read_button.pressed.connect(func() -> void: _show_message("命运卷宗", "暂无可读取的存档。"))
	delete_button.pressed.connect(func() -> void: _show_message("命运卷宗", "暂无可删除的存档。"))
	back_button.pressed.connect(_hide_message)
	dialog_vbox.add_child(_make_button_row([read_button, delete_button, back_button]))
	call_deferred("_refresh_dialog_button_pivots")
	_open_dialog()


func _show_settings_panel() -> void:
	_clear_dialog_content()
	dialog_vbox.add_theme_constant_override("separation", 9)
	dialog_vbox.add_child(_make_label("青铜机枢", 28, Color(1.0, 0.76, 0.3, 1)))
	_add_slider_setting("sfx", "音效音量", 80)
	_add_slider_setting("music", "音乐音量", 70)
	_add_slider_setting("brightness", "画面亮度", 60)
	_add_subtitle_setting()
	_add_window_mode_setting()

	var apply_button := _make_bronze_button("应用", 128)
	var reset_button := _make_bronze_button("恢复默认", 150)
	var back_button := _make_bronze_button("返回", 128)
	apply_button.pressed.connect(func() -> void: _show_message("青铜机枢", "设置已应用。\n当前版本暂未写入配置文件。"))
	reset_button.pressed.connect(_reset_settings_defaults)
	back_button.pressed.connect(_hide_message)
	dialog_vbox.add_child(_make_button_row([apply_button, reset_button, back_button]))
	call_deferred("_refresh_dialog_button_pivots")
	_open_dialog()


func _make_setting_row(title: String) -> HBoxContainer:
	var row := HBoxContainer.new()
	row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_theme_constant_override("separation", 10)
	var title_label := _make_label(title, 16, Color(0.9, 0.82, 0.66, 1), HORIZONTAL_ALIGNMENT_LEFT)
	title_label.custom_minimum_size = Vector2(92, 0)
	row.add_child(title_label)
	return row


func _add_slider_setting(key: String, title: String, value: float) -> void:
	var row := _make_setting_row(title)
	var slider := HSlider.new()
	slider.min_value = 0
	slider.max_value = 100
	slider.step = 1
	slider.value = value
	slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var value_label := _make_label("%d%%" % int(value), 15, Color(0.96, 0.78, 0.43, 1), HORIZONTAL_ALIGNMENT_RIGHT)
	value_label.custom_minimum_size = Vector2(48, 0)
	slider.value_changed.connect(func(new_value: float) -> void:
		value_label.text = "%d%%" % int(new_value)
	)
	row.add_child(slider)
	row.add_child(value_label)
	dialog_vbox.add_child(row)
	setting_sliders[key] = slider
	setting_value_labels[key] = value_label


func _add_subtitle_setting() -> void:
	var row := _make_setting_row("字幕显示")
	subtitle_checkbox = CheckBox.new()
	subtitle_checkbox.text = "开启"
	subtitle_checkbox.button_pressed = true
	subtitle_checkbox.add_theme_font_size_override("font_size", 16)
	subtitle_checkbox.add_theme_color_override("font_color", Color(0.9, 0.82, 0.66, 1))
	row.add_child(subtitle_checkbox)
	dialog_vbox.add_child(row)


func _add_window_mode_setting() -> void:
	var row := _make_setting_row("窗口模式")
	window_mode_option = OptionButton.new()
	window_mode_option.add_item("窗口化")
	window_mode_option.add_item("全屏")
	window_mode_option.selected = 0
	window_mode_option.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(window_mode_option)
	dialog_vbox.add_child(row)


func _reset_settings_defaults() -> void:
	var defaults := {"sfx": 80, "music": 70, "brightness": 60}
	for key in defaults:
		var slider := setting_sliders.get(key) as HSlider
		if slider != null:
			slider.value = defaults[key]
	if subtitle_checkbox != null:
		subtitle_checkbox.button_pressed = true
	if window_mode_option != null:
		window_mode_option.selected = 0


func _show_exit_confirm() -> void:
	_show_confirm("辞别易水", "确定要退出游戏吗？\n未保存的命运记录可能会丢失。", "确认退出", "取消", Callable(self, "_quit_game"))


func _quit_game() -> void:
	get_tree().quit()


func _refresh_dialog_button_pivots() -> void:
	for button in dialog_vbox.find_children("*", "Button", true, false):
		var bronze_button := button as Button
		bronze_button.pivot_offset = bronze_button.size * 0.5


func _hide_message() -> void:
	if message_tween != null and message_tween.is_valid():
		message_tween.kill()

	message_tween = create_tween()
	message_tween.tween_property(styled_message_overlay, "modulate:a", 0.0, 0.12)
	message_tween.tween_callback(_finish_hide_message)


func _finish_hide_message() -> void:
	styled_message_overlay.visible = false
