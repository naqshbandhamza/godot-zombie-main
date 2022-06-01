extends Node

onready var gamecontrols = preload("res://src/components/controls.tscn")
onready var Choices = preload("res://src/components/Choices.tscn")
onready var Question = preload("res://src/components/Questions.tscn")
onready var Progress = preload("res://src/components/TextureProgressBar.tscn")
onready var ScoreNode = preload("res://src/components/Score.tscn")
onready var Live = preload("res://src/components/Lives.tscn")
onready var goverfor = preload("res://src/components/gameover.tscn")
onready var menuover = preload("res://src/components/menu.tscn")
onready var Zombie = preload("res://src/zombie.tscn") 
onready var reload = false

var gcontrols
var gchoices
var gquestion
var gprogress
var gscore
var glives
var gameovercalled
var json_data
var json_url
var mylang
var nolives
onready var pathj = "user://data.data"
var dataj
var timelimit
var questions
var noqs
var current_q
var score
var userid
var token
var correctanswered
var gameflag
var game_control
var m_over
var gover
var jflag
var options
var current_zombie_level
var current_runner_level
var zombie_pause = false

var default_json_data = {
"questions": [
{
"question": "1 + 1 = _____",
"options": [
{ "value": "2", "correct": "true" },
{ "value": "3", "correct": "false" },
{ "value": "4", "correct": "false" },
{ "value": "5", "correct": "false" }
],
"score": 10
},
{
"question": "1 + 2",
"options": [
{ "value": "2", "correct": "false" },
{ "value": "3", "correct": "true" },
{ "value": "4", "correct": "false" },
{ "value": "5", "correct": "false" }
],
"score": 20
}
,
{
	"question": "3 + 2",
	"options": [
	{ "value": "2", "correct": "false" },
	{ "value": "3", "correct": "false" },
	{ "value": "4", "correct": "false" },
	{ "value": "5", "correct": "true" }
	],
	"score": 20
	}
	,
{
"question": "6 + 2",
"options": [
{ "value": "2", "correct": "false" },
{ "value": "3", "correct": "false" },
{ "value": "8", "correct": "true" },
{ "value": "5", "correct": "false" }
],
"score": 20
}
,
{
"question": "1 + 2",
"options": [
{ "value": "2", "correct": "false" },
{ "value": "3", "correct": "true" },
{ "value": "4", "correct": "false" },
{ "value": "5", "correct": "false" }
],
"score": 20
}
],
"userId": 1,
"token": "xxxyyy",
"noOfLife": 3,
"timeLimit": 120
}

onready var Runner_Scn = preload("res://src/runner.tscn")
var runner
var zombie
var withzombie
var withrunner
onready var Withzombie = preload("res://src/gowithzombie.tscn")
var thread
var move_down_once_called = false
var move_up_once_called = false
# Declare member variables here. Examples:
# var a: int = 2
# var b: String = "text"

func getrandom():
	var nums = [1,2,3,4,5,6,7,8,9,10] #list to choose from
	randomize()
	var N = nums[randi() % nums.size()]
	while N in Global.visited:
		randomize()
		N = nums[randi() % nums.size()]
	if Global.visited.size()==9:
		Global.visited = []
	Global.visited.push_back(N)
	return N	
	
func get_range(ranges_already_gain):
	randomize()
	var my_c_i = int(rand_range(0,4))
	while ranges_already_gain[my_c_i]==true:
		randomize()
		my_c_i = int(rand_range(0,4))
	ranges_already_gain[my_c_i]=true
	return my_c_i

func set_info_box_value():
	
	if  str(score).length()==2:
		gscore.get_node("Score-bg/score").text = "  "+str(score)
	elif str(score).length()==1:
		gscore.get_node("Score-bg/score").text = "   "+str(score)
	else:
		gscore.get_node("Score-bg/score").text = str(score)
	glives.get_node("holder/lives").text = 'X '+str(nolives)
	gquestion.get_node("question").text = questions[current_q]['question']
	gchoices.get_node("holder/choice1").text = 'A) '+questions[current_q]['options'][0]['value']
	gchoices.get_node("holder/choice2").text = 'B) '+questions[current_q]['options'][1]['value']
	gchoices.get_node("holder/choice3").text = 'C) '+questions[current_q]['options'][2]['value']
	gchoices.get_node("holder/choice4").text = 'D) '+questions[current_q]['options'][3]['value']
	
func save_final_data():
	var file = File.new()
	file.open("user://save.data",File.WRITE)
	var mystoredata = {"current question":current_q,"correct answered":correctanswered,
	'score':score,'nolives':nolives,'current file':str(json_url),'current file data':json_data,
	'current timer value':gprogress.get_node("ProgressBar").value}
	file.store_var(mystoredata)
	file.close()	

func reset_info_box_value():
	if  str(score).length()==2:
		gscore.get_node("Score-bg/score").text = "  "+str(score)
	elif str(score).length()==1:
		gscore.get_node("Score-bg/score").text = "   "+str(score)
	else:
		gscore.get_node("Score-bg/score").text = str(score)
	glives.get_node("holder/lives").text = 'X 0'
	gquestion.get_node("question").text = ' '
	gchoices.get_node("holder/choice1").text = ' '
	gchoices.get_node("holder/choice2").text = ' '
	gchoices.get_node("holder/choice3").text = ' '
	gchoices.get_node("holder/choice4").text = ' '

func load_data():
	var file = File.new()
	if not(file.file_exists(pathj)):
		file.open(pathj,File.WRITE)
		file.store_var(default_json_data)
		file.close()
		
	if json_data!=null:
		pass
	else:
		file.open(pathj,file.READ)
		dataj = file.get_var()
		file.close()	
		
	if json_data!=null:
		nolives = json_data['noOfLife']
		timelimit = json_data['timeLimit']
		questions = json_data['questions']
		
		gprogress.get_node("ProgressBar/Timer").set_wait_time(float(json_data['timeLimit'])/100)
		gprogress.get_node("ProgressBar/Timer").start()
		noqs = questions.size()
		current_q=0
		set_info_box_value()
	else:
		
		nolives = dataj['noOfLife']
		timelimit = dataj['timeLimit']
		userid = dataj['userId']
		token = dataj['token']
		questions = dataj['questions']
		
		gprogress.get_node("ProgressBar/Timer").set_wait_time(float(dataj['timeLimit'])/100)
		gprogress.get_node("ProgressBar/Timer").start()
		noqs = questions.size()
		current_q=0
		set_info_box_value()
	if file.file_exists("user://save.data"):
		var tempdataj
		file.open("user://save.data",file.READ)
		tempdataj = file.get_var()
		current_q = tempdataj['current question']
		correctanswered = tempdataj['correct answered']
		score = tempdataj['score']
		nolives = tempdataj['nolives']
		gprogress.get_node("ProgressBar").value = int(tempdataj['current timer value'])
		set_info_box_value()
	else:
		save_final_data()
		set_info_box_value()
		
func load_data1():
	var file = File.new()
	if not(file.file_exists("user://save.data")) or Global.replay==false:
		Global.replay = true
		file.open("user://save.data",File.WRITE)
		file.store_var({"current question":0,"correct answered":0,
	'score':0,'nolives':3,'current file':json_url,'current file data':null,'current timer value':100})
		file.close()
	
	file.open("user://save.data",file.READ)
	dataj = file.get_var()
	file.close()
	nolives = dataj['nolives']
	if nolives<3:
		if OS.has_feature('JavaScript'):
			json_url = dataj['current file']
			json_data = dataj['current file data']

