class_name Save

const PATH := "user://savegame.json"

static func defaults() -> Dictionary:
	return {"best": 0, "coins": 0, "unlocked": [0], "selected": 0}

static func load_data() -> Dictionary:
	var d := defaults()
	if FileAccess.file_exists(PATH):
		var f := FileAccess.open(PATH, FileAccess.READ)
		if f:
			var parsed = JSON.parse_string(f.get_as_text())
			if parsed is Dictionary:
				for k in parsed:
					d[k] = parsed[k]
			f.close()
	return d

static func save_data(d: Dictionary) -> void:
	var f := FileAccess.open(PATH, FileAccess.WRITE)
	if f:
		f.store_string(JSON.stringify(d, "  "))
		f.close()
