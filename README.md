# drekiGodot
One attempt at making RPG on Godot just how I like it :)

# TODO List
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
- Basic UI (party menu)
- Battle system
