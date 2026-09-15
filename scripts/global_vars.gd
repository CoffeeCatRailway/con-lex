extends Node

const LEX_ENTRY = preload("uid://cmkijaun62dm7")

@warning_ignore("unused_signal")
signal updateWrittenFont
var useWrittenFont: bool = false
var writtenFont: Font

var currentSavePath: String = ""

var _onWebFileLoadedCallback: JavaScriptObject = null
var _currentId: int = 0

func _ready() -> void:
	if OS.get_name() == "Web":
		_onWebFileLoadedCallback = JavaScriptBridge.create_callback(_onWebFileLoaded)
		var gdcallbacks: JavaScriptObject = JavaScriptBridge.get_interface("gd_callbacks")
		gdcallbacks.dataLoaded = _onWebFileLoadedCallback

func webFileUpload(accept: String = "*") -> void:
	if OS.get_name() != "Web":
		return
	JavaScriptBridge.eval("loadFileData('%s')" % accept)

func _onWebFileLoaded(args: Array) -> void:
	if OS.get_name() != "Web":
		return
	SaveData.loadFrom("Web", get_tree().current_scene, true, args[0])

func getNextId() -> int:
	var id := _currentId
	_currentId += 1
	return id
