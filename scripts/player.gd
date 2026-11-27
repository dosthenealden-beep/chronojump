extends CharacterBody2D

# get animation
@onready var _animated_sprite = $motion;
var screen_size;

@export var SPEED:float = 300.0
@export var JUMP_VELOCITY:float = -200.0

var last_direction = Vector2.ZERO;


func _ready() -> void:
	screen_size = get_viewport_rect().size

func handleMotion(delta):
	
	# Handle jump.
	'''
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	'''
	
	var direction = Vector2.ZERO # The player's movement vector.
	if Input.is_action_pressed("ui_right"):
		_animated_sprite.flip_h = false
		_animated_sprite.play("side");
		direction.x += 1
		last_direction = direction
	if Input.is_action_pressed("ui_left"):
		_animated_sprite.flip_h = true
		_animated_sprite.play("side");
		direction.x -= 1
		last_direction = direction
	if Input.is_action_pressed("ui_down"):
		_animated_sprite.play("front");
		direction.y += 1
		last_direction = direction
	if Input.is_action_pressed("ui_up"):
		_animated_sprite.play("back");
		direction.y -= 1
		last_direction = direction

	if direction.length() > 0:
		direction = direction.normalized() * SPEED
		_animated_sprite.play()
	else:
		#_animated_sprite.flip_h = false
		_animated_sprite.stop()
		
		if (last_direction.y == 1):
			_animated_sprite.play("idle_front")
		elif (last_direction.y == -1):
			_animated_sprite.play("idle_back")
			
		if (last_direction.x == 1):
			_animated_sprite.flip_h = false
			_animated_sprite.play("idle_sides")
		elif (last_direction.x == -1):
			_animated_sprite.flip_h = true
			_animated_sprite.play("idle_sides")
			
	var axis = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down");
	
	#force single axis: keep only the dominant direction
	if axis.x and axis.y:
		if abs(axis.x) > abs(axis.y):
			direction = Vector2.ZERO
		else:
			direction = Vector2.ZERO
		
	position += direction * delta
	position = position.clamp(Vector2.ZERO, screen_size)
	

	
func _physics_process(delta: float) -> void:
	# Add the gravity.
	'''
	if not is_on_floor():
		velocity += get_gravity() * delta
	'''
	
	handleMotion(delta)
		
	move_and_slide()
