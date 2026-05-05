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
@onready var styled_message_title: Label = $CanvasLayer/RootControl/StyledMessageOverlay/DialogCard/DialogPanel/DialogMargin/DialogVBox/MessageTitle
@onready var styled_message_text: Label = $CanvasLayer/RootControl/StyledMessageOverlay/DialogCard/DialogPanel/DialogMargin/DialogVBox/MessageText
@onready var styled_message_confirm_button: Button = $CanvasLayer/RootControl/StyledMessageOverlay/DialogCard/DialogPanel/DialogMargin/DialogVBox/ConfirmButton


var menu_buttons: Array[Button] = []
var lore_panel_visible := false
var lore_dialog_position := Vector2.ZERO
var lore_tween: Tween
var message_tween: Tween


# 绑定按钮逻辑，并播放主菜单入场动画。
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


# 标题淡入，左右青铜面板滑入。
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


# 收起右侧天命残卷面板，保留小按钮用于再次展开。
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


# 开始新游戏，进入主分支主场景。
func _on_start_pressed() -> void:
	get_tree().change_scene_to_file("res://scene/main.tscn")


# 进入旧版剧情 Demo 原型。
func _on_story_demo_pressed() -> void:
	get_tree().change_scene_to_file("res://WorldScene.tscn")


func _on_continue_pressed() -> void:
	_show_message("天命回声", "尚无可延续的命运记录。")


func _on_load_pressed() -> void:
	_show_message("命运卷宗", "存档系统尚未完成。")


func _on_settings_pressed() -> void:
	_show_message("青铜机枢", "设置功能正在完善中。")


func _on_quit_pressed() -> void:
	get_tree().quit()


func _show_message(title: String, message: String) -> void:
	styled_message_title.text = title
	styled_message_text.text = message
	styled_message_overlay.visible = true
	styled_message_overlay.modulate.a = 0.0
	styled_message_panel.scale = Vector2(0.96, 0.96)

	if message_tween != null and message_tween.is_valid():
		message_tween.kill()

	message_tween = create_tween()
	message_tween.set_parallel(true)
	message_tween.tween_property(styled_message_overlay, "modulate:a", 1.0, 0.16)
	message_tween.tween_property(styled_message_panel, "scale", Vector2.ONE, 0.18).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)


func _hide_message() -> void:
	if message_tween != null and message_tween.is_valid():
		message_tween.kill()

	message_tween = create_tween()
	message_tween.tween_property(styled_message_overlay, "modulate:a", 0.0, 0.12)
	message_tween.tween_callback(_finish_hide_message)


func _finish_hide_message() -> void:
	styled_message_overlay.visible = false
