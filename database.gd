extends Node

const BUN = preload("res://assets/characters/heroes/bun.tres")
const MIO = preload("res://assets/characters/heroes/mio.tres")
const FELIPE = preload("res://assets/characters/heroes/felipe.tres")
const LIRAE = preload("res://assets/characters/heroes/lirae.tres")

const BLOODLETTING_DRAUGHT = preload("res://assets/items/bloodletting_draught.tres")
const FLESHKNITTER = preload("res://assets/items/fleshknitter.tres")
const MEDICINAL_HERB = preload("res://assets/items/medicinal_herb.tres")
const SOUL_HUSK = preload("res://assets/items/soul_husk.tres")

var memberRes: Array[CharacterStats] = [BUN, MIO, FELIPE, LIRAE] # current party member in players party

var enemiesRes: Array[CharacterStats] = [] # current enemy combat enemies
var depth: int = 1
var current_sp = 0

var inventory = [BLOODLETTING_DRAUGHT, FLESHKNITTER, MEDICINAL_HERB, SOUL_HUSK]
