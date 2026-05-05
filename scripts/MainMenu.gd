extends Control


@onready var title_area: VBoxContainer = $CanvasLayer/RootControl/TitleArea
@onready var left_menu_panel: PanelContainer = $CanvasLayer/RootControl/LeftMenuPanel
@onready var right_lore_panel: PanelContainer = $CanvasLayer/RootControl/RightLorePanel
@onready var start_button: Button = $CanvasLayer/RootControl/LeftMenuPanel/MenuMargin/ButtonVBox/StartButton
@onready var story_demo_button: Button = $CanvasLayer/RootControl/LeftMenuPanel/MenuMargin/ButtonVBox/StoryDemoButton
@onready var continue_button: Button = $CanvasLayer/RootControl/LeftMenuPanel/MenuMargin/ButtonVBox/ContinueButton
@onready var load_button: Button = $CanvasLayer/RootControl/LeftMenuPanel/MenuMargin/ButtonVBox/LoadButton
@onready var settings_button: Button = $CanvasLayer/RootControl/LeftMenuPanel/MenuMargin/ButtonVBox/SettingsButton
@onready var exit_button: Button = $CanvasLayer/RootControl/LeftMenuPanel/MenuMargin/ButtonVBox/ExitButton
@onready var message_dialog: AcceptDialog = $MessageDialog


var menu_buttons: Array[Button] = []


# 绑定主菜单按钮，并播放轻量入场动画。
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

	for button in menu_buttons:
		button.mouse_entered.connect(_animate_button_scale.bind(button, Vector2(1.03, 1.03), 0.1))
		button.mouse_exited.connect(_animate_button_scale.bind(button, Vector2.ONE, 0.12))
		button.button_down.connect(_animate_button_scale.bind(button, Vector2(0.97, 0.97), 0.06))
		button.button_up.connect(_animate_button_scale.bind(button, Vector2(1.02, 1.02), 0.08))

	call_deferred("_prepare_pivots_and_intro")


func _prepare_pivots_and_intro() -> void:
	for button in menu_buttons:
		button.pivot_offset = button.size * 0.5
	_play_intro_animation()


# 主菜单入场动画：标题淡入，左右面板滑入。
func _play_intro_animation() -> void:
	var title_y := title_area.position.y
	var left_x := left_menu_panel.position.x
	var right_x := right_lore_panel.position.x

	title_area.modulate.a = 0.0
	left_menu_panel.modulate.a = 0.0
	right_lore_panel.modulate.a = 0.0
	title_area.position.y = title_y - 22.0
	left_menu_panel.position.x = left_x - 44.0
	right_lore_panel.position.x = right_x + 44.0

	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(title_area, "modulate:a", 1.0, 0.45)
	tween.tween_property(title_area, "position:y", title_y, 0.45).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(left_menu_panel, "modulate:a", 1.0, 0.45).set_delay(0.08)
	tween.tween_property(left_menu_panel, "position:x", left_x, 0.45).set_delay(0.08).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(right_lore_panel, "modulate:a", 1.0, 0.5).set_delay(0.14)
	tween.tween_property(right_lore_panel, "position:x", right_x, 0.5).set_delay(0.14).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)


func _animate_button_scale(button: Button, target_scale: Vector2, duration: float) -> void:
	var tween := create_tween()
	tween.tween_property(button, "scale", target_scale, duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)


# 开始新游戏，进入主分支主场景。
func _on_start_pressed() -> void:
	get_tree().change_scene_to_file("res://scene/main.tscn")


# 进入旧版剧情 Demo 原型。
func _on_story_demo_pressed() -> void:
	get_tree().change_scene_to_file("res://WorldScene.tscn")


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


func _show_message(message: String) -> void:
	message_dialog.dialog_text = message
	message_dialog.popup_centered()
