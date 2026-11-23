extends Label


func _ready() -> void:
	Signals.score_changed.connect(update_label)
	update_label()

func update_label() -> void:
	text = str(GameManager.score)
