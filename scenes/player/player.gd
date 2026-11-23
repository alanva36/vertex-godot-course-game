extends CharacterBody2D

@export var thrust_speed: float = 400.0
@export var rotation_speed: float = 3.5
@export var friction: float = 0.5
@export var bullet_scene: PackedScene

@export var wrap_margin: float = 32.0

@onready var shoot_point: Marker2D = $ShootPoint
@onready var shoot_timer: Timer = $ShootTimer
@onready var bullets: Node = $Bullets
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

func _physics_process(delta: float) -> void:
	handle_rotation(delta)
	handle_thrust(delta)
	move_and_slide()
	handle_collisions()
	wrap_screen()
	
func _process(_delta: float) -> void:
	handle_shooting()

func handle_rotation(delta: float) -> void:
	var turn_direction := Input.get_axis("player_left", "player_right")
	rotation += turn_direction * rotation_speed * delta
	
func handle_thrust(delta: float) -> void:
	if Input.is_action_pressed("player_forward"):
		var forward := Vector2.UP.rotated(rotation)
		velocity += forward * thrust_speed * delta
	else:
		velocity = velocity.lerp(Vector2.ZERO, friction * delta)

func handle_collisions() -> void:
	if get_slide_collision_count() > 0:
		die()

func wrap_screen() -> void:	
	var screen_size := get_viewport_rect().size
	position.x = wrapf(position.x, -wrap_margin, screen_size.x + wrap_margin)
	position.y = wrapf(position.y, -wrap_margin, screen_size.y + wrap_margin)
	
func handle_shooting() -> void:
	if Input.is_action_pressed("player_shoot") and shoot_timer.is_stopped():
		print("shoot")
		shoot()
		shoot_timer.start()

func shoot() -> void:
	if not bullet_scene:
		return

	var bullet := bullet_scene.instantiate()
	bullets.add_child(bullet)
	bullet.global_position = shoot_point.global_position
	bullet.global_rotation = shoot_point.global_rotation
	

func die() -> void:
	print("player died")
	queue_free()
