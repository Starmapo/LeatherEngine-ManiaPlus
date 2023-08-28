package ui;

#if sys
import flixel.FlxSprite;
import openfl.display.BitmapData;
import sys.io.File;

class ModIcon extends FlxSprite
{
	/**
	 * Used for ModMenu! If you use it elsewhere, prob gonna annoying
	 */
	public var sprTracker:FlxSprite;
	
	public function new(modId:String = 'Template Mod')
	{
		super();
		
		var imageDataRaw = File.getBytes(Sys.getCwd() + "mods/" + modId + "/_polymod_icon.png");
		var graphicData = BitmapData.fromBytes(imageDataRaw);
		
		loadGraphic(graphicData, false, 0, 0, false, modId);
		
		setGraphicSize(150, 150);
		updateHitbox();
		
		scrollFactor.set();
		antialiasing = true;
	}
	
	override function update(elapsed:Float)
	{
		super.update(elapsed);
		
		if (sprTracker != null)
			setPosition(sprTracker.x + sprTracker.width + 10, sprTracker.y - 30);
	}
}
#end
