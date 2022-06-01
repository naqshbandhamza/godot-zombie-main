extends CanvasLayer


# Declare member variables here. Examples:
# var a: int = 2
# var b: String = "text"



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$AnimationPlayer.play("gameoverslidein")


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
#	pass


func _on_restart_pressed() -> void:
	Global.replay1 = true
	#get_tree().change_scene("res://src/main.tscn")
	get_tree().reload_current_scene()



