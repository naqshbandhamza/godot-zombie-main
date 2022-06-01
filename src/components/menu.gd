extends Control


# Declare member variables here. Examples:
# var a: int = 2
# var b: String = "text"


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	get_tree().paused = true


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
#	pass


func _on_start_pressed() -> void:
	$AnimationPlayer.play("gamestartslidein")
	$Timer.set_wait_time(0.7)
	$Timer.start()
	





func _on_quit_pressed() -> void:
	get_tree().quit()


func _on_Timer_timeout() -> void:
	get_tree().paused = false
	get_tree().queue_delete(self)
