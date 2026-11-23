extends RigidBody2D

const BASE_RADIUS: float = 20.0
const MIN_SPLIT_RADIUS: float = 12.0

@export var radius: float = BASE_RADIUS
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
	if body is RigidBody2D and body.linear_velocity.length() > 1.25 * radius:
		split()


func _on_detector_body_entered(body: Node2D) -> void:
	if body is RigidBody2D:
		return
	split()


func _on_detector_area_entered(_area: Area2D) -> void:
	split()
	GameManager.add_score(10);

func split() -> void:
	if not can_split or is_splitting:
		return
	is_splitting = true

	queue_free()
	var next_radius: float = radius / 1.25
	if next_radius >= MIN_SPLIT_RADIUS:
		var starting_angle: float = randf() * TAU
		var parts_count: int = randi_range(2, 5)
		var per_part_angle: float = TAU / parts_count

		for i in range(parts_count):
			var direction := Vector2.from_angle(starting_angle + i * per_part_angle)
			call_deferred("instantiate_asteroid", global_position, direction * radius, next_radius)


func instantiate_asteroid(
		desired_position: Vector2, desired_velocity: Vector2, new_radius: float
	) -> void:
	var asteroid_scene: PackedScene = load(scene_file_path)
	var asteroid_node: RigidBody2D = asteroid_scene.instantiate()

	var body_shape: CollisionShape2D = asteroid_node.get_node("CollisionShape2D")
	body_shape.shape = body_shape.shape.duplicate()
	body_shape.shape.radius = new_radius

	var detector_shape: CollisionShape2D = asteroid_node.get_node("Detector/CollisionShape2D")
	detector_shape.shape = body_shape.shape
	detector_shape.shape.radius = new_radius

	var scale_factor: float = new_radius / BASE_RADIUS
	asteroid_node.get_node("Sprite2D").scale = Vector2(scale_factor, scale_factor)
	asteroid_node.radius = new_radius

	var spawn_offset := desired_velocity.normalized() * (new_radius * 0.6)
	asteroid_node.global_position = desired_position + spawn_offset
	print(desired_velocity)
	asteroid_node.linear_velocity = desired_velocity

	get_parent().add_child(asteroid_node)
