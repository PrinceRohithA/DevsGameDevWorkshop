extends CharacterBody2D
class_name Player


@export var speed: float = 0.5
@export var max_health: int = 10
@export var damage: int = 5

var health: int
var freeze: bool = false
var you_died_scene: PackedScene = load("res://you_died.tscn")

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var health_bar: ProgressBar = %HealthBar
@onready var ray_cast: RayCast2D = $RayCast2D

signal hit(damage: int)

func _ready() -> void:
	animation_player.animation_finished.connect(_on_animation_finished)
	health = max_health
	hit.connect(_on_hit)
	health_bar.max_value = max_health
	health_bar.step = 1
	health_bar.value = max_health

func _on_hit(_damage: int):
	freeze = true
	if animation_player.current_animation != "died":
		animation_player.play("hit", -1, 2)
	health -= _damage
	health_bar.value = health
	if health <= 0:
		animation_player.play("died")

func _physics_process(_delta: float) -> void:
	if !freeze:
		var dir = Input.get_vector("left", "right", "up", "down").normalized()
		position += dir * speed
		
		if dir:
			ray_cast.rotation_degrees = rad_to_deg(atan2(dir.y, dir.x)) - 90
			if abs(dir.x) > 0.5:
				sprite_2d.flip_h = dir.x < 0
			animation_player.play("walk")
		else:
			animation_player.play("idle")
		
		if Input.is_action_just_pressed("attack"):
			animation_player.play("attack", -1, 2)
			freeze = true
	
	move_and_slide()

func _on_animation_finished(anim_name):
	if anim_name == "attack":
		inflict_damage()
		freeze = false
	elif anim_name == "hit":
		freeze = false
	elif anim_name == "died":
		get_tree().change_scene_to_packed(you_died_scene)

func inflict_damage():
	if ray_cast.is_colliding():
		var colliders: Area2D = ray_cast.get_collider()
		var enemy = colliders.get_parent()
		if enemy is Enemy:
			enemy.hit.emit(damage)
