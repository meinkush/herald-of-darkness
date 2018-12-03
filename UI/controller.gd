extends Control

var f_camera_pos = Vector2()

func _ready():
	$End/Button.connect("pressed", self, "back_to_menu")
	$End/Button2.connect("pressed", get_tree(), "quit")
	$Exit/Button.connect("pressed", self, "keep")
	$Exit/Button2.connect("pressed", self, "back_to_menu")
	$Die/Button.connect("pressed", self, "back_to_menu")
	$Die/Button2.connect("pressed", get_tree(), "quit")
	get_viewport().connect("size_changed",self,"resize")
	set_physics_process(false)
	_menu_show()
	resize()

func _menu_show(menu = ""):
	for submenu in $Menu.get_children():
    if submenu.get_name() != menu:
      submenu.visible = false
    else:
      submenu.visible = true

func _menu_list_selected(index):
	if index == 0:
		_hide_menu()
		$MenuList.unselect(index)
	elif index == 1:
		_menu_show("Items")

func _show_menu():
	$MenuList.show()

func _hide_menu():
	_menu_show()
	$MenuList.hide()

func _on_Button_pressed():
	$Exit.show()
	set_process_input(false)

func keep():
	$Exit.hide()
	set_process_input(true)

func back_to_menu():
	GameState.peer.close_connection()
	set_process_input(false)
	set_physics_process(false)
	var menu = load("res://UI/main_menu.tscn").instance()
	get_tree().get_root().add_child(menu)
	get_tree().set_network_peer(null)
	get_node("/root/Scenario").queue_free()
	GameState.players = {}

func win():
	$Button.hide()
	set_physics_process(false)
	set_process_input(false)
	$End.show()

func resize():
	rect_size = get_viewport().size/GameState.viewport_size

func _on_VSlider_value_changed(value):
	GameState.viewport_size = value
	get_node("/root/Scenario/HUD").rect_scale = Vector2(1,1)/GameState.viewport_size
