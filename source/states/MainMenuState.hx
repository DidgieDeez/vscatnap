package states;

import backend.WeekData;
import backend.Achievements;

import flixel.FlxObject;
import flixel.addons.transition.FlxTransitionableState;
import flixel.effects.FlxFlicker;

import flixel.input.keyboard.FlxKey;
import lime.app.Application;
import flixel.addons.display.FlxBackdrop;

import objects.AchievementPopup;
import states.editors.MasterEditorMenu;
import options.OptionsState;

class MainMenuState extends MusicBeatState
{
	public static var psychEngineVersion:String = '0.7.3'; //This is also used for Discord RPC
	public static var curSelected:Int = 0;
	public static var initializedflash:Bool = false;
	
	var freakkey:Array<FlxKey> = [FlxKey.I, FlxKey.W, FlxKey.A, FlxKey.N, FlxKey.T, FlxKey.S, FlxKey.A, FlxKey.Y, FlxKey.G, FlxKey.E, FlxKey.X];
	var lastKeysPressed:Array<FlxKey> = [];

	var menuItems:FlxTypedGroup<FlxText>;
	private var camGame:FlxCamera;
	private var camAchievement:FlxCamera;
	
	var optionShit:Array<String> = [
		'play',
		'extras',
		'settings'
	];

	var freaky:FlxSprite;
	var thelogo:FlxSprite;
	var camFollow:FlxObject;
	var bg:FlxBackdrop;

	override function create()
	{
		#if MODS_ALLOWED
		Mods.pushGlobalMods();
		#end
		Mods.loadTopMod();
		
		FlxG.sound.music.resume();

		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end
		
		Conductor.bpm = 60;

		camGame = new FlxCamera();
		camAchievement = new FlxCamera();
		camAchievement.bgColor.alpha = 0;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camAchievement, false);
		FlxG.cameras.setDefaultDrawTarget(camGame, true);
		

		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;

		persistentUpdate = persistentDraw = true;

		var yScroll:Float = Math.max(0.25 - (0.05 * (optionShit.length - 4)), 0.1);
		
		bg = new FlxBackdrop(Paths.image('menuBG'), XY, 0, 0);
		bg.velocity.set(80, 40);
		bg.updateHitbox();
		bg.antialiasing = ClientPrefs.data.antialiasing;
		add(bg);
		
		freaky = new FlxSprite().loadGraphic(Paths.image('freakynap'));
		freaky.antialiasing = ClientPrefs.data.antialiasing;
		freaky.scrollFactor.set(0, yScroll);
		freaky.updateHitbox();
		freaky.screenCenter();

		camFollow = new FlxObject(0, 0, 1, 1);
		add(camFollow);

		
		thelogo = new FlxSprite(350, 100);
		thelogo.frames = Paths.getSparrowAtlas('logoBumpin');
		thelogo.animation.addByPrefix('bump', 'logo bumpin', 24, false);
		thelogo.scale.x = 0.8;
		thelogo.scale.y = 0.8;
		thelogo.antialiasing = ClientPrefs.data.antialiasing;
		thelogo.updateHitbox();
		thelogo.visible = true;
		add(thelogo);
		

		menuItems = new FlxTypedGroup<FlxText>();
		add(menuItems);

		var scale:Float = 1;
		/*if(optionShit.length > 6) {
			scale = 6 / optionShit.length;
		}*/

		for (i in 0...optionShit.length)
		{
			var offset:Float = 150;
				var offset:Float = 90 - (Math.max(optionShit.length, 4) - 4) * 100;
				var menuItem:FlxText = new FlxText(426 * i, FlxG.height-150, 426, optionShit[i].split("_").join(" "), 50);
				menuItem.text = menuItem.text.toLowerCase().split(' ').map(function(word) {return word.charAt(0).toUpperCase() + word.substring(1);}).join(' ');
				menuItem.setFormat(Paths.font("vcr.ttf"), 80, FlxColor.fromRGB(255, 255, 255), CENTER);
				menuItem.ID = i;
				menuItems.add(menuItem);
				var scr:Float = (optionShit.length - 4) * 1.135;
				if(optionShit.length < 6) scr = 0;
				menuItem.scrollFactor.set(0, scr);
				//menuItem.setGraphicSize(Std.int(menuItem.width * 0.58));
				menuItem.updateHitbox();
		}


