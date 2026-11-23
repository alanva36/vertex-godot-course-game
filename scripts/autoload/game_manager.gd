extends Node

static var score: int = 0;

static func add_score(points: int):
	score += points
	Signals.score_changed.emit()
