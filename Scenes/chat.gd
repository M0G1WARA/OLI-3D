extends Control

var url: String = "api/generate"
var headersPOST = ["Content-Type: application/json"]
var data = {
		"model": "",
		"prompt": ""
	}
var think:bool = false


func response_by_chunk():
	var err = 0
	var http_client = HTTPClient.new()
	
	var parts = Global.settings["ollama"]["server"].rsplit(":", false, 1)
	
	if parts.size() == 2:
		err = http_client.connect_to_host(parts[0],int(parts[1]))
		assert(err == OK)
	else:
		err = http_client.connect_to_host("http://127.0.0.1", 11434)
		return

	while http_client.get_status() == HTTPClient.STATUS_CONNECTING or http_client.get_status() == HTTPClient.STATUS_RESOLVING:
		http_client.poll()
		await get_tree().process_frame
	assert(http_client.get_status() == HTTPClient.STATUS_CONNECTED)

	var body = JSON.stringify(data)
	err = http_client.request(HTTPClient.METHOD_POST, "/api/generate", headersPOST, body)
	assert(err == OK) 

	while http_client.get_status() == HTTPClient.STATUS_REQUESTING:
		http_client.poll()
		await get_tree().process_frame
		
	assert(http_client.get_status() == HTTPClient.STATUS_BODY or http_client.get_status() == HTTPClient.STATUS_CONNECTED)
	
	if http_client.has_response() and http_client.is_response_chunked():

		var rb = PackedByteArray()
		
		while http_client.get_status() == HTTPClient.STATUS_BODY:
			http_client.poll()
			var chunk = http_client.read_response_body_chunk()
			var chunk_str = chunk.get_string_from_utf8()
			if chunk.size() == 0:
				await get_tree().process_frame
			else:
				rb = rb + chunk
				var json = JSON.new()
				var chunk_json = json.parse(chunk_str)
				if chunk_json == OK:
					var data_received = json.get_data().get("response", "")
					if data_received=='<think>':
						think = true
					
					if think:
						$VBoxContainer/Think.text += data_received
					else:
						$VBoxContainer/Response.text += data_received
						
					if data_received=='</think>':
						think = false
				
				else:
					$AcceptDialog.dialog_text = tr("ERROR JSON") +json.error
		
		if Global.settings["tts"]["status"]:
			DisplayServer.tts_speak($VBoxContainer/Response.text,Global.settings["tts"]["id"],Global.settings["tts"]["volume"],Global.settings["tts"]["pitch"],Global.settings["tts"]["rate"])
		
		http_client.close()
		$VBoxContainer/SendButton.disabled = false
		$VBoxContainer/SendButton/ProgressBar.hide()




func _on_http_request_request_completed(_result, response_code, _headers, body):

	if response_code == 200:
		var response_text = body.get_string_from_utf8()
		var lines = response_text.split("\n")
		
		var json = JSON.new()
		
		
		for line in lines:
			if line.strip_edges() != "":
				var json_result = json.parse(line)
				if json_result == OK:
					var data_received = json.data
					
					if data_received.response=='<think>':
						think = true
					
					if think:
						$VBoxContainer/Think.text += data_received.response
					else:
						$VBoxContainer/Response.text += data_received.response
						
					if data_received.response=='</think>':
						think = false
					
				else:
					$AcceptDialog.dialog_text = tr("ERROR JSON") + str(json.get_error_message())
					$AcceptDialog.show()
				
		if Global.settings["tts"]["status"]:
							DisplayServer.tts_speak($VBoxContainer/Response.text,Global.settings["tts"]["id"],Global.settings["tts"]["volume"],Global.settings["tts"]["pitch"],Global.settings["tts"]["rate"])
	else:
		$AcceptDialog.dialog_text = tr("ERROR RESPONSE") + str(response_code)
		$AcceptDialog.show()
	
	$VBoxContainer/SendButton.disabled = false
	$VBoxContainer/SendButton/ProgressBar.hide()

func _on_prompt_text_changed():
	data["prompt"] = Global.settings["prompt"]["instructional prompt"] + $VBoxContainer/Prompt.text


func _on_send_button_pressed():
	if $VBoxContainer/Prompt.text =="":
		$AcceptDialog.dialog_text = "EMPTY"
		$AcceptDialog.show()
	else:
		if Global.settings["ollama"]["model"] != "":
			$VBoxContainer/SendButton.disabled = true
			$VBoxContainer/SendButton/ProgressBar.show()
			data["model"] = Global.settings["ollama"]["model"]
			$VBoxContainer/Response.clear()
			var json = JSON.stringify(data)
			if Global.settings["interface"]["chunked"]:
				response_by_chunk()
			else:
				$HTTPRequest.request(Global.settings["ollama"]["server"]+url, headersPOST, HTTPClient.METHOD_POST, json)
		else:
			$AcceptDialog.dialog_text = tr("ERROR MODEL")
			$AcceptDialog.show()


func _on_draw():
	if Global.settings["interface"]["think"]:
		$VBoxContainer/ThinkLabel.show()
		$VBoxContainer/Think.show()
		$VBoxContainer/ResponseLabel.show()
	else:
		$VBoxContainer/ThinkLabel.hide()
		$VBoxContainer/Think.hide()
		$VBoxContainer/ResponseLabel.hide()
