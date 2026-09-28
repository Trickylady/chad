extends Node2D

const CIRCLE_RADIUS := 476.0
const COLLECTABLE_OFFSET := 40.0 
const BEAT_TIMING_OFFSET := 85.0   
const COLLECTABLE_SPEED := 1.25      
const HIT_DISTANCE_THRESHOLD := 180.0
const COLLECTABLE = preload("uid://djik2rib3k85y")

@export var MusicToPlay: AudioStreamMP3 = null
@export var BeatMap: JSON = null
@export var CorrectCollectables: Array[PackedScene] = []
@export var WrongCollectables: Array[PackedScene] = []

@onready var grab_point: Node2D = %GrabPoint
@onready var mid_point: Node2D = %MidPoint

var current_tween: Tween
var audio_player: AudioStreamPlayer
var beatmap_notes: Array = []
var next_note_index: int = 0

var active_collectables: Array[Node2D] = []

func _ready() -> void:
	audio_player = AudioStreamPlayer.new()
	add_child(audio_player)
	
	if MusicToPlay:
		audio_player.stream = MusicToPlay
		
	if BeatMap and BeatMap.data:
		var data = BeatMap.data
		if data is Dictionary and data.has("beatmap"):
			beatmap_notes = data["beatmap"]
		elif data is Array:
			beatmap_notes = data
			
	if MusicToPlay:
		audio_player.play()

func _process(_delta: float) -> void:
	_grabber_movement()
	_check_beatmap_spawns()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		trigger_pop()
		_check_hit()

func _grabber_movement() -> void:
	var mouse_pos := get_global_mouse_position()
	var direction := mid_point.global_position.direction_to(mouse_pos)
	
	if direction == Vector2.ZERO:
		direction = Vector2.RIGHT
	
	grab_point.global_position = mid_point.global_position + (direction * CIRCLE_RADIUS)
	grab_point.rotation = direction.angle()

func trigger_pop() -> void:
	if current_tween and current_tween.is_running():
		current_tween.kill()
		
	current_tween = create_tween().set_parallel(false)
	
	current_tween.tween_property(grab_point, "scale", Vector2.ONE * 1.3, 0.06).set_trans(Tween.TRANS_SINE)
	current_tween.tween_property(grab_point, "scale", Vector2.ONE, 0.1).set_trans(Tween.TRANS_SINE)

func _check_hit() -> void:
	if active_collectables.is_empty():
		return
	
	var closest_collectable: Node2D = null
	var min_distance := INF
	
	for collectable in active_collectables:
		if not is_instance_valid(collectable):
			continue
		var dist = collectable.global_position.distance_to(grab_point.global_position)
		if dist < min_distance:
			min_distance = dist
			closest_collectable = collectable
			
	if closest_collectable == null or min_distance > HIT_DISTANCE_THRESHOLD:
		return
		
	if closest_collectable.has_meta("is_correct") and closest_collectable.get_meta("is_correct"):
		print("Good!")
	else:
		print("Bad!")
		
	_pop_collectable_early(closest_collectable)

func _pop_collectable_early(collectable: Node2D) -> void:
	active_collectables.erase(collectable)
	
	if collectable.has_meta("lifecycle_tween"):
		var old_tween = collectable.get_meta("lifecycle_tween") as Tween
		if old_tween and old_tween.is_running():
			old_tween.kill()
	
	var tween = create_tween()
	tween.tween_property(collectable, "scale", Vector2.ZERO, 0.15).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	tween.tween_callback(collectable.queue_free)

func _check_beatmap_spawns() -> void:
	if not audio_player or not audio_player.playing:
		return
		
	if next_note_index >= beatmap_notes.size():
		return
		
	var current_audio_time := audio_player.get_playback_position()
	
	while next_note_index < beatmap_notes.size():
		var note_data = beatmap_notes[next_note_index]
		var note_time = note_data["time"]
		
		var spawn_time = note_time - COLLECTABLE_SPEED
		
		if current_audio_time >= spawn_time:
			_spawn_collectable_from_note(note_data)
			next_note_index += 1
		else:
			break

func _spawn_collectable_from_note(note_data: Dictionary) -> void:
	var pool_choice = randf()
	var active_pool: Array[PackedScene] = []
	var is_correct_pool := true
	
	if pool_choice < 0.5 and not CorrectCollectables.is_empty():
		active_pool = CorrectCollectables
		is_correct_pool = true
	elif not WrongCollectables.is_empty():
		active_pool = WrongCollectables
		is_correct_pool = false
	elif not CorrectCollectables.is_empty():
		active_pool = CorrectCollectables
		is_correct_pool = true
	
	if active_pool.is_empty():
		return
	
	var scene_to_spawn = active_pool.pick_random()
	var collectable = scene_to_spawn.instantiate() as Node2D
	
	collectable.set_meta("is_correct", is_correct_pool)
	
	get_parent().add_child(collectable)
	active_collectables.append(collectable)
	
	collectable.global_position = mid_point.global_position
	collectable.scale = Vector2.ZERO
	
	var eight_directions = [
		0.0,             
		PI / 4,          
		PI / 2,          
		3 * PI / 4,      
		PI,              
		5 * PI / 4,      
		3 * PI / 2,      
		7 * PI / 4       
	]
	
	var chosen_angle = 0.0
	if note_data.has("lane"):
		var lane = int(note_data["lane"])
		chosen_angle = eight_directions[lane % eight_directions.size()]
	elif note_data.has("angle"):
		chosen_angle = note_data["angle"]
		
	var outward_dir = Vector2.RIGHT.rotated(chosen_angle)
	var target_edge_pos = mid_point.global_position + (outward_dir * (CIRCLE_RADIUS - COLLECTABLE_OFFSET))
	
	collectable.rotation = outward_dir.angle() + (PI / 2)
	
	var beat_distance = CIRCLE_RADIUS - BEAT_TIMING_OFFSET
	var stop_distance = CIRCLE_RADIUS - COLLECTABLE_OFFSET
	var speed = beat_distance / COLLECTABLE_SPEED
	var actual_travel_duration = stop_distance / speed
	
	_animate_collectable_lifecycle(collectable, target_edge_pos, actual_travel_duration)

func _animate_collectable_lifecycle(collectable: Node2D, target_pos: Vector2, travel_duration: float) -> void:
	var tween = create_tween()
	collectable.set_meta("lifecycle_tween", tween)
	
	tween.parallel().tween_property(collectable, "scale", Vector2.ONE, 0.25).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(collectable, "global_position", target_pos, travel_duration).set_trans(Tween.TRANS_LINEAR)
	
	tween.chain().tween_callback(func(): active_collectables.erase(collectable))
	tween.chain().tween_property(collectable, "scale", Vector2.ZERO, 0.15).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	tween.chain().tween_callback(collectable.queue_free)
