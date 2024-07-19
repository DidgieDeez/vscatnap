package options;

import states.MainMenuState;
import backend.StageData;
import flixel.addons.transition.FlxTransitionableState;

class OptionsState extends MusicBeatState
{
	var options:Array<String> = ['Colors', 'Controls', 'Video and UI', 'Audio', 'Gameplay', 'Adjust Delay', 'Exit'];
	private var grpOptions:FlxTypedGroup<FlxText>;
	private static var curSelected:Int = 0;
	public static var menuBG:FlxSprite;
	public static var onPlayState:Bool = false;
	
	var selection:FlxSprite;
	

	function openSelectedSubstate(label:String) {
		switch(label) {
			case 'Colors':
				openSubState(new options.NotesSubState());
			case 'Controls':
				openSubState(new options.ControlsSubState());
			case 'Video and UI':
				openSubState(new options.GraphicsSettingsSubState());
			case 'Audio':
				openSubState(new options.GraphicsSettingsSubState());
			case 'Gameplay':
				openSubState(new options.GameplaySettingsSubState());
			case 'Adjust Delay':
				MusicBeatState.switchState(new options.NoteOffsetState());
			case 'Exit':
				FlxG.sound.play(Paths.sound('cancelMenu'));
				if(onPlayState)
				{
					FlxTransitionableState.skipNextTransIn = false;
					FlxTransitionableState.skipNextTransOut = false;
					StageData.loadDirectory(PlayState.SONG);
					LoadingState.loadAndSwitchState(new PlayState());
					FlxG.sound.music.volume = 0;
				}
				else 
				{
					FlxTransitionableState.skipNextTransIn = true;
					FlxTransitionableState.skipNextTransOut = true;
					FlxG.sound.music.pause();
					new FlxTimer().start(1, function(tmr:FlxTimer)
					{
						FlxG.switchState(new MainMenuState());
					});
				}
		}
	}


	override function create() {
		#if DISCORD_ALLOWED
		DiscordClient.changePresence("Options Menu", null);
		#end
		
		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		bg.screenCenter();
		add(bg);

		grpOptions = new FlxTypedGroup<FlxText>();
		add(grpOptions);
		
		selection = new FlxSprite(471, 0).loadGraphic(Paths.image('underline'));
		selection.screenCenter(X);
		selection.visible = true;
		add(selection);

		for (i in 0...options.length)
			{
				var optionText:FlxText = new FlxText(100, FlxG.height - 400, 0, options[i].toUpperCase(), true);
				optionText.setFormat(Paths.font("vcr.ttf"), 50,FlxColor.fromRGB(255, 255, 255), CENTER);
				optionText.screenCenter();
				optionText.borderSize = 3;
				optionText.y += (60 * (i - (options.length / 2))) + 50;
				optionText.ID = i;
				grpOptions.add(optionText);
				add(optionText);
			}


		changeSelection();
		ClientPrefs.saveSettings();

		FlxG.sound.music.resume();
		
		super.create();
	}

	override function closeSubState() {
		super.closeSubState();
		ClientPrefs.saveSettings();
		#if DISCORD_ALLOWED
		DiscordClient.changePresence("Options Menu", null);
		#end
	}

	override function update(elapsed:Float) {
		super.update(elapsed);

		if (controls.UI_UP_P) {
			changeSelection(-1);
		}
		if (controls.UI_DOWN_P) {
			changeSelection(1);
		}

		if (controls.BACK) {
			FlxG.sound.play(Paths.sound('cancelMenu'));
			if(onPlayState)
			{
				FlxTransitionableState.skipNextTransIn = false;
				FlxTransitionableState.skipNextTransOut = false;
				StageData.loadDirectory(PlayState.SONG);
				LoadingState.loadAndSwitchState(new PlayState());
				FlxG.sound.music.volume = 0;
			}
			else 
			{
				FlxTransitionableState.skipNextTransIn = true;
				FlxTransitionableState.skipNextTransOut = true;
				FlxG.sound.music.pause();
				new FlxTimer().start(1, function(tmr:FlxTimer)
				{
					FlxG.switchState(new MainMenuState());
				});
			}
		}
		else if (controls.ACCEPT) openSelectedSubstate(options[curSelected]);
	}
	
	function changeSelection(change:Int = 0) {
		curSelected += change;
		if (curSelected < 0)
			curSelected = options.length - 1;
		if (curSelected >= options.length)
			curSelected = 0;

		var bullShit:Int = 0;
		
		selection.y = grpOptions.members[curSelected].y + 52;

		for (item in grpOptions.members) {

			if (curSelected == item.ID && item != null)
				{
					item.color = FlxColor.fromRGB(200, 200, 200);
				}
				else
				{
					item.color = FlxColor.fromRGB(255, 255, 255);
				}
			}
		FlxG.sound.play(Paths.sound('scrollMenu'));
	}

	override function destroy()
	{
		ClientPrefs.loadPrefs();
		super.destroy();
	}
}