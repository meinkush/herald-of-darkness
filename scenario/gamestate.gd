extends Node

const DEFAULT_PORT = 10567

const MAX_PEERS = 4

var players = {}

var player_name = "Jugador 1"

var peer

var nid = 1

var viewport_size = 1

signal player_list_changed()
signal connection_failed()
signal connection_succeeded()

func _ready():
	get_tree().connect("network_peer_connected", self, "_player_connected")
	get_tree().connect("network_peer_disconnected", self,"_player_disconnected")
	get_tree().connect("connected_to_server", self, "_connected_ok")
	get_tree().connect("connection_failed", self, "_connected_fail")
	get_tree().connect("server_disconnected", self, "_server_disconnected")

func _player_connected(id):
	pass

func _player_disconnected(id):
	if (get_tree().is_network_server()):
		if (has_node("/root/world")):
			print('host disconnected')
			end_game()
		else:
			rpc("unregister_player", id)

func _connected_ok():
	rpc("register_player", get_tree().get_network_unique_id(), player_name)
	emit_signal("connection_succeeded")

func _server_disconnected():
	print("Server disconnected")
	end_game()

func _connected_fail():
	get_tree().set_network_peer(null)
	emit_signal("connection_failed")

remote func register_player(id, new_player_name):
	if (get_tree().is_network_server()):
		rpc_id(id, "register_player", 1, player_name)
		for p_id in players:
			rpc_id(id, "register_player", p_id, players[p_id])
			rpc_id(p_id, "register_player", id, new_player_name)
	players[id] = new_player_name
	emit_signal("player_list_changed")

sync func unregister_player(id):
	players.erase(id)
	emit_signal("player_list_changed")

func host_game():
	peer = NetworkedMultiplayerENet.new()
	peer.connect("peer_disconnected",self,"a")
	peer.create_server(DEFAULT_PORT, MAX_PEERS)
	get_tree().set_network_peer(peer)

func a(id):
	rpc("remove_player", id)

sync func remove_player(id):
	for player in get_tree().get_nodes_in_group("players"):
		if player.get_network_master() == id:
			for mob in get_tree().get_nodes_in_group('mobs'):
				if mob.target == player:
					mob.target = null
			player.queue_free()
func join_game(ip):
	peer = NetworkedMultiplayerENet.new()
	peer.create_client(ip, DEFAULT_PORT)
	get_tree().set_network_peer(peer)

func leave():
	peer.close_connection()
	peer = null

func get_player_list():
	return players.values()

func get_player_name():
	return player_name

func begin_game(level):
	if !peer:
		host_game()
	players[get_tree().get_network_unique_id()] = player_name
	rpc("pre_start_game",players,level)
	pre_start_game(players,level)

func end_game():
	if has_node("/root/Scenario"):
		get_node("/root/Scenario").queue_free()
	var menu = load("res://UI/main_menu.tscn").instance()
	get_tree().get_root().add_child(menu)
	get_tree().set_network_peer(null)

remote func pre_start_game(player_list,level):
	nid = get_tree().get_network_unique_id()
	var world = load("res://scenario/scenario_base.tscn").instance()
	world.populate(level)
	get_tree().get_root().add_child(world)
	world.spawn_players(player_list)
	for p_id in player_list:
		#p_id.set_network_master(p_id)
		if (p_id == get_tree().get_network_unique_id()):
			pass
			# p_id.set_player_name(player_name)
		else:
			pass
			# p_id.set_player_name(players[p_id])
	if (not get_tree().is_network_server()):
		rpc_id(1, "ready_to_start", get_tree().get_network_unique_id())
	peer.set_refuse_new_connections(true)
	get_tree().set_pause(false)
	get_node('/root/Menu').queue_free()

var players_ready = []

remote func ready_to_start(id):
	assert(get_tree().is_network_server())
	if (not id in players_ready):
		players_ready.append(id)
	if (players_ready.size() == players.size()-1):
		rpc("start_game")
