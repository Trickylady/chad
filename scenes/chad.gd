extends Node2D
	
@onready var animation_tree: AnimationTree = $AnimationTree

var brain_pressed := false
var shoulders_pressed := false
var foot_left_pressed := false
var foot_right_pressed := false


func _process(_delta: float) -> void:
	animation_tree.set("parameters/conditions/brain", brain_pressed)
	animation_tree.set("parameters/conditions/shoulders", shoulders_pressed)
	animation_tree.set("parameters/conditions/left", foot_left_pressed)
	animation_tree.set("parameters/conditions/right", foot_right_pressed)

	# Make each click last for only one processed frame.
	brain_pressed = false
	shoulders_pressed = false
	foot_left_pressed = false
	foot_right_pressed = false


func _on_buttbrain_pressed() -> void:
	brain_pressed = true


func _on_buttshoulders_pressed() -> void:
	shoulders_pressed = true


func _on_buttleftleg_pressed() -> void:
	foot_left_pressed = true


func _on_buttrightleg_pressed() -> void:
	foot_right_pressed = true
