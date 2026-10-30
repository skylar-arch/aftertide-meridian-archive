extends Node2D

const BG := Color("071a26")
const PANEL := Color("102b38")
const PANEL2 := Color("153645")
const INK := Color("e8e1cf")
const MUTED := Color("91a9aa")
const AQUA := Color("71d6c5")
const GOLD := Color("e4b879")
const RED := Color("da7771")

var screen := "title"
var panel := "chart"
var day := 1
var hull := 78
var oxygen := 92
var morale := 67
var salvage := 4
var charge := 12
var records := 0
var beacon := 16
var selected_site := 0
var last_site := 0
var last_choice := 0
var result_text := ""
var memory_choice := false
var upgraded := false
var crew_names := ["MARA VENN", "IVO RUSK", "NIA SOL"]
var crew_roles := ["DIVE LEAD", "ENGINEER", "ARCHIVIST"]
var logs := ["MERIDIAN // expedition log initialized", "The surface has been quiet for 43 years."]
var buttons: Array[Dictionary] = []

const SITES := [
	{"name":"LANTERN DISTRICT", "type":"SALVAGE", "desc":"A neighborhood still lit beneath the silt.", "risk":1},
	{"name":"CROWN STATION", "type":"SIGNAL", "desc":"A relay tower repeats a voice at low tide.", "risk":2},
	{"name":"THE BLUE VAULT", "type":"ARCHIVE", "desc":"Pressure doors. A warm pulse behind them.", "risk":3},
]

func _ready() -> void:
	get_window().title = "AFTERTIDE — The Meridian Archive"
	queue_redraw()

func _draw() -> void:
	buttons.clear()
	draw_rect(Rect2(0, 0, 1280, 720), BG)
	_draw_backdrop()
	if screen == "title": _draw_title()
	elif screen == "bridge": _draw_bridge()
	elif screen == "event": _draw_event()
	elif screen == "ending": _draw_ending()

func _draw_backdrop() -> void:
	for i in range(10):
		var y := 68.0 + i * 67.0
		draw_line(Vector2(0, y), Vector2(1280, y + sin(float(i) * 0.8) * 5.0), Color(0.18, 0.42, 0.48, 0.08), 1.0)
	draw_circle(Vector2(1090, 155), 135, Color(0.12, 0.36, 0.39, 0.09))
	draw_circle(Vector2(1090, 155), 82, Color(0.12, 0.36, 0.39, 0.07))

func _draw_title() -> void:
	_draw_text("FIELD DOSSIER   /   07.14.2198", Vector2(72, 66), 15, AQUA)
	_draw_text("AFTERTIDE", Vector2(70, 240), 74, INK)
	_draw_text("THE MERIDIAN ARCHIVE", Vector2(76, 282), 21, GOLD)
	draw_line(Vector2(76, 310), Vector2(560, 310), Color(AQUA, 0.45), 2)
	_draw_text("THE WORLD WENT UNDER. THE LIGHTS DIDN'T.", Vector2(76, 352), 18, INK)
	_draw_text("Lead a salvage crew through the drowned city. Keep the hull alive,\nrecover the archive, and decide what deserves to wake again.", Vector2(76, 400), 17, MUTED)
	_panel(Rect2(770, 108, 420, 430), PANEL)
	_draw_text("MERIDIAN // DEPTH 4,210 M", Vector2(802, 147), 15, AQUA)
	_draw_city_art()
	_draw_text("BLACK WATER / LOW SIGNAL", Vector2(802, 494), 13, MUTED)
	_button(Rect2(76, 494, 244, 56), "BEGIN EXPEDITION", "start", AQUA)
	_draw_text("A single-player strategy story  ·  20–30 min first run", Vector2(76, 585), 14, MUTED)
	_draw_text("BUILD 0.1  /  VERTICAL SLICE", Vector2(76, 650), 12, MUTED)

func _draw_city_art() -> void:
	var base := Vector2(790, 180)
	for x in range(7):
		var bx := base.x + x * 54
		var h := 92.0 + float((x * 47 + x * x * 9) % 140)
		var rect := Rect2(bx, base.y + 260 - h, 38, h)
		draw_rect(rect, Color(0.09, 0.22, 0.28))
		draw_rect(Rect2(bx + 5, rect.position.y + 12, 3, h - 22), Color(0.24, 0.49, 0.5, 0.42))
		for wy in range(int(rect.position.y + 18), int(base.y + 250), 23):
			if wy < rect.end.y and ((x + wy) % 3 != 0): draw_rect(Rect2(bx + 13, wy, 6, 3), Color(GOLD, 0.7))
	draw_line(Vector2(790, 450), Vector2(1160, 450), Color(AQUA, 0.45), 2)
	draw_arc(Vector2(1080, 340), 36, 0, TAU, 40, Color(AQUA, 0.8), 2)
	draw_circle(Vector2(1080, 340), 5, GOLD)

