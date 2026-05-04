extends Control


var fate_value := 50
var history_disturbance := 0
var taizi_relationship := 50

var player_hp := 100
var player_energy := 80
var player_status := "等待抉择"

var hp_label: Label
var energy_label: Label
var status_label: Label
var fate_label: Label
var disturbance_label: Label
var relationship_label: Label
var story_log: TextEdit
var dialogue_panel: PanelContainer
var llm_result_label: Label
var option_buttons: Array[Button] = []
var dialogue_choice_made := false


# 初始化易水河畔核心场景。
func _ready() -> void:
	load_from_game_state()
	_build_ui()
	refresh_status_ui()
	append_story_log("秦军压境，燕国危急。太子丹在易水河畔召见荆轲，希望他承担刺秦使命。\n\n这不是一次普通的刺杀，而是一次可能改写天下格局的抉择。\n\n易水寒风吹过，所有人的目光都落在荆轲身上。")
	if GameState.entered_from_world and GameState.dialogue_target == "太子丹":
		append_story_log("你走近太子丹。易水寒风吹过，他似乎已经等待这一刻很久。")


# 动态创建易水河畔场景界面。
func _build_ui() -> void:
	var background := ColorRect.new()
	background.name = "Background"
	background.color = Color(0.032, 0.03, 0.028, 1.0)
	background.set_anchors_preset(Control.PRESET_FULL_RECT)
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(background)

	var margin := MarginContainer.new()
	margin.name = "RootMargin"
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 24)
	margin.add_theme_constant_override("margin_top", 18)
	margin.add_theme_constant_override("margin_right", 24)
	margin.add_theme_constant_override("margin_bottom", 18)
	add_child(margin)

	var root := VBoxContainer.new()
	root.name = "RootLayout"
	root.add_theme_constant_override("separation", 12)
	margin.add_child(root)

	root.add_child(_create_header())

	var body := HBoxContainer.new()
	body.name = "BodyLayout"
	body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	body.add_theme_constant_override("separation", 14)
	root.add_child(body)

	body.add_child(_create_status_panel())
	body.add_child(_create_story_panel())
	body.add_child(_create_action_panel())

	dialogue_panel = _create_dialogue_panel()
	dialogue_panel.visible = false
	add_child(dialogue_panel)


# 创建顶部标题与任务栏。
func _create_header() -> PanelContainer:
	var panel := PanelContainer.new()
	panel.name = "HeaderPanel"
	panel.add_theme_stylebox_override("panel", _create_panel_style(Color(0.08, 0.06, 0.045, 0.86)))

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 18)
	margin.add_theme_constant_override("margin_top", 12)
	margin.add_theme_constant_override("margin_right", 18)
	margin.add_theme_constant_override("margin_bottom", 12)
	panel.add_child(margin)

	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 4)
	margin.add_child(box)

	var title := Label.new()
	title.text = "易水河畔 · 刺秦前夜"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 30)
	title.add_theme_color_override("font_color", Color(0.94, 0.74, 0.34, 1.0))
	box.add_child(title)

	var task := Label.new()
	task.text = "当前任务：与太子丹商议刺秦计划"
	task.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	task.add_theme_font_size_override("font_size", 18)
	task.add_theme_color_override("font_color", Color(0.86, 0.82, 0.72, 1.0))
	box.add_child(task)

	return panel


