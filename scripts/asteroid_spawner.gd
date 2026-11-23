class_name AsteroidSpawner
extends Node

const ASTEROID_SPEED: float = 150.0
const MIN_SPAWN_DELAY: float = 1.0
const MAX_SPAWN_DELAY: float = 3.0

@export var asteroid: PackedScene

var spawn_timer: SceneTreeTimer


func _process(_delta: float) -> void:
	if spawn_timer != null and spawn_timer.time_left > 0.0:
		return

	spawn_timer = get_tree().create_timer(randf_range(MIN_SPAWN_DELAY, MAX_SPAWN_DELAY))
	await spawn_timer.timeout
	if is_inside_tree():
		spawn_asteroid()


func spawn_asteroid() -> void:
	var viewport_size: Vector2 = get_viewport().get_visible_rect().size
	var spawn_pos: Vector2

	match randi_range(0, 3):
		0: spawn_pos = Vector2(randf_range(0.0, viewport_size.x), 0.0)
		1: spawn_pos = Vector2(viewport_size.x, randf_range(0.0, viewport_size.y))
		2: spawn_pos = Vector2(randf_range(0.0, viewport_size.x), viewport_size.y)
		3: spawn_pos = Vector2(0.0, randf_range(0.0, viewport_size.y))

	var asteroid_node: RigidBody2D = asteroid.instantiate()

	var collision_shape: CollisionShape2D = asteroid_node.get_node("CollisionShape2D")
	collision_shape.shape = collision_shape.shape.duplicate()

	asteroid_node.global_position = spawn_pos
	asteroid_node.global_rotation = randf() * TAU
	asteroid_node.linear_velocity = spawn_pos.direction_to(viewport_size * 0.5) * ASTEROID_SPEED
	asteroid_node.angular_velocity = randf() * TAU

	get_parent().add_child(asteroid_node)
