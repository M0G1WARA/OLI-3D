extends Control


func _on_http_request_request_completed(_result, response_code, _headers, body):
	if response_code == 200:
		var json = JSON.new()
		var error = json.parse(body.get_string_from_utf8())
		if error == OK:
			var data_received = json.data
			var models = data_received["models"] 
			var item_list = $TabContainer/Ollama/MarginContainer/VBoxContainer/ItemList
			item_list.clear()

			for model in models:
				item_list.add_item(model["name"])
			
			load_ollama_settings()
			
		else:
			$AcceptDialog.dialog_text = tr("ERROR JSON") + str(json.get_error_message())
			$AcceptDialog.show()
	else:
		$AcceptDialog.dialog_text = tr("ERROR RESPONSE") + str(response_code)
		$AcceptDialog.show()

func load_ollama_settings():
	$TabContainer/Ollama/MarginContainer/VBoxContainer/ServerEdit.text = Global.settings["ollama"]["server"]
	for i in range($TabContainer/Ollama/MarginContainer/VBoxContainer/ItemList.get_item_count()):
		if $TabContainer/Ollama/MarginContainer/VBoxContainer/ItemList.get_item_text(i) == Global.settings["ollama"]["model"]:
			$TabContainer/Ollama/MarginContainer/VBoxContainer/ItemList.select(i)
			break


func load_interface_settings():
	$TabContainer/Interface/MarginContainer/VBoxContainer/ItemList.select( 0 if Global.settings["interface"]["language"] == "en" else 1)
	
	for i in range($TabContainer/Interface/MarginContainer/VBoxContainer/ItemList.get_item_count()):
		if $TabContainer/Interface/MarginContainer/VBoxContainer/ItemList.get_item_text(i) == Global.settings["interface"]["language"]:
			$TabContainer/Interface/MarginContainer/VBoxContainer/ItemList.select(i)
			break
	$TabContainer/Interface/MarginContainer/VBoxContainer/CheckButtonHorizontal.button_pressed = Global.settings["interface"]["horizontal movement"]
	$TabContainer/Interface/MarginContainer/VBoxContainer/CheckButtonVertical.button_pressed = Global.settings["interface"]["vertical movement"]
	$TabContainer/Interface/MarginContainer/VBoxContainer/SpinBox.value = Global.settings["interface"]["timer"]
	
	var resolution = Global.settings["interface"]["resolution"]
	$TabContainer/Interface/MarginContainer/VBoxContainer/HBoxContainer/Resolution.text = str(resolution.x) +" x "+ str(resolution.y)
	$TabContainer/Interface/MarginContainer/VBoxContainer/ResolutionXHSlider.value = resolution.x
	$TabContainer/Interface/MarginContainer/VBoxContainer/ResolutionYHSlider.value = resolution.y
	
	var chatResolution = Global.settings["interface"]["chat resolution"]
	$TabContainer/Interface/MarginContainer/VBoxContainer/HBoxContainer2/ChatResolution.text = str(chatResolution.x)+" x "+str(chatResolution.y) 
	$TabContainer/Interface/MarginContainer/VBoxContainer/ChatResolutionXHSlider.value = chatResolution.x
	$TabContainer/Interface/MarginContainer/VBoxContainer/ChatResolutionYHSlider.value = chatResolution.y
	
	$TabContainer/Interface/MarginContainer/VBoxContainer/ThinkCheckButton.button_pressed = Global.settings["interface"]["think"]
	$TabContainer/Interface/MarginContainer/VBoxContainer/HBoxContainer3/ResponseCheckButton.button_pressed = Global.settings["interface"]["chunked"]
	$TabContainer/Interface/MarginContainer/VBoxContainer/HBoxContainer4/BorderCheckButton.button_pressed = Global.settings["interface"]["edges"]
	

func load_prompt_settings():
	$TabContainer/Prompt/MarginContainer/VBoxContainer/InstructionalPromptText.text = Global.settings["prompt"]["instructional prompt"]

