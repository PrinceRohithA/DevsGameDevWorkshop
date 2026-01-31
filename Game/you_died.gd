extends Control


var game_scene: PackedScene = load("res://Game/game.tscn")

func _on_respawn_button_pressed() -> void:
	get_tree().change_scene_to_packed(game_scene)
