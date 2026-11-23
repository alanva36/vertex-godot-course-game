extends RigidBody2D

const BASE_SIZE: float = 128.0
const MIN_SPLIT_SIZE: float = 32.0

@export var size: float = BASE_SIZE
@export var starting_velocity: Vector2
@export var apply_starting_velocity: bool = false

var can_split: bool = false
var is_splitting: bool = false


func _ready() -> void:
	if apply_starting_velocity:
		linear_velocity = starting_velocity

	contact_monitor = true
	max_contacts_reported = 16
	can_sleep = false

	await get_tree().create_timer(0.1).timeout
	if is_inside_tree():
		can_split = true


func on_body_entered(body: Node) -> void:
	if body is RigidBody2D and body.linear_velocity.length() > 2.0 * size:
		split()


func _on_detector_body_entered(body: Node2D) -> void:
	if body is RigidBody2D:
		return
	split()


func _on_detector_area_entered(_area: Area2D) -> void:
	split()


func split() -> void:
	if not can_split or is_splitting:
		return
	is_splitting = true

	var next_size: float = size / 2.0
	if next_size >= MIN_SPLIT_SIZE:
		var starting_angle: float = randf() * TAU
		var parts_count: int = randi_range(2, 5)
		var per_part_angle: float = TAU / parts_count

		for i in range(parts_count):
			var direction := Vector2.from_angle(starting_angle + i * per_part_angle)
			call_deferred("instantiate_asteroid", global_position, direction * size, next_size)

	hide()
	await get_tree().physics_frame
	queue_free()


func instantiate_asteroid(desired_position: Vector2, desired_velocity: Vector2, new_size: float) -> void:
	var asteroid_scene: PackedScene = load(scene_file_path)
	var asteroid_node: RigidBody2D = asteroid_scene.instantiate()

	var body_shape: CollisionShape2D = asteroid_node.get_node("CollisionShape2D")
	body_shape.shape = body_shape.shape.duplicate()
	body_shape.shape.size = Vector2(new_size, new_size)

	var detector_shape: CollisionShape2D = asteroid_node.get_node("Detector/CollisionShape2D")
	detector_shape.shape = body_shape.shape

	var scale_factor: float = new_size / BASE_SIZE
	asteroid_node.get_node("Sprite2D").scale = Vector2(scale_factor, scale_factor)
	asteroid_node.size = new_size

	var spawn_offset := desired_velocity.normalized() * (new_size * 0.6)
	asteroid_node.global_position = desired_position + spawn_offset
	asteroid_node.linear_velocity = desired_velocity

	get_parent().add_child(asteroid_node)
