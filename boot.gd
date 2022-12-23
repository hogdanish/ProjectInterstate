extends Control

var main_scene : PackedScene
const main_scene_path := "res://Main.tscn"

var scene_path := main_scene_path # default main scene
var duration : float
var expected_duration : float = 0
enum LoadingStage {LOADING, SPAWNING}
var stage := LoadingStage.LOADING

func _ready():
	print("[boot.gd]")
	print("Bootscreen.gd initialized")
	if OS.has_feature('JavaScript'):
		js_init()
		print("JS detected, running js_init()")
	else:
		print("JS not detected.")
	var file = FileAccess.open("user://boot.time", FileAccess.READ)
	if file:
		expected_duration = file.get_float()
	
	ResourceLoader.load_threaded_request(scene_path, "PackedScene", true)
	# MULTITHREADED LOADING SETTING
	print("WARNING: Make sure to test multithreaded loading before uploading a final version!")
	printraw("Requesting to load main scene: ")
	print(main_scene_path)

func _process(delta):
	duration = Time.get_ticks_msec()
	var clamped_duration = duration / (expected_duration if expected_duration != 0 else 5.0)

#	Loading bar thing
	var new_dur = str(int(clamp(remap((clamped_duration * 100),50 , 100, 1, 100), 1, 100)))
#	$TextureProgressBar.value = duration / (expected_duration if expected_duration != 0 else 5.0)

	if stage == LoadingStage.LOADING:
		print (new_dur + "%")
		var progress : Array = []
		ResourceLoader.load_threaded_get_status(scene_path, progress)

		if progress[0] == 1: # loading finished
			print ("ResourceLoader completed")
			spawn_main_scene()
			stage = LoadingStage.SPAWNING

func js_init():
	var platform = JavaScriptBridge.get_interface("platform")
	var platform_name = platform.get(platform.name.toString())

	print("js_init() successfully finished. Result: ")

func spawn_main_scene() -> void:
	#Globals.os_name = OS.get_model_name()
	#Globals.data_dir = OS.get_data_dir()
	#if OS.has_environment("USERNAME"):
	#	Globals.username = OS.get_environment("USERNAME")
	#else:
	#	Globals.username = OS.get_name()
	#if Globals.os_name.has(Globals.web_os):
		#web_setup() 
	
	print ("Attempting to spawn main scene...")
	var scene = ResourceLoader.load_threaded_get(scene_path)
	var main_scene = scene.instantiate()
	get_tree().root.add_child(main_scene)
	if main_scene:
		Globals.main = main_scene
	else:
		push_error("Main scene failed to load.")

	if expected_duration == 0:
		expected_duration = duration # if nothing was saved, use measired data
	else: # othwerise average loading time with existing data
		expected_duration = (duration + expected_duration) /2

	var file = FileAccess.open("user://boot.time", FileAccess.WRITE)
	if file:
		file.store_float(expected_duration)
		file.flush()

	# free the boot screen
	queue_free()