# 创建左侧角色与世界状态面板。
func _create_status_panel() -> PanelContainer:
	var panel := PanelContainer.new()
	panel.name = "StatusPanel"
	panel.custom_minimum_size = Vector2(270, 420)
	panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	panel.add_theme_stylebox_override("panel", _create_panel_style(Color(0.065, 0.055, 0.048, 0.90)))

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 16)
	margin.add_theme_constant_override("margin_top", 16)
	margin.add_theme_constant_override("margin_right", 16)
	margin.add_theme_constant_override("margin_bottom", 16)
	panel.add_child(margin)

	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 8)
	margin.add_child(box)

	box.add_child(_create_section_title("【玩家角色】"))
	box.add_child(_create_text_label("姓名：荆轲"))
	box.add_child(_create_text_label("身份：燕国刺客"))
	hp_label = _create_text_label("")
	energy_label = _create_text_label("")
	box.add_child(hp_label)
	box.add_child(energy_label)
	box.add_child(_create_text_label("武器：匕首"))
	status_label = _create_text_label("")
	box.add_child(status_label)

	var spacer := Control.new()
	spacer.custom_minimum_size = Vector2(1, 14)
	box.add_child(spacer)

	box.add_child(_create_section_title("【世界状态】"))
	fate_label = _create_text_label("")
	disturbance_label = _create_text_label("")
	relationship_label = _create_text_label("")
	box.add_child(fate_label)
	box.add_child(disturbance_label)
	box.add_child(_create_text_label("当前章节：第一幕 · 易水诀别"))
	box.add_child(relationship_label)

	return panel


# 创建中间剧情日志面板。
func _create_story_panel() -> PanelContainer:
	var panel := PanelContainer.new()
	panel.name = "StoryPanel"
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	panel.add_theme_stylebox_override("panel", _create_panel_style(Color(0.055, 0.05, 0.046, 0.88)))

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 16)
	margin.add_theme_constant_override("margin_top", 14)
	margin.add_theme_constant_override("margin_right", 16)
	margin.add_theme_constant_override("margin_bottom", 14)
	panel.add_child(margin)

	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 10)
	margin.add_child(box)

	box.add_child(_create_section_title("剧情 / 事件日志"))

	story_log = TextEdit.new()
	story_log.editable = false
	story_log.custom_minimum_size = Vector2(420, 360)
	story_log.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	story_log.size_flags_vertical = Control.SIZE_EXPAND_FILL
	story_log.add_theme_font_size_override("font_size", 16)
	box.add_child(story_log)

	return panel


# 创建右侧功能按钮面板。
func _create_action_panel() -> PanelContainer:
	var panel := PanelContainer.new()
	panel.name = "ActionPanel"
	panel.custom_minimum_size = Vector2(250, 420)
	panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	panel.add_theme_stylebox_override("panel", _create_panel_style(Color(0.065, 0.055, 0.048, 0.90)))

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 14)
	margin.add_theme_constant_override("margin_top", 16)
	margin.add_theme_constant_override("margin_right", 14)
	margin.add_theme_constant_override("margin_bottom", 16)
	panel.add_child(margin)

	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 12)
	margin.add_child(box)

	box.add_child(_create_section_title("可交互功能"))
	box.add_child(_create_button("与太子丹对话", open_dialogue))
	box.add_child(_create_button("查看角色状态", show_character_status))
	box.add_child(_create_button("查看世界状态", show_world_status))
	box.add_child(_create_button("模拟战斗推演", preview_combat))

	var spacer := Control.new()
	spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	box.add_child(spacer)

	if GameState.entered_from_world:
		box.add_child(_create_button("返回易水河畔", return_to_world_scene))
	box.add_child(_create_button("返回主菜单", return_to_main_menu))

	return panel


