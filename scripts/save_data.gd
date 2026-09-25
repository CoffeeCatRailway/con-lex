extends Node

func saveTo(path: String, conlex: ConLex, webBuild: bool) -> void:
	print("Saving to (%s)" % path)
	var data: Dictionary = {
		"useWrittenFont": GlobalVars.useWrittenFont,
		"writtenFontPath": GlobalVars.writtenFontPath,
		"sortOption": int(GlobalVars.sortOption),
		"entries": {}
	}
	
	var entries := conlex.entryContainer.get_children()
	for entry: LexEntry in entries:
		var speech: int = 0
		for i in range(entry.speechContainer.get_children().size()):
			if entry.speechContainer.get_child(i).visible:
				speech |= 1 << i
		
		data["entries"][entry.id] = {
			"written": entry.writtenLabel.text,
			"literal": entry.literalLabel.text,
			"translate": entry.translateLabel.text,
			#"speech": entry.speechLabel.text
			"speech": speech
		}
	
	var json := JSON.stringify(data, "\t")
	#print(json)
	
	if webBuild:
		JavaScriptBridge.download_buffer(json.to_utf8_buffer(), path, "application/x.conlex.clex")
	else:
		var file := FileAccess.open(path, FileAccess.WRITE)
		file.store_line(json)
	
	conlex.loadedLabel.text = "Current: %s" % path.split("/")[-1]
	GlobalVars.needsSaving = false

func loadFrom(path: String, conlex: ConLex, webBuild: bool, webData: String = "") -> void:
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
	
	GlobalVars.useWrittenFont = json.data["useWrittenFont"]
	GlobalVars.writtenFontPath = json.data["writtenFontPath"]
	if !webBuild && GlobalVars.useWrittenFont: # Don't load fonts on web
		GlobalVars.writtenFont = GlobalVars.loadFont(GlobalVars.writtenFontPath)
		#var font: Font = GlobalVars.loadFont(GlobalVars.writtenFontPath)
		#if font:
			#GlobalVars.writtenFont = font
		conlex.useFontBtn.button_pressed = GlobalVars.useWrittenFont
	
	conlex.clearEntries()
	
	@warning_ignore("shadowed_variable")
	var entries: Dictionary = json.data["entries"]
	var maxId: int = -1
	for id: String in entries:
		maxId = maxi(maxId, int(id))
		var entry: LexEntry = GlobalVars.LEX_ENTRY.instantiate()
		conlex.entryContainer.add_child(entry)
		entry.id = id
		
		var entryData: Dictionary = entries[id]
		entry.writtenLabel.text = entryData["written"]
		entry.literalLabel.text = entryData["literal"]
		entry.translateLabel.text = entryData["translate"]
		#entry.speechLabel.text = entryData["speech"]
		
		var speech: int = int(entryData["speech"])
		for i in range(entry.speechContainer.get_children().size()):
			entry.speechContainer.get_child(i).visible = speech & 1 << i != 0
			#print(entry.speechContainer.get_child(i).visible)
	
	GlobalVars._currentId = maxId + 1
	if !webBuild: # Don't load fonts on web
		GlobalVars.updateWrittenFont.emit()
	
	GlobalVars.sortOption = int(json.data["sortOption"]) as GlobalVars.SortOption
	conlex.performSort()
	
	conlex.loadedLabel.text = "Current: %s" % path.split("/")[-1]
	GlobalVars.needsSaving = false
