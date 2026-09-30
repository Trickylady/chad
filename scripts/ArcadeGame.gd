class_name ArcedeGame
extends Control


@export var game_number: int = 1
@export_file("*.ogg") var voice_line_path: String
@export var turn_speed: float = 5.0


@onready var catcher_center: Node2D = $CatcherCenter
@onready var to_collect_container: VBoxContainer = %ToCollectContainer
@onready var score_number: RichTextLabel = %ScoreNumber
@onready var voice: AudioStreamPlayer = $Voice
@onready var music: AudioStreamPlayer = $Music
@onready var progress_bar: ProgressBar = $ProgressBar

var is_started: bool
var points: int: set = _set_points

var _catcher_initial_angle: float
var _catcher: Catcher

var _entries: Array
var _to_be_spawned_ids: Array[int]
var _spawn_interval: float
var _music_duration: float
var _spawn_time_since_last: float


func _ready() -> void:
	_catcher = catcher_center.get_child(0)
	_catcher_initial_angle = _catcher.position.angle()
	_catcher.obj_collected.connect(_on_catcher_obj_collected)
	music.finished.connect(_on_music_finished)
	_music_duration = music.stream.get_length()
	
	_entries = to_collect_container.get_children()
	
	if _music_duration and not _to_be_spawned_ids.is_empty():
		_spawn_interval = _music_duration / _to_be_spawned_ids.size()
	else:
		_spawn_interval = 1.0
	_start()


func _start() -> void:
	if voice.stream:
		voice.finished.connect(_start_spawn)
		_music_duration = voice.stream.get_length()
	else:
		await get_tree().create_timer(3.0).timeout
		_start_spawn()
	progress_bar.value = 0.0


func _start_spawn() -> void:
	points = 0
	for entry: ToCollectEntry in _entries:
		entry.reset_count()
	
	_to_be_spawned_ids.clear()
	for entry: ToCollectEntry in to_collect_container.get_children():
		for i: int in entry.spawn_count_total:
			_to_be_spawned_ids.append(entry.idx)
	_to_be_spawned_ids.shuffle()
	
	music.play()
	is_started = true


func _stop() -> void:
	is_started = false


func _process(delta: float) -> void:
	_process_catcher_rotation(delta)
	if is_started:
		_process_spawn(delta)
		progress_bar.value = music.get_playback_position() / _music_duration


func _process_catcher_rotation(delta: float) -> void:
	var mouse_angle: float = catcher_center.get_local_mouse_position().angle() + catcher_center.rotation
	var center_target_angle: float = mouse_angle - _catcher_initial_angle
	catcher_center.rotation = lerp_angle(
		catcher_center.rotation, 
		center_target_angle,
		delta * turn_speed
	)


func _process_spawn(delta: float) -> void:
	if _to_be_spawned_ids.is_empty():
		return
	_spawn_time_since_last -= delta
	if _spawn_time_since_last < 0.0:
		_spawn_time_since_last = _spawn_interval
		_spawn_next()


func _spawn_next() -> void:
	var new_obj_id: int = _to_be_spawned_ids.pop_back()
	var entry: ToCollectEntry = _entries[new_obj_id]
	var scene_pack: PackedScene = entry.obj_scene
	
	var new_obj: ArcadeObj = scene_pack.instantiate()
	new_obj.idx = entry.idx
	new_obj.position = catcher_center.global_position
	new_obj.rotation = randf() * TAU
	
	add_child(new_obj)


func _popup_label(label_text: String, pos: Vector2) -> void:
	if not label_text: return
	var popup_label: PopupLabel = preload("uid://cl6d772vmnfmu").instantiate()
	popup_label.text = label_text
	popup_label.position = pos
	popup_label.rotation = randf_range(-0.1, 0.1) * PI/2.0
	add_child(popup_label)


func _has_collected_all() -> bool:
	for entry: ToCollectEntry in _entries:
		if entry.collected < entry.min_to_collect:
			return false
	return true


func _set_points(value: int) -> void:
	points = max(value, 0)
	score_number.text = "[shake]%d[/shake]" % points


func _on_catcher_obj_collected(obj: ArcadeObj) -> void:
	var idx: int = obj.idx
	var entry: ToCollectEntry = _entries[idx]
	entry.collected += 1
	points += entry.points_given
	
	var points_text: String = "%d" % entry.points_given
	_popup_label(points_text, obj.global_position)
	_catcher.pulse(entry.good_to_collect)
	obj.queue_free()


func _on_music_finished() -> void:
	_stop()