func _on_save_button_pressed():
	Global.settings["ollama"]["model"] = $TabContainer/Ollama/MarginContainer/VBoxContainer/ItemList.get_item_text($TabContainer/Ollama/MarginContainer/VBoxContainer/ItemList.get_selected_items()[0])if $TabContainer/Ollama/MarginContainer/VBoxContainer/ItemList.get_selected_items().size() > 0 else ""
	Global.settings["ollama"]["server"] = $TabContainer/Ollama/MarginContainer/VBoxContainer/ServerEdit.text
	$TabContainer/Ollama/HTTPRequest.request(Global.settings["ollama"]["server"]+"api/tags")
	Global.save_config()


func _on_save_interface_button_pressed():
	Global.settings["interface"]["language"] = "en" if $TabContainer/Interface/MarginContainer/VBoxContainer/ItemList.get_selected_items()[0] == 0 else "es"
	Global.settings["interface"]["horizontal movement"] = $TabContainer/Interface/MarginContainer/VBoxContainer/CheckButtonHorizontal.button_pressed
	Global.settings["interface"]["vertical movement"] = $TabContainer/Interface/MarginContainer/VBoxContainer/CheckButtonVertical.button_pressed
	Global.settings["interface"]["timer"] = $TabContainer/Interface/MarginContainer/VBoxContainer/SpinBox.value
	var tmpResolutionx = $TabContainer/Interface/MarginContainer/VBoxContainer/ResolutionXHSlider.value
	var tmpResolutionY = $TabContainer/Interface/MarginContainer/VBoxContainer/ResolutionYHSlider.value
	Global.settings["interface"]["resolution"] = Vector2i(tmpResolutionx,tmpResolutionY)
	var tmpChatResolutionx = $TabContainer/Interface/MarginContainer/VBoxContainer/ChatResolutionXHSlider.value
	var tmpChatResolutionY = $TabContainer/Interface/MarginContainer/VBoxContainer/ChatResolutionYHSlider.value
	Global.settings["interface"]["chat resolution"] = Vector2i(tmpChatResolutionx,tmpChatResolutionY)
	Global.settings["interface"]["think"] = $TabContainer/Interface/MarginContainer/VBoxContainer/ThinkCheckButton.button_pressed
	Global.settings["interface"]["chunked"] = $TabContainer/Interface/MarginContainer/VBoxContainer/HBoxContainer3/ResponseCheckButton.button_pressed
	Global.settings["interface"]["edges"] = $TabContainer/Interface/MarginContainer/VBoxContainer/HBoxContainer4/BorderCheckButton.button_pressed
	Global.save_config()


func _on_draw():
	$TabContainer/Ollama/HTTPRequest.request(Global.settings["ollama"]["server"]+"api/tags")
	load_interface_settings()
	load_prompt_settings()
	load_tts_settings()
	load_3d_settings()


func _on_save_prompt_button_pressed():
	Global.settings["prompt"]["instructional prompt"] = $TabContainer/Prompt/MarginContainer/VBoxContainer/InstructionalPromptText.text
	Global.save_config()


