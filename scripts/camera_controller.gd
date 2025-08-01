extends Camera2D

@export var move_speed: float = 300.0
@export var zoom_speed: float = 0.1
@export var min_zoom: float = 0.5
@export var max_zoom: float = 2.0

var map_bounds: Rect2
var tile_map: TileMap

func _ready():
	# Find the TileMap node
	tile_map = get_parent().get_node("TileMap")
	if tile_map:
		calculate_map_bounds()

func calculate_map_bounds():
	if not tile_map:
		return
	
	# Get the used rect of the tilemap
	var used_rect = tile_map.get_used_rect()
	var tile_size = tile_map.tile_set.tile_size
	
	# Convert tile coordinates to world coordinates
	var world_pos = tile_map.global_position
	var world_size = used_rect.size * tile_size
	
	# Calculate the map bounds in world coordinates
	map_bounds = Rect2(world_pos, world_size)
	
	# Adjust bounds to account for camera viewport
	var viewport_size = get_viewport().get_visible_rect().size
	var camera_half_size = viewport_size / (2.0 * zoom)
	
	# Clamp the bounds so camera can't go outside the map
	map_bounds.position += camera_half_size
	map_bounds.size -= camera_half_size * 2.0

func _process(delta):
	handle_movement(delta)
	handle_zoom()

func handle_movement(delta):
	var input_vector = Vector2.ZERO
	
	# WASD movement
	if Input.is_action_pressed("ui_left") or Input.is_key_pressed(KEY_A):
		input_vector.x -= 1
	if Input.is_action_pressed("ui_right") or Input.is_key_pressed(KEY_D):
		input_vector.x += 1
	if Input.is_action_pressed("ui_up") or Input.is_key_pressed(KEY_W):
		input_vector.y -= 1
	if Input.is_action_pressed("ui_down") or Input.is_key_pressed(KEY_S):
		input_vector.y += 1
	
	# Normalize the input vector to prevent faster diagonal movement
	if input_vector.length() > 0:
		input_vector = input_vector.normalized()
		var new_position = position + input_vector * move_speed * delta
		
		# Clamp position to map boundaries
		if map_bounds.has_area():
			new_position.x = clamp(new_position.x, map_bounds.position.x, map_bounds.end.x)
			new_position.y = clamp(new_position.y, map_bounds.position.y, map_bounds.end.y)
		
		position = new_position

func handle_zoom():
	# Mouse wheel zoom
	if Input.is_action_just_released("ui_page_up"):  # Mouse wheel up
		zoom += Vector2.ONE * zoom_speed
	if Input.is_action_just_released("ui_page_down"):  # Mouse wheel down
		zoom -= Vector2.ONE * zoom_speed
	
	# Clamp zoom values
	zoom.x = clamp(zoom.x, min_zoom, max_zoom)
	zoom.y = clamp(zoom.y, min_zoom, max_zoom)
	
	# Recalculate bounds when zoom changes
	if tile_map:
		calculate_map_bounds() 