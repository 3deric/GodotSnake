extends Node2D

#level constants
@export var snakeElement : PackedScene
@export var foodElement : PackedScene
const gridSize : int = 100
const gridElements : int = 9

#sprites
var sprites : Array

#gameplay variables
var score : int = 0
var isPlaying : bool = false
var isMoving : bool = false
var dir : Vector2 = Vector2(0,-1)
var foodPos : Vector2 = Vector2(-1,-1)
var foodInstance : Node2D = null

#direction constants
const dirUp : Vector2 = Vector2(0,-1)
const dirRight : Vector2 = Vector2(1,0)
const dirDown : Vector2 = Vector2(0,1)
const dirLeft : Vector2 = Vector2(-1,0)

#snake arrays
var snakePos : Array
var snakeOldPos : Array
var snake : Array

func _ready():
	_reset()
	
func _init():
	_loadSprites()

func _loadSprites():
	#head
	sprites.append(load("res://Sprites/headUp.png"))
	sprites.append(load("res://Sprites/headRight.png"))
	sprites.append(load("res://Sprites/headDown.png"))
	sprites.append(load("res://Sprites/headLeft.png"))
	#tail
	sprites.append(load("res://Sprites/tailUp.png"))
	sprites.append(load("res://Sprites/tailRight.png"))
	sprites.append(load("res://Sprites/tailDown.png"))
	sprites.append(load("res://Sprites/tailLeft.png"))
	#body
	sprites.append(load("res://Sprites/bodyDown.png"))
	sprites.append(load("res://Sprites/bodyStraight.png"))
	sprites.append(load("res://Sprites/bodyCurve1.png"))
	sprites.append(load("res://Sprites/bodyCurve2.png"))
	sprites.append(load("res://Sprites/bodyCurve3.png"))
	sprites.append(load("res://Sprites/bodyCurve4.png"))

	
func _reset():
	score = 0
	dir = dirUp
	_clearGame()
	_generateSnake()
	_placeFood()
	_updateScore()
	_update()
	_start()
	_updateSprites()

func _start():
	$Timer.start()
	$GameOver/Panel.visible = false
	isPlaying = true
	
func _endGame():
	$Timer.stop()
	$GameOver/Panel.visible = true
	isMoving = false;
	isPlaying = false;
	#display end screen with points and reset functionality
	
func _placeFood():
	var pos = Vector2(int(randf_range(0, gridElements)), int(randf_range(0, gridElements)))
	foodPos = pos
	foodInstance = foodElement.instantiate()
	add_child(foodInstance)
	
func _clearGame():
	for i in snake.size():
		remove_child(snake[i])
		snake[i].queue_free()
	snake.clear()
	snakePos.clear()
	snakeOldPos.clear()
	if(foodInstance != null):
		remove_child(foodInstance)
		foodInstance.queue_free()
	
func _generateSnake():
	for i in 3:
		var currentElement = snakeElement.instantiate()
		snakePos.append(Vector2(0, i) + Vector2(4 ,4))
		currentElement.position = snakePos[i]
		snake.append(currentElement)
		add_child(currentElement)
	snake[0].get_node("Sprite2D").z_index = 1

func _on_timer_timeout():
	_move()
	_update()
	_updateSprites()
		
func _move():
	snakeOldPos = [] + snakePos
	if isMoving:
		snakePos[0] += dir
		for i in snake.size():
			if i > 0:
				snakePos[i] = snakeOldPos[i-1]		
	_outOfBounds()
	_selfEaten()
	_foodEaten()
	_updateScore()
		
func _outOfBounds():
	if snakePos[0].x < 0 or snakePos[0].x > gridElements or snakePos[0].y < 0 or snakePos[0].y > gridElements:
		_endGame()
	
func _selfEaten():
	for i in snakePos.size():
		if i > 0:
			if snakePos[0] == snakePos[i]:
				_endGame()
	
