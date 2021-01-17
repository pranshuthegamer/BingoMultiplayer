extends Node
var hosting = false
var _ServerScene
var udp_network = PacketPeerUDP.new()
var _server = NetworkedMultiplayerENet.new()
var ip = ""
var port = 63389
var connected = false

var greenicon = preload("res://assets/green.png")
var redicon = preload("res://assets/red.png")
var yellowicon = preload("res://assets/yellow.png")
var fontx = preload("res://assets/fontX.tres")
var myturn = false

func _ready():
	if Vars.hosting == false:
		$Button2.hide()
	udp_network = PacketPeerUDP.new()
	if udp_network.listen(8081) != OK:
		print("Error listening on port: ", 8081)
	else:
		print("Listening on port: ",8081)
	_server.connect("connection_succeeded",self,"Connected")
	_server.connect("connection_failed",self,"Failed")

func _input(event):
	if Vars.isshowing == true and Vars.hosting == true:
		Vars.server.input_event(event)
		get_tree().set_input_as_handled()


func _process(delta):
	if udp_network.get_available_packet_count() > 0:
		var array_bytes = udp_network.get_packet()
		var packet_string = array_bytes.get_string_from_ascii()
		
		ip = packet_string
		print(ip)

func ServerConnect():
	if Vars.hosting == true:
		_server.create_client(str("127.0.0.1"),port)
		get_tree().set_network_peer(_server)
		$ip.hide()
	elif $TextEdit.text == "":
		_server.create_client(str(ip),port)
		get_tree().set_network_peer(_server)
		$TextEdit.hide()
		$ip.hide()
	else:
		_server.create_client(str($TextEdit.text),port)
		get_tree().set_network_peer(_server)
		$TextEdit.hide()
		$ip.hide()

func Connected():
	connected = true
	$Button.text = "Ready"
	$TextEdit.hide()

func Failed():
	print("connection failed")
	ServerConnect()
	$ip.text = "Connection failed"
	$TextEdit.show()
	$ip.show()

var wth = 0
var number = 0
var TEMPS = ""
var TEMPI


func _on_data():
	pass
	#TEMPS = _client.get_peer(1).get_packet().get_string_from_utf8()
	print(TEMPS)
	TEMPI = TEMPS.split(",",true,0)
	if TEMPI[0] == "wth":
		wth = TEMPI[0]
		wth = int(TEMPI[0])
		print(wth)
	# Print the received packet, you MUST always use get_peer(1).get_packet
	# to receive data from server, and not get_packet directly when not
	# using the MultiplayerAPI.


func _on_00_pressed():
	if wth == 0 and get_node("Numbers/1").selected == false:
		number = number + 1
		get_node("Numbers/1").text = str(number)
		get_node("Numbers/1").value = number
		get_node("Numbers/1").selected = true

remote func Start():
	wth = 1
	for i in get_node("Numbers").get_children():
		get_node("Numbers/" + str(i.name) + "/TextureRect").texture = redicon

remote func turn():
	myturn = true
	get_node("Turn").text = "YOUR TURN"

remotesync func turnplayed(value):
	var temp1
	for i in get_node("Numbers").get_children():
		if i.value == value:
			temp1 = i
	temp1.selected = true
	temp1.text = "X"
	temp1.set("custom_fonts/font", fontx)
	get_node("Numbers/" + str(temp1.name) + "/TextureRect").texture = greenicon
	myturn = false
	get_node("Turn").text = ""

remote func winner(winner):
	if winner == str(_server.get_unique_id()):
		get_node("Leader").add_text("YOU WON" + "\n")
	else:
		get_node("Leader").add_text(str(winner) + "Won \n")

func _ressed(NAME):
	if wth == 0 and get_node(("Numbers/") + (NAME)).selected == false:
		number = number + 1
		get_node("Numbers/" + NAME).text = str(number)
		get_node("Numbers/" + NAME).value = number
		get_node("Numbers/" + NAME).selected = true
		get_node("Numbers/" + NAME + "/TextureRect").texture = greenicon
		rpc("setnum",NAME,number)
	if wth == 1 and myturn == true:
		if str(get_node("Numbers/" + NAME).text) != "X":
			rpc("turnplayed",get_node("Numbers/" + NAME).value)

remote func reset():
	wth = 0
	for i in get_node("Numbers").get_children():
		i.text = ""
		i.value = 0
		i.selected = false
		i.set("custom_fonts/font", fontx)
		get_node("Numbers/" + str(i.name) + "/TextureRect").texture = yellowicon
		myturn = false
		$Button.text = "Ready"
		$Leader.text = ""
		$Turn.text = ""
		number = 0


func _on_Send_Button_pressed():
	var temp = 0
	if wth == 0:
		for i in $Numbers.get_children():
			if i.value != 0:
				temp = temp + 1
	if temp == 25:
		rpc_id(1,"PlayerReady")
	if connected == false:
		print("connecting")
		ServerConnect()





func _on_Button2_pressed():
	Vars.SwitchToServer()
