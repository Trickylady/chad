class_name ArcadeLoseScreen
extends CenterContainer


signal retry_pressed


func _ready() -> void:
	hide()


func _on_button_retry_pressed() -> void:
	hide()
	retry_pressed.emit()
