function onCreate()
	setPropertyFromClass('GameOverSubstate', 'characterName', 'playablecatnap'); --Character json file for the death animation
	setPropertyFromClass('GameOverSubstate', 'deathSoundName', 'none'); --put in mods/sounds/
	setPropertyFromClass('GameOverSubstate', 'loopSoundName', 'gameoversad'); --put in mods/music/
	setPropertyFromClass('GameOverSubstate', 'endSoundName', 'retrysad'); --put in mods/music/
end