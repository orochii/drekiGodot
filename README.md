# drekiGodot
One attempt at making RPG on Godot just how I like it :)

# TODO List
- Implement general item/skill effects in battle
	- Move battler (maybe split into movement types)
	- Move battle camera
	- Apply basic damage (actually implement)
		- Damage popups
	- Show battler animation
	- Spawn VFX
- Groups menu
- Data menu (enemies, characters, topics, journal)
- Character status options (position, scrolls, fylgja)
- Character skills screen: Skill check/use, learn skills.
- Multi-message support.

# DONE List
- Battle system
	- Turn behavior
	- Skill/Item selection
	- Target selection
	- Action execution
- Basic UI (party menu)
	- Party menu main screen: select/open characters, inventory, etc (DONE)
	- Character screens (DONE)
		- Character Status layout: you can check status (DONE)
		- Character equip: items can be equipped/unequipped (DONE)
		- Character skills/learntree layout: list and tree are correctly populated (DONE)
	- System: all options working (save,load,config,title,exit) (DONE)
- Finish with basic database structures (DONE)
	- Spritesheets: DONE
	- BasicEffect: DONE
		- ApplyBasicDamage- DONE
	- Battlers: DONE
		- ElementAffinity- DONE
		- StatusAffinity- DONE
	- Actors: DONE
		- SkillLearnings- DONE
	- Skills: uses BasicEffect- DONE
	- Items: uses BasicEffect- DONE
		- Equip- DONE
	- Enemies: DONE
		EnemyAction- DONE
	- Troops: DONE
	- Status: uses BasicEffect- DONE
	- System: DONE
		- Starting party- DONE
		- Starting map/position- DONE
- AudioManager (DONE)
	- Volume support: DONE
	- BGM/BGS: DONE
		- Multipurpose tracks, with crossfade/fadein/fadeout and loop points support.- DONE
			- N BGM tracks- DONE
			- N Ambient tracks (weather)- DONE
	- SFX: DONE
		- System SE preload.- DONE
		- SoundEvent object (interfaces with AudioManager for volume/etc). -Not necessary
			- Arbitrary map-specific tracks, support looping and playing on demand. -Doneso, for AudioStreamPlayer tho.
			- Register as map-specific tracks for fadein/fadeout on map change. -Eh.
			- Let them manage volume/etc for modulating volume on proximity, etc. -There's an AudioStreamPlayer2D and 3D already, you dingus.
- Translation stuff (DONE)
	- Set up CSV for translations: DONE
- Message box resize/reposition around objects and so on: DONE
- Game State: DONE
	- Save/Load- DONE
	- Events- DONE
	- Map persistency- DONE
- Map transitions: DONE
