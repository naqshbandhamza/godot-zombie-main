extends Node

var up = false
var down = true
var right= true
var left = true
var level = 0
var lastmove=''
var motionpause = false

var frame_h
var frame_w

signal checkthisoption

func move_right():
	if right and not( $Sprite.position.y < get_parent().rect_size.y+45 and $Sprite.position.y > Global.all_woods[0].position.y+45 or
	$Sprite.position.y< Global.all_woods[0].position.y+28 and  $Sprite.position.y > Global.all_woods[1].position.y+45 or
	$Sprite.position.y< Global.all_woods[1].position.y+28 and  $Sprite.position.y > Global.all_woods[2].position.y+45 ):
		get_node("Sprite").set_flip_h( false )
		$AnimationPlayer.current_animation="move_right"
		if $Sprite.position.x+2 < get_parent().rect_size.x+100:
			lastmove='r'
			$Sprite.position.x+=2
	
		
func move_left():
	if left and not( $Sprite.position.y < get_parent().rect_size.y+45 and $Sprite.position.y > Global.all_woods[0].position.y+45 or
	$Sprite.position.y< Global.all_woods[0].position.y+28 and  $Sprite.position.y > Global.all_woods[1].position.y+45 or
	$Sprite.position.y< Global.all_woods[1].position.y+28 and  $Sprite.position.y > Global.all_woods[2].position.y+45):
		get_node("Sprite").set_flip_h( true)
		$AnimationPlayer.current_animation="move_left"
		if $Sprite.position.x-2 > 170:
			lastmove='l'
			$Sprite.position.x-=2
		
	
			
			
func get_myrunner_current_level():
	if $Sprite.position.y< get_parent().rect_size.y+100 and  $Sprite.position.y > Global.all_woods[0].position.y+60:
		return 0
	elif $Sprite.position.y< Global.all_woods[0].position.y+60 and  $Sprite.position.y > Global.all_woods[1].position.y+60:
		return 1
	elif $Sprite.position.y< Global.all_woods[1].position.y+60 and  $Sprite.position.y > Global.all_woods[2].position.y+60:
		return 2
	elif $Sprite.position.y< Global.all_woods[2].position.y+60 and  $Sprite.position.y > 0 :
		return 3
	
	return -1
			
			
