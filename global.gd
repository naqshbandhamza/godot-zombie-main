extends Node


# Declare member variables here. Examples:
# var a: int = 2
# var b: String = "text"

var all_ladders = []
var all_woods = []
var all_doors = []

var replay = false
var replay1 = false
var buffer = [] 
var visited = []
var downfirst = true

var doorflag = false
var door2flag= false
var door3flag= false
var door4flag= false
var door5flag= false
var c = 'none'
var donce = false


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
#	pass
