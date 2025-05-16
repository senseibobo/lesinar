class_name QuestDisplay
extends Node3D


@export var quest_label: Label3D


func _ready():
	update_quest_text()
	QuestManager.quests_updated.connect(_on_quests_updated)


func _on_quests_updated():
	update_quest_text()


func update_quest_text():
	for quest in QuestManager.Quest.size():
		if not QuestManager.quests_done[int(quest)]:
			quest_label.text = QuestManager.QUEST_TEXT[int(quest)]
			return
	quest_label.text = ""
