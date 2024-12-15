@tool
extends EditorPlugin

const LOGGER : String = "Logger"

var _http : HTTPRequest = null
var _version : String = ""
var _url : String = "https://raw.githubusercontent.com/Healleu/Logger/main/addons/Logger/plugin.cfg"

func _enter_tree() -> void :
	# Het plugin current version
	_version = get_plugin_version()
	
	# Request lastest plugin version in Github
	_http = HTTPRequest.new()
	call_deferred("add_child", _http)
	await _http.ready
	_http.request_completed.connect(_on_http_request_request_completed)
	_http.request(_url)
	
	# Initialize
	
	add_autoload_singleton(LOGGER, "logger.gd")
	_set_plugin_settings()

	print("Logger System v" + _version + " initialized!")
	return


func _exit_tree() -> void :
	# Deinitialize
	remove_autoload_singleton(LOGGER)
	return

## Called when the request to the repository is completed, parses the config file and sets the newest version.
func _on_http_request_request_completed(result : int, response_code : int, headers : PackedStringArray, body : PackedByteArray):
	var config = ConfigFile.new()
	var err = config.parse(body.get_string_from_ascii())
	if err == OK :
		if config.has_section_key("plugin", "version") :
			var newest_version : Variant = config.get_value("plugin", "version")
			config.clear()
			if newest_version > _version :
				print("New version of Logger is available!")
				print("actual : " + _version + " / lastest : " + newest_version)
				_http.call_deferred("queue_free")
			return
	
	print("Fail to get the lastest version of Logger")
	_http.call_deferred("queue_free")
	return

func _set_plugin_settings() -> void :
	ProjectSettings.set_setting("Plugin/Logger/log_level", 0)
	var log_level = {
		"name": "Plugin/Logger/log_level",
		"type": TYPE_INT,
		"hint": PROPERTY_HINT_ENUM,
		"hint_string": "INFO,DEBUG,WARNING,ERROR"
	}
	ProjectSettings.add_property_info(log_level)
	# Timestamp
	ProjectSettings.set_setting("Plugin/Logger/timestamp", true)
	var timestamp_info = {
		"name": "Plugin/Logger/timestamp",
		"type": TYPE_BOOL
	}
	ProjectSettings.add_property_info(timestamp_info)
	# Color info
	ProjectSettings.set_setting("Plugin/Logger/info_color", Color.WHITE)
	var info_color = {
		"name": "Plugin/Logger/info_color",
		"type": TYPE_COLOR
	}
	ProjectSettings.add_property_info(info_color)
	
	# Color info
	ProjectSettings.set_setting("Plugin/Logger/warning_color", Color.YELLOW)
	var warning_color = {
		"name": "Plugin/Logger/warning_color",
		"type": TYPE_COLOR
	}
	ProjectSettings.add_property_info(warning_color)
	
	# Color info
	ProjectSettings.set_setting("Plugin/Logger/error_color", Color.RED)
	var error_color = {
		"name": "Plugin/Logger/error_color",
		"type": TYPE_COLOR
	}
	ProjectSettings.add_property_info(error_color)
