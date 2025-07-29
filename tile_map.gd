extends TileMap

@onready var highlight := preload("res://scenes/Highlight.tscn") 

var current_highlight : Node = null

func _unhandled_input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		var clicked_pos = event.position
		var tile_coords = local_to_map(clicked_pos)
		print("Tile clicked at:", tile_coords)
		
		# Remove old highlight if it exists
		if current_highlight and current_highlight.is_inside_tree():
			current_highlight.queue_free()

		# Add highlight instance to show selection
		current_highlight = highlight.instantiate()
		current_highlight.global_position = to_global(map_to_local(tile_coords))
		add_child(current_highlight)
	
