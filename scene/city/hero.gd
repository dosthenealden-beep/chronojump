extends CharacterBody2D

var facing := Vector2.DOWN
var stride := 0.0

var dodge_time := 0.0
var cooldown := 0.0
var shift_held := false

func _ready():
	var collider := CollisionShape2D.new()
	var circle := CircleShape2D.new()
	circle.radius = 4
	collider.shape = circle
	add_child(collider)
	z_index = 4

func _physics_process(delta):
	var motion := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	motion += Vector2(int(Input.is_physical_key_pressed(KEY_D))-int(Input.is_physical_key_pressed(KEY_A)), int(Input.is_physical_key_pressed(KEY_S))-int(Input.is_physical_key_pressed(KEY_W)))
	velocity = motion.limit_length(1) * 104
	if velocity.length() > 0:
		facing = velocity.normalized()
		stride += delta * 12
	cooldown = maxf(0,cooldown-delta)
	dodge_time = maxf(0,dodge_time-delta)
	var shift := Input.is_physical_key_pressed(KEY_SHIFT)
	if shift and not shift_held and cooldown == 0:
		dodge_time = 0.24
		cooldown = 0.85
	shift_held = shift
	if dodge_time > 0: velocity = facing * 210
	modulate = Color("#a1faff") if dodge_time > 0 else Color.WHITE
	move_and_slide()
	queue_redraw()

func _draw():
	var step := int(sin(stride) * 1.8) if velocity.length() > 0 else 0
	draw_rect(Rect2(-5,-3,4,6+step),Color("#24283e"))
	draw_rect(Rect2(1,-3,4,6-step),Color("#24283e"))
	draw_rect(Rect2(-6,-11,12,10),Color("#177d91"))
	draw_rect(Rect2(-6,-11,12,2),Color("#ffc660"))
	draw_rect(Rect2(-4,-19,8,8),Color("#b77750"))
	draw_rect(Rect2(-5,-20,10,4),Color("#302739"))
	if facing.y >= 0:
		draw_rect(Rect2(1 if facing.x >= 0 else -3,-15,2,1),Color("#362637"))
