package states;

import backend.WeekData;
import backend.Highscore;
import backend.Song;
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

class SceneSelectState extends MusicBeatState
{
	public var songs:Array<SceneMetadata> = [];
	
	private var catnapsongs:FlxTypedGroup<FlxSprite>;
	private var dogdaysongs:FlxTypedGroup<FlxSprite>;
	
	private static var curSelected:Int = 0;
	private static var curRow:Int = 0;
	var curDifficulty:Int = -1;
	private static var lastDifficultyName:String = '';
	
	private var camGame:FlxCamera;
	private var camAchievement:FlxCamera;
	
	var menuItems:FlxTypedGroup<FlxText>;
	
	var optionShit:Array<String> = [
		'play',
		'extras',
		'settings'
	];

	var camFollow:FlxObject;
	var bg:FlxSprite;
	
	var canExit:Bool;
	var canEnter:Bool;

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
		
		
		addSong('soporific', 'catnap', 'catweekbeat');
		addSong('sour-nightmares', 'catnap', 'catweekbeat');
		addSong('insomniac', 'catnap', 'catweekbeat');
		addSong('doggone-happy', 'dogday', 'dogbeat');
		addSong('eclipse', 'dogday', 'dogbeat');
		

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
		
		var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('scenebg'));
		bg.updateHitbox();
		bg.screenCenter();
		bg.antialiasing = true;
		add(bg);
		
		var titletext:FlxText = new FlxText(0, 70, 1280, "SCENE SELECTION", 90);
		titletext.setFormat(Paths.font("vcr.ttf"), 90, FlxColor.fromRGB(255, 255, 255), CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(titletext);
		

		camFollow = new FlxObject(0, 0, 1, 1);
		add(camFollow);

		

		

		menuItems = new FlxTypedGroup<FlxText>();
		add(menuItems);
		
		catnapsongs = new FlxTypedGroup<FlxSprite>();
		add(catnapsongs);
		dogdaysongs = new FlxTypedGroup<FlxSprite>();
		add(dogdaysongs);

		canEnter = true;
		
		for (i in 0...songs.length)
		{
			if (songs[i].week == "catnap")
			{
				var theiconthing:FlxSprite = new FlxSprite(37 + (i * 390), 160);
				theiconthing.frames = Paths.getSparrowAtlas('sceneicons/' + songs[i].songName.split("-").join(" "));
				theiconthing.animation.addByPrefix('idle', 'idle', 24, true);
				theiconthing.animation.addByPrefix('select', 'select', 24, true);
				theiconthing.animation.play('idle');
				theiconthing.updateHitbox();
				
				theiconthing.ID = i;
				
				catnapsongs.add(theiconthing);
				theiconthing.antialiasing = true;
			}
			else if (songs[i].week == "dogday")
			{
				var theiconthing:FlxSprite = new FlxSprite(190 + ((i - 3) * 390), 400);
				theiconthing.frames = Paths.getSparrowAtlas('sceneicons/' + songs[i].songName.split("-").join(" "));
				theiconthing.animation.addByPrefix('idle', 'idle', 24, true);
				theiconthing.animation.addByPrefix('select', 'select', 24, true);
				theiconthing.animation.play('idle');
				theiconthing.updateHitbox();
				
				theiconthing.ID = i;
				
				dogdaysongs.add(theiconthing);
				theiconthing.antialiasing = true;
			}
			

			Mods.currentModDirectory = songs[i].folder;

		}
		WeekData.setDirectoryFromWeek();

		
		changeSelection();

		super.create();
		
	}


	var selectedSomethin:Bool = false;

	override function update(elapsed:Float)
	{
			
		if (FlxG.sound.music.volume < 0.8)
		{
			FlxG.sound.music.volume += 0.5 * elapsed;
			if(FreeplayState.vocals != null) FreeplayState.vocals.volume += 0.5 * elapsed;
		}
		
		var accepted = controls.ACCEPT;

		if (!selectedSomethin)
		{
			if (controls.UI_LEFT_P)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeSelection(-1);
			}

			if (controls.UI_RIGHT_P)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeSelection(1);
			}
			
			if (controls.UI_UP_P || controls.UI_DOWN_P)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeRow();
			}
			
			if (controls.BACK)
			{
				FlxTransitionableState.skipNextTransIn = true;
				FlxTransitionableState.skipNextTransOut = true;
				persistentUpdate = false;
				FlxG.sound.music.pause();
				FlxG.sound.play(Paths.sound('cancelMenu'));
				new FlxTimer().start(1, function(tmr:FlxTimer)
				{
					FlxG.switchState(new ExtrasState());
				});
			}
			if (accepted && canEnter == true)
			{
				persistentUpdate = false;
				var songLowercase:String = Paths.formatToSongPath(songs[curSelected].songName);

				PlayState.SONG = Song.loadFromJson(songLowercase + '-hard', songLowercase);
				PlayState.isStoryMode = false;
				
				FlxG.sound.play(Paths.sound('confirmMenu'));

				var black:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
				black.screenCenter();
				add(black);
				FlxG.sound.music.volume = 0;
				LoadingState.loadAndSwitchState(new PlayState());
				
						
				//destroyFreeplayVocals();
			}
		}

		super.update(elapsed);

	}
	
	public function addSong(songName:String, week:String, lockvar:String)
	{
		songs.push(new SceneMetadata(songName, week, lockvar));
	}

	

	function changeSelection(huh:Int = 0)
	{
		curSelected += huh;

		if (curRow == 0)
		{
			if (curSelected >= catnapsongs.length)
				curSelected = 0;
			if (curSelected < 0)
				curSelected = catnapsongs.length - 1;
		}
		else if (curRow == 1)
		{
			if (curSelected >= dogdaysongs.length + catnapsongs.length)
				curSelected = catnapsongs.length;
			if (curSelected < catnapsongs.length)
				curSelected = dogdaysongs.length + catnapsongs.length - 1;
		}

		catnapsongs.forEach(function(spr:FlxSprite)
		{
			spr.animation.play('idle');
			spr.updateHitbox();

			if (spr.ID == curSelected)
			{
				spr.animation.play('select');
				spr.updateHitbox();
			}
		});
		
		dogdaysongs.forEach(function(spr:FlxSprite)
		{
			spr.animation.play('idle');
			spr.updateHitbox();

			if (spr.ID == curSelected)
			{
				spr.animation.play('select');
				spr.updateHitbox();
			}
		});
	}
	function changeRow()
	{

		if (curRow == 0)
		{
			curRow = 1;
			curSelected += catnapsongs.length;
			if (curSelected >= dogdaysongs.length + catnapsongs.length)
				curSelected = dogdaysongs.length + catnapsongs.length - 1;
		}
		else if (curRow == 1)
		{
			curRow = 0;
			curSelected -= catnapsongs.length;
		}

		catnapsongs.forEach(function(spr:FlxSprite)
		{
			spr.animation.play('idle');
			spr.updateHitbox();

			if (spr.ID == curSelected)
			{
				spr.animation.play('select');
				spr.updateHitbox();
			}
		});
		
		dogdaysongs.forEach(function(spr:FlxSprite)
		{
			spr.animation.play('idle');
			spr.updateHitbox();

			if (spr.ID == curSelected)
			{
				spr.animation.play('select');
				spr.updateHitbox();
			}
		});
	}
	
}

class SceneMetadata
{
	public var songName:String = "";
	public var week:String = '';
	public var lockvar:String = ""; // not sure if this will be used tbh
	public var folder:String = "";

	public function new(song:String, week:String, lockvar:String)
	{
		this.songName = song;
		this.week = week;
		this.lockvar = lockvar;
		this.folder = Mods.currentModDirectory;
		if(this.folder == null) this.folder = '';
	}
}