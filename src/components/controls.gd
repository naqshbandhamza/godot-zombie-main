extends Node


# Declare member variables here. Examples:
# var a: int = 2
# var b: String = "text"


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
#	pass


signal l
signal r
signal u
signal d


signal arup
signal alup
signal auup
signal adup



func _on_rightbtn_button_down() -> void:
	Global.c='r'


func _on_rightbtn_button_up() -> void:
	Global.c='none'
	emit_signal("arup")


func _on_leftbtn_button_down() -> void:
	Global.c='l'


func _on_leftbtn_button_up() -> void:
	Global.c='none'
	emit_signal("alup")


func _on_upbtn_button_down() -> void:
	Global.c='u'


func _on_upbtn_button_up() -> void:
	Global.c='none'
	emit_signal("auup")


func _on_downbtn_button_down() -> void:
	Global.c = 'd'
	


func _on_downbtn_button_up() -> void:
	Global.c = 'none'
	emit_signal("adup")
