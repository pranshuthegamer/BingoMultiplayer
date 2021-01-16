extends Button

export var value = 0
export var selected = false
var NAME = name
signal ressed(NAME)

func _ready():
	var secondary = get_parent().get_parent()
	connect("ressed", secondary,"_ressed")

func _on_Button_pressed():
	NAME = get(name)
	emit_signal("ressed",name)
