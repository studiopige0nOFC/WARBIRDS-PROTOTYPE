extends Node3D

@export var velocidade_projetil: float = 10.0
@export var tempo_de_vida: float = 3.0

var direcao: Vector3 = Vector3.FORWARD

func _process(delta):
	global_position += direcao * velocidade_projetil * delta

	tempo_de_vida -= delta

	if tempo_de_vida <= 0.0:
		queue_free()

func definir_direcao(nova_direcao: Vector3):
	direcao = nova_direcao.normalized()
