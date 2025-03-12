@tool
extends Control

@onready var output = $VBoxContainer/Output
@onready var input = $VBoxContainer/Input

var current_path = _get_initial_path()  # 초기 디렉토리 설정
var command_history = []
var history_index = -1

func _ready():
	input.connect("text_submitted", _on_command_submitted)
	update_prompt()

func _on_command_submitted(command):
	if command.strip_edges() == "":
		return

	command_history.append(command)
	history_index = len(command_history)  # 마지막 입력 위치로 설정
	
	output.text += "\n> " + command

	var tokens = command.split(" ")
	var cmd = tokens[0]
	var args = tokens.slice(1)

	if cmd == "cd":
		_change_directory(args)
	else:
		_execute_command(command)

	update_prompt()
	input.clear()

func _change_directory(args):
	if args.size() == 0:
		return

	var new_path = args[0]
	
	# 홈 디렉토리 처리
	if new_path == "~":
		new_path = _get_initial_path()
	elif new_path.begins_with("/"):
		# 절대 경로
		pass
	else:
		# 상대 경로 → 절대 경로 변환
		new_path = current_path + "/" + new_path  # plus_file() 대신 "/" 결합

	# 유효한 디렉토리인지 확인 후 이동
	if DirAccess.dir_exists_absolute(new_path):
		current_path = new_path
	else:
		output.text += "\n[Error] Directory not found: " + new_path

func _execute_command(command):
	var result = []
	var shell_command = "cd \"%s\" && %s" % [current_path, command]  # 현재 경로 유지
	var exit_code = OS.execute("/bin/sh", ["-c", shell_command], result, true)

	if result.size() > 0:
		output.text += "\n" + "\n".join(result)

	if exit_code != 0:
		output.text += "\n[Error] Exit code: %s" % exit_code

func update_prompt():
	var username = OS.get_environment("USER") if OS.has_environment("USER") else "user"
	var hostname = OS.get_environment("HOSTNAME") if OS.has_environment("HOSTNAME") else "machine"
	output.text += "\n%s@%s:%s$ " % [username, hostname, current_path]

func _unhandled_input(event):
	if event is InputEventKey:
		if event.pressed:
			if event.keycode == KEY_UP:
				if history_index > 0:
					history_index -= 1
					input.text = command_history[history_index]
					input.caret_column = input.text.length()
			elif event.keycode == KEY_DOWN:
				if history_index < len(command_history) - 1:
					history_index += 1
					input.text = command_history[history_index]
					input.caret_column = input.text.length()
				else:
					input.text = ""

func _get_initial_path() -> String:
	var result = []
	OS.execute("pwd", [], result, true)
	if result.size() > 0:
		var path = result[0].strip_edges()
		var dir = DirAccess.open(path)
		if dir != null:
			dir.change_dir("..")
			return dir.get_current_dir()
	return "/"
