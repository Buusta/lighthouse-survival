class_name DevConsoleControl extends Control

var history: Array[String]

@export var line_edit: LineEdit
@export var rich_text_label: RichTextLabel
@export var suggestion_label: RichTextLabel

var depth: int = -1
var suggestion_index: int = -1
var cycling: bool = false
var current_suggestions: Array[String] = []

func _ready() -> void:
	DevConsole.output.connect(_console_written)

func _text_changed(input: String) -> void:
	if input.length() < 1:
		suggestion_label.text = ""
		return

	if cycling:
		return
	suggestion_index = -1

	var suggestions: Variant = DevConsole.get_suggestions(input)
	current_suggestions = suggestions
	var suggest_lines: String = ""
	for suggestion: String in suggestions:
		suggest_lines += (suggestion + "\n")

	suggestion_label.text = suggest_lines

func _edit_finished(input: String) -> void:
	DevConsole.execute(input)
	history.append(input)
	line_edit.text = ""
	suggestion_label.text = ""
	depth = 0

func _visible_changed() -> void:
	if visible:
		line_edit.grab_focus()
		line_edit.text = ""
		suggestion_label.text = ""
		depth = 0

func _input(event: InputEvent) -> void:
	if visible && line_edit.has_focus():
		if event.is_action_pressed("ui_up"):
			get_viewport().set_input_as_handled()
			if depth < history.size():
				depth += 1
				line_edit.text = history[history.size() - depth]
				line_edit.set_caret_column(line_edit.text.length())

		if event.is_action_pressed("ui_down"):
			get_viewport().set_input_as_handled()
			if depth > 0:
				depth -= 1
				if depth == 0:
					line_edit.text = ""
				else:
					line_edit.text = history[history.size() - depth]
					line_edit.set_caret_column(line_edit.text.length())

		if event.is_action_pressed("ui_focus_next"):
			get_viewport().set_input_as_handled()
			if current_suggestions.size() == 0:
				return
			cycling = true
			suggestion_index = (suggestion_index + 1) % current_suggestions.size()
			line_edit.text = current_suggestions[suggestion_index]
			line_edit.set_caret_column(line_edit.text.length())
			cycling = false

func _console_written(input: String) -> void:
	rich_text_label.append_text(input + "\n")
