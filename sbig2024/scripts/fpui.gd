
class_name FPUI
extends Control

@onready var progress: CircularProgressBar = $ProgressBar
@onready var label: Label = $TextLabel
@onready var vignette: CanvasItem = $VignetteRect

func show_intro_a(showThis: String) -> void:
	$IntroLabelA.text = showThis
	
func show_intro_b(showThis: String) -> void:
	$IntroLabelB.text = showThis

func show_instruction(showThis: String) -> void:
	label.text = showThis
	
func hide_instruction() -> void:
	label.text = ""

func progressBar() -> CircularProgressBar:
	return progress


func vignette_intensity(intensity: float) -> void:
	vignette.material.set_shader_parameter("vignette_intensity",intensity)


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
