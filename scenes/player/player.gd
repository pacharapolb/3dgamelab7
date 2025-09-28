extends RigidBody3D

## How much vertical force to apply when moving (between 750 and 3000).
@export_range(750.0, 3000.0) var thrust: float = 1000.0

@export var torque_thrust: float = 100.0

var has_crashed: bool = false
var has_won: bool = false
var file_path: String = ""

@onready var explosion_audio: AudioStreamPlayer = $ExplosionAudio
@onready var success_audio: AudioStreamPlayer = $SuccessAudio
@onready var rocket_audio: AudioStreamPlayer3D = $RocketAudio
@onready var booster_particles: GPUParticles3D = $BoosterParticles
@onready var right_booster_particles: GPUParticles3D = $RightBoosterParticles
@onready var left_booster_particles: GPUParticles3D = $LeftBoosterParticles
@onready var explosion_particles: GPUParticles3D = $ExplosionParticles
@onready var success_particles: GPUParticles3D = $SuccessParticles

func _process(delta: float) -> void:
	if Input.is_action_pressed("boost"):
		apply_central_force(basis.y * delta * thrust)
		booster_particles.emitting = true
		if !rocket_audio.playing:
			rocket_audio.play()
	else:
		booster_particles.emitting = false
		rocket_audio.stop()
		
	if Input.is_action_pressed("rotate_left"):
		apply_torque(Vector3(0.0, 0.0, torque_thrust * delta))
		right_booster_particles.emitting = true
	else:
		right_booster_particles.emitting = false
		
	if Input.is_action_pressed("rotate_right"):
		apply_torque(Vector3(0.0, 0.0, -torque_thrust * delta))
		left_booster_particles.emitting = true
	else: 
		left_booster_particles.emitting = false

func _on_body_entered(body: Node) -> void:
	if has_crashed || has_won:
		return
	if "LandingPad" in body.get_groups():
		win(body.file_path)
	if "Hazard" in body.get_groups():
		crash()

func crash() -> void:
	has_crashed = true
	set_process(false)
	print('KABOOM!')
	explosion_particles.emitting = true
	explosion_audio.play()
	transition(2.5)

func win(next_level_file: String) -> void:
	file_path = next_level_file
	has_won = true
	set_process(false)
	print("You win!")
	success_particles.emitting = true
	success_audio.play()
	transition(1.5)

func transition(interval: float) -> void:
	var tween = create_tween()
	tween.tween_interval(interval)
	if has_won:
		tween.tween_callback(get_tree().change_scene_to_file.bind(file_path))
	tween.tween_callback(get_tree().reload_current_scene)
	
