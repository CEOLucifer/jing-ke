extends Button


# 点击按钮后返回主菜单。
func _ready() -> void:
	pressed.connect(_on_pressed)


func _on_pressed() -> void:
	get_tree().change_scene_to_file("res://MainMenu.tscn")