func spawn_option():
	
	if gameflag==false:
		return
	
	for i in range(0,5):
		Global.all_doors[i].get_node("RichTextLabel").text = ''	
		
	var ranges_already_gain = [false,false,false,false,false]
	var temp
	for i in range(0,4):
		randomize()
		temp = randi()%5
		while ranges_already_gain[temp]:
			randomize()
			temp = randi()%5
		ranges_already_gain[temp]=true
		if i==0:
			Global.all_doors[temp].get_node("RichTextLabel").text = 'A'
		elif i==1:
			Global.all_doors[temp].get_node("RichTextLabel").text = 'B'
		elif i==2:
			Global.all_doors[temp].get_node("RichTextLabel").text = 'C'
		elif i==3:
			Global.all_doors[temp].get_node("RichTextLabel").text='D'
		
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	thread = Thread.new()
	current_zombie_level=0
	jflag=false
	runner = Runner_Scn.instance()
	get_node("main-game-board").add_child(runner)
	#$"main-game-board".add_child(runner)
	runner.get_node("Sprite").position.y = $"main-game-board".rect_size.y+45
	runner.get_node("Sprite").position.x = 700
	#runner.get_node("Sprite").position.x = 0+198
	#runner.get_node("Sprite").position.y = 0+172
	
	
	
	zombie = Zombie.instance()
	get_node("main-game-board").add_child(zombie)
	zombie.get_node("Sprite").position.y = $"main-game-board".rect_size.y +110
	zombie.get_node("Sprite").position.x = 450
	
	
	
	
	
	
	
	runner.connect("zombiekill",self,"zombie_kill")
	
	withzombie = Withzombie.instance()
	
	get_node("main-game-board").add_child(withzombie)
	
	withzombie.rect_position = Vector2(zombie.get_node("Sprite").position.x-220,zombie.get_node("Sprite").position.y-220)
	
	
	Global.all_ladders=[]
	Global.all_ladders.append($"main-game-board/ladder")
	Global.all_ladders.append($"main-game-board/ladder2")
	Global.all_ladders.append($"main-game-board/ladder3")
	Global.all_ladders.append($"main-game-board/ladder4")
	Global.all_ladders.append($"main-game-board/ladder5")
	Global.all_woods=[]
	Global.all_woods.append($"main-game-board/wood")
	Global.all_woods.append($"main-game-board/wood2")
	Global.all_woods.append($"main-game-board/wood3")
	Global.all_doors = []
	Global.all_doors.append($"main-game-board/door")
	Global.all_doors.append($"main-game-board/door2")
	Global.all_doors.append($"main-game-board/door3")
	Global.all_doors.append($"main-game-board/door4")
	Global.all_doors.append($"main-game-board/door5")
	
	#$"main-game-board/ColorRect2".rect_position = Vector2(Global.all_ladders[4].position.x,Global.all_ladders[4].position.y-50)
	
	#zombie.get_node("Sprite").position.y = Global.all_woods[2].position.y+100
	
	#$ColorRect.rect_position = Vector2(zombie.get_node("Sprite").position.x,zombie.get_node("Sprite").position.y+56)
	
	runner.connect("checkthisoption",self,"check_question_validaty")
	
	
	if Global.replay:
		pass
	else:
		Global.replay = true
	
	
	gchoices = Choices.instance()
	gquestion = Question.instance()
	gprogress = Progress.instance()
	gscore = ScoreNode.instance()
	glives = Live.instance()
	glives.get_node("AnimationPlayer").current_animation="liveanim"
	
	add_child(gprogress)
	add_child(gquestion)
	add_child(gscore)
	add_child(glives)
	
	
		
	
	gquestion.get_node("question").visible = false
	add_child(gchoices)
	
	gchoices.get_node("holder/choice1").visible = false
	gchoices.get_node("holder/choice2").visible = false
	gchoices.get_node("holder/choice3").visible = false
	gchoices.get_node("holder/choice4").visible = false	
	gameovercalled = false
	
	json_data= null
	json_url = null
	mylang = null
	load_data1()
	
	if OS.has_feature('JavaScript') and nolives==3:
		json_url =  JavaScript.eval(""" 
			  const queryString = window.location.search;
	  const urlParams = new URLSearchParams(queryString);
	  const id = urlParams.get("id");
	  const server = urlParams.get("server");
	  const userId = urlParams.get("userId");
	  const token = urlParams.get("token");
	  let thereturn = null;
	  const score = 100;
	  function sendResult() {
		console.log("sendResult");
		var formData = new FormData();
		formData.append("paperId", id);
		formData.append("score", score);
		formData.append("userId", userId);
		formData.append("token", token);

		var xhr = new XMLHttpRequest();
		// xhr.withCredentials=true
		xhr.open("POST", server + "/api/submitGameResult");
		xhr.send(formData);
		xhr.onreadystatechange = function () {
		  // If the request completed, close the extension popup
		  if (this.readyState == 4)
			if (this.status == 200) {
			  const response = JSON.parse(this.response);
			  console.log(response);

			  if (response.success) {
				// result submission succefully
				console.log("success");
			  } else {
				console.log("fail");
			  }
			}
		};
	  }
	  var getJSON = function (url, callback) {
		var xhr = new XMLHttpRequest();
		xhr.open("GET", url, true);
		xhr.responseType = "json";
		xhr.onload = function () {
		  var status = xhr.status;
		  if (status === 200) {
			callback(null, xhr.response);
		  } else {
			callback(status, xhr.response);
		  }
		};
		xhr.send();
	  };
	  function getRandomArbitrary(min, max) {
		
		return Math.random() * (max - min) + min;
	  }
	  let file_num = parseInt(getRandomArbitrary(1, 11));
	  
	thereturn = server + "/game/" + id + "/" + file_num.toString() + ".json";
	thereturn = server + "/game/" + id + "/";
	thereturn = "https://demo-backend.learning-canvas.com"+"/game/"+46+"/";
		""")
	#thereturn = "https://demo-backend.learning-canvas.com"+"/game/"+46+"/";
		mylang =  JavaScript.eval(""" 
			  const queryString = window.location.search;
	  const urlParams = new URLSearchParams(queryString);
	  let temp = urlParams.get("lang");
	  
	  temp; 
	   """)
	
	if json_url!=null and json_data==null:
		
		if OS.has_feature('JavaScript') and Global.buffer.size()==0 and Global.replay1==false:
			
			
			
			$HTTPRequest.request(json_url+str(getrandom())+".json")
			
		else:
			if Global.buffer.size()==0:
				json_data = default_json_data
			else:
				json_data = Global.buffer.pop_front()
			load_data()
			if OS.has_feature('JavaScript') :
				$HTTPRequest2.request(json_url+str(getrandom())+".json")
			
				
	get_tree().paused = false
	var temp_pos = Vector2(0,0)
	
	correctanswered=0
	load_data1()
	
	if json_url==null:
		load_data()
	if json_data!=null:
		load_data()
	
	
	gameflag = true
	gprogress.get_node("ProgressBar").connect("timebartimeout",self,"timebar_runout")
	
	
	if nolives==3 and Global.replay1==false:
		m_over = menuover.instance()
		add_child(m_over)
		
		if mylang=='zh':
			m_over.get_node("CanvasLayer2/Start-box/ReferenceRect/RichTextLabel").text='開始遊戲'
		else:
			m_over.get_node("CanvasLayer2/Start-box/ReferenceRect/RichTextLabel").text=' START'
		m_over.get_node("CanvasLayer/Area2D/CollisionShape2D").set_z_index(9)
		if OS.has_feature('JavaScript'):
			m_over.get_node("CanvasLayer2/Start-box/start").disabled = true
	
	if Global.replay1:
		get_tree().paused = false
	
	gcontrols = gamecontrols.instance()
	
	
	
	add_child(gcontrols)
	
	gcontrols.connect("alup",self,"resetanim")
	gcontrols.connect("arup",self,"resetanim")
	
	spawn_option()
	
	set_physics_process(true)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
