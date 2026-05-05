extends PanelContainer


signal quest_accepted


@onready var npc_name_label: Label = $DialogueMargin/DialogueVBox/NpcNameLabel
@onready var left_portrait_frame: Control = $DialogueMargin/DialogueVBox/PortraitRow/LeftPortraitFrame
@onready var right_portrait_frame: Control = $DialogueMargin/DialogueVBox/PortraitRow/RightPortraitFrame
@onready var dialogue_text_label: Label = $DialogueMargin/DialogueVBox/DialogueTextLabel
@onready var continue_hint_label: Label = $DialogueMargin/DialogueVBox/ContinueHintLabel
@onready var option_container: VBoxContainer = $DialogueMargin/DialogueVBox/OptionContainer
@onready var option_button_1: Button = $DialogueMargin/DialogueVBox/OptionContainer/OptionButton1
@onready var option_button_2: Button = $DialogueMargin/DialogueVBox/OptionContainer/OptionButton2
@onready var option_button_3: Button = $DialogueMargin/DialogueVBox/OptionContainer/OptionButton3
@onready var close_button: Button = $DialogueMargin/DialogueVBox/CloseButton


const TYPE_INTERVAL := 0.03


var initial_dialogue := "荆卿，秦军压境，燕国已无退路。你可愿为天下一试？"
var option_results := [
	"太子丹凝视着你，缓缓点头：“燕国的命数，便托付于你了。出发前，先取徐夫人匕首与督亢地图。”",
	"太子丹叹息道：“我知此行凶险，可秦国不会再给我们太多时间。”",
	"太子丹沉默片刻：“若你失败，燕国仍会抗争，只是天下再难有转机。”"
]
var current_full_text := ""
var is_typing := false
var typing_version := 0
var breathe_tween: Tween


# 初始化对话面板，并绑定按钮事件。
func _ready() -> void:
	visible = false
	npc_name_label.text = "太子丹"
	option_button_1.pressed.connect(_on_option_pressed.bind(0))
	option_button_2.pressed.connect(_on_option_pressed.bind(1))
	option_button_3.pressed.connect(_on_option_pressed.bind(2))
	close_button.pressed.connect(close_dialogue)
	gui_input.connect(_on_gui_input)
	_connect_option_animation(option_button_1)
	_connect_option_animation(option_button_2)
	_connect_option_animation(option_button_3)
	_start_portrait_breath()

	var talk_button := get_node_or_null("../TalkToTaiziButton") as Button
	if talk_button != null:
		talk_button.pressed.connect(open_dialogue)


# 打开对话面板，并恢复初始对白和选项。
func open_dialogue() -> void:
	typing_version += 1
	visible = true
	modulate.a = 0.0
	scale = Vector2(0.98, 0.98)
	create_tween().set_parallel(true).tween_property(self, "modulate:a", 1.0, 0.18)
	create_tween().tween_property(self, "scale", Vector2.ONE, 0.18)

	npc_name_label.text = "太子丹"
	_set_speaker("taizi")
	option_container.visible = false
	continue_hint_label.visible = true
	option_button_1.disabled = false
	option_button_2.disabled = false
	option_button_3.disabled = false
	_start_typewriter(initial_dialogue, true)


# 关闭对话面板，回到 3D 场景。
func close_dialogue() -> void:
	typing_version += 1
	is_typing = false
	visible = false


# 选择对话选项后，显示对应结果并隐藏选项。
func _on_option_pressed(option_index: int) -> void:
	if option_index < 0 or option_index >= option_results.size():
		return

	_set_speaker("taizi")
	option_container.visible = false
	_start_typewriter(option_results[option_index], false)

	if option_index == 0:
		quest_accepted.emit()


func _start_typewriter(text: String, show_options_after: bool) -> void:
	current_full_text = text
	dialogue_text_label.text = text
	dialogue_text_label.visible_characters = 0
	is_typing = true
	var local_version := typing_version

	for character_index in text.length():
		if local_version != typing_version or not visible:
			return
		if not is_typing:
			break
		dialogue_text_label.visible_characters = character_index + 1
		await get_tree().create_timer(TYPE_INTERVAL).timeout

	if local_version != typing_version:
		return

	_finish_typewriter(show_options_after)


func _finish_typewriter(show_options_after: bool) -> void:
	is_typing = false
	dialogue_text_label.visible_characters = -1
	continue_hint_label.visible = show_options_after

	if show_options_after:
		_set_speaker("jingke")
		_show_options_with_animation()


func _show_options_with_animation() -> void:
	option_container.visible = true
	var option_buttons := [option_button_1, option_button_2, option_button_3]
	for index in option_buttons.size():
		var button := option_buttons[index] as Button
		button.modulate.a = 0.0
		button.scale = Vector2(0.96, 0.96)
		var tween := create_tween()
		tween.tween_interval(index * 0.08)
		tween.tween_property(button, "modulate:a", 1.0, 0.18)
		tween.parallel().tween_property(button, "scale", Vector2.ONE, 0.18)


func _set_speaker(speaker: String) -> void:
	if speaker == "jingke":
		npc_name_label.text = "荆轲"
		left_portrait_frame.modulate = Color(1, 1, 1, 1)
		right_portrait_frame.modulate = Color(1, 1, 1, 0.45)
	else:
		npc_name_label.text = "太子丹"
		left_portrait_frame.modulate = Color(1, 1, 1, 0.45)
		right_portrait_frame.modulate = Color(1, 1, 1, 1)
		var tween := create_tween()
		tween.tween_property(right_portrait_frame, "scale", Vector2(1.04, 1.04), 0.16)
		tween.tween_property(right_portrait_frame, "scale", Vector2.ONE, 0.16)


func _start_portrait_breath() -> void:
	if breathe_tween != null and breathe_tween.is_valid():
		breathe_tween.kill()

	breathe_tween = create_tween().set_loops()
	breathe_tween.set_parallel(true)
	breathe_tween.tween_property(left_portrait_frame, "scale", Vector2(1.025, 1.025), 1.2)
	breathe_tween.tween_property(right_portrait_frame, "scale", Vector2(1.025, 1.025), 1.2)
	breathe_tween.chain().tween_property(left_portrait_frame, "scale", Vector2.ONE, 1.2)
	breathe_tween.parallel().tween_property(right_portrait_frame, "scale", Vector2.ONE, 1.2)


func _connect_option_animation(button: Button) -> void:
	button.mouse_entered.connect(func() -> void:
		create_tween().tween_property(button, "scale", Vector2(1.03, 1.03), 0.08)
	)
	button.mouse_exited.connect(func() -> void:
		create_tween().tween_property(button, "scale", Vector2.ONE, 0.08)
	)
	button.button_down.connect(func() -> void:
		create_tween().tween_property(button, "scale", Vector2(0.98, 0.98), 0.05)
	)
	button.button_up.connect(func() -> void:
		create_tween().tween_property(button, "scale", Vector2.ONE, 0.05)
	)


func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and is_typing:
		_finish_current_text()


func _unhandled_input(event: InputEvent) -> void:
	if visible and event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_SPACE:
		if is_typing:
			_finish_current_text()


func _finish_current_text() -> void:
	is_typing = false
	dialogue_text_label.text = current_full_text
	dialogue_text_label.visible_characters = -1
