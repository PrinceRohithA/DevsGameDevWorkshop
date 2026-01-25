extends CharacterBody2D
class_name Enemy

@onready var vision: Area2D = $Vision
@onready var player: Player = %Player
@onready var attak_area: Area2D = $AttakArea
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var health_bar: ProgressBar = $HealthBar

@export var speed: float = 10
@export var max_health: int = 10
@export var damage: int = 2

var health: int
var freeze: bool = false

var is_player_on_vision: bool = false
var is_player_on_attackarea: bool = false

signal hit(damage: int)

func _ready() -> void:
	vision.body_entered.connect(_on_vision_entered)
	vision.body_exited.connect(_on_vision_exited)
	attak_area.body_entered.connect(_on_attackarea_entered)
	attak_area.body_exited.connect(_on_attackarea_exited)
	animation_player.animation_finished.connect(_on_animation_finished)
	health = max_health
	hit.connect(_on_hit)
	health_bar.max_value = max_health
	health_bar.step = 1
	health_bar.value = max_health

func _on_hit(_damage: int):
	freeze = true
	animation_player.play("hit", -1, 2)
	health -= _damage
	health_bar.value = health
	if health <= 0:
		animation_player.play("died")

func _on_attackarea_entered(body):
	if body.name == "Player":
		is_player_on_attackarea = true

func _on_attackarea_exited(body):
	if body.name == "Player":
		is_player_on_attackarea = false

func _on_vision_entered(body):
	if body.name == "Player":
		is_player_on_vision = true

func _on_vision_exited(body):
	if body.name == "Player":
		is_player_on_vision = false

func _physics_process(_delta: float) -> void:
	if !freeze:
		if is_player_on_vision:
			var move_dir: Vector2 = (player.global_position - global_position).normalized()
			
			if is_player_on_attackarea:
				animation_player.play("attack")
				velocity = Vector2.ZERO
				
			else:
				velocity = move_dir * speed
				
				if velocity:
					animation_player.play("walk")
				else:
					animation_player.play("idle")
				
			if move_dir.x > 0.5:
				sprite_2d.flip_h = false
			else:
				sprite_2d.flip_h = true
		
	move_and_slide()

func _on_animation_finished(anim_name):
	if anim_name == "attack":
		player.hit.emit(damage)
	
	elif anim_name == "hit":
		freeze = false
	
	elif anim_name == "died":
		queue_free()
