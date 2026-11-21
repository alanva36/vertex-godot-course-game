extends RigidBody2D

@export var starting_velocity: Vector2
@export var apply_starting_velocity: bool
var asteroid = preload("res://scenes/asteroid/asteroid.tscn")
var size = 128;
func _ready() -> void:
	if apply_starting_velocity:
		linear_velocity = starting_velocity
		#apply_central_impulse(starting_velocity)
	await get_tree().create_timer(0.1).timeout
	contact_monitor = true
	max_contacts_reported = 16

func instanciate_asteroid
(
	desired_position: Vector2, desired_velocity: Vector2, new_size: float
	):
	var asteroid_node = asteroid.instantiate()
	
	var collision_shape = asteroid_node.get_node("CollisionShape2D")
	collision_shape.shape = collision_shape.shape.duplicate()
	collision_shape.shape.size = Vector2(new_size, new_size)
	
	asteroid_node.get_node("Sprite2D").scale = Vector2(new_size / 128, new_size / 128)
	asteroid_node.size = new_size
	
	get_parent().add_child(asteroid_node);
	asteroid_node.global_position = desired_position;
	asteroid_node.linear_velocity = desired_velocity

func on_body_entered(body: Node) -> void:
	var body_velocity = body.linear_velocity
	#print(body_velocity.length())
	if body_velocity.length() < 2 * size: return
	
	queue_free();
	if size / 2 < 32: return
	
	var random_generator := RandomNumberGenerator.new();
	var starting_angle: float = random_generator.randf() * 2.0 * PI 
	var parts_count: int = random_generator.randi_range(2, 5)
	var per_part_angle: float = 2.0 * PI / parts_count
	for i in range(parts_count):
		var desired_velocity : Vector2 = global_position - body.global_position
		desired_velocity *= 0.25
		var desired_force_vector : Vector2 = Vector2.from_angle(starting_angle + i * per_part_angle)
		desired_velocity += desired_force_vector * size
		call_deferred("instanciate_asteroid", global_position, desired_velocity, size / 2)
