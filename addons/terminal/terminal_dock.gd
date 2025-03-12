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

	output.text += "\n> " + command  # 입력한 명령어 추가

	if cmd == "cd":
		_change_directory(args)
	else:
		_execute_command(command)

	update_current_path()
	input.clear()
	
	await get_tree().process_frame
	output.scroll_vertical = output.get_v_scroll_bar().max_value


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
	
	output.text += "\n" + "\n".join(result)  # 기존 출력에 추가
	
	if exit_code != 0:
		output.text += "\n[Error] Exit code: %s" % exit_code

func update_current_path() -> void:
	current_path_label.text = current_path

func _get_initial_path() -> String:
	var result = []
	OS.execute("pwd", [], result, true)
	return _resolve_absolute_path(result[0].strip_edges() if result.size() > 0 else "/")

func _resolve_absolute_path(path: String) -> String:
	var result = []
	OS.execute("realpath", [path], result, true)
	return result[0].strip_edges() if result.size() > 0 else path
