class_name ArcadeObj
extends Area2D

@export var forward_direction: Vector2 = Vector2.UP
@export var speed: float = 150.0 #px/s
@export var sway_multiplier: float = 1.0


@onready var visible_on_screen_notifier_2d: VisibleOnScreenNotifier2D = $VisibleOnScreenNotifier2D

var idx: int
var custom_sprite_img: Texture2D

var _initial_rotation: float
var _spawn_time: float


func _ready() -> void:
	if custom_sprite_img:
		var sprite := Sprite2D.new()
		sprite.texture = custom_sprite_img
		add_child(sprite)
	visible_on_screen_notifier_2d.screen_exited.connect(queue_free)
	_initial_rotation = randf() * TAU


func _physics_process(delta: float) -> void:
	_spawn_time += delta
	_spawn_time = wrapf(_spawn_time, 0.0, TAU)
	var sway_angle: float = sin(_spawn_time) * sway_multiplier
	
	var final_direction: Vector2 = forward_direction.rotated(_initial_rotation)
	final_direction = final_direction.rotated(sway_angle)
	rotation = _initial_rotation + sway_angle
	translate(final_direction * speed * delta)