# 创建屏幕内天命对话浮层。
func _create_dialogue_panel() -> PanelContainer:
	var panel := PanelContainer.new()
	panel.name = "DialoguePanel"
	panel.set_anchors_preset(Control.PRESET_FULL_RECT)
	panel.anchor_left = 0.26
	panel.anchor_top = 0.30
	panel.anchor_right = 0.76
	panel.anchor_bottom = 0.96
	panel.offset_left = 0
	panel.offset_top = 0
	panel.offset_right = 0
	panel.offset_bottom = 0
	panel.add_theme_stylebox_override("panel", _create_panel_style(Color(0.07, 0.055, 0.045, 0.95)))

	var margin := MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 16)
	margin.add_theme_constant_override("margin_top", 12)
	margin.add_theme_constant_override("margin_right", 16)
	margin.add_theme_constant_override("margin_bottom", 12)
	panel.add_child(margin)

	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 8)
	margin.add_child(box)

	var engine_label := _create_text_label("【天命回响】\n\n命运正在根据人物关系、当前局势与历史扰动，推演下一段对话……")
	engine_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	box.add_child(engine_label)

	var npc_text := _create_text_label("太子丹：荆卿，秦军日盛，燕国危如累卵。此去咸阳，九死一生。你可愿为燕国改写天命？")
	npc_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	box.add_child(npc_text)

	var options := VBoxContainer.new()
	options.add_theme_constant_override("separation", 8)
	box.add_child(options)

	option_buttons.clear()
	options.add_child(_create_option_button("1. [忠义] 臣愿一试，虽死无悔。\n效果：关系 +10，天命 +5，扰动 +0", 1))
	options.add_child(_create_option_button("2. [谨慎] 此事凶险，我还需要准备。\n效果：关系 -2，天命 -2，扰动 +5", 2))
	options.add_child(_create_option_button("3. [追问] 若刺秦失败，燕国又当如何？\n效果：关系 +3，天命 -1，扰动 +8", 3))

	llm_result_label = _create_text_label("")
	llm_result_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	llm_result_label.add_theme_color_override("font_color", Color(0.95, 0.86, 0.66, 1.0))
	box.add_child(llm_result_label)

	var close_button := _create_button("关闭对话", close_dialogue)
	close_button.custom_minimum_size = Vector2(180, 36)
	box.add_child(close_button)

	return panel


# 刷新左侧角色状态与世界状态。
func refresh_status_ui() -> void:
	hp_label.text = "生命值：%d" % player_hp
	energy_label.text = "精力值：%d" % player_energy
	status_label.text = "状态：%s" % player_status
	fate_label.text = "天命值：%d" % fate_value
	disturbance_label.text = "历史扰动值：%d" % history_disturbance
	relationship_label.text = "太子丹关系值：%d" % taizi_relationship


# 从全局状态读取当前数值。
func load_from_game_state() -> void:
	fate_value = GameState.fate_value
	history_disturbance = GameState.history_disturbance
	taizi_relationship = GameState.taizi_relationship

	player_hp = GameState.player_hp
	player_energy = GameState.player_energy
	player_status = GameState.player_status


# 将当前数值写回全局状态。
func save_to_game_state() -> void:
	GameState.fate_value = fate_value
	GameState.history_disturbance = history_disturbance
	GameState.taizi_relationship = taizi_relationship

	GameState.player_hp = player_hp
	GameState.player_energy = player_energy
	GameState.player_status = player_status


# 向剧情日志追加文本。
func append_story_log(text: String) -> void:
	if story_log.text != "":
		story_log.text += "\n\n"
	story_log.text += text
	story_log.scroll_vertical = story_log.get_line_count()


# 打开天命对话区域。
func open_dialogue() -> void:
	dialogue_panel.visible = true
	if not dialogue_choice_made:
		llm_result_label.text = ""
	for button in option_buttons:
		button.disabled = dialogue_choice_made
	append_story_log("【NPC 对话】太子丹开始根据当前局势与你商议刺秦计划。")


# 关闭天命对话区域。
func close_dialogue() -> void:
	dialogue_panel.visible = false


