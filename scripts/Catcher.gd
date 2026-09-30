class_name Catcher
extends Area2D


signal obj_collected(obj: ArcadeObj)


func _ready() -> void:
	area_entered.connect(_on_area_entered)


func pulse(good_to_collect: bool) -> void:
	pass


func _on_area_entered(area: Area2D) -> void:
	if area is ArcadeObj:
		obj_collected.emit(area)
