package states;

import backend.WeekData;

import flash.system.System;
import flixel.FlxObject;
import flixel.addons.transition.FlxTransitionableState;
import flixel.effects.FlxFlicker;

import flixel.input.keyboard.FlxKey;
import lime.app.Application;
import flixel.addons.display.FlxBackdrop;

import options.OptionsState;

class ExtrasState extends MusicBeatState
{
	public static var psychEngineVersion:String = '0.7.3'; //This is also used for Discord RPC
	public static var curSelected:Int = 0;
	

	var menuItems:FlxTypedGroup<FlxText>;
	private var camGame:FlxCamera;
	
	var optionShit:Array<String> = [
		'scene_selection',
		'more_episodes',
		'cutscenes',
		'credits',
		'evil_fifth_option'
	];


	var camFollow:FlxObject;

	override function create()
	{
		#if MODS_ALLOWED
		Mods.pushGlobalMods();
		#end
		Mods.loadTopMod();

		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end
		

		camGame = new FlxCamera();

		FlxG.cameras.reset(camGame);
		FlxG.cameras.setDefaultDrawTarget(camGame, true);
		
		FlxG.sound.music.resume();
		

		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;

		persistentUpdate = persistentDraw = true;

		var yScroll:Float = Math.max(0.25 - (0.05 * (optionShit.length - 4)), 0.1);
		
		var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('menuBGMagenta'));
		bg.updateHitbox();
		bg.screenCenter();
		bg.antialiasing = true;
		add(bg);
		
		var titletext:FlxText = new FlxText(50, 70, 1280, "Bonus Features", 90);
		titletext.setFormat(Paths.font("vcr.ttf"), 90, FlxColor.fromRGB(255, 255, 255), LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(titletext);

		camFollow = new FlxObject(0, 0, 1, 1);
		add(camFollow);

		
		
		// magenta.scrollFactor.set();

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
				var menuItem:FlxText = new FlxText(50, i * 80, 1280, optionShit[i].split("_").join(" "), 60);
				menuItem.text = menuItem.text.toLowerCase().split(' ').map(function(word) {return word.charAt(0).toUpperCase() + word.substring(1);}).join(' ');
				menuItem.setFormat(Paths.font("vcr.ttf"), 60, FlxColor.fromRGB(255, 255, 255), LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
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
			spr.y += 195;
		});
		

		changeItem();


		super.create();
		
	}


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
			if (controls.UI_UP_P)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItem(-1);
			}

			if (controls.UI_DOWN_P)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItem(1);
			}

			if (controls.BACK)
			{
				selectedSomethin = true;
				FlxTransitionableState.skipNextTransIn = true;
				FlxTransitionableState.skipNextTransOut = true;
				FlxG.sound.music.pause();
				FlxG.sound.play(Paths.sound('cancelMenu'));
				new FlxTimer().start(1, function(tmr:FlxTimer)
				{
					FlxG.switchState(new MainMenuState());
				});
			}

			if (controls.ACCEPT)
			{
				if (optionShit[curSelected] == 'donate')
				{
					CoolUtil.browserLoad('https://www.google.com/search?q=fuck+you');
				}
				else
				{
					selectedSomethin = true;
					FlxTransitionableState.skipNextTransIn = true;
					FlxTransitionableState.skipNextTransOut = true;
					FlxG.sound.play(Paths.sound('confirmMenu'));
					FlxG.sound.music.pause();

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
									case 'scene_selection':
										FlxG.switchState(new SceneSelectState());
									case 'more_episodes':
										FlxG.switchState(new FreeplayState());
									case 'credits':
										FlxG.switchState(new CreditsState());
									case 'cutscenes':
										FlxG.switchState(new CreditsState());
									case 'evil_fifth_option':
										evil();
								}
							});
						}
					});
				}
			}
		}
		


		super.update(elapsed);

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
	
	function evil()
	{
		var black:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		black.screenCenter();
		add(black);
		
		var evilf:FlxSprite = new FlxSprite().loadGraphic(Paths.image('evil'));
		evilf.screenCenter();
		evilf.alpha = 0;
		add(evilf);
		
		FlxTween.tween(evilf, {alpha: 1}, 5, {
				onComplete: function(tween:FlxTween)
				{
					CoolUtil.browserLoad('https://www.youtube.com/watch?v=94bKsZUOcgM');
					System.exit(0);
				},
				startDelay: 3
			});
	}
	
}
