
class_name FPUI
extends Control

@onready var progress: CircularProgressBar = $ProgressBar
@onready var label: Label = $TextLabel
@onready var vignette: CanvasItem = $VignetteRect

var intro_a_timer: float
var intro_b_timer: float
var instruction_timer: float

func show_intro_a(showThis: String, text_time: float = INF) -> void:
	$IntroLabelA.text = showThis
	intro_a_timer = text_time

func hide_intro_a() -> void:
	$IntroLabelA.text = ""
	intro_a_timer = -1

func show_intro_b(showThis: String, text_time: float = INF) -> void:
	$IntroLabelB.text = showThis
	intro_b_timer = text_time

func hide_intro_b() -> void:
	$IntroLabelB.text = ""
	intro_b_timer = -1

func show_instruction(showThis: String, text_time: float = INF) -> void:
	label.text = showThis
	instruction_timer = text_time 
	
func hide_instruction() -> void:
	label.text = ""
	instruction_timer = -1

func progressBar() -> CircularProgressBar:
	return progress


func vignette_intensity(intensity: float) -> void:
	vignette.material.set_shader_parameter("vignette_intensity",intensity)


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	
	pass # Replace with function body.



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	if instruction_timer >= 0:
		var pre = instruction_timer
		instruction_timer -= delta
		#print("%.3f %.3f" % [pre, instruction_timer])
		if instruction_timer <= 0:
			hide_instruction()
	
	if intro_a_timer >= 0:
		intro_a_timer -= delta
		if intro_a_timer <= 0:
			hide_intro_a()
	
	if intro_b_timer >= 0:
		instruction_timer -= delta
		if intro_b_timer <= 0:
			hide_intro_b()
	
	pass
