extends PanelContainer


signal quest_accepted


@onready var npc_name_label: Label = $DialogueMargin/DialogueVBox/NpcNameLabel
@onready var dialogue_text_label: Label = $DialogueMargin/DialogueVBox/DialogueTextLabel
@onready var option_container: VBoxContainer = $DialogueMargin/DialogueVBox/OptionContainer
@onready var option_button_1: Button = $DialogueMargin/DialogueVBox/OptionContainer/OptionButton1
@onready var option_button_2: Button = $DialogueMargin/DialogueVBox/OptionContainer/OptionButton2
@onready var option_button_3: Button = $DialogueMargin/DialogueVBox/OptionContainer/OptionButton3
@onready var close_button: Button = $DialogueMargin/DialogueVBox/CloseButton


var initial_dialogue := "荆卿，秦军压境，燕国已无退路。你可愿为天下一试？"
var option_results := [
	"太子丹凝视着你，缓缓点头：“燕国的命数，便托付于你了。出发前，先取徐夫人匕首与督亢地图。”",
	"太子丹叹息道：“我知此行凶险，可秦国不会再给我们太多时间。”",
	"太子丹沉默片刻：“若你失败，燕国仍会抗争，只是天下再难有转机。”"
]


# 初始化对话面板，并绑定按钮事件。
func _ready() -> void:
	visible = false
	npc_name_label.text = "太子丹"
	option_button_1.pressed.connect(_on_option_pressed.bind(0))
	option_button_2.pressed.connect(_on_option_pressed.bind(1))
	option_button_3.pressed.connect(_on_option_pressed.bind(2))
	close_button.pressed.connect(close_dialogue)

	var talk_button := get_node_or_null("../TalkToTaiziButton") as Button
	if talk_button != null:
		talk_button.pressed.connect(open_dialogue)


# 打开对话面板，并恢复初始对白和选项。
func open_dialogue() -> void:
	dialogue_text_label.text = initial_dialogue
	option_container.visible = true
	option_button_1.disabled = false
	option_button_2.disabled = false
	option_button_3.disabled = false
	visible = true


# 关闭对话面板，回到 3D 场景。
func close_dialogue() -> void:
	visible = false


# 选择对话选项后，显示对应结果并隐藏选项。
func _on_option_pressed(option_index: int) -> void:
	if option_index < 0 or option_index >= option_results.size():
		return

	dialogue_text_label.text = option_results[option_index]
	option_container.visible = false

	if option_index == 0:
		quest_accepted.emit()
