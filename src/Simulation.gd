extends Node2D

const BOIDS_COUNT := 300

onready var boid_scene := preload("res://src/Boid.tscn")
onready var boids_container: Node2D = $Boids
onready var water: Sprite = $Water

var boids := []


func _ready() -> void:
	for _index in BOIDS_COUNT:
		var boid: Boid = boid_scene.instance()
		boid.move_speed = $HUD/VBoxContainer/MoveSlider/HSlider.value
		boid.steer_force = $HUD/VBoxContainer/TurnSlider/HSlider.value
		boid.alignment_force = $HUD/VBoxContainer/AlignSlider/HSlider.value
		boid.cohesion_force = $HUD/VBoxContainer/CohesionSlider/HSlider.value
		boid.seperation_force = $HUD/VBoxContainer/AlignSlider/HSlider.value
		boids_container.add_child(boid)
		boids.push_back(boid)

	for boid in boids:
		var other_boids = boids.duplicate()
		other_boids.erase(boid)
		boid.boids = other_boids


func _on_MoveSlider_value_changed(value: float) -> void:
	for boid in boids:
		boid.move_speed = value


func _on_TurnSlider_value_changed(value: float) -> void:
	for boid in boids:
		boid.steer_force = value


func _on_AlignSlider_value_changed(value: float) -> void:
	for boid in boids:
		boid.alignment_force = value


func _on_CohesionSlider_value_changed(value: float) -> void:
	for boid in boids:
		boid.cohesion_force = value


func _on_SeperationSlider_value_changed(value: float) -> void:
	for boid in boids:
		boid.seperation_force = value


func _on_DistortionSlider_value_changed(value: float) -> void:
	water.material.set_shader_param("distortion_amount", value)