func load_tts_settings():
	var voices = DisplayServer.tts_get_voices()
	
	if voices.size() > 0:
		
		var voices_list = $TabContainer/TTS/MarginContainer/VBoxContainer/VoicesItemList
		
		voices_list.clear()
		
		for voice in voices:
			var index = voices_list.add_item(voice["name"])
			voices_list.set_item_metadata(index, voice["id"])
		
		for i in range($TabContainer/TTS/MarginContainer/VBoxContainer/VoicesItemList.get_item_count()):
			if $TabContainer/TTS/MarginContainer/VBoxContainer/VoicesItemList.get_item_metadata(i) == Global.settings["tts"]["id"]:
				$TabContainer/TTS/MarginContainer/VBoxContainer/VoicesItemList.select(i)
				break
		
		$TabContainer/TTS/MarginContainer/VBoxContainer/CheckButton.button_pressed = Global.settings["tts"]["status"]
		$TabContainer/TTS/MarginContainer/VBoxContainer/RateHSlider.value = Global.settings["tts"]["rate"]
		$TabContainer/TTS/MarginContainer/VBoxContainer/PitchHSlider.value = Global.settings["tts"]["pitch"]
		$TabContainer/TTS/MarginContainer/VBoxContainer/VolumeHSlider.value = Global.settings["tts"]["volume"]
		$TabContainer/TTS/MarginContainer/VBoxContainer/TextEdit.text = Global.settings["tts"]["text"] if Global.settings["tts"]["text"] != "" else "Hello"
	
	else:
		$TabContainer/TTS/MarginContainer/VBoxContainer/CheckButton.disabled
		$TabContainer/TTS/MarginContainer/VBoxContainer/EmptyVoicesListLabel.show()
		$TabContainer/TTS/MarginContainer/VBoxContainer/HBoxContainer.hide()
		$TabContainer/TTS/MarginContainer/VBoxContainer/RateHSlider.hide()
		$TabContainer/TTS/MarginContainer/VBoxContainer/HBoxContainer2.hide()
		$TabContainer/TTS/MarginContainer/VBoxContainer/PitchHSlider.hide()
		$TabContainer/TTS/MarginContainer/VBoxContainer/HBoxContainer3.hide()
		$TabContainer/TTS/MarginContainer/VBoxContainer/VolumeHSlider.hide()

func _on_test_voice_button_pressed() -> void:
	var text = $TabContainer/TTS/MarginContainer/VBoxContainer/TextEdit.text
	var voice_selected = $TabContainer/TTS/MarginContainer/VBoxContainer/VoicesItemList.get_item_metadata($TabContainer/TTS/MarginContainer/VBoxContainer/VoicesItemList.get_selected_items()[0])if $TabContainer/TTS/MarginContainer/VBoxContainer/VoicesItemList.get_selected_items().size() > 0 else ""
	var rate = $TabContainer/TTS/MarginContainer/VBoxContainer/RateHSlider.value
	var pitch = $TabContainer/TTS/MarginContainer/VBoxContainer/PitchHSlider.value
	var volume = $TabContainer/TTS/MarginContainer/VBoxContainer/VolumeHSlider.value
	
	if text == "":
		$AcceptDialog.dialog_text = tr("ERROR EMPTY TEXT")
		$AcceptDialog.show()
	
	if voice_selected != "":
		DisplayServer.tts_speak(text,voice_selected,volume,pitch,rate)
	else:
		$AcceptDialog.dialog_text = tr("ERROR SELECTED VOICE")
		$AcceptDialog.show()


func _on_rate_h_slider_value_changed(value: float) -> void:
	$TabContainer/TTS/MarginContainer/VBoxContainer/HBoxContainer/Rate.text = str($TabContainer/TTS/MarginContainer/VBoxContainer/RateHSlider.value) + "x"


func _on_pitch_h_slider_value_changed(value: float) -> void:
	$TabContainer/TTS/MarginContainer/VBoxContainer/HBoxContainer2/Pitch.text = str($TabContainer/TTS/MarginContainer/VBoxContainer/PitchHSlider.value) + "x"


func _on_volume_h_slider_value_changed(value: float) -> void:
	$TabContainer/TTS/MarginContainer/VBoxContainer/HBoxContainer3/Volume.text = str($TabContainer/TTS/MarginContainer/VBoxContainer/VolumeHSlider.value) + "%" 


