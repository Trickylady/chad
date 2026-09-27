extends Node2D

@export var hover_rotation := 5.0
@export var tween_time := 0.15
var original_rotations := {}

func _ready() -> void:
	$buttons.show()
	$ButBack.hide()
	$SettingsTab.hide()
	$CreditsTab.hide()
	$tabbg.hide()
	for button in get_tree().get_nodes_in_group("hover_left"):
		_setup_button(button, -hover_rotation)
	for button in get_tree().get_nodes_in_group("hover_right"):
		_setup_button(button, hover_rotation)
	$SettingsTab/Master_slider.value = AudioServer.get_bus_volume_linear(0)
	$SettingsTab/Music_slider.value = AudioServer.get_bus_volume_linear(1)
	$SettingsTab/SFX_slider.value = AudioServer.get_bus_volume_linear(2)

func _setup_button(button: TextureButton, rot_amount: float):
	original_rotations[button] = button.rotation_degrees
	button.mouse_entered.connect(func():
		var tween = create_tween()
		tween.tween_property(button, "rotation_degrees",
		original_rotations[button] + rot_amount, tween_time)
		)
	button.mouse_exited.connect(func():
		var tween = create_tween()
		tween.tween_property(button, "rotation_degrees",
		original_rotations[button], tween_time)
		)

func _on_but_exit_pressed() -> void:
	get_tree().quit()

func _on_but_credits_pressed() -> void:
	$buttons.hide()
	$ButBack.show()
	$CreditsTab.show()
	$tabbg.show()

func _on_but_settings_pressed() -> void:
	$buttons.hide()
	$ButBack.show()
	$SettingsTab.show()
	$tabbg.show()

func _on_but_start_pressed() -> void:
	Mng.start_game()

func _on_but_back_pressed() -> void:
	$buttons.show()
	$ButBack.hide()
	$SettingsTab.hide()
	$CreditsTab.hide()
	$tabbg.hide()


func _on_master_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_linear(0, value)

func _on_music_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_linear(1, value)

func _on_sfx_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_linear(2, value)
