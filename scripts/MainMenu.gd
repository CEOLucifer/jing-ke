extends Control


var message_dialog: AcceptDialog


# 初始化正式游戏主菜单。
func _ready() -> void:
	_build_ui()


# 动态创建主菜单界面。
func _build_ui() -> void:
	var background := ColorRect.new()
	background.name = "Background"
	background.color = Color(0.035, 0.03, 0.028, 1.0)
	background.set_anchors_preset(Control.PRESET_FULL_RECT)
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(background)

	var shade := ColorRect.new()
	shade.name = "HistoricalShade"
	shade.color = Color(0.18, 0.11, 0.06, 0.35)
	shade.set_anchors_preset(Control.PRESET_FULL_RECT)
	shade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(shade)

	var margin := MarginContainer.new()
	margin.name = "RootMargin"
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 72)
	margin.add_theme_constant_override("margin_top", 56)
	margin.add_theme_constant_override("margin_right", 72)
	margin.add_theme_constant_override("margin_bottom", 56)
	add_child(margin)

	var layout := HBoxContainer.new()
	layout.name = "MainLayout"
	layout.add_theme_constant_override("separation", 36)
	margin.add_child(layout)

	var left_box := VBoxContainer.new()
	left_box.name = "MenuColumn"
	left_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	left_box.alignment = BoxContainer.ALIGNMENT_CENTER
	left_box.add_theme_constant_override("separation", 16)
	layout.add_child(left_box)

	var title := Label.new()
	title.name = "Title"
	title.text = "《荆轲：天命改写》"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 44)
	title.add_theme_color_override("font_color", Color(0.94, 0.73, 0.32, 1.0))
	left_box.add_child(title)

	var subtitle := Label.new()
	subtitle.name = "Subtitle"
	subtitle.text = "历史宿命，由你改写"
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle.add_theme_font_size_override("font_size", 22)
	subtitle.add_theme_color_override("font_color", Color(0.86, 0.80, 0.68, 1.0))
	left_box.add_child(subtitle)

	var spacer := Control.new()
	spacer.custom_minimum_size = Vector2(1, 22)
	left_box.add_child(spacer)

	left_box.add_child(_create_menu_button("开始新游戏", _on_start_pressed))
	left_box.add_child(_create_menu_button("继续游戏", _on_continue_pressed))
	left_box.add_child(_create_menu_button("读取存档", _on_load_pressed))
	left_box.add_child(_create_menu_button("设置", _on_settings_pressed))
	left_box.add_child(_create_menu_button("退出游戏", _on_quit_pressed))

	var info_panel := PanelContainer.new()
	info_panel.name = "InfoPanel"
	info_panel.custom_minimum_size = Vector2(420, 360)
	info_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	info_panel.add_theme_stylebox_override("panel", _create_panel_style(Color(0.08, 0.065, 0.052, 0.82)))
	layout.add_child(info_panel)

	var info_margin := MarginContainer.new()
	info_margin.add_theme_constant_override("margin_left", 26)
	info_margin.add_theme_constant_override("margin_top", 24)
	info_margin.add_theme_constant_override("margin_right", 26)
	info_margin.add_theme_constant_override("margin_bottom", 24)
	info_panel.add_child(info_margin)

	var info_box := VBoxContainer.new()
	info_box.alignment = BoxContainer.ALIGNMENT_CENTER
	info_box.add_theme_constant_override("separation", 16)
	info_margin.add_child(info_box)

	info_box.add_child(_create_info_label("【天命残卷】", "秦并六国之势已成，燕国危在旦夕。\n你将成为荆轲，在易水之畔作出选择。"))
	info_box.add_child(_create_info_label("命运分支", "你的言语、战斗与抉择，都将改变人物关系与历史扰动。"))
	info_box.add_child(_create_info_label("易水之约", "让天命走向不同的分支，亲手写下刺秦前夜的答案。"))

	message_dialog = AcceptDialog.new()
	message_dialog.name = "MessageDialog"
	message_dialog.visible = false
	add_child(message_dialog)


# 创建主菜单按钮并显式绑定 pressed 信号。
func _create_menu_button(text: String, callback: Callable) -> Button:
	var button := Button.new()
	button.text = text
	button.custom_minimum_size = Vector2(280, 48)
	button.focus_mode = Control.FOCUS_ALL
	button.pressed.connect(callback)
	return button


# 创建右侧说明区的一行文本。
func _create_info_label(label: String, value: String) -> Label:
	var item := Label.new()
	item.text = "%s：\n%s" % [label, value]
	item.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	item.add_theme_font_size_override("font_size", 20)
	item.add_theme_color_override("font_color", Color(0.88, 0.83, 0.72, 1.0))
	return item


# 创建半透明面板样式。
func _create_panel_style(color: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = color
	style.border_color = Color(0.55, 0.40, 0.18, 0.85)
	style.set_border_width_all(1)
	style.set_corner_radius_all(6)
	return style


# 开始新游戏，进入易水河畔场景。
func _on_start_pressed() -> void:
	get_tree().change_scene_to_file("res://scene/main.tscn")


# 显示继续游戏暂未开放提示。
func _on_continue_pressed() -> void:
	_show_message("尚未发现可延续的命运记录。")


# 显示读取存档暂未开放提示。
func _on_load_pressed() -> void:
	_show_message("尚无可读取的命运记录。")


# 显示设定尚未开启提示。
func _on_settings_pressed() -> void:
	_show_message("设定之卷尚未开启。")


# 退出游戏。
func _on_quit_pressed() -> void:
	get_tree().quit()


# 显示主菜单提示弹窗。
func _show_message(message: String) -> void:
	message_dialog.dialog_text = message
	message_dialog.popup_centered()