func _on_save_tts_button_pressed() -> void:
	var voice_selected = $TabContainer/TTS/MarginContainer/VBoxContainer/VoicesItemList.get_item_metadata($TabContainer/TTS/MarginContainer/VBoxContainer/VoicesItemList.get_selected_items()[0])if $TabContainer/TTS/MarginContainer/VBoxContainer/VoicesItemList.get_selected_items().size() > 0 else ""
	if $TabContainer/TTS/MarginContainer/VBoxContainer/CheckButton.button_pressed:
		if voice_selected != "":
			Global.settings["tts"]["status"] = $TabContainer/TTS/MarginContainer/VBoxContainer/CheckButton.button_pressed
		else:
			$AcceptDialog.dialog_text = tr("ERROR SELECTED VOICE")
			$AcceptDialog.show()
	else:
		Global.settings["tts"]["status"] = $TabContainer/TTS/MarginContainer/VBoxContainer/CheckButton.button_pressed
	
	Global.settings["tts"]["id"] = $TabContainer/TTS/MarginContainer/VBoxContainer/VoicesItemList.get_item_metadata($TabContainer/TTS/MarginContainer/VBoxContainer/VoicesItemList.get_selected_items()[0])if $TabContainer/TTS/MarginContainer/VBoxContainer/VoicesItemList.get_selected_items().size() > 0 else ""
	Global.settings["tts"]["rate"] = $TabContainer/TTS/MarginContainer/VBoxContainer/RateHSlider.value
	Global.settings["tts"]["volume"] = $TabContainer/TTS/MarginContainer/VBoxContainer/VolumeHSlider.value
	Global.settings["tts"]["pitch"] = $TabContainer/TTS/MarginContainer/VBoxContainer/PitchHSlider.value
	Global.settings["tts"]["text"] =$TabContainer/TTS/MarginContainer/VBoxContainer/TextEdit.text
	Global.save_config()

func load_3d_settings():
	
	var dir = DirAccess.open("res://Assets/Shaders")
	dir.list_dir_begin()
	var file_name = dir.get_next()
	while file_name != "":
		if file_name.ends_with(".gdshader"):
			$"TabContainer/3D/MarginContainer/VBoxContainer/ShaderOptionButton".add_item(file_name)
		file_name = dir.get_next()
	dir.list_dir_end()
	
	if Global.settings["model"]["shader"] == "None":
		$"TabContainer/3D/MarginContainer/VBoxContainer/ShaderOptionButton".selected = 0
	else:
		for i in range($"TabContainer/3D/MarginContainer/VBoxContainer/ShaderOptionButton".get_item_count()):
			if $"TabContainer/3D/MarginContainer/VBoxContainer/ShaderOptionButton".get_item_text(i) == Global.settings["model"]["shader"]:
				$"TabContainer/3D/MarginContainer/VBoxContainer/ShaderOptionButton".select(i)
				break
	
	if Global.settings["model"]["custom model"] != "":
		$"TabContainer/3D/MarginContainer/VBoxContainer/HBoxContainer2/CustomModelTextEdit".text = Global.settings["model"]["custom model"]
		$"TabContainer/3D/MarginContainer/VBoxContainer/HBoxContainer2".show()
	
	$"TabContainer/3D/MarginContainer/VBoxContainer/CameraXHSlider".value = Global.settings["model"]["camera x"]
	$"TabContainer/3D/MarginContainer/VBoxContainer/CameraYHSlider".value = Global.settings["model"]["camera y"]
	$"TabContainer/3D/MarginContainer/VBoxContainer/CameraZHSlider".value = Global.settings["model"]["camera z"]
	
	load_animations("res://Assets/3D/Demo/demo.glb" if Global.settings["model"]["custom model"] == "" else "user://"+Global.settings["model"]["custom model"])
	
	var option_buttons = get_tree().get_nodes_in_group("animation_option_button")
	var animation_setting_keys = ["walking","vertical", "idle","dragging","chat", "options"]
	for index in len(option_buttons):
		for i in range(option_buttons[index].get_item_count()):
			if option_buttons[index].get_item_text(i) == Global.settings["model"]["animation "+animation_setting_keys[index]]:
				option_buttons[index].select(i)
				break

