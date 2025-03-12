@tool
extends EditorPlugin

var terminal_dock

func _enter_tree():
	# 플러그인이 로드될 때 실행
	terminal_dock = preload("res://addons/terminal/terminal_dock.tscn").instantiate()
	add_control_to_bottom_panel(terminal_dock, "Terminal")

func _exit_tree():
	# 플러그인이 제거될 때 실행
	remove_control_from_bottom_panel(terminal_dock)
	terminal_dock.queue_free()