func _draw_bridge() -> void:
	_draw_header()
	_draw_stats()
	if panel == "chart": _draw_chart()
	elif panel == "crew": _draw_crew()
	else: _draw_archive()
	_draw_footer()

func _draw_header() -> void:
	_draw_text("AFTERTIDE  /  MERIDIAN EXPEDITION", Vector2(38, 36), 16, AQUA)
	_draw_text("OPERATIONAL DAY %02d  /  07" % day, Vector2(1005, 36), 14, GOLD)
	draw_line(Vector2(38, 52), Vector2(1242, 52), Color(AQUA, 0.24), 1)
	var nav_y := 67.0
	_button(Rect2(38, nav_y, 128, 34), "CHART", "tab_chart", AQUA if panel == "chart" else PANEL2)
	_button(Rect2(174, nav_y, 128, 34), "CREW", "tab_crew", AQUA if panel == "crew" else PANEL2)
	_button(Rect2(310, nav_y, 128, 34), "ARCHIVE", "tab_archive", AQUA if panel == "archive" else PANEL2)
	_draw_text("LAST LIGHT / SHIP'S BRIDGE", Vector2(892, 89), 12, MUTED)

func _draw_stats() -> void:
	var x := 455.0
	var stats := [["HULL", hull, 100, AQUA], ["O₂", oxygen, 100, Color("a4c9e3")], ["CREW", morale, 100, GOLD], ["BEACON", beacon, 100, Color("e5a96e")]]
	for s in stats:
		_panel(Rect2(x, 64, 178, 44), PANEL)
		_draw_text(s[0], Vector2(x + 10, 81), 10, MUTED)
		_draw_text("%d%%" % s[1], Vector2(x + 10, 101), 18, INK)
		draw_rect(Rect2(x + 67, 91, 98, 6), Color(0.04, 0.12, 0.16))
		draw_rect(Rect2(x + 67, 91, 98 * clamp(float(s[1]) / 100.0, 0.0, 1.0), 6), s[3])
		x += 187

func _draw_chart() -> void:
	_panel(Rect2(38, 120, 780, 478), PANEL)
	_draw_text("MERIDIAN CITY  /  SURVEY CHART", Vector2(62, 151), 16, INK)
	_draw_text("Select a dive site. Every descent spends oxygen and costs one day.", Vector2(62, 177), 13, MUTED)
	_draw_map()
	var site = SITES[selected_site]
	_panel(Rect2(840, 120, 402, 228), PANEL)
	_draw_text("TARGET LOCK", Vector2(864, 151), 13, AQUA)
	_draw_text(site.name, Vector2(864, 192), 23, INK)
	_draw_text(site.type + "  /  THREAT " + "●".repeat(site.risk), Vector2(864, 220), 13, GOLD)
	_draw_text(site.desc, Vector2(864, 249), 14, MUTED)
	_draw_text("POTENTIAL: SALVAGE · CHARGE · RECORDS", Vector2(864, 291), 11, AQUA)
	_panel(Rect2(840, 364, 402, 234), PANEL)
	_draw_text("SHIP INVENTORY", Vector2(864, 395), 14, INK)
	_draw_text("SCRAP", Vector2(864, 435), 12, MUTED); _draw_text("%02d" % salvage, Vector2(1180, 435), 18, GOLD)
	_draw_text("BEACON CHARGE", Vector2(864, 475), 12, MUTED); _draw_text("%02d" % charge, Vector2(1180, 475), 18, AQUA)
	_draw_text("MEMORY SHARDS", Vector2(864, 515), 12, MUTED); _draw_text("%02d" % records, Vector2(1180, 515), 18, INK)
	_button(Rect2(840, 535, 188, 45), "UPGRADE HULL  /  3", "upgrade_hull", GOLD)
	_button(Rect2(1038, 535, 204, 45), "DIVE TO SITE  →", "dispatch", AQUA)
	_draw_log(Rect2(38, 610, 1204, 63))

