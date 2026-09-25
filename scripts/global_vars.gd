extends Node

const LEX_ENTRY = preload("uid://cmkijaun62dm7")

@warning_ignore("unused_signal")
signal updateWrittenFont
var useWrittenFont: bool = false
var writtenFontPath: String = ""
var writtenFont: Font

var currentSavePath: String = ""

enum SortOption {
	WRITTEN,
	LITERAL,
	TRANSLATE,
	SPEECH,
	NONE
}
var sortOption := SortOption.NONE
@warning_ignore("unused_signal")
signal performSort
var findOption := SortOption.NONE

enum SpeechPart {
	ADJECTIVE,
	ADVERB,
	ARTICLE,
	AUXILIARY_VERB,
	CONJUNCTION,
	COVERB,
	DETERMINER,
	INTERJECTION,
	NOUN,
	NUMERAL,
	PARTICLE,
	PREPOSITION,
	PREVERB,
	PRONOUN,
	VERB,
}
var speechSort := SpeechPart.ADJECTIVE

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

func getTimeId() -> String:
	var id := _currentId
	_currentId += 1
	return str(id)

func loadFont(path: String) -> Font:
	if !FileAccess.file_exists(path):
		push_warning("Font file (%s) does not exist!" % path)
		return null
	var font := FontFile.new()
	font.load_dynamic_font(path)
	return font
