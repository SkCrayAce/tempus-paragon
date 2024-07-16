extends Node

#can add property to make a unique effect i think
#maybe separate rarity of items to different arrays to deal with probability

var items_common = [
	#common non-consumables
	{"type": "Non-consumable", "name": "Flintlock Pistol", "effect": "Additional Damage", "rarity": "Common",  
	"texture": preload("res://tempus_assets/item sprites/item-spritesheet6.png"), "quantity": 1},
	{"type": "Non-consumable", "name": "Steam Helmet", "effect": "Reduce Damage Recieved", "rarity": "Common",  
	"texture": preload("res://tempus_assets/item sprites/item-spritesheet15.png"), "quantity": 1},
	{"type": "Non-consumable", "name": "Mini Steam Engine", "effect": "Extra Max Health", "rarity": "Common",  
	"texture": preload("res://tempus_assets/item sprites/item-spritesheet12.png"), "quantity": 1},
	{"type": "Non-consumable", "name": "Plated Gloves", "effect": "Small Chance to Block", "rarity": "Common",  
	"texture": preload("res://tempus_assets/item sprites/item-spritesheet7.png"), "quantity": 1},
	{"type": "Non-consumable", "name": "Brass Cookie", "effect": "Small Chance to Critical Damage", "rarity": "Common",  
	"texture": preload("res://tempus_assets/item sprites/item-spritesheet16.png"), "quantity": 1}
]

var items_uncommon = [
	#uncommon non-consumables
	{"type": "Non-consumable", "name": "Cog Ring", "effect": "Become invincible for a short duration after getting hit", "rarity": "Uncommon",  
	"texture": preload("res://tempus_assets/item sprites/item-spritesheet8.png"), "quantity": 1},
	{"type": "Non-consumable", "name": "Anima Ring", "effect": "Grants health regeneration but increases Attack Cooldown", "rarity": "Uncommon",  
	"texture": preload("res://tempus_assets/item sprites/item-spritesheet8.png"), "quantity": 1}
	]

var items_rare = [
	#rare non-consumables
	{"type": "Non-consumable", "name": "Shard of Time", "effect": "Reduce attack cooldown greatly but removes critical chance", "rarity": "Rare",  
	"texture": preload("res://tempus_assets/item sprites/item-spritesheet1.png"), "quantity": 1},
	{"type": "Non-consumable", "name": "Shard of Space", "effect": "Doubles AoE attack of character but reduced damage", "rarity": "Rare",  
	"texture": preload("res://tempus_assets/item sprites/item-spritesheet2.png"), "quantity": 1},
	{"type": "Non-consumable", "name": "Shard of Construct", "effect": "Greatly increase damage but reduces AoE", "rarity": "Rare",  
	"texture": preload("res://tempus_assets/item sprites/item-spritesheet3.png"), "quantity": 1},
	{"type": "Non-consumable", "name": "Shard of Life", "effect": "Grants lifesteal equal to damage done, but reduces character health by 40%", "rarity": "Rare",  
	"texture": preload("res://tempus_assets/item sprites/item-spritesheet10.png"), "quantity": 1},
	{"type": "Non-consumable", "name": "Shard of Chaos", "effect": "Greatly increase critical chance but randomizes AoE", "rarity": "Rare",  
	"texture": preload("res://tempus_assets/item sprites/item-spritesheet11.png"), "quantity": 1}
]

var items_epic = [
	#epic non-consumables
	{"type": "Non-consumable", "name": "Clockwork Edge", "effect": "Makes user deal double damage but also take double damage.", "rarity": "Epic",  
	"texture": preload("res://tempus_assets/item sprites/item-spritesheet18.png"), "quantity": 1},
	{"type": "Non-consumable", "name": "Ultima Emblem", "effect": "Grants special ability to damage all enemies in the area but damages 10% of all characters' health.", "rarity": "Epic",  
	"texture": preload("res://tempus_assets/item sprites/item-spritesheet18.png"), "quantity": 1}
]

var items_legendary = [
	{"type": "Non-consumable", "name": "Balls of Fury", "effect": "Grants special ability to deal testicular torsion to everyone.", "rarity": "Legendary",  
	"texture": preload("res://tempus_assets/item sprites/item-spritesheet18.png"), "quantity": 1}
]
