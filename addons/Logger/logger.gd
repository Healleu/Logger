extends Node

enum LOG_LEVEL
{
	INFO,
	DEBUG,
	WARNING,
	ERROR,
}

var file : FileAccess = null

var level : LOG_LEVEL = LOG_LEVEL.INFO

func _enter_tree() -> void :
	var datetime = _get_string_date_time_no_special()
	var project_name = ProjectSettings.get_setting("application/config/name")
	file = FileAccess.open("user://" + project_name + "_" + datetime + ".txt", FileAccess.WRITE_READ)
	if file :
		var version : Variant = ProjectSettings.get_setting("application/config/version")
		file.store_string(project_name + "\n")
		file.store_string("Version : " + str(version) + "\n")
		file.store_string("Logging Level : " + str(level) + "\n")
		file.store_string("\n")
		file.store_string("---- Logging start ----")
		file.store_string("\n")
	else :
		push_error("Fail to start logging")
	return

func info(msg : String) -> void :
	if file :
		var log_header : String = _get_string_date_time()
		log_header += " INFO "
		file.store_string(log_header + msg + "\n")
	return
	
func debug(msg : String) -> bool :
	if file and OS.is_debug_build() :
		var log_header : String = _get_string_date_time()
		log_header += " DEBUG "
		file.store_string(log_header + msg + "\n")
	return true
	
func warning(msg : String) -> void :
	if file :
		var log_header : String = _get_string_date_time()
		log_header += " WARNING "
		file.store_string(log_header + msg + "\n")
	return
	
func error(msg : String) -> void :
	if file :
		var log_header : String = _get_string_date_time()
		log_header += " ERROR "
		file.store_string(log_header + msg + "\n")
	return
	

func _get_string_date_time() -> String :
	var datetime_dict : Dictionary = Time.get_datetime_dict_from_system(true)
	var date : String = "%02d/%02d/%02d" % [datetime_dict.year, datetime_dict.month, datetime_dict.day]
	var time : String = "%02d:%02d:%02d" % [datetime_dict.hour, datetime_dict.minute, datetime_dict.second]
	return date + "-" + time

func _get_string_date_time_no_special() -> String :
	var datetime_dict : Dictionary = Time.get_datetime_dict_from_system(true)
	var date : String = "%02d_%02d_%02d" % [datetime_dict.year, datetime_dict.month, datetime_dict.day]
	var time : String = "%02d_%02d_%02d" % [datetime_dict.hour, datetime_dict.minute, datetime_dict.second]
	return date + "_" + time

func _exit_tree() -> void :
	file.close()
	return
