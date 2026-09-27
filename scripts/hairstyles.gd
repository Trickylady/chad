@tool
extends Node2D
@export var hairstyle_ID: int: set = set_hair

func set_hair(value: int):
	hairstyle_ID = value
	for child in get_children():
		var child_id: int = child.get_index()
		var is_visible_hair: bool = child_id == hairstyle_ID
		child.visible = is_visible_hair
