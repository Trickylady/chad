extends Control
class_name PopupLabel

var text: String
var duration: float = 0.7 # seconds


func _ready() -> void:
	$Label.text = text
	$Label.modulate.a = 0.0
	var tween: Tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_BOUNCE)
	tween.tween_property($Label, ^"position:y", -150.0, duration).as_relative()
	tween.parallel().tween_property($Label, ^"modulate:a", 1.0, duration)
	tween.tween_interval(1.0)
	tween.parallel().tween_property($Label, ^"modulate:a", 0.0, 0.1)
	tween.tween_callback(queue_free)
