extends CharacterBody2D

const SPEED = 100.0
const FISHING_DISTANCE = 50.0  # Distance at which the player can fish from the border
@onready var _animated_sprite = $AnimatedSprite2D
@onready var _camera = $Camera2D
var able_to_fish = false

# World boundaries (set these values based on your game world size)
var world_left = 0
var world_right = 1024  # Adjust to your world’s right boundary
var world_top = 0
var world_bottom = 768  # Adjust to your world’s bottom boundary

func _ready() -> void:
	_animated_sprite.play("idle_down")
	_camera.make_current()

func _process(delta: float) -> void:
	get_input()
	check_proximity_to_world_border()

func get_input() -> void:
	var input_vector = Vector2.ZERO

	if Input.is_action_pressed("left"):
		input_vector.x -= 1
	if Input.is_action_pressed("right"):
		input_vector.x += 1
	if Input.is_action_pressed("up"):
		input_vector.y -= 1
	if Input.is_action_pressed("down"):
		input_vector.y += 1

	if input_vector != Vector2.ZERO:
		if input_vector.x < 0:
			_animated_sprite.play("left")
		elif input_vector.x > 0:
			_animated_sprite.play("right")
		elif input_vector.y < 0:
			_animated_sprite.play("up")
		elif input_vector.y > 0:
			_animated_sprite.play("down")
	else:
		if Input.is_action_just_released("left"):
			_animated_sprite.play("idle_left")
		elif Input.is_action_just_released("right"):
			_animated_sprite.play("idle_right")
		elif Input.is_action_just_released("up"):
			_animated_sprite.play("idle_up")
		elif Input.is_action_just_released("down"):
			_animated_sprite.play("idle_down")

	velocity = input_vector.normalized() * SPEED

func _physics_process(delta: float) -> void:
	move_and_slide()
	#print(able_to_fish)

# Check if the player is close to the world border to enable fishing
func check_proximity_to_world_border() -> void:
	# Get the player's current position
	var player_position = global_position

	# Check proximity to the left border
	if player_position.x <= world_left + FISHING_DISTANCE:
		able_to_fish = true
	# Check proximity to the right border
	elif player_position.x >= world_right - FISHING_DISTANCE:
		able_to_fish = true
	# Check proximity to the top border
	elif player_position.y <= world_top + FISHING_DISTANCE:
		able_to_fish = true
	# Check proximity to the bottom border
	elif player_position.y >= world_bottom - FISHING_DISTANCE:
		able_to_fish = true
	else:
		able_to_fish = false
		
func go_to_fishing_spot(target_position: Vector2) -> void:
	var direction = (target_position - global_position).normalized()
	while global_position.distance_to(target_position) > 1.0:
		velocity = direction * SPEED
		move_and_slide()
		await get_tree().create_timer(0.01).timeout
		velocity = Vector2.ZERO
	

func _on_fishing_area_body_entered(body: CharacterBody2D) -> void:
		able_to_fish = true
		var fishing_area_center = body.global_position
		go_to_fishing_spot(fishing_area_center)
		print("area entered")
		

func _on_fishing_area_body_exited(body: CharacterBody2D) -> void:
		able_to_fish = false
		print("area exited")
