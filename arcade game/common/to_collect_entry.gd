@tool
class_name ToCollectEntry
extends HBoxContainer

@export var icon_image: Texture2D:
	set(value):
		icon_image = value
		if not is_node_ready(): await ready
		icon.texture = icon_image

@export var obj_name: String:
	set(value):
		obj_name = value
		if not is_node_ready(): await ready
		name_label.text = obj_name
@export var obj_scene: PackedScene

@export var spawn_count_total: int = 20
@export var min_to_collect: int = 0
@export var points_given: int = 50
@export var good_to_collect: bool = true

@onready var icon: TextureRect = $Icon
@onready var name_label: RichTextLabel = $NameLabel
@onready var collected_label: RichTextLabel = $CollectedLabel

var collected: int:
	set(value):
		collected = value
		if not is_node_ready(): await ready
		var text: String = "%d" % collected
		if min_to_collect:
			text += "/%d" % min_to_collect
		collected_label.text = text


var idx: int:
	get: return get_index()


func _ready() -> void:
	if not Engine.is_editor_hint():
		reset_count()


func reset_count() -> void:
	collected = 0
