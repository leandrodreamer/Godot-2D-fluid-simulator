extends CanvasLayer

var tilemapsize = Vector2(128,75)
var coorsvalueA = {vy = Vector2(0,1), vx = Vector2(1,0), vnx = Vector2(-1,0)}
var coorsvalueB = {vy = Vector2(0,1), vnx = Vector2(-1,0), vx = Vector2(1,0)}
var blockmode = 0
var watermode = 0
var proccesmode = true

func _ready():
	for iy in range(0,tilemapsize.y):
		for ix in range(0,tilemapsize.x):
			if $TileMap.get_cell(ix,iy) != 0:
				$TileMap.set_cell(ix,iy,1,false,false,false,Vector2(0,0))

func _input(event):
	var mousepos = get_viewport().get_mouse_position()/8
	
	watermode = 8
	if Input.is_action_pressed("shift"):
		watermode = 16
	if Input.is_action_pressed("click1"):
		$TileMap.set_cell(mousepos.x,mousepos.y,1,false,false,false,Vector2(watermode,0))
	
	if not Input.is_action_pressed("shift"):
		blockmode = 0
	else:
		blockmode = 1
	if Input.is_action_pressed("click2"):
		$TileMap.set_cell(mousepos.x,mousepos.y,blockmode)
	
	if Input.is_action_just_pressed("space"):
		proccesmode = !proccesmode
	if Input.is_action_just_pressed("r"):
		get_tree().reload_current_scene()

func _process(delta):
	if proccesmode:
		var tiles = []
		
		for til in $TileMap.get_used_cells_by_id(1):
			if $TileMap.get_cell_autotile_coord(til.x,til.y).x != 0:
				tiles.insert(0,til)
		tiles.shuffle()
		for i in tiles:
			if $TileMap.get_cell(i.x,i.y) == 1:
				var value = $TileMap.get_cell_autotile_coord(i.x,i.y).x
				
				var coorsvalue = []
				if rand_range(-100,100) < 0:
					coorsvalue = coorsvalueA
				else:
					coorsvalue = coorsvalueB
				
				var closevalue = {}
				
				for coors in coorsvalue.keys():
					if $TileMap.get_cell(i.x+coorsvalue[coors].x,i.y+coorsvalue[coors].y) == 0:
						closevalue[coors] = 99
					elif $TileMap.get_cell(i.x+coorsvalue[coors].x,i.y+coorsvalue[coors].y) == 1:
						closevalue[coors] = $TileMap.get_cell_autotile_coord(i.x+coorsvalue[coors].x,i.y+coorsvalue[coors].y).x
					if $TileMap.get_cell(i.x+coorsvalue[coors].x,i.y+coorsvalue[coors].y) == 2:
						closevalue[coors] = -999
				
				if closevalue.has("vnx") and closevalue.has("vx"):
					if closevalue["vx"] > closevalue["vnx"]:
						closevalue.erase("vx")
					elif closevalue["vx"] < closevalue["vnx"]:
						closevalue.erase("vnx")
					
				for closekey in closevalue.keys():
					if closevalue[closekey] < value or closevalue[closekey] < 8:
						$TileMap.set_cell(i.x,i.y,1,false,false,false,Vector2(value-1,0))
						$TileMap.set_cell(i.x+coorsvalue[closekey].x,i.y+coorsvalue[closekey].y,1,false,false,false,Vector2(closevalue[closekey]+1,0))
						break