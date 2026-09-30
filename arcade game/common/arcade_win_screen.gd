class_name ArcadeWinScreen
extends CenterContainer


signal continue_pressed


func _ready() -> void:
	hide()


func _on_button_continue_pressed() -> void:
	hide()
	continue_pressed.emit()
