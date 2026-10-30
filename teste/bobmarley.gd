extends CharacterBody3D

@export var velocidade: float = 2.5
@export var gravidade: float = 18.0
@export var vida: int = 100

var jogador: Node3D


func _ready():
	jogador = get_tree().get_first_node_in_group("jogador") as Node3D


func _physics_process(delta):
	# Gravidade
	if not is_on_floor():
		velocity.y -= gravidade * delta
	else:
		velocity.y = 0.0

	# Perseguir jogador
	if jogador != null:
		var direcao = jogador.global_position - global_position
		direcao.y = 0

		if direcao.length() > 1.5:
			direcao = direcao.normalized()
			velocity.x = direcao.x * velocidade
			velocity.z = direcao.z * velocidade
		else:
			velocity.x = 0
			velocity.z = 0

	move_and_slide()


func receber_dano(dano):
	vida -= dano
	print("Bob Marley recebeu dano! Vida: ", vida)

	if vida <= 0:
		morrer()


func morrer():
	print("Bob Marley morreu!")
	queue_free()