#	pass

func resetanim():
	runner.get_node("AnimationPlayer").current_animation = 'RESET'

func getlevelfordoor(num):
	if num==0:
		return 0
	elif num==1:
		return 1
	elif num==2 or num==3:
		return 2
	elif num==4:
		return 3
	return -1

func check_question_validaty(txt='p',io=-1):
	#print("in validity")
	gprogress.get_node("ProgressBar/Timer").paused = true
	runner.motionpause = true
	var qflag = false
	var temp_runner_level=-1
	if io!=-1:
		if io==0:
			temp_runner_level=0
		elif io==1:
			temp_runner_level=1
		elif io==2 or io==3:
			temp_runner_level=2
		elif io==4:
			temp_runner_level=3
	if io==0:
		$"main-game-board/AnimationPlayer".current_animation='dooranim'
	elif io==1:
		$"main-game-board/AnimationPlayer".current_animation='dooranim1'
	elif io==2:
		$"main-game-board/AnimationPlayer".current_animation='dooranim2'
	elif io==3:
		$"main-game-board/AnimationPlayer".current_animation='dooranim3'
	elif io==4:
		$"main-game-board/AnimationPlayer".current_animation='dooranim4'
		
	
	yield(get_tree().create_timer(0.5), "timeout")
	runner.get_node("Sprite").visible = false
	yield(get_tree().create_timer(0.4), "timeout")	
	spawn_option()
		
	var newappeardoor = randi()%5
	while getlevelfordoor(newappeardoor)==current_zombie_level or getlevelfordoor(newappeardoor)==temp_runner_level:
		newappeardoor = randi()%5
		
	if newappeardoor==0:
		runner.get_node("Sprite").position.y = $"main-game-board".rect_size.y +45
		runner.get_node("Sprite").position.x = $"main-game-board/door".position.x+140
		$"main-game-board/AnimationPlayer".current_animation='dooranim'
	elif newappeardoor==1:
		runner.get_node("Sprite").position.y = $"main-game-board/wood".position.y +36
		runner.get_node("Sprite").position.x = $"main-game-board/door2".position.x+140
		$"main-game-board/AnimationPlayer".current_animation='dooranim1'
	elif newappeardoor==2:
		runner.get_node("Sprite").position.y = $"main-game-board/wood2".position.y +36
		runner.get_node("Sprite").position.x = $"main-game-board/door3".position.x+140
		$"main-game-board/AnimationPlayer".current_animation='dooranim2'
	elif newappeardoor==3:
		runner.get_node("Sprite").position.y = $"main-game-board/wood2".position.y +36
		runner.get_node("Sprite").position.x = $"main-game-board/door4".position.x+140
		$"main-game-board/AnimationPlayer".current_animation='dooranim3'
	elif newappeardoor==4:
		runner.get_node("Sprite").position.y = $"main-game-board/wood3".position.y +36
		runner.get_node("Sprite").position.x = $"main-game-board/door5".position.x+140
		$"main-game-board/AnimationPlayer".current_animation='dooranim4'
	yield(get_tree().create_timer(0.5), "timeout")
	
	runner.get_node("Sprite").visible = true
	
	var prev_score = score
	
	if current_q < questions.size():
		var iscorrect = ''
		if txt=='A':
			if json_data==null:
				#when not on web and on godot engine
				if dataj['questions'][current_q]['options'][0]['correct']=="true":
					score+=dataj['questions'][current_q]['score']
					correctanswered+=1
					iscorrect = 'A'
					gscore.get_node("AnimationPlayer").current_animation = "scoreanim"
			else:
				#when online on web
				if json_data['questions'][current_q]['options'][0]['correct']=="true":
					score+=int(json_data['questions'][current_q]['score'])
					correctanswered+=1
					iscorrect = 'A'
					gscore.get_node("AnimationPlayer").current_animation = "scoreanim"
		elif txt=='B':
			if json_data==null:
				if dataj['questions'][current_q]['options'][1]['correct']=="true":
					score+=dataj['questions'][current_q]['score']
					correctanswered+=1
					iscorrect = 'B'
					gscore.get_node("AnimationPlayer").current_animation = "scoreanim"
			else:
				if json_data['questions'][current_q]['options'][1]['correct']=="true":
					score+=int(json_data['questions'][current_q]['score'])
					correctanswered+=1
					iscorrect = 'B'
					gscore.get_node("AnimationPlayer").current_animation = "scoreanim"
		elif txt=='C':
			if json_data==null:
				if dataj['questions'][current_q]['options'][2]['correct']=="true":
					score+=dataj['questions'][current_q]['score']
					correctanswered+=1
					iscorrect = 'C'
					gscore.get_node("AnimationPlayer").current_animation = "scoreanim"
			else:
				if json_data['questions'][current_q]['options'][2]['correct']=="true":
					score+=int(json_data['questions'][current_q]['score'])
					correctanswered+=1
					iscorrect = 'C'
					gscore.get_node("AnimationPlayer").current_animation = "scoreanim"
		elif txt=='D':
			if json_data==null:
				if dataj['questions'][current_q]['options'][3]['correct']=="true":
					score+=dataj['questions'][current_q]['score']
					correctanswered+=1
					iscorrect = 'D'
					gscore.get_node("AnimationPlayer").current_animation = "scoreanim"
			else:
				if json_data['questions'][current_q]['options'][3]['correct']=="true":
					score+=int(json_data['questions'][current_q]['score'])
					correctanswered+=1
					iscorrect = 'D'
					gscore.get_node("AnimationPlayer").current_animation = "scoreanim" 
			
					
					
		if score==prev_score:
			if nolives>0:
				nolives-=1
				glives.get_node("AnimationPlayer").current_animation="liveanim"
				glives.get_node("holder/lives").text = 'X '+str(nolives)
			if nolives==0:
				qflag = true
		else:
			if  str(score).length()==2:
				gscore.get_node("Score-bg/score").text = "  "+str(score)
			elif str(score).length()==1:
				gscore.get_node("Score-bg/score").text = "   "+str(score)
			else:
				gscore.get_node("Score-bg/score").text = str(score)
		
		if current_q + 1 < questions.size():
			current_q+=1
			set_info_box_value()
		else:
			current_q+=1
			qflag=true
			reset_info_box_value()
			
		if qflag:
			if not(gameovercalled):
				gameovercalled = true
				yield(get_tree().create_timer(2.0), "timeout")
				game_over()
				gover = goverfor.instance()
				reset_info_box_value()
				add_child(gover)
				if get_tree().paused==false:
					get_tree().paused = true
					
	runner.motionpause = false
	gprogress.get_node("ProgressBar/Timer").paused = false

