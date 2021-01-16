extends Node

var client
var server

export var hosting = false

func _ready():
	set_process(false)
	set_physics_process(false)

func SwitchToServer():
	server.get_root().set_update_mode(Viewport.UPDATE_ALWAYS)
	get_tree().get_root().set_update_mode(Viewport.UPDATE_ALWAYS)
	yield(get_tree().create_timer(1), "timeout")
	server.get_root().set_update_mode(Viewport.UPDATE_DISABLED)
	get_tree().get_root().set_update_mode(Viewport.UPDATE_WHEN_VISIBLE)

func SwitchToClient():
	server.get_root().set_update_mode(Viewport.UPDATE_DISABLED)
	get_tree().get_root().set_update_mode(Viewport.UPDATE_WHEN_VISIBLE)

func _process(delta):
	server.idle(delta)

func _physics_process(delta):
	server.iteration(delta)

func StartClient(clien):
	client = clien
	clien.change_scene("res://Bingo.tscn")

func StartServer(clien):
	client = clien
	clien.change_scene("res://Bingo.tscn")
	server = SceneTree.new()
	server.init()
	set_process(true)
	set_physics_process(true)
	server.change_scene("res://Server.tscn")
	server.get_root().set_update_mode(Viewport.UPDATE_DISABLED)
	get_tree().get_root().set_update_mode(Viewport.UPDATE_WHEN_VISIBLE)
