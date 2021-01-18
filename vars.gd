extends Node

var client
var server
var isshowing

export var hosting = false

func _ready():
	set_process(false)
	set_physics_process(false)

func SwitchToServer():
	isshowing = true
	server.get_root().set_update_mode(Viewport.UPDATE_ALWAYS)
	client.get_root().set_update_mode(Viewport.UPDATE_ALWAYS)

func SwitchToClient():
	isshowing = false
	server.get_root().set_update_mode(Viewport.UPDATE_DISABLED)
	client.get_root().set_update_mode(Viewport.UPDATE_WHEN_VISIBLE)

func _process(delta):
	server.idle(delta)

func _size_changed():
	server.get_root().get_viewport().size = client.get_root().get_viewport().size
	server.set_screen_stretch(SceneTree.STRETCH_MODE_2D,SceneTree.STRETCH_ASPECT_EXPAND,Vector2(640,360),1)

func StartClient(clien):
	client = clien
	clien.change_scene("res://Bingo.tscn")

func StartServer(clien):
	client = clien
	clien.change_scene("res://Bingo.tscn")
	client.get_root().connect("size_changed",self,"_size_changed")
	server = SceneTree.new()
	server.init()
	set_process(true)
	set_physics_process(true)
	server.change_scene("res://Server.tscn")
	server.set_screen_stretch(SceneTree.STRETCH_MODE_2D,SceneTree.STRETCH_ASPECT_EXPAND,Vector2(640,360),1)
	server.get_root().set_update_mode(Viewport.UPDATE_DISABLED)
	client.get_root().set_update_mode(Viewport.UPDATE_WHEN_VISIBLE)
