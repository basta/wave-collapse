extends Node

class_name WaveTile

enum DIR {
	TOP_LEFT = 0,
	TOP = 1,
	TOP_RIGHT = 2,
	LEFT = 3,
	RIGHT = 4,
	BOTTOM_LEFT = 5,
	BOTTOM = 6,
	BOTTOM_RIGHT = 7,
}

var offsets = [  
  [-1, -1], # TOP_LEFT
  [0, -1], # TOP
  [1, -1], # TOP_RIGHT
  [-1, 0], # LEFT
  [1, 0], # RIGHT
  [-1, 1], # BOTTOM_LEFT
  [0, 1], # BOTTOM
  [1, 1], # BOTTOM_RIGHT
]


var frame = 0

var RULES = []

func _init():
	for i in 8:
		RULES.append([])
	
func set_rule_for_all(rule):
	for i in 8:
		RULES[i] = rule
	
func get_possibilities():
	pass #TODO ended here
