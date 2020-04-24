class_name Boid
extends Node2D

export (Array, Color) var colors := []

onready var detectors: Node2D = $ObsticleDetectors
onready var sensors: Node2D = $ObsticleSensors

var boids := []
var move_speed := 200
var perception_radius := 50
var velocity := Vector2()
var acceleration := Vector2()
var steer_force := 50.0
var alignment_force := 0.6
var cohesion_force := 0.6
var seperation_force := 1.0
var avoidance_force := 3.0


func _ready() -> void:
	randomize()

	position = Vector2(rand_range(0, get_viewport().size.x), rand_range(0, get_viewport().size.y))
	velocity = Vector2(rand_range(-1, 1), rand_range(-1, 1)).normalized() * move_speed
	modulate = colors[rand_range(0, colors.size())]


func _process(delta: float) -> void:
	var neighbors := get_neighbors(perception_radius)

	acceleration += process_alignments(neighbors) * alignment_force
	acceleration += process_cohesion(neighbors) * cohesion_force
	acceleration += process_seperation(neighbors) * seperation_force

	if is_obsticle_ahead():
		acceleration += process_obsticle_avoidance() * avoidance_force

	velocity += acceleration * delta
	velocity = velocity.clamped(move_speed)
	rotation = velocity.angle()

	translate(velocity * delta)

	position.x = wrapf(position.x, -32, get_viewport().size.x + 32)
	position.y = wrapf(position.y, -32, get_viewport().size.y + 32)


func process_cohesion(neighbors: Array) -> Vector2:
	var vector = Vector2()
	if neighbors.empty():
		return vector
	for boid in neighbors:
		vector += boid.position
	vector /= neighbors.size()
	return steer((vector - position).normalized() * move_speed)


func process_alignments(neighbors: Array) -> Vector2:
	var vector = Vector2()
	if neighbors.empty():
		return vector

	for boid in neighbors:
		vector += boid.velocity
	vector /= neighbors.size()
	return steer(vector.normalized() * move_speed)


func process_seperation(neighbors: Array) -> Vector2:
	var vector := Vector2()
	var close_neighbors := []
	for boid in neighbors:
		if position.distance_to(boid.position) < perception_radius / 2.0:
			close_neighbors.push_back(boid)
	if close_neighbors.empty():
		return vector

	for boid in close_neighbors:
		var difference = position - boid.position
		vector += difference.normalized() / difference.length()

	vector /= close_neighbors.size()
	return steer(vector.normalized() * move_speed)


func steer(target: Vector2) -> Vector2:
	return (target - velocity).normalized() * steer_force


func is_obsticle_ahead() -> bool:
	for ray in detectors.get_children():
		if ray.is_colliding():
			return true
	return false


func process_obsticle_avoidance() -> Vector2:
	for ray in sensors.get_children():
		if not ray.is_colliding():
			return steer((ray.cast_to.rotated(ray.rotation + rotation)).normalized() * move_speed)
	return Vector2.ZERO


func get_neighbors(view_radius: int) -> Array:
	var neighbors := []

	for boid in boids:
		if position.distance_to(boid.position) <= view_radius:
			neighbors.push_back(boid)
	return neighbors
