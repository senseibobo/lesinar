class_name NormalGrave
extends Grave


@export var name_label: Label3D
@export var year_label: Label3D


func add_corpse(corpse_info: CorpseInfo = null) -> bool:
	print("batonga")
	var added: bool = super(corpse_info)
	if added:
		print("batonga2")
		name_label.text = corpse_info.formatted_name
		year_label.text = str(corpse_info.birth_year,"-",Time.get_date_dict_from_system().year)
		name_label.visible = true
		year_label.visible = true
	return added
