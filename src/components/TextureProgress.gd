extends TextureProgress


# Declare member variables here. Examples:
# var a: int = 2
# var b: String = "text"
signal timebartimeout
onready var value1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	value=100
	value1 = 1

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
#	pass
func _on_Timer_timeout() -> void:
	value-=1
	if value==0 and value1==1:
		value1=0
		emit_signal("timebartimeout")
		
