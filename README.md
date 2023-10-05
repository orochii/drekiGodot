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
- AudioManager
	- Volume support
	- BGM/BGS
		- Multipurpose tracks, with crossfade/fadein/fadeout and loop points support.
			- N BGM tracks
			- N Ambient tracks (weather)
	- SFX
		- System SE preload.
		- SoundEvent object (interfaces with AudioManager for volume/etc).
			- Arbitrary map-specific tracks, support looping and playing on demand.
			- Register as map-specific tracks for fadein/fadeout on map change.
			- Let them manage volume/etc for modulating volume on proximity, etc.
- Translation stuff
	- Investigate what tools Godot has built-in for this, or popular approaches.
- Basic UI (party menu)
- Battle system