func _foodEaten():
	if snakePos[0] == foodPos:
		remove_child(foodInstance)
		foodInstance.queue_free()
		_growSnake()
		_placeFood()
		score += 1
		
func _growSnake():
	var currentElement = snakeElement.instantiate()
	snakePos.append(Vector2(-1,-1))
	snake.append(currentElement)
	add_child(currentElement)
		
func _updateScore():
	$Scoreboard/Panel/Label.text = "Score: " + str(score)

func _update():
	for i in snake.size():
		snake[i].position =snakePos[i] * gridSize + Vector2 (0,1) * gridSize / 2
	if foodInstance != null:
		foodInstance.position = foodPos * gridSize + Vector2 (0,1) * gridSize / 2
	
func _process(delta):
	if Input.is_action_just_pressed("Up") and dir != dirDown:
		if !isMoving:
			isMoving = true
		dir = dirUp
	if Input.is_action_just_pressed("Right") and dir != dirLeft:
		if !isMoving:
			isMoving = true
		dir = dirRight
	if Input.is_action_just_pressed("Down") and dir != dirUp:
		if !isMoving:
			isMoving = true
		dir = dirDown
	if Input.is_action_just_pressed("Left") and dir != dirRight:
		if !isMoving:
			isMoving = true
		dir = dirLeft

func _updateSprites():
	var added : bool = false
	if Vector2(-1,-1) == snakePos[snake.size()-1]:
		added = true
		
	#update head
	if dir == dirUp:
		snake[0].get_node("Sprite2D").texture = sprites[0]
	if dir == dirRight:
		snake[0].get_node("Sprite2D").texture = sprites[1]
	if dir == dirDown:
		snake[0].get_node("Sprite2D").texture = sprites[2]
	if dir == dirLeft:
		snake[0].get_node("Sprite2D").texture = sprites[3]
		
	#update tail
	var tailDir
	if added:
		tailDir = snakePos[snake.size()-3] - snakePos[snake.size()-2]
	else:
		tailDir = snakePos[snake.size()-2] - snakePos[snake.size()-1]
	if tailDir == dirUp:
		snake[snake.size()-1].get_node("Sprite2D").texture = sprites[4]
	if tailDir == dirRight:
		snake[snake.size()-1].get_node("Sprite2D").texture = sprites[5]
	if tailDir == dirDown:
		snake[snake.size()-1].get_node("Sprite2D").texture = sprites[6]
	if tailDir == dirLeft:
		snake[snake.size()-1].get_node("Sprite2D").texture = sprites[7]
		
	#update body
	for i in snake.size()-1:
		if i > 0:
			var leadDir
			var trailDir
			leadDir = snakePos[i-1] - snakePos[i]
			trailDir = snakePos[i+1] - snakePos[i]
			if (leadDir == dirUp and trailDir == dirDown) or (leadDir == dirDown and trailDir == dirUp):
				snake[i].get_node("Sprite2D").texture = sprites[8]
			if (leadDir == dirLeft and trailDir == dirRight) or (leadDir == dirRight and trailDir == dirLeft):
				snake[i].get_node("Sprite2D").texture = sprites[9]
			#curves
			if (leadDir == dirLeft and trailDir == dirDown) or (leadDir == dirDown and trailDir == dirLeft):
				snake[i].get_node("Sprite2D").texture = sprites[10]
			if (leadDir == dirRight and trailDir == dirDown) or (leadDir == dirDown and trailDir == dirRight):
				snake[i].get_node("Sprite2D").texture = sprites[11]
			if (leadDir == dirLeft and trailDir == dirUp) or (leadDir == dirUp and trailDir == dirLeft):
				snake[i].get_node("Sprite2D").texture = sprites[12]
			if (leadDir == dirRight and trailDir == dirUp) or (leadDir == dirUp and trailDir == dirRight):
				snake[i].get_node("Sprite2D").texture = sprites[13]
				
		
	
func _on_game_over_restart():
	_reset()