func _on_save_3d_button_pressed():
	if $"TabContainer/3D/MarginContainer/VBoxContainer/ShaderOptionButton".get_selected_id() == 0:
		Global.settings["model"]["shader"] = "None"
	else:
		Global.settings["model"]["shader"] = $"TabContainer/3D/MarginContainer/VBoxContainer/ShaderOptionButton".get_item_text($"TabContainer/3D/MarginContainer/VBoxContainer/ShaderOptionButton".get_selected_id())
	
	Global.settings["model"]["custom model"] = $"TabContainer/3D/MarginContainer/VBoxContainer/HBoxContainer2/CustomModelTextEdit".text
	
	Global.settings["model"]["camera x"] = $"TabContainer/3D/MarginContainer/VBoxContainer/CameraXHSlider".value
	Global.settings["model"]["camera y"] = $"TabContainer/3D/MarginContainer/VBoxContainer/CameraYHSlider".value
	Global.settings["model"]["camera z"] = $"TabContainer/3D/MarginContainer/VBoxContainer/CameraZHSlider".value
	
	var option_buttons = get_tree().get_nodes_in_group("animation_option_button")
	var animation_setting_keys = ["walking","vertical", "idle","dragging","chat", "options"]
	for index in len(option_buttons):
		Global.settings["model"]["animation "+animation_setting_keys[index]] = option_buttons[index].get_item_text(option_buttons[index].get_selected_id())
	
	Global.save_config()
	
	await get_tree().create_timer(0.2).timeout
	get_tree().reload_current_scene()


func _on_file_dialog_file_selected(path):
	var file_name = path.get_file()
	var file_extension = path.get_extension()

	var file = FileAccess.open(path, FileAccess.READ)
	if (file_extension == "glb" or file_extension == "gltf") and file:
		var destination_path = "user://"+file_name
		var file_copy = FileAccess.open(destination_path, FileAccess.WRITE)
		if file_copy:
			var content = file.get_buffer(file.get_length()) 
			file_copy.store_buffer(content)
			file_copy.close()
			$"TabContainer/3D/MarginContainer/VBoxContainer/HBoxContainer2/CustomModelTextEdit".text = file_name
			$"TabContainer/3D/MarginContainer/VBoxContainer/HBoxContainer2".show()
			load_animations(destination_path)
		else:
			$AcceptDialog.dialog_text = tr("ERROR COPY MODEL")
			$AcceptDialog.show()
			file.close()
	else:
		$AcceptDialog.dialog_text = tr("ERROR MODEL FILE")
		$AcceptDialog.show()


func _on_select_button_pressed():
	$"TabContainer/3D/MarginContainer/VBoxContainer/FileDialog".show()

func _on_clear_button_pressed():
	var file_path = "user://"+$"TabContainer/3D/MarginContainer/VBoxContainer/HBoxContainer2/CustomModelTextEdit".text
	var dir_access = DirAccess.open(file_path.get_base_dir())
	if dir_access:
		dir_access.remove(file_path.get_file())
		dir_access = null
	$"TabContainer/3D/MarginContainer/VBoxContainer/HBoxContainer2/CustomModelTextEdit".text = ""
	$"TabContainer/3D/MarginContainer/VBoxContainer/HBoxContainer2".hide()
	Global.settings["model"]["custom model"] = $"TabContainer/3D/MarginContainer/VBoxContainer/HBoxContainer2/CustomModelTextEdit".text
	Global.save_config()


func _on_camera_xh_slider_value_changed(value):
	$"TabContainer/3D/MarginContainer/VBoxContainer/HBoxContainer3/X".text = str(value)
	var camera = get_parent().get_parent().get_node("Node3D/Camera3D")
	camera.position.x = value 


func _on_camera_yh_slider_value_changed(value):
	$"TabContainer/3D/MarginContainer/VBoxContainer/HBoxContainer4/Y".text = str(value)
	var camera = get_parent().get_parent().get_node("Node3D/Camera3D")
	camera.position.y = value 


func _on_camera_zh_slider_value_changed(value):
	$"TabContainer/3D/MarginContainer/VBoxContainer/HBoxContainer5/Z".text = str(value)
	var camera = get_parent().get_parent().get_node("Node3D/Camera3D")
	camera.position.z = value 

