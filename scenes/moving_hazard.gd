extends AnimatableBody3D

@export var destination: Vector3
@export var duration: float = 1.0

func _ready() -> void:
	var tween: Tween = create_tween()
	tween.set_loops()
	tween.set_trans(Tween.TRANS_SINE)
	var starting_pos: Vector3 = global_position
	tween.tween_property(self, "global_position", starting_pos + destination, duration)
	tween.tween_property(self, "global_position", starting_pos, duration)


func _process(delta: float) -> void:
	pass
