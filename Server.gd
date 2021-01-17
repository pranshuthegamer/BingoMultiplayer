extends Node

var currentip = 0 
var auto = false
var brodcaster = PacketPeerUDP.new()
var doit = true
var brodcast = 0
export var ip = ""
var turn = 0
var playerload = preload("res://Player.tscn")
var playernow = []

const possible = [["B1","B2","B3","B4","B5"],
["B6","B7","B8","B9","B10"],
["B11","B12","B13","B14","B15"],
["B16","B17","B18","B19","B20"],
["B21","B22","B23","B24","B25"],
["B1","B6","B11","B16","B21"],
["B2","B7","B12","B17","B22"],
["B3","B8","B13","B18","B23"],
["B4","B9","B14","B19","B24"],
["B5","B10","B15","B20","B25"],
["B1","B7","B13","B19","B25"],
["B5","B9","B13","B17","B21"]
]
var slots = [Vector2(416,240),Vector2(208,240),Vector2(0,240),Vector2(832,0),Vector2(624,0),Vector2(416,0),Vector2(208,0),Vector2(0,0)]
var temparray = []
var players = []

# The port we will listen to
const port = 63389
# Our WebSocketServer instance
var _server = NetworkedMultiplayerENet.new()
var wth = 0
var TEMP = ""
var temppos = Vector2()


func _ready():
	auto = get_node("Button2").pressed
	StartServer()
	brodcaster.set_broadcast_enabled(true)
	var temp1 = IP.get_local_addresses()
	for i in temp1:
		var temp = i.split(".")
		if str(temp[0]) == "192":
			ip = PoolStringArray(temp).join(".")
			print(ip)



func _process(delta):
	brodcast -= delta
	if brodcast <= 0 and doit == true:
		brodcast = 5
		print("sending")
		for adress in IP.get_local_addresses():
			var address = adress.split("[")
			var parts = address[0].split('.')
			if (parts[0] == "192"):
				currentip = parts.join('.')
				parts[3] = '255'
				brodcaster.set_dest_address(parts.join('.'), 8081)
				var pac = str(ip).to_ascii()
				var error = brodcaster.put_packet(pac)
				print('sending', parts)
				if error == 1:
					print("Error while sending to ", ip, ":", 8081)


func StartServer():
	_server.create_server(port,8)
	get_tree().set_network_peer(_server)
	
	_server.connect("peer_connected",self,"PeerConnected")
	_server.connect("peer_disconnected",self,"PeerDisconnected")

func PeerConnected(playerid):
	print(str(playerid) + " connected")
	add_child(playerload.instance())
	get_node("CanvasLayer/Label").text = str(playerid)
	get_node("CanvasLayer").name = str(playerid)
	temppos = [slots[slots.size() - 1]]
	print(temppos)
	get_node(str(playerid)).offset = Vector2(temppos[0])
	slots.remove(slots.size() - 1) 
	players = players + [playerid]


remote func setnum(NAME,number):
	get_node(str(get_tree().get_rpc_sender_id()) + "/Numbers/" + NAME).text = str(number)

remote func PlayerReady():
	print(str(get_tree().get_rpc_sender_id()) + " is ready")
	get_node(str(get_tree().get_rpc_sender_id())).ready = true
	var temp = 0
	for i in get_children():
		if i is CanvasLayer and i.ready == true:
			temp = temp + 1
	if temp == get_child_count() - 3 :
		playernow = players.duplicate(true)
		rpc("Start")
		Start()
		print("game starting")
		doit = false


func Start():
	if playernow.size() - 1 < turn:
		turn = 0 
	if auto == true and playernow.size() == 0:
		yield(get_tree().create_timer(5), "timeout")
		_on_Button_pressed()
	if playernow.size() > 0:
		wth = 1
		rpc_id(playernow[turn],"turn")
		print(playernow[turn],"'s turn")
		turn = turn + 1

remote func turnplayed(value):
	print("Turn played ",value)
	for i in get_children():
		if i is CanvasLayer:
			for v in i.get_node("Numbers").get_children():
				if v.text == str(value):
					v.text = "X"
					v.selected = true
	for i in get_children():
		var temp = 0
		if i is CanvasLayer:
			if i.won == false:
				for v in possible:
					var temp1 = 0
					for vv in v:
						if i.get_node("Numbers/" + str(vv)).selected == true:
							temp1 = temp1 + 1
					if temp1 >= 5:
						print(i.name ," found combination")
						temp = temp+1
						print("temp = ",temp)
			if temp >= 5:
				playernow.find(i.name)
				print("found player")
				rpc("winner",i.name)
				print(i.name," WON!")
				var temp1 = playernow.find(int(i.name))
				playernow.remove(temp1)
	if wth == 1:
		Start()


func PeerDisconnected(playerid):
	print(str(playerid) + " disconnected")
	temparray = [get_node(str(playerid)).offset]
	slots = slots + temparray
	get_node(str(playerid)).queue_free()
	players.remove(players.find(playerid))

func _on_Button_pressed():
	rpc("reset")
	doit = true
	wth = 0
	playernow = []
	for i in get_children():
		if i is CanvasLayer:
			var tempname = i.name
			var temparry = [get_node(str(tempname)).offset]
			slots = slots + temparry
			i.queue_free()
			yield(get_tree().create_timer(0), "timeout")
			add_child(playerload.instance())
			get_node("CanvasLayer/Label").text = str(tempname)
			get_node("CanvasLayer").name = str(tempname)
			temppos = [slots[slots.size() - 1]]
			print(temppos)
			get_node(str(tempname)).offset = Vector2(temppos[0])
			slots.remove(slots.size() - 1) 




func _on_Button2_toggled(button_pressed):
	auto = button_pressed




func _on_Button3_pressed():
	Vars.SwitchToClient()
