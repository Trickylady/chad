class_name ArcedeGame
extends Control


@export_file("*.ogg") var voice_line_path: String
@export var turn_speed: float = 5.0

@export var obj_to_spawn: Array[PackedScene]
@export var count_to_spawn: Array[int]
@export var count_min_to_collect: Array[int]

@onready var catcher_center: Node2D = $CatcherCenter
@onready var voice: AudioStreamPlayer = $Voice
@onready var music: AudioStreamPlayer = $Music


var _catcher_initial_angle: float
var _catcher: Catcher

var _to_be_spawned: Array[PackedScene]
var _music_duration: float



func _ready() -> void:
	_catcher = catcher_center.get_child(0)
	_catcher_initial_angle = _catcher.position.angle()
	_catcher.obj_collected.connect(_on_catcher_obj_collected)
	
	if obj_to_spawn.size() != count_min_to_collect.size() or \
			obj_to_spawn.size() != count_to_spawn.size():
		push_error("The objects count and the spawn count and min to collect, must be the same size.")
		return
	
	for i: int in obj_to_spawn.size():
		var packed_scene: PackedScene = obj_to_spawn[i]
		for count: int in count_to_spawn[i]:
			_to_be_spawned.append(packed_scene)
	
	_start()


func _start() -> void:
	if voice.stream:
		voice.finished.connect(_start_spawn)
		_music_duration = voice.stream.get_length()
	else:
		await get_tree().create_timer(3.0).timeout
		_start_spawn()


func _start_spawn() -> void:
	music.play()


func _process(delta: float) -> void:
	var mouse_angle: float = catcher_center.get_local_mouse_position().angle() + catcher_center.rotation
	var center_target_angle: float = mouse_angle - _catcher_initial_angle
	catcher_center.rotation = lerp_angle(
		catcher_center.rotation, 
		center_target_angle,
		delta * turn_speed
	)


func _on_catcher_obj_collected(obj) -> void:
	pass
