class_name AsteroidSpawner
extends Node

var asteroid = preload("res://scenes/asteroid/asteroid.tscn")
@onready var random_generator := RandomNumberGenerator.new()
var timer : SceneTreeTimer;

func _process(_delta: float) -> void:
	if timer != null and timer.time_left > 0.0:  return
	var random_time := random_generator.randf() * 2.0 + 1.0
	timer = get_tree().create_timer(random_time)
	await timer.timeout
	spawn_asteroid()
	
func spawn_asteroid():
	var random_side := random_generator.randi_range(0, 3)
	var random_x := random_generator.randf() * get_window().size.x
	var random_y := random_generator.randf() * get_window().size.y
	var spawn_pos : Vector2;
	match random_side:
		0: spawn_pos = Vector2(random_x, 0)
		1: spawn_pos = Vector2(get_window().size.x, random_y)
		2: spawn_pos = Vector2(random_x, get_window().size.y)
		3: spawn_pos = Vector2(0, random_y)
	
	var asteroid_node = asteroid.instantiate()
	
	var collision_shape = asteroid_node.get_node("CollisionShape2D")
	collision_shape.shape = collision_shape.shape.duplicate()
	
	get_parent().add_child(asteroid_node);
	asteroid_node.global_position = spawn_pos;
	var random_rotation: float = random_generator.randf() * 2.0 * PI
	asteroid_node.global_rotation = random_rotation 
	var desired_velocity: Vector2 = spawn_pos.direction_to(get_window().size / 2) * 350
	asteroid_node.linear_velocity = desired_velocity
	var random_angular_velocity: float = random_generator.randf() * 2.0 * PI
	asteroid_node.angular_velocity = random_angular_velocity
	