func _draw_map() -> void:
	var mapbox := Rect2(62, 198, 732, 388)
	for i in range(6):
		var y := 218 + i * 59
		draw_line(Vector2(72, y), Vector2(782, y + 16), Color(AQUA, 0.08), 1)
	for i in range(8):
		var x := 82 + i * 96
		draw_line(Vector2(x, 205), Vector2(x - 10, 570), Color(AQUA, 0.07), 1)
	# Surveyed routes
	var points := [Vector2(140, 490), Vector2(350, 360), Vector2(565, 270)]
	draw_line(points[0], points[1], Color(AQUA, 0.34), 3)
	draw_line(points[1], points[2], Color(AQUA, 0.2), 2)
	for i in range(3):
		var p: Vector2 = points[i]
		var active := selected_site == i
		draw_circle(p, 30 if active else 24, Color(AQUA, 0.13 if active else 0.07))
		draw_circle(p, 17, AQUA if active else Color("37616a"))
		draw_circle(p, 6, BG)
		var label: String = SITES[i].name
		_draw_text(label, p + Vector2(30, 5), 12, INK if active else MUTED)
		_add_button(Rect2(p.x - 33, p.y - 33, 66, 66), "site_%d" % i)
	_draw_text("YOU ARE HERE", Vector2(82, 544), 10, GOLD)
	draw_circle(Vector2(140, 516), 3, GOLD)
	# Subtle bathymetric contour rings around the far signal.
	for r in range(4):
		draw_arc(Vector2(650, 326), 46 + r * 19, 0.25, 5.55, 48, Color(AQUA, 0.10 - r * 0.015), 1.0)

func _draw_crew() -> void:
	_panel(Rect2(38, 120, 1204, 478), PANEL)
	_draw_text("CREW MANIFEST  /  THREE DIVERS, ONE LAST CHANCE", Vector2(64, 155), 17, INK)
	_draw_text("Fatigue follows every descent. Keep morale above zero to finish the operation.", Vector2(64, 182), 14, MUTED)
	var cols := [Color("dba77a"), Color("7dabb2"), Color("c28fb0")]
	for i in range(3):
		var x := 64 + i * 386
		_panel(Rect2(x, 212, 356, 260), PANEL2)
		draw_circle(Vector2(x + 52, 270), 29, cols[i])
		draw_circle(Vector2(x + 52, 261), 11, Color("102b38"))
		draw_arc(Vector2(x + 52, 293), 19, PI, TAU, 18, Color("102b38"), 8)
		_draw_text(crew_names[i], Vector2(x + 94, 252), 17, INK)
		_draw_text(crew_roles[i], Vector2(x + 94, 274), 11, AQUA)
		_draw_text(["Never leaves a diver behind.", "Can patch hull breaches mid-dive.", "Hears a voice in the old relay."][i], Vector2(x + 24, 334), 13, MUTED)
		_draw_text("STATUS", Vector2(x + 24, 392), 10, MUTED)
		_draw_text("READY" if morale > 20 else "STRAINED", Vector2(x + 24, 420), 15, GOLD if morale > 20 else RED)
	_panel(Rect2(64, 498, 1118, 73), PANEL)
	_draw_text("FIELD DOCTRINE", Vector2(88, 528), 12, AQUA)
	_draw_text("Mara opens the route. Ivo keeps the vessel breathing. Nia reads the signal beneath the noise.", Vector2(260, 531), 14, INK)
	_draw_log(Rect2(38, 610, 1204, 63))

func _draw_archive() -> void:
	_panel(Rect2(38, 120, 1204, 478), PANEL)
	_draw_text("THE MERIDIAN ARCHIVE", Vector2(64, 156), 21, INK)
	_draw_text("Recovered fragments are changing the signal. Decide what you believe it is.", Vector2(64, 184), 14, MUTED)
	for i in range(4):
		var y := 222 + i * 79
		_panel(Rect2(64, y, 1118, 61), PANEL2)
		var unlocked := records >= i + 1
		_draw_text("0%d" % (i + 1), Vector2(88, y + 37), 16, GOLD if unlocked else MUTED)
		_draw_text(["THE WEATHER LOG", "A CHILD'S MAP", "VOICEPRINT  /  LUMEN", "THE FIRST EVACUATION"][i], Vector2(145, y + 27), 14, INK if unlocked else MUTED)
		_draw_text(["No storm was recorded that night.", "The city is drawn from below.", "It says the old crew is still on board.", "The archive remembers who was left behind."][i] if unlocked else "SIGNAL NOT YET RECOVERED", Vector2(500, y + 37), 13, AQUA if unlocked else Color("526c73"))
	_draw_text("Recovered records: %d / 4" % min(records, 4), Vector2(66, 562), 13, AQUA)
	_draw_log(Rect2(38, 610, 1204, 63))

func _draw_footer() -> void:
	# log/footer area is drawn by current panel
	pass

