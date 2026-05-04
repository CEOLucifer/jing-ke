extends Node


var last_scene_path: String = ""
var dialogue_target: String = ""
var entered_from_world: bool = false

var fate_value: int = 50
var history_disturbance: int = 0
var taizi_relationship: int = 50

var player_hp: int = 100
var player_energy: int = 80
var player_status: String = "等待抉择"

var latest_world_message: String = ""


# 重置新游戏状态。
func reset_new_game() -> void:
	last_scene_path = ""
	dialogue_target = ""
	entered_from_world = false

	fate_value = 50
	history_disturbance = 0
	taizi_relationship = 50

	player_hp = 100
	player_energy = 80
	player_status = "等待抉择"

	latest_world_message = ""
