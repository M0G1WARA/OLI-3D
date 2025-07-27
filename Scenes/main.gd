extends Node2D

var dragging:bool = false
var moving:bool = false
var directions: Array = [ "right"]
var current_direction:int = 0

var model_path: String = ""
var default_model_path: String = "res://Assets/3D/Demo/demo.glb"
var modelInstance: Node
var animation_player: AnimationPlayer

# Called when the node enters the scene tree for the first time.
func _ready():
	Global.load_config()
	$Timer.wait_time = Global.settings["interface"]["timer"]
	if Global.settings["interface"]["horizontal movement"]:
		directions.append("left")
	if Global.settings["interface"]["vertical movement"]:
		directions = [ "down", "up"] if directions.size() == 1 else [ "right", "down","left", "up"]
	model_path = default_model_path if Global.settings["model"]["custom model"] == "" else "user://"+Global.settings["model"]["custom model"]
	
	var gltf_doc = GLTFDocument.new()
	var gltf_state = GLTFState.new()

	var dir_access = DirAccess.open(model_path.get_base_dir())
	if dir_access:
		var error = gltf_doc.append_from_file(model_path, gltf_state)
		if error != OK:
			print("Error GLB: ", error)
			return
			
		modelInstance = gltf_doc.generate_scene(gltf_state)
			
		if not modelInstance:
			print("Error: Scene.")
			return
			
	else:
		var model = load(default_model_path)
		modelInstance = model.instantiate()
		
	$Node3D.add_child(modelInstance)
	animation_player = modelInstance.get_node("AnimationPlayer")
	
	if Global.settings["model"]["shader"] != "None" :
		apply_shader_to_meshes(modelInstance)
	
	$Node3D/Camera3D.position.x = Global.settings["model"]["camera x"]
	$Node3D/Camera3D.position.y = Global.settings["model"]["camera y"]
	$Node3D/Camera3D.position.z = Global.settings["model"]["camera z"]
	
	if Global.settings["interface"]["edges"]:
		$CanvasLayer.show()


func apply_shader_to_meshes(node: Node):
	if node is MeshInstance3D:
		var shaderMaterial = ShaderMaterial.new()
		shaderMaterial.shader = load("res://Assets/Shaders/"+Global.settings["model"]["shader"])
		node.material_override = shaderMaterial
		
	for child in node.get_children():
		apply_shader_to_meshes(child)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if moving and (Global.settings["interface"]["horizontal movement"] or Global.settings["interface"]["vertical movement"]):
		move_window()
	else:
		if not animation_player.is_playing():
			animation_player.play(Global.settings["model"]["animation idle"])


func _input(event):
	if event is InputEventMouseMotion and dragging:
		modelInstance.rotation_degrees.y += 0
		animation_player.play(Global.settings["model"]["animation dragging"])
		get_tree().root.position = DisplayServer.mouse_get_position() - (DisplayServer.window_get_size()/2)

	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.double_click:
				$PopupMenu.set_position(DisplayServer.mouse_get_position()+Vector2i(DisplayServer.window_get_size().x/2,0))
				$PopupMenu.show()
				modelInstance.rotation_degrees.y += 0
				animation_player.play(Global.settings["model"]["animation options"])
			elif event.pressed:
				dragging = true
				moving = false
			else:
				dragging = false
				if not $ChatWindow.visible and not $PopupMenu.visible:
					$Timer.start()
	
		if event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			chat()

func chat():

	modelInstance.rotation_degrees.y = 0
	animation_player.play(Global.settings["model"]["animation chat"])
	if not $ChatWindow.visible:
		moving = false
		$Timer.stop()
	
		var monitor_id = DisplayServer.window_get_current_screen()
		var monitor_resolution = DisplayServer.screen_get_size(monitor_id)
		var window_position = DisplayServer.window_get_position()
		
		$ChatWindow.show()
		$ChatWindow.size = Vector2(Global.settings["interface"]["chat resolution"].x, Global.settings["interface"]["chat resolution"].y) 
		if window_position.x >= monitor_resolution.x/2:
			$ChatWindow.position = Vector2(window_position.x - Global.settings["interface"]["chat resolution"].x , window_position.y)
		else:
			$ChatWindow.position = Vector2(window_position.x + DisplayServer.window_get_size().x, window_position.y)
		
	else:
		$ChatWindow.hide()
		$Timer.start()


func move_window():
	var monitor_id = DisplayServer.window_get_current_screen()
	var monitor_resolution = DisplayServer.screen_get_size(monitor_id)
	var window_position = DisplayServer.window_get_position()

	match directions[current_direction]:

		"right":
			modelInstance.rotation_degrees.y = 90
			animation_player.play(Global.settings["model"]["animation walking"])
			if dragging == false and window_position.x < monitor_resolution.x-DisplayServer.window_get_size().x:
				get_tree().root.position += Vector2i(1,0)

			if window_position.x+DisplayServer.window_get_size().x >= monitor_resolution.x:
				idle()
		
		"down":
			modelInstance.rotation_degrees.y = 0
			animation_player.play_backwards(Global.settings["model"]["animation vertical"])
			if dragging == false and window_position.y < monitor_resolution.y-DisplayServer.window_get_size().y:
				get_tree().root.position += Vector2i(0,1)
				
			if window_position.y+DisplayServer.window_get_size().y >= monitor_resolution.y:
				idle()

		"left":
			modelInstance.rotation_degrees.y = -90
			animation_player.play(Global.settings["model"]["animation walking"])
			if dragging == false and window_position.x > 0:
				get_tree().root.position -= Vector2i(1,0)

			if window_position.x == 0:
				idle()
		
		"up":
			modelInstance.rotation_degrees.y = 180
			animation_player.play(Global.settings["model"]["animation vertical"])
			if dragging == false and window_position.y > 0:
				get_tree().root.position -= Vector2i(0,1)
				
			if window_position.y == 0:
				idle()

func idle():
	modelInstance.rotation_degrees.y = 0
	animation_player.play(Global.settings["model"]["animation idle"])
	moving = false
	current_direction = (current_direction + 1) % directions.size()
	$Timer.start()

func _on_timer_timeout():
	moving = true
	if not Global.settings["interface"]["horizontal movement"] and not Global.settings["interface"]["vertical movement"]:
		modelInstance.rotation_degrees.y = 0
		animation_player.play(Global.settings["model"]["animation idle"])

func _on_popup_menu_id_pressed(id):
	match id:
		1:
			settings()
		2:
			get_tree().quit()

func _on_popup_menu_visibility_changed():
	if not $ChatWindow.visible and not $PopupMenu.visible and $Timer.is_stopped() and dragging == false:
		$Timer.start()
	else:
		$Timer.stop()

func settings():
	$SettingsWindow.show()
	animation_player.play(Global.settings["model"]["animation options"])
	$Timer.stop()

func _on_settings_window_close_requested():
	$SettingsWindow.hide()
	$Timer.start()