func zombie_kill():
	gprogress.get_node("ProgressBar/Timer").paused = true
	zombie_pause=true
	
	runner.motionpause = true
	if nolives>0:
		nolives-=1
		glives.get_node("AnimationPlayer").current_animation="liveanim"
		glives.get_node("holder/lives").text = 'X '+str(nolives)
		yield(get_tree().create_timer(2.0), "timeout")
		zombie.get_node("Sprite").position.y = $"main-game-board".rect_size.y +110
		zombie.get_node("Sprite").position.x = 450
		runner.get_node("Sprite").position.y = $"main-game-board".rect_size.y +45
		runner.get_node("Sprite").position.x = 700
		resetanim()
		withzombie.rect_position = Vector2(zombie.get_node("Sprite").position.x-220,zombie.get_node("Sprite").position.y-220)
	if nolives==0:
		if not(gameovercalled):
			gameovercalled = true
			#yield(get_tree().create_timer(2.0), "timeout")
			game_over()
			gover = goverfor.instance()
			reset_info_box_value()
			add_child(gover)
			if get_tree().paused==false:
				get_tree().paused = true
				zombie.get_node("Sprite").pause_mode = true
				withzombie.pause_mode = true
	runner.motionpause = false
	zombie_pause=false
	gprogress.get_node("ProgressBar/Timer").paused = false

func _physics_process(delta: float) -> void:
	if gameflag:
		if not(zombie_pause):
			
			#update2()
			check_for_d()
			update()
		if not(jflag):
			jflag = true
			gquestion.get_node("question").visible = true
			#gquestion.get_node("question").rect_position.x = 600
			#gquestion.get_node("question").rect_position.y = 970
			gchoices.get_node("holder/choice1").visible = true
			gchoices.get_node("holder/choice2").visible = true
			gchoices.get_node("holder/choice3").visible = true
			gchoices.get_node("holder/choice4").visible = true

func _on_Area2D_area_entered(area: Area2D) -> void:
	if area.get_name()=='runerr':
		runner.up = true
	if area.get_name()=='zombie':
		zombie.collidewithladder = true
		zombie.up = true
		zombie.inair = true
		runner.down=true
	if area.get_name()=='withzombie':
		withzombie.up = true
		
func _on_Area2D_area_exited(area: Area2D) -> void:
	if area.get_name()=='runerr':
		if runner.lastmove=='u':
			if not(zombie.collidewithladder):
				decision=null
			runner.level+=1
			Global.downfirst = true
			#runner.get_node("AnimationPlayer").current_animation="get_upladder"
		Global.donce = true
		runner.up = false
	if area.get_name()=='zombie':
		zombie.collidewithladder = false
		if zombie.lastmove=='u':
			decision=null
		zombie.lastmove=''
		zombie.up=false
		zombie.inair = false
		withzombie.up=false
	

func _on_HTTPRequest_request_completed(result: int, response_code: int, headers: PoolStringArray, body: PoolByteArray) -> void:
	var json = JSON.parse(body.get_string_from_utf8())
	
	json_data = json.result
	if response_code==200:
		pass
	else:
		json_data = default_json_data
	randomize()
	$HTTPRequest2.request(json_url+str(getrandom())+".json")
	load_data()


func _on_HTTPRequest2_request_completed(result: int, response_code: int, headers: PoolStringArray, body: PoolByteArray) -> void:
	var json = JSON.parse(body.get_string_from_utf8())
	if response_code==200:
		Global.buffer.push_back(json.result)
	else:
		Global.buffer.push_back(default_json_data)
	if Global.replay1==false:
		m_over.get_node("CanvasLayer2/Start-box/start").disabled = false
	else:
		get_tree().paused = false
	
func set_info_box_value_answered():
	if  str(score).length()==2:
		gscore.get_node("Score-bg/score").text = "  "+str(score)
	elif str(score).length()==1:
		gscore.get_node("Score-bg/score").text = "   "+str(score)
	else:
		gscore.get_node("Score-bg/score").text = str(score)
	glives.get_node("holder/lives").text = 'X '+str(nolives)
	gquestion.get_node("question").text = ''
	gchoices.get_node("holder/choice1").text = ''
	gchoices.get_node("holder/choice2").text = ''
	gchoices.get_node("holder/choice3").text = ''
	gchoices.get_node("holder/choice4").text = ''
	
		
func game_over():
	gameovercalled = true
	reload = true
	set_info_box_value_answered()
	glives.get_node("AnimationPlayer").current_animation="liveanim"
	var file = File.new()
	#file.open("res://gamestate.json",File.WRITE)
	if OS.has_feature('JavaScript'):
		JavaScript.eval("""
		
		String.prototype.hashCode = function() {
	var hash = 0;
	if (this.length == 0) {
		return hash;
	}
	for (var i = 0; i < this.length; i++) {
		var char = this.charCodeAt(i);
		hash = ((hash<<5)-hash)+char;
		hash = hash & hash; 
	}
	return hash;
	  }
	
		const queryString = window.location.search;
	  const urlParams = new URLSearchParams(queryString);
	const keys = urlParams.keys();
	
	  const id = urlParams.get("id");
	  const server = urlParams.get("server");
	  const userId = urlParams.get("userId");
	  const token = urlParams.get("token");

	  const score = \'%s\';
	
	  var hashed_score = id+score;
	  //console.log(hashed_score.hashCode());

	  function sendResult() {
		
		var formData = new FormData();
		
		for (const key of keys) {
			if (key==="id")
				formData.append("paperId", urlParams.get(key));
			else if(key!=="server" && key!=="lang")
				formData.append(key, urlParams.get(key));
			}
		formData.append("score", score);
		formData.append("hashcode", hashed_score.hashCode());

		var xhr = new XMLHttpRequest();
		// xhr.withCredentials=true
		xhr.open("POST", server + "/api/submitGameResult");
		xhr.send(formData);
		xhr.onreadystatechange = function () {
		  // If the request completed, close the extension popup
		  if (this.readyState == 4)
			if (this.status == 200) {
			  const response = JSON.parse(this.response);
			  //console.log(response);

			  if (response.success) {
				// result submission succefully
				//console.log("success");
			  } else {
				//console.log("fail");
			  }
			}
		};
	  }
	
	  sendResult();
	
	
		"""%score)
	file.open("user://save.data",File.WRITE)
	var mystoredata = {"current question":0,"correct answered":0,
	'score':0,'nolives':3,'current file':null,'current timer value':100}
	#print(mystoredata)
	file.store_var(mystoredata)
	file.close()
		
func timebar_runout():
	gameflag = false
	#print("in time bar runout")
	if not(gameovercalled):
		gameovercalled = true
		nolives = 0
		game_over()
		gover = goverfor.instance()
		#reset_infobox("correct answers:"+str(correctanswered)+"\ntotal questions:"+str(noqs)+"\nscore:"+str(score))
		add_child(gover)
		if get_tree().paused==false:
			get_tree().paused = true


