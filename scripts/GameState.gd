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

var current_chapter: int = 1
var quest_stage: String = "yan_camp_start"

var has_dagger: bool = false
var has_map: bool = false
var has_mission_token: bool = false

var passed_qin_checkpoint: bool = false
var entered_xianyang: bool = false
var reached_qin_palace: bool = false
var demo_completed: bool = false
var ending_branch: String = ""


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
	current_chapter = 1
	quest_stage = "yan_camp_start"
	has_dagger = false
	has_map = false
	has_mission_token = false
	passed_qin_checkpoint = false
	entered_xianyang = false
	reached_qin_palace = false
	demo_completed = false
	ending_branch = ""