		var versionShit:FlxText = new FlxText(12, FlxG.height - 44, 0, "Psych Engine v" + psychEngineVersion, 12);
		versionShit.scrollFactor.set();
		versionShit.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		var versionShit:FlxText = new FlxText(12, FlxG.height - 24, 0, "Friday Night Funkin' v" + Application.current.meta.get('version'), 12);
		versionShit.scrollFactor.set();
		versionShit.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);

		// NG.core.calls.event.logEvent('swag').send();
		
		menuItems.forEach(function(spr:FlxSprite)
		{
			spr.x -= 25;
		});
		

		changeItem();

		#if ACHIEVEMENTS_ALLOWED
		Achievements.loadAchievements();
		var leDate = Date.now();
		if (leDate.getDay() == 5 && leDate.getHours() >= 18) {
			var achieveID:Int = Achievements.getAchievementIndex('friday_night_play');
			if(!Achievements.isAchievementUnlocked(Achievements.achievementsStuff[achieveID][2])) { //It's a friday night. WEEEEEEEEEEEEEEEEEE
				Achievements.achievementsMap.set(Achievements.achievementsStuff[achieveID][2], true);
				giveAchievement();
				ClientPrefs.saveSettings();
			}
		}
		#end

		super.create();
		
		if (!initializedflash)
		{
			FlxG.camera.flash(ClientPrefs.data.flashing ? FlxColor.WHITE : 0x4CFFFFFF, 1);
			initializedflash = true;
		}
	}

	#if ACHIEVEMENTS_ALLOWED
	// Unlocks "Freaky on a Friday Night" achievement
	function giveAchievement() {
		add(new AchievementPopup('friday_night_play', camAchievement));
		FlxG.sound.play(Paths.sound('confirmMenu'), 0.7);
		trace('Giving achievement "friday_night_play"');
	}
	#end

	var selectedSomethin:Bool = false;

	override function update(elapsed:Float)
	{
		if (FlxG.sound.music != null)
			Conductor.songPosition = FlxG.sound.music.time;
			
		if (FlxG.sound.music.volume < 0.8)
		{
			FlxG.sound.music.volume += 0.5 * elapsed;
			if(FreeplayState.vocals != null) FreeplayState.vocals.volume += 0.5 * elapsed;
		}

		if (!selectedSomethin)
		{
			if (controls.UI_LEFT_P)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItem(-1);
			}

			if (controls.UI_RIGHT_P)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItem(1);
			}
			if (controls.ACCEPT)
			{
				if (optionShit[curSelected] == 'donate')
				{
					CoolUtil.browserLoad('https://ninja-muffin24.itch.io/funkin');
				}
				else
				{
					selectedSomethin = true;
					FlxG.sound.play(Paths.sound('confirmMenu'));
					FlxTransitionableState.skipNextTransIn = true;
					FlxTransitionableState.skipNextTransOut = true;
					FlxG.sound.music.pause();
					bg.velocity.set(0, 0);
					thelogo.animation.pause();
					
					menuItems.forEach(function(spr:FlxSprite)
					{
						if (curSelected != spr.ID)
						{
							spr.kill();
						}
						else
						{
							new FlxTimer().start(1, function(tmr:FlxTimer)
							{
								var daChoice:String = optionShit[curSelected];

								switch (daChoice)
								{
									case 'play':
										FlxG.switchState(new StoryMenuState());
									case 'extras':
										FlxG.switchState(new ExtrasState());
									case 'settings':
										LoadingState.loadAndSwitchState(new OptionsState());
										OptionsState.onPlayState = false;
										if (PlayState.SONG != null)
										{
											PlayState.SONG.arrowSkin = null;
											PlayState.SONG.splashSkin = null;
										}
								}
							});	
						}
					});
				}
			}
			#if desktop
			else if (controls.justPressed('debug_1'))
			{
				selectedSomethin = true;
				MusicBeatState.switchState(new MasterEditorMenu());
			}
			#end
		}
		
		var finalKey:FlxKey = FlxG.keys.firstJustPressed();
		if(finalKey != FlxKey.NONE) {
			lastKeysPressed.push(finalKey); //Convert int to FlxKey
			if(lastKeysPressed.length > freakkey.length)
			{
				lastKeysPressed.shift();
			}
				
			if(lastKeysPressed.length == freakkey.length)
			{
				var isDifferent:Bool = false;
				for (i in 0...lastKeysPressed.length) {
					if(lastKeysPressed[i] != freakkey[i]) {
						isDifferent = true;
						break;
					}
				}

				if (!isDifferent) {
					freakmode();
				}
			}
		}

		super.update(elapsed);

	}
	
	override function beatHit()
	{
		super.beatHit();

		if(thelogo != null)
			thelogo.animation.play('bump', true);
	}

	function changeItem(huh:Int = 0)
	{
		curSelected += huh;

		if (curSelected >= menuItems.length)
			curSelected = 0;
		if (curSelected < 0)
			curSelected = menuItems.length - 1;

		menuItems.forEach(function(spr:FlxSprite)
		{
			spr.color = FlxColor.fromRGB(255, 255, 255);
			spr.updateHitbox();

			if (spr.ID == curSelected)
			{
				spr.color = FlxColor.fromRGB(240, 0, 0);
				var add:Float = 0;
				if(menuItems.length > 4) {
					add = menuItems.length * 8;
				}
				// camFollow.setPosition(spr.getGraphicMidpoint().x, spr.getGraphicMidpoint().y - add);
				spr.centerOffsets();
			}
		});
	}
	
	function freakmode() //you happy now?
	{
		add(freaky);
		menuItems.forEach(function(spr:FlxText)
		{
			spr.font = Paths.font("papyrus.ttf");
		});
	}
}