func _on_door_area_entered(area: Area2D) -> void:
	if area.get_name()=='runerr':
		Global.doorflag = true


func _on_door_area_exited(area: Area2D) -> void:
	if area.get_name()=='runerr':
		Global.doorflag = false


func _on_door2_area_entered(area: Area2D) -> void:
	if area.get_name()=='runerr':
		Global.door2flag = true


func _on_door2_area_exited(area: Area2D) -> void:
	if area.get_name()=='runerr':
		Global.door2flag = false


func _on_door3_area_entered(area: Area2D) -> void:
	if area.get_name()=='runerr':
		Global.door3flag = true


func _on_door3_area_exited(area: Area2D) -> void:
	if area.get_name()=='runerr':
		Global.door3flag = false


func _on_door4_area_entered(area: Area2D) -> void:
	if area.get_name()=='runerr':
		Global.door4flag = true


func _on_door4_area_exited(area: Area2D) -> void:
	if area.get_name()=='runerr':
		Global.door4flag = false


func _on_door5_area_entered(area: Area2D) -> void:
	if area.get_name()=='runerr':
		Global.door5flag = true


func _on_door5_area_exited(area: Area2D) -> void:
	if area.get_name()=='runerr':
		Global.door5flag = false
		
var target_level = 0

var decision = null
var theindex = null

var decision2 = null
var theindex2 = null

func compute_smaller_of_two(arr,pos):
	
	var distance1
	var distance2
	
	if Global.all_ladders[arr[0]].position.x > pos.x:
		distance1 = Global.all_ladders[arr[0]].position.x-pos.x
	elif Global.all_ladders[arr[0]].position.x < pos.x:
		distance1 = pos.x-Global.all_ladders[arr[0]].position.x
		
	if Global.all_ladders[arr[1]].position.x > pos.x:
		distance2 = Global.all_ladders[arr[1]].position.x-pos.x
	elif Global.all_ladders[arr[1]].position.x < pos.x:
		distance2 = pos.x-Global.all_ladders[arr[1]].position.x
		
	if distance1 < distance2:
		return 0
	else:
		return 1

func inbounds():
	var val1 = 20
	var val2 = 16
	if zombie.get_node("Sprite").is_flipped_h():
		val2 = 22
		val1 = 26
	
	if (withzombie.rect_position.x>= Global.all_ladders[0].position.x-val1 and withzombie.rect_position.x<=Global.all_ladders[0].position.x-val2
	or withzombie.rect_position.x>= Global.all_ladders[1].position.x-val1 and withzombie.rect_position.x<=Global.all_ladders[1].position.x-val2
	or withzombie.rect_position.x>= Global.all_ladders[2].position.x-val1 and withzombie.rect_position.x<=Global.all_ladders[2].position.x-val2
	or withzombie.rect_position.x>= Global.all_ladders[3].position.x-val1 and withzombie.rect_position.x<=Global.all_ladders[3].position.x-val2
	or withzombie.rect_position.x>= Global.all_ladders[4].position.x-val1 and withzombie.rect_position.x<=Global.all_ladders[4].position.x-val2):
		return true
	return false
	
func inbounds0():
	var val1 = 20
	var val2 = 16
	if zombie.get_node("Sprite").is_flipped_h():
		val2 = 22
		val1 = 26
	if current_zombie_level==1:
		if (withzombie.rect_position.x>= Global.all_ladders[0].position.x-val1 and withzombie.rect_position.x<=Global.all_ladders[0].position.x-val2
	or withzombie.rect_position.x>= Global.all_ladders[3].position.x-val1 and withzombie.rect_position.x<=Global.all_ladders[3].position.x-val2):
			return true
	elif current_zombie_level==2:
		if (withzombie.rect_position.x>= Global.all_ladders[1].position.x-val1 and withzombie.rect_position.x<=Global.all_ladders[1].position.x-val2
	or withzombie.rect_position.x>= Global.all_ladders[4].position.x-val1 and withzombie.rect_position.x<=Global.all_ladders[4].position.x-val2):
			return true
	elif current_zombie_level==3:
		if withzombie.rect_position.x>= Global.all_ladders[2].position.x-val1 and withzombie.rect_position.x<=Global.all_ladders[2].position.x-val2:
			return true
		
	return false
	
	
func inbounds1():
	var val1 = 20
	var val2 = 16
	if zombie.get_node("Sprite").is_flipped_h():
		val2 = 22
		val1 = 26
	if current_zombie_level==0:
		if (withzombie.rect_position.x>= Global.all_ladders[0].position.x-val1 and withzombie.rect_position.x<=Global.all_ladders[0].position.x-val2
	or withzombie.rect_position.x>= Global.all_ladders[3].position.x-val1 and withzombie.rect_position.x<=Global.all_ladders[3].position.x-val2):
			return true
	elif current_zombie_level==1:
		if (withzombie.rect_position.x>= Global.all_ladders[1].position.x-val1 and withzombie.rect_position.x<=Global.all_ladders[1].position.x-val2
	or withzombie.rect_position.x>= Global.all_ladders[4].position.x-val1 and withzombie.rect_position.x<=Global.all_ladders[4].position.x-val2):
			return true
	elif current_zombie_level==2:
		if withzombie.rect_position.x>= Global.all_ladders[2].position.x-val1 and withzombie.rect_position.x<=Global.all_ladders[2].position.x-val2:
			return true
		
	return false	

var once = false
var prezval

func make_decsison(from,to):
	
	var doptions
	var iterator = to
	var virtual_l 
	var d1
	var d2
	if to > from:
		while iterator > from:
			if iterator==2:
				doptions = [1,4]
			elif iterator==1:
				doptions = [0,3]
			#var d1
			#var d2
			if iterator==3:
				virtual_l = 2
			else:
				if runner.get_myrunner_current_level()==iterator:
					d1 = abs(runner.get_node("Sprite").position.x-198 - Global.all_ladders[doptions[0]].position.x)
					d2 = abs(runner.get_node("Sprite").position.x-198 - Global.all_ladders[doptions[1]].position.x)
				elif virtual_l!=null:
				
					#print("virtual_l:",virtual_l)
					d1 = abs(Global.all_ladders[virtual_l].position.x - Global.all_ladders[doptions[0]].position.x)
					d2 = abs(Global.all_ladders[virtual_l].position.x - Global.all_ladders[doptions[1]].position.x)
				if d1!=null and d2!=null and d1<d2:
					virtual_l = doptions[0]
				else:
					virtual_l = doptions[1]
			iterator-=1
			
		if iterator==current_zombie_level:
			if Global.all_ladders[virtual_l].position.x >= withzombie.rect_position.x:
				return 'right'
			else:
				return 'left'
	elif to < from:
		while iterator < from:
			if iterator==1:
				doptions = [1,4]
			elif iterator==0:
				doptions = [0,3]
			#var d1
			#var d2
			if iterator==2:
				virtual_l = 2
			else:
				if runner.get_myrunner_current_level()==iterator:
					d1 = abs(runner.get_node("Sprite").position.x-198 - Global.all_ladders[doptions[0]].position.x)
					d2 = abs(runner.get_node("Sprite").position.x-198 - Global.all_ladders[doptions[1]].position.x)
				elif virtual_l!=null:
				#else:
					#print("virtual_l:",virtual_l)
					d1 = abs(Global.all_ladders[virtual_l].position.x - Global.all_ladders[doptions[0]].position.x)
					d2 = abs(Global.all_ladders[virtual_l].position.x - Global.all_ladders[doptions[1]].position.x)
				if d1!=null and d2!=null and d1<d2:
					virtual_l = doptions[0]
				else:
					virtual_l = doptions[1]
			iterator+=1
			
		if iterator==current_zombie_level:
			if Global.all_ladders[virtual_l].position.x >= withzombie.rect_position.x:
				return 'right'
			else:
				return 'left'
	
	
