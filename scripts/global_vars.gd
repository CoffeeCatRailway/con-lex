extends Node

const LEX_ENTRY = preload("uid://cmkijaun62dm7")

@warning_ignore("unused_signal")
signal updateWrittenFont
var useWrittenFont: bool = false
var writtenFont: Font

var currentSavePath: String = ""

var _currentId: int = 0

func getNextId() -> int:
	var id := _currentId
	_currentId += 1
	return id
