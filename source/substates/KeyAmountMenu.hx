package substates;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import utilities.NoteVariables;

class KeyAmountMenu extends MusicBeatSubstate
{
	var alpha_Value:Int = 0;
	var offsetText:FlxText = new FlxText(0, 0, 0, "", 64).setFormat(Paths.font("vcr.ttf"), 64, FlxColor.WHITE, CENTER, OUTLINE, FlxColor.BLACK);
	
	public function new()
	{
		super();
		
		alpha_Value = utilities.Options.getData("customKeyAmount");
		
		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		bg.alpha = 0;
		bg.scrollFactor.set();
		add(bg);
		
		FlxTween.tween(bg, {alpha: 0.5}, 1, {ease: FlxEase.circOut, startDelay: 0});
		
		add(offsetText);
	}
	
	override function update(elapsed:Float)
	{
		super.update(elapsed);
		
		var leftP = controls.LEFT_P;
		var rightP = controls.RIGHT_P;
		
		var back = controls.BACK;
		
		if (back)
		{
			utilities.Options.setData(alpha_Value, "customKeyAmount");
			FlxG.state.closeSubState();
		}
		
		if (leftP)
			alpha_Value -= 1;
		if (rightP)
			alpha_Value += 1;
			
		if (alpha_Value > NoteVariables.Note_Count_Directions.length)
			alpha_Value = NoteVariables.Note_Count_Directions.length;
			
		if (alpha_Value < 0)
			alpha_Value = 0;
			
		offsetText.text = "Key Amount: " + (alpha_Value > 0 ? Std.string(alpha_Value) : "Default");
		offsetText.screenCenter();
	}
}
