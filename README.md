# drekiGodot
One attempt at making RPG on Godot just how I like it :)

# TODO List
- AudioManager
	--Volume support
	BGM/BGS
		Multipurpose tracks, with crossfade/fadein/fadeout and loop points support.
			N BGM tracks
			N Ambient tracks (weather)
	SFX
		System SE preload.
		SoundEvent object (interfaces with AudioManager for volume/etc).
			Arbitrary map-specific tracks, support looping and playing on demand.
			Register as map-specific tracks for fadein/fadeout on map change.
			Let them manage volume/etc for modulating volume on proximity, etc.

- Finish with basic database structures
	Spritesheets: DONE
	BasicEffect: DONE?
		ApplyBasicDamage
	Battlers:
		ElementAffinity- DONE
		StatusAffinity
	Actors: DONE
		SkillLearnings
	Skills: uses BasicEffect
		
	Items: uses BasicEffect
		Weapons
		Armors
	Enemies: 
		EnemyAction
	Troops:
	Status: uses BasicEffect
	System:
		Starting party
		Starting map/position

- Translation stuff
	Investigate what tools Godot has built-in for this, or popular approaches.

- Basic UI (party menu)

- Battle system