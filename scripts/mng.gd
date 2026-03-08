extends Node

func _ready() -> void:
	var mouseimg : CompressedTexture2D = load("res://images/menu-UI/mouse_regular.png")
	Input.set_custom_mouse_cursor(mouseimg)

func go_to_menu():
	get_tree().change_scene_to_file("res://mainmenu.tscn")

func start_game():
	get_tree().change_scene_to_file("res://chad.tscn")