func make_decise():
	
	if runner.get_myrunner_current_level()!=-1:
		target_level = runner.get_myrunner_current_level()
	if zombie.get_myrunner_current_level()!=-1:
		current_zombie_level = zombie.get_myrunner_current_level()
	
	var rand_index = null
	var maoptions
	if current_zombie_level==0 and decision==null:
		randomize()
		maoptions = [0,3]
		var d1 = abs(withzombie.rect_position.x - Global.all_ladders[0].position.x)
		var d2 = abs(withzombie.rect_position.x - Global.all_ladders[3].position.x)
		var choice
		if d1<d2:
			rand_index = 0
			choice=0
		else:
			rand_index=1
			choice=3
		theindex = maoptions[rand_index]
			
			
		decision = make_decsison(current_zombie_level,target_level)
			
		"""
			if Global.all_ladders[choice].position.x >= withzombie.rect_position.x:
				decision='right'
			else:
				decision='left' 
			"""
			
	elif current_zombie_level==1 and decision==null:
			
		randomize()
		maoptions = [1,4]
			
		var d1 = abs(withzombie.rect_position.x - Global.all_ladders[1].position.x)
		var d2 = abs(withzombie.rect_position.x - Global.all_ladders[4].position.x)
		var choice
		if d1<d2:
			rand_index = 0
			choice = 1
		else:
			rand_index=1
			choice=4
		theindex = maoptions[rand_index]
			
		decision = make_decsison(current_zombie_level,target_level)
			
		"""
			if Global.all_ladders[choice].position.x >= withzombie.rect_position.x:
				decision='right'
			else:
				decision='left' 
				"""
			
	elif current_zombie_level==2 and decision==null:
		rand_index = 2
		theindex = 2
			
		decision = make_decsison(current_zombie_level,target_level)
			
		"""
			if Global.all_ladders[rand_index].position.x >= withzombie.rect_position.x:
				decision='right'
			else:
				decision='left' 
				"""

func update():
	
	prezval=target_level
	if runner.get_myrunner_current_level()!=-1:
		target_level = runner.get_myrunner_current_level()
	if zombie.get_myrunner_current_level()!=-1:
		current_zombie_level = zombie.get_myrunner_current_level()
		
	if prezval!=target_level:
		decision=null
	#for same level
	if current_zombie_level==target_level and not(move_down_once_called) :
		var icre = 70
		if runner.get_node("Sprite").is_flipped_h():
			icre = 40
		
		if runner.get_node("Sprite").position.x+icre > zombie.get_node("Sprite").position.x:
			if current_zombie_level!=0 and zombie.get_node("Sprite").position.y+1 !=  Global.all_woods[target_level-1].position.y+100:
				zombie.lastmove='d'
				zombie.get_node("Sprite").set_flip_h( false )
				zombie.get_node("AnimationPlayer").current_animation = "zombie_up"
				zombie.get_node("Sprite").position.y+=1
				withzombie.rect_position.y+=1
			elif current_zombie_level==0  and zombie.get_node("Sprite").position.y+1 !=  $"main-game-board".rect_size.y +111:
				zombie.lastmove='d'
				zombie.get_node("Sprite").set_flip_h( false )
				zombie.get_node("AnimationPlayer").current_animation = "zombie_up"
				zombie.get_node("Sprite").position.y+=1
				withzombie.rect_position.y+=1
			else:
				zombie.lastmove='r'
				zombie.get_node("Sprite").set_flip_h( false )
				zombie.get_node("AnimationPlayer").current_animation = "zombie_right"
				zombie.get_node("Sprite").position.x+=1
				withzombie.rect_position.x+=1
			
		elif runner.get_node("Sprite").position.x+icre < zombie.get_node("Sprite").position.x:
			
			
			
			if current_zombie_level!=0 and zombie.get_node("Sprite").position.y+1 !=  Global.all_woods[target_level-1].position.y+100:
				zombie.lastmove='d'
				zombie.get_node("Sprite").set_flip_h( true )
				zombie.get_node("AnimationPlayer").current_animation = "zombie_up"
				zombie.get_node("Sprite").position.y+=1
				withzombie.rect_position.y+=1
			elif current_zombie_level==0  and zombie.get_node("Sprite").position.y+1 !=  $"main-game-board".rect_size.y +111:
				zombie.lastmove='d'
				zombie.get_node("Sprite").set_flip_h( true )
				zombie.get_node("AnimationPlayer").current_animation = "zombie_up"
				zombie.get_node("Sprite").position.y+=1
				withzombie.rect_position.y+=1
			else:
				zombie.lastmove='l'
				zombie.get_node("AnimationPlayer").current_animation = "zombie_right"
				zombie.get_node("Sprite").set_flip_h( true )
				zombie.get_node("Sprite").position.x-=1
				withzombie.rect_position.x-=1
						
		else:
			zombie.get_node("AnimationPlayer").current_animation = "zombie_up"
			zombie.get_node("Sprite").position.y-=1
			withzombie.rect_position.y-=1
						
	elif current_zombie_level < target_level and not(move_down_once_called)  and not(gameovercalled):
		var rand_index = null
		var maoptions
		if current_zombie_level==0 and decision==null :
			randomize()
			maoptions = [0,3]
			var d1 = abs(withzombie.rect_position.x - Global.all_ladders[0].position.x)
			var d2 = abs(withzombie.rect_position.x - Global.all_ladders[3].position.x)
			var choice
			if d1<d2:
				rand_index = 0
				choice=0
			else:
				rand_index=1
				choice=3
			theindex = maoptions[rand_index]
			
			if not(zombie.collidewithladder):
				decision = make_decsison(current_zombie_level,target_level)
			
			"""
			if Global.all_ladders[choice].position.x >= withzombie.rect_position.x:
				decision='right'
			else:
				decision='left' 
			"""
			
		elif current_zombie_level==1 and decision==null  :
			
			randomize()
			maoptions = [1,4]
			
			var d1 = abs(withzombie.rect_position.x - Global.all_ladders[1].position.x)
			var d2 = abs(withzombie.rect_position.x - Global.all_ladders[4].position.x)
			var choice
			if d1<d2:
				rand_index = 0
				choice = 1
			else:
				rand_index=1
				choice=4
			theindex = maoptions[rand_index]
			
			if not(zombie.collidewithladder):
				decision = make_decsison(current_zombie_level,target_level)
			
			"""
			if Global.all_ladders[choice].position.x >= withzombie.rect_position.x:
				decision='right'
			else:
				decision='left' 
				"""
			
		elif current_zombie_level==2 and decision==null  :
			rand_index = 2
			theindex = 2
			
			
			decision = make_decsison(current_zombie_level,target_level)
			
			"""
			if Global.all_ladders[rand_index].position.x >= withzombie.rect_position.x:
				decision='right'
			else:
				decision='left' 
				"""
			
		if decision=='left':
			zombie.get_node("Sprite").set_flip_h( true )
			if not(zombie.up and inbounds()) :
				
				if zombie.get_node("Sprite").position.x-1 > 230:
					zombie.lastmove='l'
					zombie.get_node("AnimationPlayer").current_animation = "zombie_right"
					zombie.get_node("Sprite").position.x-=1
					withzombie.rect_position.x-=1
				else:
					decision='right'
				#decision=null
					
					
			else:
				decision='left'	
				if theindex!=null:
					pass
					
				zombie.lastmove='u'
				if  zombie.get_node("Sprite").position.y+56 < Global.all_ladders[theindex].position.y-80+172:
					if not(once):
						zombie.get_node("AnimationPlayer").current_animation = "zladderup"
						once=true
						yield(get_tree().create_timer(5.0), "timeout")
						
					
					zombie.get_node("Sprite").position.y-=2
					withzombie.rect_position.y-=2
					
				else:
					once =false
					zombie.get_node("AnimationPlayer").current_animation = "zombie_up"
					zombie.get_node("Sprite").position.y-=1
					withzombie.rect_position.y-=1
					
				
		elif decision=='right':
			zombie.get_node("Sprite").set_flip_h( false )
			if not(zombie.up  and inbounds()) :
				
				if zombie.get_node("Sprite").position.x+1 < $"main-game-board".rect_size.y+360:
					zombie.lastmove='r'
					zombie.get_node("AnimationPlayer").current_animation = "zombie_right"
					zombie.get_node("Sprite").position.x+=1
					withzombie.rect_position.x+=1
				else:
					decision='left'
				#decision=null
			else:
				decision='right'
				if theindex!=null:
					pass
				
				
				zombie.lastmove='u'
				if  zombie.get_node("Sprite").position.y+56 < Global.all_ladders[theindex].position.y-80+172:
					if not(once):
						zombie.get_node("AnimationPlayer").current_animation = "zladderup"
						once = true
						yield(get_tree().create_timer(5.0), "timeout")
					zombie.get_node("Sprite").position.y-=2
					withzombie.rect_position.y-=2
					
				else:
					once = false
					zombie.get_node("AnimationPlayer").current_animation = "zombie_up"
					zombie.get_node("Sprite").position.y-=1
					withzombie.rect_position.y-=1
					
			
		if not(zombie.up and inbounds()) and decision==null:
			if zombie.get_node("Sprite").is_flipped_h():
				if zombie.get_node("Sprite").position.x-1 > 230:
					zombie.lastmove='l'
					zombie.get_node("AnimationPlayer").current_animation = "zombie_right"
					zombie.get_node("Sprite").position.x-=1
					withzombie.rect_position.x-=1
				else:
					decision='right'
			else:
				if zombie.get_node("Sprite").position.x+1 < $"main-game-board".rect_size.y+360:
					zombie.lastmove='r'
					zombie.get_node("AnimationPlayer").current_animation = "zombie_right"
					zombie.get_node("Sprite").position.x+=1
					withzombie.rect_position.x+=1
				else:
					decision='left'
		elif decision==null:
			zombie.lastmove='u'
			if  zombie.get_node("Sprite").position.y+56 < Global.all_ladders[theindex].position.y-80+172:
				
				if not(once):
					zombie.get_node("AnimationPlayer").current_animation = "zladderup"
					once = true
					yield(get_tree().create_timer(5.0), "timeout")
				zombie.get_node("Sprite").position.y-=2
				withzombie.rect_position.y-=2
					
			else:
				
				once = false
				zombie.get_node("AnimationPlayer").current_animation = "zombie_up"
				zombie.get_node("Sprite").position.y-=1
				withzombie.rect_position.y-=1
						
	
	elif current_zombie_level > target_level:
		if not(move_down_once_called) and not(zombie.lastmove=='u'):
			move_down_once_called=true
			move_zombie_down_one_level()
		elif not(move_down_once_called):
			zombie.lastmove='u'
			zombie.get_node("AnimationPlayer").current_animation = "zombie_up"
			zombie.get_node("Sprite").position.y-=1
			withzombie.rect_position.y-=1
		
