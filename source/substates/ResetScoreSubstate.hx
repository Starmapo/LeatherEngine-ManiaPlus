package substates;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import game.Highscore;
import ui.Alphabet;

class ResetScoreSubstate extends MusicBeatSubstate
{
	public var songName:String = "tutorial";
	public var difficulty:String = "normal";
	
	var yes:Alphabet;
	var no:Alphabet;
	
	public var story:Bool = false;
	public var weekPath:String = "original_weeksWeek";
	public var weekNum:Int = 0;
	
	public function new(_songName:String, _difficulty:String, ?_weekNum:Int = 0, ?_weekPath:String = "original_weeksWeek", ?_story:Bool = false)
	{
		FlxG.mouse.visible = true;
		
		super();
		
		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		bg.alpha = 0;
		bg.scrollFactor.set();
		add(bg);
		
		FlxTween.tween(bg, {alpha: 0.5}, 1, {ease: FlxEase.circOut, startDelay: 0});
		
		songName = _songName;
		difficulty = _difficulty;
		story = _story;
		weekPath = _weekPath;
		weekNum = _weekNum;
		
		var areYouSure = new Alphabet(0, 0, "Reset " + (story ? "Week" : "Song") + " " + "Score?", true);
		areYouSure.screenCenter();
		areYouSure.y -= areYouSure.height * 2;
		
		yes = new Alphabet(areYouSure.x, areYouSure.y + areYouSure.height, "Yes", true);
		
		no = new Alphabet(areYouSure.x + areYouSure.width, areYouSure.y + areYouSure.height, "No", true);
		no.x -= no.width;
		
		add(areYouSure);
		add(yes);
		add(no);
	}
	
	override function update(elapsed:Float)
	{
		super.update(elapsed);
		
		if (FlxG.mouse.overlaps(yes))
			yes.alpha = 1;
		else
			yes.alpha = 0.5;
			
		if (FlxG.mouse.overlaps(no))
			no.alpha = 1;
		else
			no.alpha = 0.5;
			
		if (FlxG.mouse.justPressed)
		{
			if (FlxG.mouse.overlaps(yes))
			{
				if (story)
					Highscore.resetWeek(weekNum, difficulty, weekPath);
				else
					Highscore.resetSong(songName, difficulty);
					
				FlxG.state.closeSubState();
			}
			else if (FlxG.mouse.overlaps(no))
				FlxG.state.closeSubState();
		}
		
		if (controls.BACK)
			FlxG.state.closeSubState();
	}
}
