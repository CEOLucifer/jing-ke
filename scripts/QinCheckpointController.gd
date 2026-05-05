extends Node


@onready var encounter_panel: PanelContainer = $"../EncounterPanel"
@onready var encounter_text_label: Label = $"../EncounterPanel/EncounterMargin/EncounterVBox/EncounterTextLabel"
@onready var choice_container: VBoxContainer = $"../EncounterPanel/EncounterMargin/EncounterVBox/ChoiceContainer"
@onready var stealth_choice_button: Button = $"../EncounterPanel/EncounterMargin/EncounterVBox/ChoiceContainer/StealthChoiceButton"
@onready var dagger_choice_button: Button = $"../EncounterPanel/EncounterMargin/EncounterVBox/ChoiceContainer/DaggerChoiceButton"
@onready var talk_choice_button: Button = $"../EncounterPanel/EncounterMargin/EncounterVBox/ChoiceContainer/TalkChoiceButton"
@onready var dice_result_label: Label = $"../EncounterPanel/EncounterMargin/EncounterVBox/DiceResultLabel"
@onready var continue_button: Button = $"../EncounterPanel/EncounterMargin/EncounterVBox/ContinueButton"
@onready var fate_label: Label = $"../StatusPanel/StatusMargin/StatusVBox/FateLabel"
@onready var disturbance_label: Label = $"../StatusPanel/StatusMargin/StatusVBox/DisturbanceLabel"
@onready var hp_label: Label = $"../StatusPanel/StatusMargin/StatusVBox/HpLabel"
@onready var floating_feedback_label: Label = $"../FloatingFeedbackLabel"
@onready var result_panel: PanelContainer = $"../StageResultPanel"
@onready var close_result_button: Button = $"../StageResultPanel/StageResultMargin/StageResultVBox/StageResultButtonRow/CloseStageResultButton"
@onready var back_to_menu_button: Button = $"../StageResultPanel/StageResultMargin/StageResultVBox/StageResultButtonRow/BackToMenuButton"
@onready var scene_fade_overlay: ColorRect = $"../SceneFadeOverlay"


var hp := 100
var event_resolved := false
var feedback_tween: Tween


# 初始化秦境关隘遭遇事件。
func _ready() -> void:
	randomize()
	hp = GameState.player_hp
	result_panel.visible = false
	continue_button.visible = false
	dice_result_label.text = ""
	floating_feedback_label.visible = false
	refresh_status_ui()

	stealth_choice_button.pressed.connect(_resolve_choice.bind("潜行绕过", 12))
	dagger_choice_button.pressed.connect(_resolve_choice.bind("使用徐夫人匕首突袭", 10))
	talk_choice_button.pressed.connect(_resolve_choice.bind("正面交涉", 15))
	continue_button.pressed.connect(show_stage_result)
	close_result_button.pressed.connect(close_stage_result)
	back_to_menu_button.pressed.connect(return_to_main_menu)

	encounter_panel.modulate.a = 0.0
	create_tween().tween_property(encounter_panel, "modulate:a", 1.0, 0.35)
	_play_scene_fade_in()


# 执行一次 D20 检定并更新遭遇结果。
func _resolve_choice(choice_name: String, dc: int) -> void:
	if event_resolved:
		return

	event_resolved = true
	var roll := randi_range(1, 20)
	var success := roll >= dc
	var result_text := _apply_choice_result(choice_name, success)

	choice_container.visible = false
	dice_result_label.text = "检定：%s\nD20 点数：%d\n难度 DC：%d\n结果：%s" % [
		choice_name,
		roll,
		dc,
		"成功" if success else "失败"
	]
	encounter_text_label.text = result_text
	continue_button.visible = true
	refresh_status_ui()

	dice_result_label.modulate.a = 0.0
	create_tween().tween_property(dice_result_label, "modulate:a", 1.0, 0.3)


func _apply_choice_result(choice_name: String, success: bool) -> String:
	match choice_name:
		"潜行绕过":
			if success:
				GameState.fate_value += 5
				GameState.history_disturbance += 5
				_show_feedback("天命值 +5\n历史扰动值 +5")
				return "你屏住呼吸，借着夜色和路旁乱石绕过斥候。秦军没有发现你的踪迹。\n天命值 +5，历史扰动值 +5"
			GameState.history_disturbance += 15
			_apply_hp_delta(-10)
			_show_feedback("历史扰动值 +15\n生命值 -10")
			return "脚下碎石轻响，斥候猛然回头。你虽及时脱身，但行踪已有暴露风险。\n历史扰动值 +15，生命值 -10"
		"使用徐夫人匕首突袭":
			if success:
				GameState.fate_value += 8
				GameState.history_disturbance += 12
				_show_feedback("天命值 +8\n历史扰动值 +12")
				return "寒光一闪，斥候尚未来得及呼喊便倒在阴影之中。你清除了眼前威胁，但血腥味让历史开始偏移。\n天命值 +8，历史扰动值 +12"
			GameState.history_disturbance += 20
			_apply_hp_delta(-20)
			_show_feedback("历史扰动值 +20\n生命值 -20")
			return "你出手稍慢，斥候避开要害并吹响短哨。你不得不强行突围。\n历史扰动值 +20，生命值 -20"
		"正面交涉":
			if success:
				GameState.fate_value += 6
				GameState.history_disturbance += 8
				_show_feedback("天命值 +6\n历史扰动值 +8")
				return "你以燕使随从的身份稳住斥候，对方虽有疑心，却最终放你通过。\n天命值 +6，历史扰动值 +8"
			GameState.history_disturbance += 18
			_apply_hp_delta(-15)
			_show_feedback("历史扰动值 +18\n生命值 -15")
			return "你的说辞露出破绽，斥候拔刀逼近。你只能仓促脱身。\n历史扰动值 +18，生命值 -15"

	return ""


func _apply_hp_delta(delta: int) -> void:
	hp = max(0, hp + delta)
	GameState.player_hp = hp


func refresh_status_ui() -> void:
	fate_label.text = "天命值：%d" % GameState.fate_value
	disturbance_label.text = "历史扰动值：%d" % GameState.history_disturbance
	hp_label.text = "生命值：%d" % hp


# 显示第二阶段完成面板。
func show_stage_result() -> void:
	result_panel.visible = true
	result_panel.modulate.a = 0.0
	create_tween().tween_property(result_panel, "modulate:a", 1.0, 0.25)


func close_stage_result() -> void:
	result_panel.visible = false


func return_to_main_menu() -> void:
	get_tree().change_scene_to_file("res://MainMenu.tscn")


func _show_feedback(message: String) -> void:
	if feedback_tween != null and feedback_tween.is_valid():
		feedback_tween.kill()

	floating_feedback_label.text = message
	floating_feedback_label.modulate.a = 1.0
	floating_feedback_label.visible = true
	feedback_tween = create_tween()
	feedback_tween.tween_interval(1.0)
	feedback_tween.tween_property(floating_feedback_label, "modulate:a", 0.0, 0.35)
	feedback_tween.tween_callback(func() -> void: floating_feedback_label.visible = false)


func _play_scene_fade_in() -> void:
	scene_fade_overlay.visible = true
	scene_fade_overlay.modulate.a = 1.0
	var tween := create_tween()
	tween.tween_property(scene_fade_overlay, "modulate:a", 0.0, 0.45)
	tween.tween_callback(func() -> void: scene_fade_overlay.visible = false)
