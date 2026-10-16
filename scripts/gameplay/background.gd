extends CanvasLayer


@export var color_change_duration: float = 0.2

@onready var sky: ColorRect = $Sky
@onready var stars_gpu_particles: GPUParticles2D = $StarsGPUParticles


func _set_colors_instantly() -> void:
	var material = sky.material as ShaderMaterial

	if not sky.material:
		return

	var current_color = ColorUtils.get_current_color(17)
	var fog_color = current_color.lerp(Color("#ffffff"), 0.4)
	material.set_shader_parameter("top_color", current_color)
	material.set_shader_parameter("bottom_color", fog_color)

func _set_colors() -> void:
	var material = sky.material as ShaderMaterial
	if not sky.material:
		return

	var current_color = ColorUtils.get_current_color(17)
	var top_color = current_color.lerp(Color("000000ff"), 0.2)
	var fog_color = current_color.lerp(Color("#ffffff"), 0.4)
	TweenUtils.smooth_shader_color(
		sky,
		material,
		{
			"top_color": top_color,
			"bottom_color": fog_color
		},
		5
	)


func _ready() -> void:
	_set_colors_instantly()
	ColorUtils.new_color_set.connect(_set_colors)

	var screen_size = get_viewport().size
	stars_gpu_particles.position = Vector2(
		screen_size.x / 2,
		screen_size.y / 2
	)
	var mat = stars_gpu_particles.process_material as ParticleProcessMaterial
	if mat:
		mat.emission_shape_scale = Vector3(
			screen_size.x * 0.55,
			screen_size.y * 0.55,
			1.0
		)
