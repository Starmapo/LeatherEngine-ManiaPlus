package states;

import flixel.FlxG;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import utilities.Options;

class FlashingLightsMenu extends MusicBeatState
{
	override public function create()
	{
		super.create();
		
		var text = new FlxText(0, 0, 0,
			"Hey! Leather Engine has flashing lights\nPress Y to enable them, or anything else to not.\n(Any key closes this menu)", 32);
		text.font = Paths.font("vcr.ttf");
		text.screenCenter();
		text.setBorderStyle(OUTLINE, FlxColor.BLACK, 1.5, 1);
		add(text);
	}
	
	override function update(elapsed:Float)
	{
		super.update(elapsed);
		
		if (FlxG.keys.justPressed.Y)
			Options.setData(true, "flashingLights");
		else if (!FlxG.keys.justPressed.Y && FlxG.keys.justPressed.ANY)
			Options.setData(false, "flashingLights");
			
		if (FlxG.keys.justPressed.ANY)
			FlxG.switchState(new TitleState());
	}
}
