extends Node


var title_label: Label
var body_label: Label
var back_button: Button
var restart_button: Button


func _ready() -> void:
	print("[DemoResult] ready")
	print("[DemoResult] ending_branch: ", GameState.ending_branch)

	_bind_result_nodes()
	var ending := _get_ending_text()

	if title_label != null:
		title_label.text = "《荆轲：天命改写》Demo 主流程完成"
	if body_label != null:
		body_label.text = _build_summary(ending)
	if back_button != null:
		back_button.pressed.connect(func() -> void: get_tree().change_scene_to_file("res://MainMenu.tscn"))
	if restart_button != null:
		restart_button.pressed.connect(_restart)


func _bind_result_nodes() -> void:
	var canvas := get_parent()
	if canvas == null:
		push_warning("[DemoResult] Controller has no CanvasLayer parent.")
		return

	title_label = canvas.get_node_or_null("ResultPanel/ResultMargin/ResultVBox/TitleLabel") as Label
	body_label = canvas.get_node_or_null("ResultPanel/ResultMargin/ResultVBox/BodyLabel") as Label
	back_button = canvas.get_node_or_null("ResultPanel/ResultMargin/ResultVBox/ButtonRow/BackToMenuButton") as Button
	restart_button = canvas.get_node_or_null("ResultPanel/ResultMargin/ResultVBox/ButtonRow/RestartButton") as Button

	if title_label == null:
		push_warning("[DemoResult] Missing TitleLabel.")
	if body_label == null:
		push_warning("[DemoResult] Missing BodyLabel.")
	if back_button == null:
		push_warning("[DemoResult] Missing BackToMenuButton.")
	if restart_button == null:
		push_warning("[DemoResult] Missing RestartButton.")


func _get_ending_text() -> Dictionary:
	match GameState.ending_branch:
		"assassinate_now":
			return {
				"title": "结局分支：图穷匕见",
				"choice": "立即出手，孤注一掷",
				"body": "你在地图尽头拔出匕首，殿中惊呼骤起。\n这一击未必能彻底改变历史，却已让天命出现最剧烈的裂痕。",
			}
		"wait_for_chance":
			return {
				"title": "结局分支：隐忍待机",
				"choice": "等待更近的时机",
				"body": "你压下杀意，等待更近的一步。\n历史仍沿原轨前进，但你的迟疑让未来出现新的可能。",
			}
		"abandon_assassination":
			return {
				"title": "结局分支：止戈一念",
				"choice": "收起杀意，放弃刺秦",
				"body": "你收起匕首，没有让血溅秦殿。\n这并非懦弱，而是一次对宿命的背离。\n只是燕国与天下，又将走向何处？",
			}

	return {
		"title": "结局分支：未定之命",
		"choice": "未做出最终抉择",
		"body": "你尚未做出最终抉择，天命仍在迷雾之中。",
	}


func _build_summary(ending: Dictionary) -> String:
	return """流程回顾：
1. 易水受命：接下太子丹托付
2. 密议刺秦：取得入秦信物
3. 入秦关隘：通过秦军盘查
4. 咸阳献图：进入秦王殿
5. 图穷匕见：做出最终抉择

%s
%s

最终选择：%s

状态变化：
天命值：%d
历史扰动值：%d
太子丹关系：%d""" % [
		ending["title"],
		ending["body"],
		ending["choice"],
		GameState.fate_value,
		GameState.history_disturbance,
		GameState.taizi_relationship,
	]


func _restart() -> void:
	GameState.reset_demo_state()
	get_tree().change_scene_to_file("res://scene/main.tscn")
