# drekiGodot
One attempt at making RPG on Godot just how I like it :)

# TODO List
- Choice box.
- Make a new first map (I guess training cave?).
	- To fix/improve:
		- Details in ground.
		- Apply emission shader to missing sections, improve look of brown rocks.
		- Fix south entrance/exit.
- Skill tree learning
- Character info: scrolls, fylgja, position.
- Implement general item/skill effects in battle
	- Move battle camera
	- Scan: target
	- RunEvent: evt
	- Switch/Variable operation
- Data menu (enemies, characters, topics, journal)
- Character status options (position, scrolls, fylgja)
- Character skills screen: Skill check/use, learn skills.
- Multi-message support.
- Groups menu
- Item synthesis
- Fylgja stuff

# DONE List
- Added compass.
- Implement skill use in party menu
- Item use in party menu
- Character animations: Move, death, standing, actionSpecific(effect), status
- Scope change
- Target select kind variance and priority fix (shenanigans with changing kind skills)
- Effects
	- Apply basic damage
	- Show battler animation
	- Move battler
	- Spawn VFX
	- AddStatus: target, status
	- Wait effect
	- ApplyPercentDamage: hp/mp, amount
- Collapse animation
- Counter feature (can be extended for other counters)
- Battle end screen
- Escape option
- Damage popups
- Battle system
	- Turn behavior
	- Skill/Item selection
	- Target selection
	- Action execution
- Basic UI (party menu)
	- Party menu main screen: select/open characters, inventory, etc
	- Character screens
		- Character Status layout: you can check status
		- Character equip: items can be equipped/unequipped
		- Character skills/learntree layout: list and tree are correctly populated
	- System: all options working (save,load,config,title,exit)
- Finish with basic database structures
	- Spritesheets
	- BasicEffect
		- ApplyBasicDamage
	- Battlers
		- ElementAffinity
		- StatusAffinity
	- Actors
		- SkillLearnings
	- Skills: uses BasicEffect
	- Items: uses BasicEffect
		- Equip
	- Enemies
		EnemyAction
	- Troops
	- Status: uses BasicEffect
	- System
		- Starting party
		- Starting map/position
- AudioManager
	- Volume support
	- BGM/BGS:
		- Multipurpose tracks, with crossfade/fadein/fadeout and loop points support.
			- N BGM tracks
			- N Ambient tracks (weather)
	- SFX:
		- System SE preload.
- Translation stuff
	- Set up CSV for translations
- Message box resize/reposition around objects and so on
- Game State
	- Save/Load
	- Events
	- Map persistency
- Map transitions