func _draw_log(box: Rect2) -> void:
	_panel(box, Color("0a202b"))
	_draw_text("LOG", Vector2(box.position.x + 16, box.position.y + 24), 10, AQUA)
	_draw_text(logs[logs.size() - 1], Vector2(box.position.x + 70, box.position.y + 25), 12, MUTED)
	_draw_text("%02d" % logs.size(), Vector2(box.end.x - 40, box.position.y + 25), 11, GOLD)

func _draw_event() -> void:
	_draw_header()
	var site = SITES[last_site]
	_panel(Rect2(86, 132, 1108, 495), PANEL)
	_draw_text("DIVE REPORT  /  DAY %02d" % day, Vector2(120, 172), 13, AQUA)
	_draw_text(site.name, Vector2(120, 218), 30, INK)
	_draw_text("DEPTH 4,210 M     ·     PRESSURE RISING     ·     LINK UNSTABLE", Vector2(120, 246), 12, GOLD)
	draw_line(Vector2(120, 270), Vector2(1160, 270), Color(AQUA, 0.2), 1)
	var narrative := _event_narrative(last_site)
	_draw_text(narrative, Vector2(120, 325), 19, INK)
	_draw_text("MARA: \"We have time for one decision. Not two.\"", Vector2(120, 392), 15, MUTED)
	_button(Rect2(120, 486, 470, 76), _choice_label(0), "choice_0", AQUA)
	_button(Rect2(620, 486, 470, 76), _choice_label(1), "choice_1", GOLD)
	_draw_text("Crew condition and recovered data persist between dives.", Vector2(120, 593), 12, MUTED)

func _draw_ending() -> void:
	_draw_text("EXPEDITION CLOSED  /  MERIDIAN ARCHIVE", Vector2(70, 70), 14, AQUA)
	_draw_text("THE LIGHT REMAINS.", Vector2(70, 185), 48, INK)
	_draw_text(result_text, Vector2(76, 235), 18, GOLD)
	_panel(Rect2(76, 292, 770, 207), PANEL)
	_draw_text("FINAL REPORT", Vector2(104, 328), 14, AQUA)
	_draw_text("BEACON OUTPUT     %d%%" % beacon, Vector2(104, 374), 17, INK)
	_draw_text("ARCHIVE FRAGMENTS     %d" % records, Vector2(104, 408), 17, INK)
	_draw_text("CREW MORALE     %d%%" % morale, Vector2(104, 442), 17, INK)
	_draw_text("ENDING: " + ("A VOICE RETURNS" if memory_choice else "A CITY AT REST"), Vector2(104, 476), 13, GOLD)
	_button(Rect2(76, 552, 250, 54), "NEW EXPEDITION", "restart", AQUA)
	_draw_text("There is more below. There is always more below.", Vector2(76, 639), 14, MUTED)

func _draw_text(text: String, pos: Vector2, size: int, color: Color) -> void:
	draw_string(ThemeDB.fallback_font, pos, text, HORIZONTAL_ALIGNMENT_LEFT, -1, size, color)

func _panel(rect: Rect2, color: Color) -> void:
	draw_rect(rect, color)
	draw_rect(Rect2(rect.position, Vector2(rect.size.x, 1)), Color(AQUA, 0.16))
	draw_rect(Rect2(rect.position + Vector2(0, rect.size.y - 1), Vector2(rect.size.x, 1)), Color(AQUA, 0.09))

