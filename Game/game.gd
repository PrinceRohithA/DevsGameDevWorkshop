extends Node2D

@onready var bg_music: AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var floor_tilemap: TileMapLayer = $Environment/Tilemap/Floor
@onready var wall_tilemap: TileMapLayer = $Environment/Tilemap/Wall
@onready var enemies: Node2D = $Environment/Enemies
@onready var player: Player = %Player

@export var spawn_interval := 2.0
@export var spawn_radius := 400.0
@export var min_distance := 120.0
@export var max_enemies := 20

var enemy_scene: PackedScene = preload("res://Enemy/ememy.tscn")

var spawn_timer: Timer


func _ready() -> void:
	bg_music.play()

	spawn_timer = Timer.new()
	spawn_timer.wait_time = spawn_interval
	spawn_timer.one_shot = false
	add_child(spawn_timer)

	spawn_timer.timeout.connect(_on_time_out)
	spawn_timer.start()


func _on_time_out() -> void:
	if enemies.get_child_count() >= max_enemies:
		return

	var pos = get_valid_spawn_position()
	if pos == null:
		return

	var enemy = enemy_scene.instantiate()
	enemy.global_position = pos
	enemies.add_child(enemy)


# -----------------------------
# Spawn helpers
# -----------------------------

func get_valid_spawn_position() -> Variant:
	for i in range(30):
		var pos = random_point_in_ring(player.global_position, min_distance, spawn_radius)

		if not is_on_floor(pos):
			continue

		if is_on_wall(pos):
			continue

		return pos

	return null


func random_point_in_ring(origin: Vector2, inner: float, outer: float) -> Vector2:
	var angle = randf() * TAU
	var u = randf()
	var r = sqrt(u * (outer * outer - inner * inner) + inner * inner)
	return origin + Vector2(cos(angle), sin(angle)) * r


func is_on_floor(pos: Vector2) -> bool:
	var cell: Vector2i = floor_tilemap.local_to_map(floor_tilemap.to_local(pos))
	return floor_tilemap.get_cell_source_id(cell) != -1  # ✅ not empty


func is_on_wall(pos: Vector2) -> bool:
	var cell: Vector2i = wall_tilemap.local_to_map(wall_tilemap.to_local(pos))
	return wall_tilemap.get_cell_source_id(cell) != -1