func move_up():
	
	if Global.doorflag:
		
		Global.doorflag=false
		if Global.all_doors[0].get_node("RichTextLabel").text!='':
			emit_signal("checkthisoption",Global.all_doors[0].get_node("RichTextLabel").text,0)
			return
	elif Global.door2flag:
		Global.door2flag=false
		if Global.all_doors[1].get_node("RichTextLabel").text!='':
			emit_signal("checkthisoption",Global.all_doors[1].get_node("RichTextLabel").text,1)
			return
	elif Global.door3flag:
		Global.door3flag=false
		if Global.all_doors[2].get_node("RichTextLabel").text!='':
			emit_signal("checkthisoption",Global.all_doors[2].get_node("RichTextLabel").text,2)
			return
	elif Global.door4flag:
		Global.door4flag=false
		if Global.all_doors[3].get_node("RichTextLabel").text!='':
			emit_signal("checkthisoption",Global.all_doors[3].get_node("RichTextLabel").text,3)
			return
	elif Global.door5flag:
		Global.door5flag=false
		if Global.all_doors[4].get_node("RichTextLabel").text!='':
			emit_signal("checkthisoption",Global.all_doors[4].get_node("RichTextLabel").text,4)
			return
	
	if up:
		if (get_node("Sprite").position.x>= Global.all_ladders[0].position.x+90 and get_node("Sprite").position.x<=Global.all_ladders[0].position.x+200
		or get_node("Sprite").position.x>= Global.all_ladders[1].position.x+90 and get_node("Sprite").position.x<=Global.all_ladders[1].position.x+200
		or get_node("Sprite").position.x>= Global.all_ladders[2].position.x+90 and get_node("Sprite").position.x<=Global.all_ladders[2].position.x+200
		or get_node("Sprite").position.x>= Global.all_ladders[3].position.x+90 and get_node("Sprite").position.x<=Global.all_ladders[3].position.x+200
		or get_node("Sprite").position.x>= Global.all_ladders[4].position.x+90 and get_node("Sprite").position.x<=Global.all_ladders[4].position.x+200):
			#get_node("Sprite").set_flip_h( false )
			if get_node("Sprite").position.x>= Global.all_ladders[0].position.x+90 and get_node("Sprite").position.x<=Global.all_ladders[0].position.x+160:
				if get_node("Sprite").position.y< Global.all_ladders[0].position.y-30:
					$AnimationPlayer.current_animation="get_upladder"
					$Sprite.position.y-=8
				else:
					if lastmove=='l':
						$Sprite.position.x = Global.all_ladders[0].position.x+154
					elif lastmove=='r':
						$Sprite.position.x = Global.all_ladders[0].position.x+130
					"""
					if get_node("Sprite").position.y+125 < Global.all_ladders[0].position.y-50+172:
						$AnimationPlayer.current_animation="get_upladder"
						while(up):
							$Sprite.position.y-=1
							yield(get_tree().create_timer(0.02), "timeout")
							
					else:
						$AnimationPlayer.current_animation="move_up"
						$Sprite.position.y-=2
						"""
					$AnimationPlayer.current_animation="move_up"
					$Sprite.position.y-=2
				#print($Sprite.position)
				#print(Global.all_ladders[0].position)
			elif get_node("Sprite").position.x>= Global.all_ladders[1].position.x+90 and get_node("Sprite").position.x<=Global.all_ladders[1].position.x+160:
				if get_node("Sprite").position.y< Global.all_ladders[1].position.y-30:
					$AnimationPlayer.current_animation="get_upladder"
					$Sprite.position.y-=8
				else:
					if lastmove=='l':
						$Sprite.position.x = Global.all_ladders[1].position.x+154
					elif lastmove=='r':
						$Sprite.position.x = Global.all_ladders[1].position.x+130
					$AnimationPlayer.current_animation="move_up"
					$Sprite.position.y-=2
			elif get_node("Sprite").position.x>= Global.all_ladders[2].position.x+90 and get_node("Sprite").position.x<=Global.all_ladders[2].position.x+160:
				if get_node("Sprite").position.y< Global.all_ladders[2].position.y-30:
					$AnimationPlayer.current_animation="get_upladder"
					$Sprite.position.y-=8
				else:
					if lastmove=='l':
						$Sprite.position.x = Global.all_ladders[2].position.x+154
					elif lastmove=='r':
						$Sprite.position.x = Global.all_ladders[2].position.x+130
					$AnimationPlayer.current_animation="move_up"
					$Sprite.position.y-=2
			elif get_node("Sprite").position.x>= Global.all_ladders[3].position.x+90 and get_node("Sprite").position.x<=Global.all_ladders[3].position.x+160:
				if get_node("Sprite").position.y< Global.all_ladders[3].position.y-30:
					$AnimationPlayer.current_animation="get_upladder"
					$Sprite.position.y-=8
				else:
					if lastmove=='l':
						$Sprite.position.x = Global.all_ladders[3].position.x+154
					elif lastmove=='r':
						$Sprite.position.x = Global.all_ladders[3].position.x+130
					$AnimationPlayer.current_animation="move_up"
					$Sprite.position.y-=2
			elif get_node("Sprite").position.x>= Global.all_ladders[4].position.x+90 and get_node("Sprite").position.x<=Global.all_ladders[4].position.x+160:
				if get_node("Sprite").position.y< Global.all_ladders[4].position.y-30:
					$AnimationPlayer.current_animation="get_upladder"
					$Sprite.position.y-=8
				else:
					if lastmove=='l':
						$Sprite.position.x = Global.all_ladders[4].position.x+154
					elif lastmove=='r':
						$Sprite.position.x = Global.all_ladders[4].position.x+130
					$AnimationPlayer.current_animation="move_up"
					$Sprite.position.y-=2
			
			lastmove='u'
	
	