func _button(rect: Rect2, label: String, action: String, tint: Color) -> void:
	_add_button(rect, action)
	var hover := rect.has_point(get_global_mouse_position())
	var fill := tint if tint == AQUA or tint == GOLD else PANEL2
	draw_rect(rect, Color(fill, 0.88 if hover else 0.58))
	draw_rect(rect, Color(tint, 0.85), false, 1.4)
	var font_size := 14 if label.length() < 24 else 12
	var text_width := ThemeDB.fallback_font.get_string_size(label, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x
	draw_string(ThemeDB.fallback_font, Vector2(rect.position.x + (rect.size.x - text_width) / 2, rect.position.y + rect.size.y / 2 + 5), label, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, BG if tint in [AQUA, GOLD] else INK)

func _add_button(rect: Rect2, action: String) -> void:
	buttons.append({"rect": rect, "action": action})

func _draw_text_shadow(text: String, pos: Vector2, size: int, color: Color) -> void:
	_draw_text(text, pos + Vector2(1, 2), size, Color(BG, 0.8))
	_draw_text(text, pos, size, color)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		for item in buttons:
			if item.rect.has_point(event.position):
				_handle(item.action)
				get_viewport().set_input_as_handled()
				return
	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		if screen == "event": screen = "bridge"
		queue_redraw()

func _handle(action: String) -> void:
	if action == "start": _new_run()
	elif action.begins_with("site_"):
		selected_site = int(action.trim_prefix("site_")); panel = "chart"
	elif action == "tab_chart": panel = "chart"
	elif action == "tab_crew": panel = "crew"
	elif action == "tab_archive": panel = "archive"
	elif action == "dispatch": _dispatch()
	elif action == "upgrade_hull": _upgrade()
	elif action == "choice_0": _resolve(0)
	elif action == "choice_1": _resolve(1)
	elif action == "restart": _new_run()
	queue_redraw()

func _new_run() -> void:
	screen = "bridge"; panel = "chart"; day = 1; hull = 78; oxygen = 92; morale = 67
	salvage = 4; charge = 12; records = 0; beacon = 16; selected_site = 0; upgraded = false; memory_choice = false
	logs = ["MERIDIAN // expedition log initialized", "The surface has been quiet for 43 years."]

func _dispatch() -> void:
	if day > 7: _close_run(); return
	if oxygen < 15: _log("DIVE ABORTED // oxygen reserve too low."); return
	last_site = selected_site
	oxygen -= 10 + int(SITES[last_site].risk) * 5
	hull -= int(SITES[last_site].risk) * 3
	morale -= 2 + int(SITES[last_site].risk)
	screen = "event"
	_log("DAY %02d // descended to %s." % [day, SITES[last_site].name])

func _event_narrative(site: int) -> String:
	if site == 0: return "A tram car is pinned under the old market.\nIts emergency lamps blink in a pattern that looks almost deliberate."
	if site == 1: return "The relay is broadcasting a roll call from the evacuation.\nOne name is Mara's. She has never told you she was there."
	return "The vault opens onto a room with dry air and warm lights.\nA voice asks you to bring the city back exactly as it was."

func _choice_label(choice: int) -> String:
	if last_site == 0:
		return "SALVAGE THE TRAM  /  +SCRAP, RISK HULL" if choice == 0 else "FOLLOW THE LIGHTS  /  +RECORD, RISK O₂"
	if last_site == 1:
		return "CUT THE RELAY  /  +CHARGE, PROTECT CREW" if choice == 0 else "ANSWER THE SIGNAL  /  +RECORD, RISK MORALE"
	return "TAKE THE CORE  /  +CHARGE, RISK HULL" if choice == 0 else "LET LUMEN SPEAK  /  +RECORD, OPEN MEMORY"

func _resolve(choice: int) -> void:
	last_choice = choice
	if last_site == 0:
		if choice == 0: salvage += 3; hull -= 4; _log("TRAM SALVAGED // Mara found the passenger manifest.")
		else: records += 1; oxygen -= 6; _log("LIGHT PATTERN RECORDED // someone was guiding them out.")
	elif last_site == 1:
		if choice == 0: charge += 14; morale += 3; _log("RELAY DISCONNECTED // the ship is quiet again.")
		else: records += 1; morale -= 8; _log("SIGNAL ANSWERED // a second voice answered from the bridge.")
	else:
		if choice == 0: charge += 20; hull -= 8; _log("CORE SECURED // pressure damage contained.")
		else: records += 2; memory_choice = true; morale -= 5; _log("LUMEN AWAKENED // it remembers the crew by name.")
	beacon = clampi(beacon + int(charge / 3) + (4 if last_site == 1 and choice == 0 else 0), 0, 100)
	oxygen = min(100, oxygen + 18) # surface resupply after each completed dive
	day += 1
	if hull <= 0 or morale <= 0 or oxygen <= 0 or day > 7: _close_run()
	else: screen = "bridge"

func _upgrade() -> void:
	if upgraded: _log("ENGINEER // one hull refit per expedition."); return
	if salvage < 3: _log("UPGRADE FAILED // need 3 salvage units."); return
	salvage -= 3; hull = min(100, hull + 22); oxygen = min(100, oxygen + 8); upgraded = true
	_log("HULL PATCH // Ivo reinforced the dive bell. +22 hull, +8 oxygen.")

func _close_run() -> void:
	screen = "ending"
	if hull <= 0: result_text = "The dive bell failed before dawn. The city keeps its secrets."
	elif morale <= 0: result_text = "The crew turned back together. The beacon will wait one more year."
	elif beacon >= 65: result_text = "After seven watches, the Meridian beacon cuts a path through the dark."
	else: result_text = "The crew surfaced with fragments, not answers. The signal still waits below."

func _log(message: String) -> void:
	logs.append(message)
	if logs.size() > 10: logs.pop_front()
