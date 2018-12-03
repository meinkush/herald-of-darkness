extends Control

func _ready():
	get_viewport().set_canvas_transform(Transform2D(Vector2(1,0),Vector2(0,1),Vector2(0,0)))
	$Main/Options.connect("pressed", self, "show_menu",["Options"])
	$Main/Multi.connect("pressed", self, "show_menu",["MultiPlayer"])
	$Main/Exit.connect("pressed", self, "show_menu",["Exit"])
	$Main/Single.connect("pressed", self, "begin_game")
	$Main.connect("draw", self, "_view_change")
	$Options/Back.connect("pressed", self, "show_menu",["Main"])
	$Options/Save.connect("pressed", $Options/Change, "show_menu")
	#$Options/Change/Button2.connect("pressed", self, "change_name")
	#$Options/Change/Button.connect("pressed", $Options/Change, "hide")
	$MultiPlayer/Connect/Join.connect("pressed", self, "join")
	$MultiPlayer/Connect/Create.connect("pressed", self, "host")
	$MultiPlayer/Connect/Back.connect("pressed", self, "show_menu",["Main"])
	$MultiPlayer/Lobby/Start.connect("pressed", self, "begin_game")
	$MultiPlayer/Lobby/Back.connect("pressed", self, "disconnect")
	$Exit/Back.connect("pressed", self, "show_menu",["Main"])
	$Exit/Exit.connect("pressed", get_tree(), "quit")
	GameState.connect("connection_succeeded", self, "_on_connection_success")
	GameState.connect("connection_failed", self, "_on_connection_failed")
	GameState.connect("player_list_changed", self, "refresh_lobby")
	show_menu("Main")

func _on_connection_success():
	print('connection succeded')
	return

func _on_connection_failed():
	print('connection failed')
	return

func join():
	$MultiPlayer/Lobby/IP.text = ""
	var ip = $MultiPlayer/Connect/Ip.text
	if !ip.is_valid_ip_address():
		# get_node("connect/error_label").text="Invalid IPv4 address!"
		return
	GameState.join_game(ip)
	refresh_lobby()
	show_menu("Lobby","MultiPlayer")

func disconnected():
	GameState.leave()
	show_menu("Main")

func change_name():
	$Options/Change.hide()
	GameState.player_name = $Options/Name.text
	show_menu("Main")

func host():
	GameState.host_game()
	refresh_lobby()
	for ip in IP.get_local_addresses():
		if ip.begins_with("192"):
			$MultiPlayer/Lobby/IP.text = "Usa esta direccion para conectarte con amigos: "+ ip
			break
	show_menu("Lobby","MultiPlayer")

func refresh_lobby():
	var players = GameState.get_player_list()
	players.sort()
	$MultiPlayer/Lobby/List.clear()
	$MultiPlayer/Lobby/List.add_item(GameState.get_player_name() + " (Tu)")
	for p in players:
		$MultiPlayer/Lobby/List.add_item(p)
	if players.size() == 0 and !get_tree().is_network_server():
		$MultiPlayer/Lobby/Status.text = "Buscando partida..."
	else:
		$MultiPlayer/Lobby/Status.text = ""
	$MultiPlayer/Lobby/Start.disabled = !get_tree().is_network_server()

func show_menu(menu,index = "./"):
  for submenu in get_node(index).get_children():
    if submenu.get_name() != menu:
      submenu.visible = false
    else:
      submenu.visible = true

func begin_game():
	GameState.begin_game("town")

func _view_change():
	$Main/Label.text = "Bienvenido " + GameState.player_name
	show_menu("Connect","MultiPlayer")
