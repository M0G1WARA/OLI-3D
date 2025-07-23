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
	
	var resolution = Global.settings["interface"]["resolution"].x
	$TabContainer/Interface/MarginContainer/VBoxContainer/HBoxContainer/Resolution.text = str(resolution) +" x "+ str(resolution)
	$TabContainer/Interface/MarginContainer/VBoxContainer/ResolutionHSlider.value = resolution
	
	var chatScale = Global.settings["interface"]["chat scale"]
	$TabContainer/Interface/MarginContainer/VBoxContainer/HBoxContainer2/Scale.text = str(chatScale)+" ("+str(chatScale*resolution)+" x "+str(chatScale*resolution)+")" 
	$TabContainer/Interface/MarginContainer/VBoxContainer/ScaleHSlider.value = Global.settings["interface"]["chat scale"]
	
	$TabContainer/Interface/MarginContainer/VBoxContainer/ThinkCheckButton.button_pressed = Global.settings["interface"]["think"]
	$TabContainer/Interface/MarginContainer/VBoxContainer/HBoxContainer3/ResponseCheckButton.button_pressed = Global.settings["interface"]["chunked"]
	

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
	var tmpResolution = $TabContainer/Interface/MarginContainer/VBoxContainer/ResolutionHSlider.value
	Global.settings["interface"]["resolution"] = Vector2i(tmpResolution,tmpResolution)
	Global.settings["interface"]["chat scale"] = $TabContainer/Interface/MarginContainer/VBoxContainer/ScaleHSlider.value
	Global.settings["interface"]["think"] = $TabContainer/Interface/MarginContainer/VBoxContainer/ThinkCheckButton.button_pressed
	Global.settings["interface"]["chunked"] = $TabContainer/Interface/MarginContainer/VBoxContainer/HBoxContainer3/ResponseCheckButton.button_pressed
	Global.save_config()


func _on_resolution_h_slider_value_changed(value):
	var tmpScale = $TabContainer/Interface/MarginContainer/VBoxContainer/ScaleHSlider.value
	$TabContainer/Interface/MarginContainer/VBoxContainer/ScaleHSlider.emit_signal("value_changed",tmpScale)
	var tmpResolution = str($TabContainer/Interface/MarginContainer/VBoxContainer/ResolutionHSlider.value)
	$TabContainer/Interface/MarginContainer/VBoxContainer/HBoxContainer/Resolution.text = tmpResolution +" x "+ tmpResolution


func _on_scale_h_slider_value_changed(value):
	var tmpResolution = $TabContainer/Interface/MarginContainer/VBoxContainer/ResolutionHSlider.value
	var tmpScale = $TabContainer/Interface/MarginContainer/VBoxContainer/ScaleHSlider.value
	$TabContainer/Interface/MarginContainer/VBoxContainer/HBoxContainer2/Scale.text = str(tmpScale)+" ("+str(tmpScale*tmpResolution)+" x "+str(tmpScale*tmpResolution)+")" 


func _on_draw():
	$TabContainer/Ollama/HTTPRequest.request(Global.settings["ollama"]["server"]+"api/tags")
	load_interface_settings()
	load_prompt_settings()
	load_tts_settings()


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
	Global.settings["tts"]["status"] = $TabContainer/TTS/MarginContainer/VBoxContainer/CheckButton.button_pressed
	Global.settings["tts"]["id"] = $TabContainer/TTS/MarginContainer/VBoxContainer/VoicesItemList.get_item_metadata($TabContainer/TTS/MarginContainer/VBoxContainer/VoicesItemList.get_selected_items()[0])if $TabContainer/TTS/MarginContainer/VBoxContainer/VoicesItemList.get_selected_items().size() > 0 else ""
	Global.settings["tts"]["rate"] = $TabContainer/TTS/MarginContainer/VBoxContainer/RateHSlider.value
	Global.settings["tts"]["volume"] = $TabContainer/TTS/MarginContainer/VBoxContainer/VolumeHSlider.value
	Global.settings["tts"]["pitch"] = $TabContainer/TTS/MarginContainer/VBoxContainer/PitchHSlider.value
	Global.settings["tts"]["text"] =$TabContainer/TTS/MarginContainer/VBoxContainer/TextEdit.text
	Global.save_config()