# 根据玩家选择处理对话分支。
func choose_dialogue_option(option_id: int) -> void:
	var log_text := ""
	var result_text := ""

	match option_id:
		1:
			taizi_relationship += 10
			fate_value += 5
			log_text = "【对话选择 · 忠义】荆轲答应承担刺秦使命。太子丹关系 +10，天命值 +5，历史扰动 +0。"
			result_text = "【天命回响】\n太子丹神色动容，向荆轲深深一拜。燕国上下将希望寄托于你，历史暂时沿着既定轨迹前进。"
			GameState.latest_world_message = "太子丹望向荆轲，神色稍安。你们之间的信任更加坚定。"
		2:
			taizi_relationship -= 2
			fate_value -= 2
			history_disturbance += 5
			log_text = "【对话选择 · 谨慎】荆轲要求更多准备。太子丹关系 -2，天命值 -2，历史扰动 +5。"
			result_text = "【天命回响】\n太子丹沉默片刻，理解你的谨慎，却也感到局势更加紧迫。准备时间增加，但历史的不确定性随之上升。"
			GameState.latest_world_message = "太子丹沉默良久。你的谨慎让局势多了几分迟疑。"
		3:
			taizi_relationship += 3
			fate_value -= 1
			history_disturbance += 8
			log_text = "【对话选择 · 追问】荆轲追问刺秦失败后的燕国退路。太子丹关系 +3，天命值 -1，历史扰动 +8。"
			result_text = "【天命回响】\n太子丹没有立刻回答。你的追问让计划出现更多分支，燕国命运开始偏离原本的历史线。"
			GameState.latest_world_message = "你的追问让太子丹陷入沉思。燕国的命运出现新的分支。"
		_:
			return

	save_to_game_state()
	refresh_status_ui()
	append_story_log(log_text)
	llm_result_label.text = result_text
	dialogue_choice_made = true
	for button in option_buttons:
		button.disabled = true


# 展示战斗推演。
func preview_combat() -> void:
	player_energy = max(player_energy - 5, 0)
	player_status = "备战"
	GameState.latest_world_message = "荆轲在心中预演咸阳宫一战，气息渐沉，已进入备战状态。"
	save_to_game_state()
	refresh_status_ui()
	append_story_log("【战斗推演】\n\n荆轲握紧匕首，在心中预演咸阳宫中的凶险一战。\n若战斗爆发，行动顺序、体力消耗、命中判定与敌人状态都将影响最终结果。\n\n预演结果：荆轲进入备战状态，精力值 -5。")


# 在剧情日志中展示当前角色状态。
func show_character_status() -> void:
	append_story_log("【角色状态】\n姓名：荆轲\n身份：燕国刺客\n生命值：%d\n精力值：%d\n武器：匕首\n状态：%s" % [player_hp, player_energy, player_status])


# 在剧情日志中展示当前世界状态。
func show_world_status() -> void:
	append_story_log("【世界状态】\n天命值：%d\n历史扰动值：%d\n太子丹关系值：%d\n当前章节：第一幕 · 易水诀别" % [fate_value, history_disturbance, taizi_relationship])


# 返回主菜单。
func return_to_main_menu() -> void:
	GameState.entered_from_world = false
	get_tree().change_scene_to_file("res://MainMenu.tscn")


# 返回 3D 易水河畔场景。
func return_to_world_scene() -> void:
	var target_scene := GameState.last_scene_path
	if target_scene == "":
		target_scene = "res://WorldScene.tscn"
	GameState.entered_from_world = false
	get_tree().change_scene_to_file(target_scene)


# 创建统一文本标签。
func _create_text_label(text: String) -> Label:
	var label := Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", 16)
	label.add_theme_color_override("font_color", Color(0.86, 0.82, 0.72, 1.0))
	return label


# 创建小标题标签。
func _create_section_title(text: String) -> Label:
	var label := Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", 20)
	label.add_theme_color_override("font_color", Color(0.94, 0.74, 0.34, 1.0))
	return label


# 创建普通按钮并显式绑定 pressed 信号。
func _create_button(text: String, callback: Callable) -> Button:
	var button := Button.new()
	button.text = text
	button.custom_minimum_size = Vector2(210, 42)
	button.focus_mode = Control.FOCUS_ALL
	button.pressed.connect(callback)
	return button


# 创建对话选项按钮。
func _create_option_button(text: String, option_id: int) -> Button:
	var button := Button.new()
	button.text = text
	button.custom_minimum_size = Vector2(1, 48)
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.focus_mode = Control.FOCUS_ALL
	button.pressed.connect(choose_dialogue_option.bind(option_id))
	option_buttons.append(button)
	return button


# 创建半透明历史风格面板样式。
func _create_panel_style(color: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = color
	style.border_color = Color(0.52, 0.38, 0.18, 0.85)
	style.set_border_width_all(1)
	style.set_corner_radius_all(6)
	return style
