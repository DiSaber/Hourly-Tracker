extends Control

@export var start_stop_button: TextureButton
@export var play_texture: Texture2D
@export var pause_texture: Texture2D
@export var last_earnings_label: Label
@export var last_time_label: Label
@export var total_earned_label: Label
@export var total_time_label: Label
@export var hourly_wage_input: SpinBox

var start_stop_toggle = false
var state = {
	hourly_wage = 0.0,
	total_time = 0.0,
	total_earned = 0.0,
	last_time = 0.0,
	last_timestamp = -1.0,
	last_earned = 0.0
}


func _ready():
	DisplayServer.window_set_min_size(Vector2i(960, 540))
	load_state()
	
	var time_difference = last_timestamp()
	last_earnings_label.text = "$%.3f" % (state.last_earned + ((time_difference / 3600.0) * state.hourly_wage))
	last_time_label.text = format_seconds(state.last_time + time_difference)
	
	total_earned_label.text = "$%.3f total" % (state.total_earned + ((time_difference / 3600.0) * state.hourly_wage))
	total_time_label.text = format_seconds(state.total_time + time_difference)
	
	hourly_wage_input.set_value_no_signal(state.hourly_wage)
	
	if state.last_timestamp > 0:
		start_stop_toggle = true
		start_stop_button.texture_normal = pause_texture


func _process(_delta):
	var time_difference = last_timestamp()
	last_earnings_label.text = "$%.3f" % (state.last_earned + ((time_difference / 3600.0) * state.hourly_wage))
	last_time_label.text = format_seconds(state.last_time + time_difference)
	
	total_earned_label.text = "$%.3f total" % (state.total_earned + ((time_difference / 3600.0) * state.hourly_wage))
	total_time_label.text = format_seconds(state.total_time + time_difference)


func _on_start_stop_button_pressed():
	if start_stop_toggle:
		var time_difference = last_timestamp()
		state.last_time += time_difference
		state.last_earned += (time_difference / 3600.0) * state.hourly_wage
		
		state.total_time += time_difference
		state.total_earned += (time_difference / 3600.0) * state.hourly_wage
		
		state.last_timestamp = -1
		
		save_state()
		
		
		last_earnings_label.text = "$%.3f" % state.last_earned
		last_time_label.text = format_seconds(state.last_time)
		
		total_earned_label.text = "$%.3f total" % state.total_earned
		total_time_label.text = format_seconds(state.total_time)
	
		start_stop_toggle = false
		start_stop_button.texture_normal = play_texture
	else:
		state.last_timestamp = Time.get_unix_time_from_system()
		
		save_state()
		
		start_stop_toggle = true
		start_stop_button.texture_normal = pause_texture


func save_state():
	var save_file = FileAccess.open("user://user.data", FileAccess.WRITE)
	save_file.store_line(JSON.stringify(state))

func load_state():
	if not FileAccess.file_exists("user://user.data"):
		return
	
	var save_file = FileAccess.open("user://user.data", FileAccess.READ)
	state = JSON.parse_string(save_file.get_line())


func format_seconds(total_seconds: float) -> String:
	var seconds = fmod(total_seconds, 60.0)
	var minutes = int(total_seconds / 60.0) % 60
	var hours = int(total_seconds / 3600.0)
	
	return "%02d:%02d:%05.2f" % [hours, minutes, seconds]


func last_timestamp() -> float:
	if state.last_timestamp > 0:
		return Time.get_unix_time_from_system() - state.last_timestamp
	else:
		return 0


func _on_hourly_wage_value_changed(value):
	state.hourly_wage = value
	save_state()


func _on_reset_button_pressed():
	state.last_time = 0.0
	state.last_earned = 0.0
	state.last_timestamp = -1
	
	save_state()
	
	start_stop_toggle = false
	start_stop_button.texture_normal = play_texture


func _on_clear_button_pressed():
	state.total_earned = 0.0
	state.total_time = 0.0
	
	save_state()
