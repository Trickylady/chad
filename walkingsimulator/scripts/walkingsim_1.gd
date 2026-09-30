extends Node2D

@onready var chad = $chad
@onready var background = $grass
@onready var bushes = $bushes

var previous_state := ""
var background_tween: Tween

const MOVE_DISTANCE := 100.0
const MOVE_DURATION := 1.0


func _process(_delta: float) -> void:
	var playback: AnimationNodeStateMachinePlayback = \
		chad.get_node("AnimationTree").get("parameters/playback")

	var current_state: String = playback.get_current_node()

	if current_state != previous_state:
		if current_state == "shouldersright" or current_state == "shouldersleft":
			move_background()

	previous_state = current_state


func move_background() -> void:
	if background_tween and background_tween.is_running():
		background_tween.kill()

	background_tween = create_tween()
	background_tween.set_parallel(true)
	background_tween.set_trans(Tween.TRANS_LINEAR)

	background_tween.tween_property(
		background,
		"position:x",
		background.position.x - MOVE_DISTANCE,
		MOVE_DURATION
	)

	background_tween.tween_property(
		bushes,
		"position:x",
		bushes.position.x - MOVE_DISTANCE,
		MOVE_DURATION
	)