func load_animations(model_path):
	var gltf_doc = GLTFDocument.new()
	var gltf_state = GLTFState.new()

	var dir_access = DirAccess.open(model_path.get_base_dir())
	if dir_access:
		var error = gltf_doc.append_from_file(model_path, gltf_state)
		if error != OK:
			$AcceptDialog.dialog_text = tr("ERROR MODEL FILE" + str(error))
			$AcceptDialog.show()
			return
		
		var animations_array = gltf_state.animations
		var animation_count = animations_array.size()
		
		var option_buttons = get_tree().get_nodes_in_group("animation_option_button")
		
		if animation_count > 0:
			for option_button in option_buttons:
				option_button.clear()
				for i in range(animation_count):
					var gltf_animation = animations_array[i]
					var animation_name = gltf_animation.resource_name
					option_button.add_item(animation_name, i)
					option_button.select(0)
		else:
			$"TabContainer/3D/MarginContainer/VBoxContainer/HBoxContainer2/CustomModelTextEdit".text = ""
			$"TabContainer/3D/MarginContainer/VBoxContainer/HBoxContainer2".hide()
			$AcceptDialog.dialog_text = tr("ERROR EMPTY ANIMATIONS" + str(error))
			$AcceptDialog.show()


func _on_border_check_button_pressed():
	get_parent().get_parent().get_node("CanvasLayer").visible = $TabContainer/Interface/MarginContainer/VBoxContainer/HBoxContainer4/BorderCheckButton.button_pressed


func _on_hidden():
	get_parent().get_parent().get_node("CanvasLayer").visible = Global.settings["interface"]["edges"]
	DisplayServer.window_set_size(Global.settings["interface"]["resolution"])


func _on_resolution_xh_slider_value_changed(value):
	var tmpResolutionX = $TabContainer/Interface/MarginContainer/VBoxContainer/ResolutionXHSlider.value
	var tmpResolutionY = $TabContainer/Interface/MarginContainer/VBoxContainer/ResolutionYHSlider.value
	$TabContainer/Interface/MarginContainer/VBoxContainer/HBoxContainer/Resolution.text = str(tmpResolutionX) +" x "+ str(tmpResolutionY)
	DisplayServer.window_set_size(Vector2i(tmpResolutionX, tmpResolutionY))


func _on_resolution_yh_slider_value_changed(value):
	var tmpResolutionX = $TabContainer/Interface/MarginContainer/VBoxContainer/ResolutionXHSlider.value
	var tmpResolutionY = $TabContainer/Interface/MarginContainer/VBoxContainer/ResolutionYHSlider.value
	$TabContainer/Interface/MarginContainer/VBoxContainer/HBoxContainer/Resolution.text = str(tmpResolutionX) +" x "+ str(tmpResolutionY)
	DisplayServer.window_set_size(Vector2i(tmpResolutionX, tmpResolutionY))


func _on_resolution_chat_xh_slider_value_changed(value):
	var tmpChatResolutionX = $TabContainer/Interface/MarginContainer/VBoxContainer/ChatResolutionXHSlider.value
	var tmpChatResolutionY = $TabContainer/Interface/MarginContainer/VBoxContainer/ChatResolutionYHSlider.value
	$TabContainer/Interface/MarginContainer/VBoxContainer/HBoxContainer2/ChatResolution.text = str(tmpChatResolutionX)+" x "+str(tmpChatResolutionY) 


func _on_chat_resolution_yh_slider_value_changed(value):
	var tmpChatResolutionX = $TabContainer/Interface/MarginContainer/VBoxContainer/ChatResolutionXHSlider.value
	var tmpChatResolutionY = $TabContainer/Interface/MarginContainer/VBoxContainer/ChatResolutionYHSlider.value
	$TabContainer/Interface/MarginContainer/VBoxContainer/HBoxContainer2/ChatResolution.text = str(tmpChatResolutionX)+" x "+str(tmpChatResolutionY) 
