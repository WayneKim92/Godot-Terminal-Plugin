@tool
extends Control

@onready var output = $VBoxContainer/Output
@onready var input = $VBoxContainer/Input
@onready var current_path_label = $VBoxContainer/CurrentPath

var current_path = _get_initial_path()
var command_history = []
var history_index = -1

func _ready():
	input.connect("text_submitted", _on_command_submitted)
	input.connect("gui_input", _on_input_gui_event)  # 입력 이벤트 감지
	update_current_path()

func _on_command_submitted(command: String) -> void:
	command = command.strip_edges()
	if command == "":
		return

	command_history.append(command)
	history_index = command_history.size()

	var tokens = command.split(" ")
	var cmd = tokens[0]
	var args = tokens.slice(1)

	if cmd == "cd":
		_change_directory(args)
	else:
		_execute_command(command)

	update_current_path()
	input.clear()

func _change_directory(args: Array) -> void:
	if args.is_empty():
		return

	var new_path = args[0]
	
	if new_path == "~":
		new_path = _get_initial_path()
	elif !new_path.begins_with("/"):
		new_path = current_path + "/" + new_path
	
	new_path = ProjectSettings.globalize_path(new_path)
	new_path = _resolve_absolute_path(new_path)
	
	if DirAccess.open(new_path) != null:
		current_path = new_path
	else:
		output.text += "\n[Error] Directory not found: " + new_path

func _execute_command(command: String) -> void:
	var result = []
	var shell_command = "cd \"%s\" && %s" % [current_path, command]
	var exit_code = OS.execute("/bin/sh", ["-c", shell_command], result, true)
	
	output.text = "\n".join(result)
	
	if exit_code != 0:
		output.text += "\n[Error] Exit code: %s" % exit_code

func update_current_path() -> void:
	current_path_label.text = current_path

func _on_input_gui_event(event: InputEvent) -> void:
	if event is InputEventKey and not input.has_focus():  # 입력창에서만 화살표 동작 방지
		if event.keycode == KEY_UP:
			if history_index > 0:
				history_index -= 1
				input.text = command_history[history_index]
				input.set_caret_column(input.text.length())
				input.caret_position = input.text.length()
				print("Key UP pressed, history_index: ", history_index)
		elif event.keycode == KEY_DOWN:
			if history_index < command_history.size() - 1:
				history_index += 1
				input.text = command_history[history_index]
				input.set_caret_column(input.text.length())
				input.caret_position = input.text.length()
				print("Key DOWN pressed, history_index: ", history_index)
			else:
				input.text = ""
				print("Key DOWN pressed, no more history")

func _get_initial_path() -> String:
	var result = []
	OS.execute("pwd", [], result, true)
	return _resolve_absolute_path(result[0].strip_edges() if result.size() > 0 else "/")

func _resolve_absolute_path(path: String) -> String:
	var result = []
	OS.execute("realpath", [path], result, true)
	return result[0].strip_edges() if result.size() > 0 else path
