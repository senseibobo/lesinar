extends Node


signal quests_updated()

enum Quest {
	PICK_UP_CORPSE,
	PICK_UP_TOOL,
	DIG_GRAVE,
	BURY_BODY,
	FILL_QUOTA
}


const QUEST_TEXT: Dictionary[int, String] = {
	int(Quest.PICK_UP_CORPSE): "Pick up a corpse from one of the drawers.",
	int(Quest.PICK_UP_TOOL): "Pick up a tool to the left of the exit.",
	int(Quest.DIG_GRAVE): "Dig a grave.",
	int(Quest.BURY_BODY): "Bury the corpse into the grave.",
	int(Quest.FILL_QUOTA): "Fill out your quota for the day.",
}

var quests_done: Array = [false,false,false,false,false]


func complete_quest(quest: Quest):
	print("COMPLETED QUEST ", quest)
	quests_done[int(quest)] = true
	quests_updated.emit()
