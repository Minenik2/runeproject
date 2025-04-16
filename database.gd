extends Node

const BUN = preload("res://assets/characters/heroes/bun.tres")
const MIO = preload("res://assets/characters/heroes/mio.tres")
const FELIPE = preload("res://assets/characters/heroes/felipe.tres")
const LIRAE = preload("res://assets/characters/heroes/lirae.tres")

var memberRes: Array[CharacterStats] = [BUN, MIO, FELIPE, LIRAE] # current party member in players party

var enemiesRes: Array[CharacterStats] = [] # current enemy combat enemies
var depth: int = 1
var current_sp = 0
