extends Node


var up = false
var down = false
var inair = false
# Declare member variables here. Examples:
# var a: int = 2
# var b: String = "text"

var collidewithladder = false
var lastmove

func get_myrunner_current_level():
	if $Sprite.position.y< get_parent().rect_size.y+120 and  $Sprite.position.y > Global.all_woods[0].position.y+100:
		return 0
	elif $Sprite.position.y< Global.all_woods[0].position.y+100 and  $Sprite.position.y > Global.all_woods[1].position.y+100:
		#print( Global.all_woods[0].position.y+100)
		#print($Sprite.position.y)
		return 1
	elif $Sprite.position.y< Global.all_woods[1].position.y+100 and  $Sprite.position.y > Global.all_woods[2].position.y+100:
		return 2
	elif $Sprite.position.y< Global.all_woods[2].position.y+100 and  $Sprite.position.y > 0 :
		return 3
	return -1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
#	pass
