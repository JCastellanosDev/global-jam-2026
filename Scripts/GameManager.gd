extends Node
#Gamemanager controlador principal del sistema de juego Deadl1ne
# Estados del juego
enum GameState {
	MENU,
	CHAT,
	DECISION,
	META_PUZZLE,
	ENDING
}
enum Route {
	STANDART, 
	BAD, 
	TRUE
}
# Variables de estado
var current_state: GameState = GameState.MENU
var current_route: Route= Route.STANDART
var current_day: int =1 
var current_scene_index: int = 0
#estados de los personajes 
var characters_status = {
	"jesus": {"alive": true, "saved": false, "mask_removed": false},
	"diego_s": {"alive": true, "saved": false, "free": false},
	"diego_i": {"alive": true, "saved": false, "can_sleep": false},
	"irvin": {"revealed": false, "forguiven": false }
}
# Deicisiones del usuario o jugador
var player_decisiones =[]

#sistema de archivos
var game_path: String
var meta_files_checked = {
	"jesus_mask": false,
	"facke_contracts": false,
	"diego_logic":false,
	"irvin_chr": false
}
#señales 
signal state_changed(new_state)
signal character_status_changed(character_name, status)
signal route_changed(new_route)
signal meta_puzzle_complemented(puzzle_name)
signal endig_reached(ending_type)

func _ready():
	game_path = OS.get_executable_path().get_base_dir()
	print("Game initialized at: ", game_path)
	print("✅ GameManager está funcionando!") 
	#Gestion de decisiones

func register_decision(decision_id: String, choice: String):
	player_decisiones.append({"id": decision_id, "choice": choice})
	print("Decisión registrada: ", decision_id, " = ", choice)
	
	#cambio de estado
func change_state(new_state: GameState):
	current_state = new_state
	emit_signal("state_changed", new_state)
	print("Estado cambiado a: ", new_state)