func move_down():
	if( ($Sprite.position.y< get_parent().rect_size.y+45 and  $Sprite.position.y > Global.all_woods[0].position.y+40 and down) or
	($Sprite.position.y< Global.all_woods[0].position.y+45 and  $Sprite.position.y > Global.all_woods[1].position.y+40 and down) or
	($Sprite.position.y<= Global.all_woods[1].position.y+40 and  $Sprite.position.y > Global.all_woods[2].position.y+40 and down) or
	($Sprite.position.y< Global.all_woods[2].position.y+60 and  $Sprite.position.y > 0 and down)):
		if (get_node("Sprite").position.x>= Global.all_ladders[0].position.x+90 and get_node("Sprite").position.x<=Global.all_ladders[0].position.x+200 and
		get_node("Sprite").position.y>= Global.all_ladders[0].position.y-98 and get_node("Sprite").position.y<=Global.all_ladders[0].position.y+150 
		or get_node("Sprite").position.x>= Global.all_ladders[1].position.x+90 and get_node("Sprite").position.x<=Global.all_ladders[1].position.x+200 and
		get_node("Sprite").position.y>= Global.all_ladders[1].position.y-98 and get_node("Sprite").position.y<=Global.all_ladders[1].position.y+130 
		or get_node("Sprite").position.x>= Global.all_ladders[2].position.x+90 and get_node("Sprite").position.x<=Global.all_ladders[2].position.x+200 and 
		get_node("Sprite").position.y>= Global.all_ladders[2].position.y-98 and get_node("Sprite").position.y<=Global.all_ladders[2].position.y+130
		or get_node("Sprite").position.x>= Global.all_ladders[3].position.x+90 and get_node("Sprite").position.x<=Global.all_ladders[3].position.x+200 and 
		get_node("Sprite").position.y>= Global.all_ladders[3].position.y-98 and get_node("Sprite").position.y<=Global.all_ladders[3].position.y+150 
		or get_node("Sprite").position.x>= Global.all_ladders[4].position.x+90 and get_node("Sprite").position.x<=Global.all_ladders[4].position.x+200 and 
		get_node("Sprite").position.y>= Global.all_ladders[4].position.y-98 and get_node("Sprite").position.y<=Global.all_ladders[4].position.y+130 ):
			
			if get_node("Sprite").position.x>= Global.all_ladders[0].position.x+90 and get_node("Sprite").position.x<=Global.all_ladders[0].position.x+160:
				if lastmove=='l':
					$Sprite.position.x = Global.all_ladders[0].position.x+154
				elif lastmove=='r':
					$Sprite.position.x = Global.all_ladders[0].position.x+130
				#if get_node("Sprite").position.y+125 < Global.all_ladders[0].position.y-50+172:
				#get_node("Sprite").position.y< Global.all_ladders[0].position.y-30
				if get_node("Sprite").position.y+125 < Global.all_ladders[0].position.y-50+172:
					$AnimationPlayer.current_animation="get_downladder"
					var count = 0
					while(count < 4):
						$Sprite.position.y+=2
						count+=1
						#yield(get_tree().create_timer(0.1), "timeout")
				else:
					
					$AnimationPlayer.current_animation="move_up"
					$Sprite.position.y+=2
			elif get_node("Sprite").position.x>= Global.all_ladders[1].position.x+90 and get_node("Sprite").position.x<=Global.all_ladders[1].position.x+160:
				if lastmove=='l':
					$Sprite.position.x = Global.all_ladders[1].position.x+154
				elif lastmove=='r':
					$Sprite.position.x = Global.all_ladders[1].position.x+130
				
				if get_node("Sprite").position.y+125 < Global.all_ladders[1].position.y-50+172:
					$AnimationPlayer.current_animation="get_downladder"
					var count = 0
					while(count < 4):
						$Sprite.position.y+=2
						count+=1
						#yield(get_tree().create_timer(0.1), "timeout")
				else:
					
					$AnimationPlayer.current_animation="move_up"
					$Sprite.position.y+=2
			elif get_node("Sprite").position.x>= Global.all_ladders[2].position.x+90 and get_node("Sprite").position.x<=Global.all_ladders[2].position.x+160:
				if lastmove=='l':
					$Sprite.position.x = Global.all_ladders[2].position.x+154
				elif lastmove=='r':
					$Sprite.position.x = Global.all_ladders[2].position.x+130
				
				if get_node("Sprite").position.y+125 < Global.all_ladders[2].position.y-50+172:
					$AnimationPlayer.current_animation="get_downladder"
					var count = 0
					while(count < 4):
						$Sprite.position.y+=2
						count+=1
						#yield(get_tree().create_timer(0.1), "timeout")
				else:
					
					$AnimationPlayer.current_animation="move_up"
					$Sprite.position.y+=2
			elif get_node("Sprite").position.x>= Global.all_ladders[3].position.x+90 and get_node("Sprite").position.x<=Global.all_ladders[3].position.x+160:
				if lastmove=='l':
					$Sprite.position.x = Global.all_ladders[3].position.x+154
				elif lastmove=='r':
					$Sprite.position.x = Global.all_ladders[3].position.x+130
				
				if get_node("Sprite").position.y+125 < Global.all_ladders[3].position.y-50+172:
					$AnimationPlayer.current_animation="get_downladder"
					var count = 0
					while(count < 4):
						$Sprite.position.y+=2
						count+=1
						#yield(get_tree().create_timer(0.1), "timeout")
				else:
					
					$AnimationPlayer.current_animation="move_up"
					$Sprite.position.y+=2
			elif get_node("Sprite").position.x>= Global.all_ladders[4].position.x+90 and get_node("Sprite").position.x<=Global.all_ladders[4].position.x+160:
				if lastmove=='l':
					$Sprite.position.x = Global.all_ladders[4].position.x+154
				elif lastmove=='r':
					$Sprite.position.x = Global.all_ladders[4].position.x+130
				
				if get_node("Sprite").position.y+125 < Global.all_ladders[4].position.y-50+172:
					$AnimationPlayer.current_animation="get_downladder"
					var count = 0
					while(count < 4):
						$Sprite.position.y+=2
						count+=1
						#yield(get_tree().create_timer(0.1), "timeout")
				else:
					
					$AnimationPlayer.current_animation="move_up"
					$Sprite.position.y+=2
			
			lastmove='d'

func update():
	if Input.is_key_pressed(KEY_RIGHT) or Global.c=='r':
		move_right()
	elif  Input.is_key_pressed(KEY_LEFT) or Global.c=='l':
		move_left()
	elif Input.is_key_pressed(KEY_UP) or Global.c=='u':
		move_up()
	elif Input.is_key_pressed(KEY_DOWN) or Global.c=='d':
		move_down()
		
	if Input.is_action_just_released("ui_right") and not(up):
		
		$AnimationPlayer.current_animation = 'RESET'
		
	if Input.is_action_just_released("ui_left") and not(up):
		$AnimationPlayer.current_animation = 'RESET'

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	frame_h = $Sprite.texture.get_height()/$Sprite.hframes
	frame_w = $Sprite.texture.get_width()/$Sprite.vframes
	pass # Replace with function body.
	set_physics_process(true)

func _physics_process(delta: float) -> void:
	if not(motionpause):
		update()
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
#	pass

signal zombiekill

func _on_runerr_area_entered(area: Area2D) -> void:
	if area.get_name()=='withzombie':
		emit_signal("zombiekill")