var which_ladder = null
var once1 = false
var down_decision
func move_zombie_down_one_level():
	
	if current_zombie_level==1 :
		
		#0,3
		var choice
		var increment
		var d1 = abs(withzombie.rect_position.x - Global.all_ladders[0].position.x)
		var d2 = abs(withzombie.rect_position.x - Global.all_ladders[3].position.x)
		
		var dt1 = abs(runner.get_node("Sprite").position.x - Global.all_ladders[0].position.x)
		var dt2 = abs(runner.get_node("Sprite").position.x  - Global.all_ladders[3].position.x)
		
		var d
		if d1+dt1<d2+dt2:
			choice = 0
			d = d1
		else:
			choice = 3
			d=d2
			
		
		
		if Global.all_ladders[choice].position.x >= withzombie.rect_position.x:
			increment = 1
			d-=15
		else:
			increment=-1
			d+=28
			
		var i = 0
		
		"""
		while ( not(gameovercalled) and i < d and not(current_zombie_level==target_level) and 
		not(current_zombie_level<target_level) ) :
			if zombie_pause:
				break
			if increment > 0:
				zombie.get_node("Sprite").set_flip_h( false )
			else:
				zombie.get_node("Sprite").set_flip_h( true )
			zombie.get_node("AnimationPlayer").current_animation = "zombie_right"
			zombie.get_node("Sprite").position.x+=increment
			withzombie.rect_position.x+=increment
			yield(get_tree().create_timer(0.01), "timeout")
			i+=1
			"""
			
		
		
		while not(inbounds0()) and not(gameovercalled) and not(current_zombie_level==target_level) and not(current_zombie_level<target_level) :
			if zombie_pause:
				break
			if increment > 0:
				zombie.get_node("Sprite").set_flip_h( false )
			else:
				zombie.get_node("Sprite").set_flip_h( true )
			
			if zombie.get_node("Sprite").position.x+increment > 230 and zombie.get_node("Sprite").position.x+1 < $"main-game-board".rect_size.y+360:
				pass
			else:
				if increment==-1:
					increment=1
				elif increment==1:
					increment=-1
				if increment > 0:
					zombie.get_node("Sprite").set_flip_h( false )
				else:
					zombie.get_node("Sprite").set_flip_h( true )	
				
			zombie.get_node("AnimationPlayer").current_animation = "zombie_right"
			zombie.get_node("Sprite").position.x+=increment
			withzombie.rect_position.x+=increment
			yield(get_tree().create_timer(0.01), "timeout")
			i+=1
		
		if  not(current_zombie_level==target_level) and not(current_zombie_level<target_level):
			var count = 0
			
			#zombie.get_node("Sprite").position.x=Global.all_ladders[choice].position.x+198
			#withzombie.rect_position.y = zombie.get_node("Sprite").position.x
			
			while not(gameovercalled) and zombie.get_node("Sprite").position.y+1!=$"main-game-board".rect_size.y+111:
				if zombie_pause:
					break
				if count < 4:
					if not(once1):
						once1 = true
						zombie.get_node("AnimationPlayer").current_animation = "zdown"
					count +=1
					yield(get_tree().create_timer(0.05), "timeout")
					if count==4:
						zombie.get_node("Sprite").position.y+=2
						withzombie.rect_position.y+=2
				else:
					zombie.get_node("AnimationPlayer").current_animation = "zombie_up"
				zombie.get_node("Sprite").position.y+=1
				withzombie.rect_position.y+=1
				yield(get_tree().create_timer(0.01), "timeout")
			
	elif current_zombie_level==2 :
		#1,4	
		var choice
		var increment
		var d1 = abs(withzombie.rect_position.x - Global.all_ladders[1].position.x)
		var d2 = abs(withzombie.rect_position.x - Global.all_ladders[4].position.x)
		var dt1 = abs(runner.get_node("Sprite").position.x - Global.all_ladders[1].position.x)
		var dt2 = abs(runner.get_node("Sprite").position.x  - Global.all_ladders[4].position.x)
		
		
		var d
		if d1+dt1<d2+dt2:
			choice = 1
			d = d1
		else:
			choice = 4
			d=d2
			
		
		
		
		if Global.all_ladders[choice].position.x >= withzombie.rect_position.x:
			increment = 1
			d-=15
		else:
			increment=-1
			d+=28
			
		
		var i = 0
		"""
		while ( not(gameovercalled) and i < d and not(current_zombie_level==target_level) and 
		not(current_zombie_level<target_level) )  :
			if zombie_pause:
				break
			if increment > 0:
				zombie.get_node("Sprite").set_flip_h( false )
			else:
				zombie.get_node("Sprite").set_flip_h( true )
			zombie.get_node("AnimationPlayer").current_animation = "zombie_right"
			zombie.get_node("Sprite").position.x+=increment
			withzombie.rect_position.x+=increment
			yield(get_tree().create_timer(0.01), "timeout")
			i+=1
			"""
			
			
		while not(inbounds0()) and not(gameovercalled) and not(current_zombie_level==target_level) and not(current_zombie_level<target_level) :
			if zombie_pause:
				break
			if increment > 0:
				zombie.get_node("Sprite").set_flip_h( false )
			else:
				zombie.get_node("Sprite").set_flip_h( true )
			
			if zombie.get_node("Sprite").position.x+increment > 230 and zombie.get_node("Sprite").position.x+1 < $"main-game-board".rect_size.y+360:
				pass
			else:
				if increment==-1:
					increment=1
				elif increment==1:
					increment=-1
				if increment > 0:
					zombie.get_node("Sprite").set_flip_h( false )
				else:
					zombie.get_node("Sprite").set_flip_h( true )	
				
			zombie.get_node("AnimationPlayer").current_animation = "zombie_right"
			zombie.get_node("Sprite").position.x+=increment
			withzombie.rect_position.x+=increment
			yield(get_tree().create_timer(0.01), "timeout")
			i+=1
			
		if  not(current_zombie_level==target_level) and not(current_zombie_level<target_level):
			var count = 0
			#zombie.get_node("Sprite").position.x=Global.all_ladders[choice].position.x+198
			#withzombie.rect_position.y = zombie.get_node("Sprite").position.x
			while not(gameovercalled) and zombie.get_node("Sprite").position.y+1!=Global.all_woods[0].position.y+100:
				if zombie_pause:
					break
				if count < 4:
					if not(once1):
						once1 = true
						zombie.get_node("AnimationPlayer").current_animation = "zdown"
					count +=1
					
					yield(get_tree().create_timer(0.05), "timeout")	
					if count==4:
						zombie.get_node("Sprite").position.y+=2
						withzombie.rect_position.y+=2
				else:
					zombie.get_node("AnimationPlayer").current_animation = "zombie_up"
				#zombie.get_node("AnimationPlayer").current_animation = "zombie_up"
				zombie.get_node("Sprite").position.y+=1
				withzombie.rect_position.y+=1
				yield(get_tree().create_timer(0.01), "timeout")	
			
				
	elif current_zombie_level==3 :
		#2
		var choice = 2
		var increment
		var d1 = abs(withzombie.rect_position.x - Global.all_ladders[2].position.x)
		var d
		d = d1
			
		
		
		down_decision = make_decsison(current_zombie_level,target_level)
		
		
		
		
		if Global.all_ladders[choice].position.x >= withzombie.rect_position.x:
			increment = 1
			d-=15
		else:
			increment=-1
			d+=28
			
		
		var i = 0
		"""
		while ( not(gameovercalled) and i < d and not(current_zombie_level==target_level) and 
		not(current_zombie_level<target_level) ) :
			if zombie_pause:
				break
			if increment > 0:
				zombie.get_node("Sprite").set_flip_h( false )
			else:
				zombie.get_node("Sprite").set_flip_h( true )
			zombie.get_node("AnimationPlayer").current_animation = "zombie_right"
			zombie.get_node("Sprite").position.x+=increment
			withzombie.rect_position.x+=increment
			yield(get_tree().create_timer(0.01), "timeout")
			i+=1
			"""
			
			
		while not(inbounds0()) and not(gameovercalled) and not(current_zombie_level==target_level) and not(current_zombie_level<target_level) :
			if zombie_pause:
				break
			if increment > 0:
				zombie.get_node("Sprite").set_flip_h( false )
			else:
				zombie.get_node("Sprite").set_flip_h( true )
			
			if zombie.get_node("Sprite").position.x+increment > 230 and zombie.get_node("Sprite").position.x+1 < $"main-game-board".rect_size.y+360:
				pass
			else:
				if increment==-1:
					increment=1
				elif increment==1:
					increment=-1
				if increment > 0:
					zombie.get_node("Sprite").set_flip_h( false )
				else:
					zombie.get_node("Sprite").set_flip_h( true )	
				
			zombie.get_node("AnimationPlayer").current_animation = "zombie_right"
			zombie.get_node("Sprite").position.x+=increment
			withzombie.rect_position.x+=increment
			yield(get_tree().create_timer(0.01), "timeout")
			i+=1
			
		if  not(current_zombie_level==target_level) and not(current_zombie_level<target_level):
			var count = 0
			#zombie.get_node("Sprite").position.x=Global.all_ladders[choice].position.x+198
			#withzombie.rect_position.y = zombie.get_node("Sprite").position.x
			while not(gameovercalled) and zombie.get_node("Sprite").position.y+1!=Global.all_woods[1].position.y+100:
				if zombie_pause:
					break
				if count < 4:
					if not(once1):
						once1 = true
						zombie.get_node("AnimationPlayer").current_animation = "zdown"
					count +=1
					yield(get_tree().create_timer(0.05), "timeout")
					if count==4:
						zombie.get_node("Sprite").position.y+=2
						withzombie.rect_position.y+=2
				else:
					zombie.get_node("AnimationPlayer").current_animation = "zombie_up"
				zombie.get_node("Sprite").position.y+=1
				withzombie.rect_position.y+=1
				yield(get_tree().create_timer(0.01), "timeout")	
			
	move_down_once_called = false
	once1 = false


func check_for_d():
	if target_level!=current_zombie_level and not(zombie.collidewithladder):
		if zombie.get_node("Sprite").position.x-100 <= runner.get_node("Sprite").position.x and zombie.get_node("Sprite").position.x+100 >= runner.get_node("Sprite").position.x:
			decision=null
