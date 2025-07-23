extends Node

var config_file_path = "user://OLI-3D-config.cfg"
var config = ConfigFile.new()
var settings = {  
	"ollama": {
		"model": "",
		"server":"http://127.0.0.1:11434/"
	},
	"interface": {
		"language": "en",
		"horizontal movement": true,
		"vertical movement": false,
		"timer": 5,
		"resolution": Vector2i(120, 120),
		"chat scale": 2,
		"think": false,
		"chunked": true,
	},
	"prompt": {
		"instructional prompt": ""
	},
	"tts":{
		"status": false,
		"id": "",
		"volume": 50,
		"pitch": 1.0,
		"rate": 1.0,
		"text": "",
	}
}

func _ready():

	var english_translation = Translation.new()
	english_translation.set_locale("en")
	
	english_translation.add_message("MESSAGE", "Message")
	english_translation.add_message("SEND", "Send")
	english_translation.add_message("SETTINGS", "Settings")
	english_translation.add_message("EXIT", "Exit")
	
	english_translation.add_message("MODEL", "Model")
	english_translation.add_message("SERVER", "Server")
	english_translation.add_message("Interface", "Interface")
	english_translation.add_message("LANGUAGE", "Language")
	english_translation.add_message("HORIZONTAL", "Horizontal Movement")
	english_translation.add_message("VERTICAL", "Vertical Movement")
	english_translation.add_message("TIMER", "Idle time (Seconds)")
	english_translation.add_message("RESOLUTION", "Resolution")
	english_translation.add_message("SCALE", "Chat scale")
	english_translation.add_message("SHOWTHINK", "Show thinking")
	english_translation.add_message("CHUNKED RESPONSE", "Response by chunks")
	english_translation.add_message("COMPLETE RESPONSE", "Complete response")
	english_translation.add_message("THINK", "Think: ")
	english_translation.add_message("RESPONSE", "Response: ")
	english_translation.add_message("TTS STATUS", "Responses with TTS(Text To Speech)")
	english_translation.add_message("RATE", "Rate ")
	english_translation.add_message("PITCH", "Pitch ")
	english_translation.add_message("VOLUME", "Volume ")
	english_translation.add_message("TEST VOICE", "Test voice")
	english_translation.add_message("VOICES LIST EMPTY", "Si eres usuario linux, tu sistema necesita bibliotecas (speech-dispatcher festival espeakup) para que TTS funcione.")
	english_translation.add_message("ERROR EMPTY TEXT", "Text is empty")
	english_translation.add_message("ERROR SELECTED VOICE", "Select a voice from the list")
	english_translation.add_message("SAVE", "Save")
	
	english_translation.add_message("ERROR JSON", "JSON parse error: ")
	english_translation.add_message("ERROR RESPONSE", "Connection to Ollama failed. \nMake sure it is installed and/or configure the server in the settings menu. \nError code: ")
	english_translation.add_message("EMPTY", "Prompt is empty")
	english_translation.add_message("ERROR MODEL", "No model is selected \nSelect one from the settings menu.")
	
	english_translation.add_message("INSTRUCTIONAL PROMPT","Instructional Prompt")
	english_translation.add_message("INSTRUCTIONAL PROMPT TEXT","A brief and clear instruction used to guide the AI and generate appropriate responses. For example: \nYou are a translator. Translate this sentence from Spanish to English:")
	
	TranslationServer.add_translation(english_translation)


	var spanish_translation = Translation.new()
	spanish_translation.set_locale("es")
	
	spanish_translation.add_message("MESSAGE", "Mensaje")
	spanish_translation.add_message("SEND", "Enviar")
	spanish_translation.add_message("SETTINGS", "Opciones")
	spanish_translation.add_message("EXIT", "Salir")
	
	spanish_translation.add_message("MODEL", "Modelo")
	spanish_translation.add_message("SERVER", "Servidor")
	spanish_translation.add_message("Interface", "Interfaz")
	spanish_translation.add_message("LANGUAGE", "Idioma")
	spanish_translation.add_message("HORIZONTAL", "Movimiento Horizontal")
	spanish_translation.add_message("VERTICAL", "Movimiento Vertical")
	spanish_translation.add_message("TIMER", "Tiempo inactivo (Segundos)")
	spanish_translation.add_message("RESOLUTION", "Resolución")
	spanish_translation.add_message("SCALE", "Escala del chat")
	spanish_translation.add_message("SHOWTHINK", "Mostrar pensamiento")
	spanish_translation.add_message("CHUNKED RESPONSE", "Respuesta por partes")
	spanish_translation.add_message("COMPLETE RESPONSE", "Respuesta completa")
	spanish_translation.add_message("THINK", "Pensamiento: ")
	spanish_translation.add_message("RESPONSE", "Respuesta: ")
	spanish_translation.add_message("TTS STATUS", "Respuestas con TTS (Texto a Voz)")
	spanish_translation.add_message("RATE", "Velocidad")
	spanish_translation.add_message("PITCH", "Tono")
	spanish_translation.add_message("VOLUME", "Volumen")
	spanish_translation.add_message("TEST VOICE", "Probar voz")
	spanish_translation.add_message("VOICES LIST EMPTY", "Si eres usuario de Linux, tu sistema necesita bibliotecas (speech-dispatcher, festival, espeakup) para que TTS funcione.")
	spanish_translation.add_message("ERROR EMPTY TEXT", "El texto está vacío")
	spanish_translation.add_message("ERROR SELECTED VOICE", "Selecciona una voz de la lista")
	spanish_translation.add_message("SAVE", "Guardar")
	
	spanish_translation.add_message("ERROR JSON", "Error al analizar JSON: ")
	spanish_translation.add_message("ERROR RESPONSE", "No se ha podido conectar con Ollama. \nAsegúrese de que está instalado y/o configure el servidor en el menú de opciones. \nCódigo de error: ")
	spanish_translation.add_message("EMPTY", "El promp está vacío")
	spanish_translation.add_message("ERROR MODEL", "No hay ningún modelo seleccionado \nSeleccione uno en el menú de opciones")
	
	spanish_translation.add_message("INSTRUCTIONAL PROMPT","Mensaje de orientación/Instructional Prompt")
	spanish_translation.add_message("INSTRUCTIONAL PROMPT TEXT","Una instrucción breve y clara utilizada para guiar a la IA y generar respuestas adecuadas. Por ejemplo: \nEres un traductor. Traduce esta frase del inglés al español: ")
	
	TranslationServer.add_translation(spanish_translation)


func save_config():
	for category in settings.keys():
		for key in settings[category].keys():
			config.set_value(category, key, settings[category][key])
	config.save(config_file_path)
	TranslationServer.set_locale(settings["interface"]["language"])
	DisplayServer.window_set_size(settings["interface"]["resolution"])


func load_config():
	if config.load(config_file_path) == OK:
		for category in settings.keys():
			if config.has_section(category):
				for key in settings[category].keys():
					settings[category][key] = config.get_value(category, key, settings[category][key])
		TranslationServer.set_locale(settings["interface"]["language"])
		DisplayServer.window_set_size(settings["interface"]["resolution"])
		
	else:
		save_config()
