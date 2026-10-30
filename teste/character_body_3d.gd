
extends CharacterBody3D

# MOVIMENTAÇÃO
const VELOCIDADE = 5.0
const FORCA_PULO = 5.5
const GRAVIDADE = 18.0
const SENSIBILIDADE_MOUSE = 0.002

# TIRO
const DANO_TIRO = 20.0
const FORCA_EMPURRAO = 5.0

# MUNIÇÃO
const MAX_BALAS = 5
var balas = MAX_BALAS

# CÂMERA
var rotacao_vertical = 0.0
var recuo_camera = 0.0
var intensidade_tremor = 0.0
var posicao_camera_original = Vector3.ZERO

# ARMA
var recuo_arma = 0.0
var posicao_arma_original = Vector3.ZERO

@onready var camera: Camera3D = $Camera3D
@onready var raycast: RayCast3D = $Camera3D/RayCast3D
@onready var arma: Node3D = get_node_or_null("Camera3D/Arma") as Node3D


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

	rotacao_vertical = camera.rotation.x
	posicao_camera_original = camera.position

	raycast.enabled = true
	raycast.target_position = Vector3(0, 0, -100)

	if arma != null:
		posicao_arma_original = arma.position

	print("Munição: ", balas, "/5")


func _input(event: InputEvent) -> void:

	# TECLADO
	if event is InputEventKey:
		if event.pressed and not event.echo:

			# ESC LIBERA O MOUSE
			if event.keycode == KEY_ESCAPE:
				Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
				return

			# R RECARREGA
			if event.keycode == KEY_R:
				recarregar()
				return

	# MOUSE
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:

			if Input.mouse_mode != Input.MOUSE_MODE_CAPTURED:
				Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
			else:
				atirar()

			return

	# MOVIMENTAÇÃO DA CÂMERA
	if event is InputEventMouseMotion:
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:

			rotate_y(
				-event.relative.x * SENSIBILIDADE_MOUSE
			)

			rotacao_vertical -= event.relative.y * SENSIBILIDADE_MOUSE

			rotacao_vertical = clamp(
				rotacao_vertical,
				deg_to_rad(-89),
				deg_to_rad(89)
			)


func _physics_process(delta: float) -> void:

	# GRAVIDADE
	if not is_on_floor():
		velocity.y -= GRAVIDADE * delta

	# PULAR
	if is_on_floor() and Input.is_key_pressed(KEY_SPACE):
		velocity.y = FORCA_PULO

	# WASD
	var direcao = Vector3.ZERO

	if Input.is_key_pressed(KEY_W):
		direcao -= transform.basis.z

	if Input.is_key_pressed(KEY_S):
		direcao += transform.basis.z

	if Input.is_key_pressed(KEY_A):
		direcao -= transform.basis.x

	if Input.is_key_pressed(KEY_D):
		direcao += transform.basis.x

	direcao.y = 0
	direcao = direcao.normalized()

	velocity.x = direcao.x * VELOCIDADE
	velocity.z = direcao.z * VELOCIDADE

	move_and_slide()


func _process(delta: float) -> void:

	# RECUO DA CÂMERA
	recuo_camera = lerp(
		recuo_camera,
		0.0,
		min(1.0, 12.0 * delta)
	)

	camera.rotation.x = rotacao_vertical + recuo_camera

	# TREMIDINHA
	if intensidade_tremor > 0.0:

		camera.position = posicao_camera_original + Vector3(
			randf_range(-intensidade_tremor, intensidade_tremor),
			randf_range(-intensidade_tremor, intensidade_tremor),
			0
		)

		intensidade_tremor = move_toward(
			intensidade_tremor,
			0.0,
			0.12 * delta
		)

	else:
		camera.position = posicao_camera_original

	# RECUO DA ARMA
	if arma != null:

		recuo_arma = lerp(
			recuo_arma,
			0.0,
			min(1.0, 12.0 * delta)
		)

		arma.position = posicao_arma_original + Vector3(
			0,
			0,
			recuo_arma
		)


func atirar() -> void:

	# SEM BALAS = SEM TIRO E SEM TREMIDINHA
	if balas <= 0:
		print("SEM MUNIÇÃO! APERTE R!")
		return

	# GASTA UMA BALA
	balas -= 1

	print("Balas restantes: ", balas, "/5")

	# RECUO E TREMIDINHA SOMENTE COM TIRO
	recuo_camera -= 0.035
	intensidade_tremor = 0.025
	recuo_arma = 0.12

	# DETECTAR ALVO
	raycast.force_raycast_update()

	if not raycast.is_colliding():
		return

	var alvo = raycast.get_collider()

	if alvo == null:
		return

	# DANO NO INIMIGO
	if alvo.has_method("take_damage"):
		alvo.call("take_damage", DANO_TIRO)

	elif alvo.has_method("receber_dano"):
		alvo.call("receber_dano", DANO_TIRO)

	# EMPURRÃO
	if alvo is RigidBody3D:

		var impulso = -camera.global_transform.basis.z * FORCA_EMPURRAO

		alvo.apply_impulse(
			impulso,
			raycast.get_collision_point() - alvo.global_position
		)


func recarregar() -> void:

	# SÓ RECARREGA SE ESTIVER VAZIO
	if balas > 0:
		print("Ainda tem ", balas, " balas!")
		return

	# RECARREGA EXATAMENTE 5 BALAS
	balas = MAX_BALAS

	print("ARMA RECARREGADA! 5/5")
