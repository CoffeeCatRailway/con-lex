extends Node

var useWrittenFont: bool = false
var writtenFontPath: String = ""

class SaveEntry:
	var written: String = ""
	var literal: String = ""
	var translate: String = ""
	var speech: String = ""
	
	func _to_string() -> String:
		return "SaveEntry: [\"%s\", \"%s\", \"%s\", \"%s\"]" % [written, literal, translate, speech]

var entries: Dictionary[int, SaveEntry] = {}

#func _process(_delta: float) -> void:
	#if Input.is_action_just_pressed("ui_down"):
		#saveTo("user://test_save.json")

func saveTo(path: String, webBuild: bool) -> void:
	print("Saving to (%s)" % path)
	var data: Dictionary = {
		"useWrittenFont": useWrittenFont,
		"writtenFontPath": writtenFontPath,
		"entries": {}
	}
	
	for entryId in entries:
		var entry := entries[entryId]
		data["entries"][str(entryId)] = {
			"written": entry.written,
			"literal": entry.literal,
			"translate": entry.translate,
			"speech": entry.speech
		}
	
	var json := JSON.stringify(data, "\t")
	#print(json)
	
	if webBuild:
		JavaScriptBridge.download_buffer(json.to_utf8_buffer(), path, "application/x.conlex.clex")
	else:
		var file := FileAccess.open(path, FileAccess.WRITE)
		file.store_line(json)

func loadFrom(path: String, conLex: ConLex, webBuild: bool, webData: String = "") -> void:
	print("Loading from (%s)" % path)
	var data: String
	if webBuild:
		data = webData
	else:
		if !FileAccess.file_exists(path):
			push_warning("Save file (%s) does not exist!" % path)
			return
		
		var file := FileAccess.open(path, FileAccess.READ)
		data = file.get_as_text()
		GlobalVars.currentSavePath = path
	
	var json := JSON.new()
	if json.parse(data) != OK:
		printerr("JSON Parse Error: %s at line %s" % [json.get_error_message(), json.get_error_line()])
		return
	
	if typeof(json.data) != TYPE_DICTIONARY:
		printerr("File formatted incorrectly!")
		return
	
	self.useWrittenFont = json.data["useWrittenFont"]
	self.writtenFontPath = json.data["writtenFontPath"]
	GlobalVars.useWrittenFont = self.useWrittenFont
	if !webBuild: # Don't load fonts on web
		GlobalVars.writtenFont = GlobalVars.loadFont(self.writtenFontPath)
		conLex.useFontBtn.button_pressed = self.useWrittenFont
	
	self.entries.clear()
	conLex.clearEntries()
	
	@warning_ignore("shadowed_variable")
	var entries: Dictionary = json.data["entries"]
	var maxId: int = -1
	for id: String in entries:
		var saveEntry := SaveEntry.new()
		saveEntry.written = entries[id]["written"]
		saveEntry.literal = entries[id]["literal"]
		saveEntry.translate = entries[id]["translate"]
		saveEntry.speech = entries[id]["speech"]
		self.entries[int(id)] = saveEntry
		
		maxId = maxi(maxId, int(id))
		var entry: LexEntry = GlobalVars.LEX_ENTRY.instantiate()
		
		entry.id = int(id)
		
		conLex.entryContainer.add_child(entry)
		entry.writtenLabel.text = saveEntry.written
		entry.literalLabel.text = saveEntry.literal
		entry.translateLabel.text = saveEntry.translate
		entry.speechLabel.text = saveEntry.speech
	
	GlobalVars._currentId = maxId + 1
	if !webBuild: # Don't load fonts on web
		GlobalVars.updateWrittenFont.emit()
