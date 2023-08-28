package modding;

import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.addons.ui.FlxUIInputText;
import flixel.text.FlxText;
import flixel.ui.FlxBar;
import flixel.util.FlxColor;
import game.Character;
import game.Conductor;
import game.StageGroup;
import states.MusicBeatState;
import states.OptionsMenu;
import ui.FlxUIDropDownMenuCustom;
import ui.HealthIcon;
import utilities.CoolUtil;
import utilities.MusicUtilities;

using StringTools;

#if discord_rpc
import utilities.Discord.DiscordClient;
#end

class CharacterCreationState extends MusicBeatState
{
	var stage:StageGroup;
	var character:Character;
	var charStr:String = "bf";
	
	var animList:FlxText;
	
	var camFollow:FlxObject;
	
	var coolCam:FlxCamera;
	var camHUD:FlxCamera;
	
	var curAnimation:Int = 0;
	var animations:Array<String> = [];
	
	var funnyBox:FlxSprite;
	
	var characters:Map<String, Array<String>> = new Map<String, Array<String>>();
	
	var charDropDown:FlxUIDropDownMenuCustom;
	var modDropDown:FlxUIDropDownMenuCustom;
	
	// health bar shit
	var healthBarBG:FlxSprite;
	var healthBar:FlxBar;
	var icons:HealthIcon;
	
	// animation shit
	var animationBox:FlxUIInputText;
	
	override public function new(?char:String = "bf")
	{
		super();
		
		charStr = char;
	}
	
	override function create()
	{
		FlxG.mouse.visible = true;
		
		coolCam = new FlxCamera();
		camHUD = new FlxCamera();
		camHUD.bgColor.alpha = 0;
		
		FlxG.cameras.reset();
		FlxG.cameras.add(coolCam, true);
		FlxG.cameras.add(camHUD, false);
		
		FlxG.cameras.setDefaultDrawTarget(coolCam, true);
		
		FlxG.camera = coolCam;
		
		camFollow = new FlxObject(0, 0, 2, 2);
		camFollow.screenCenter();
		add(camFollow);
		
		coolCam.follow(camFollow);
		
		stage = new StageGroup("stage");
		add(stage);
		add(stage.infrontOfGFSprites);
		add(stage.foregroundSprites);
		
		funnyBox = new FlxSprite(0, 0);
		funnyBox.makeGraphic(32, 32, FlxColor.RED);
		
		reloadCharacterStuff();
		
		animList = new FlxText(8, 8, 0, "Corn", 24);
		animList.color = FlxColor.CYAN;
		animList.cameras = [camHUD];
		animList.font = Paths.font("vcr.ttf");
		animList.borderSize = 1;
		animList.borderStyle = OUTLINE;
		
		updateAnimList();
		
		add(animList);
		
		healthBarBG = new FlxSprite(8, FlxG.height - 75).loadGraphic(Paths.image('ui skins/default/other/healthBar', 'shared'));
		healthBarBG.scrollFactor.set();
		healthBarBG.cameras = [camHUD];
		
		add(healthBarBG);
		
		healthBar = new FlxBar(healthBarBG.x + 4, healthBarBG.y + 4, RIGHT_TO_LEFT, Std.int(healthBarBG.width - 8), Std.int(healthBarBG.height - 8), this);
		healthBar.scrollFactor.set();
		healthBar.createFilledBar(character.barColor, character.barColor);
		healthBar.cameras = [camHUD];
		
		add(healthBar);
		
		icons = new HealthIcon(character.icon, false);
		
		icons.loadGraphic(icons.graphic);
		icons.setGraphicSize(0, 150);
		icons.updateHitbox();
		icons.cameras = [camHUD];
		
		icons.y = healthBar.y - (icons.height / 2) - icons.offsetY;
		icons.x = healthBar.x;
		
		add(icons);
		
		var characterList = CoolUtil.coolTextFile(Paths.txt('characterList'));
		
		for (Text in characterList)
		{
			var Properties = Text.split(":");
			
			var name = Properties[0];
			var mod = Properties[1];
			
			var base_array;
			
			if (characters.exists(mod))
				base_array = characters.get(mod);
			else
				base_array = [];
				
			base_array.push(name);
			characters.set(mod, base_array);
		}
		
		var arrayCharacters = ["bf", "gf"];
		var tempCharacters = characters.get("default");
		
		if (tempCharacters != null)
		{
			for (Item in tempCharacters)
			{
				arrayCharacters.push(Item);
			}
		}
		
		charDropDown = new FlxUIDropDownMenuCustom(10, 10, FlxUIDropDownMenuCustom.makeStrIdLabelArray(arrayCharacters, true), function(character:String)
		{
			charStr = arrayCharacters[Std.parseInt(character)];
			reloadCharacterStuff();
		}, null, null, null, null, camHUD);
		
		charDropDown.x = FlxG.width - charDropDown.width;
		charDropDown.cameras = [camHUD];
		
		var mods:Array<String> = [];
		
		var iterator = characters.keys();
		
		for (i in iterator)
		{
			mods.push(i);
		}
		
		var selected_mod:String = "default";
		
		var modDropDown = new FlxUIDropDownMenuCustom(charDropDown.x - charDropDown.width, charDropDown.y,
			FlxUIDropDownMenuCustom.makeStrIdLabelArray(mods, true), function(mod:String)
		{
			selected_mod = mods[Std.parseInt(mod)];
			
			arrayCharacters = ["bf", "gf"];
			tempCharacters = characters.get(selected_mod);
			
			for (Item in tempCharacters)
			{
				arrayCharacters.push(Item);
			}
			
			var character_Data_List = FlxUIDropDownMenuCustom.makeStrIdLabelArray(arrayCharacters, true);
			
			charDropDown.setData(character_Data_List);
			charDropDown.selectedLabel = charStr;
		}, null, null, null, null, camHUD);
		
		modDropDown.selectedLabel = "default";
		
		add(modDropDown);
		add(charDropDown);
		
		#if discord_rpc
		DiscordClient.changePresence("Creating characters.", null, null, true);
		#end
		
		if (FlxG.sound.music == null)
			FlxG.sound.playMusic(MusicUtilities.GetOptionsMenuMusic(), 0.7, true);
			
		super.create();
	}
	
	override function update(elapsed:Float)
	{
		super.update(elapsed);
		
		if (FlxG.sound.music != null)
			Conductor.songPosition = FlxG.sound.music.time;
			
		if (controls.BACK)
			FlxG.switchState(new OptionsMenu());
			
		if (FlxG.keys.justPressed.SPACE)
			character.playAnim(animations[curAnimation % animations.length], true);
			
		if (FlxG.keys.justPressed.W)
			curAnimation -= 1;
		if (FlxG.keys.justPressed.S)
			curAnimation += 1;
			
		if (FlxG.keys.justPressed.S || FlxG.keys.justPressed.W)
		{
			if (curAnimation < 0)
				curAnimation = animations.length - 1;
			if (curAnimation > animations.length - 1)
				curAnimation = 0;
				
			updateAnimList();
			
			character.playAnim(animations[curAnimation % animations.length], true);
		}
		
		var shiftThing:Int = FlxG.keys.pressed.SHIFT ? 5 : 1;
		
		if (FlxG.keys.pressed.I || FlxG.keys.pressed.J || FlxG.keys.pressed.K || FlxG.keys.pressed.L) // stolen from animation debug lmao
		{
			if (FlxG.keys.pressed.I)
				camFollow.velocity.y = -90 * shiftThing;
			else if (FlxG.keys.pressed.K)
				camFollow.velocity.y = 90 * shiftThing;
			else
				camFollow.velocity.y = 0;
				
			if (FlxG.keys.pressed.J)
				camFollow.velocity.x = -90 * shiftThing;
			else if (FlxG.keys.pressed.L)
				camFollow.velocity.x = 90 * shiftThing;
			else
				camFollow.velocity.x = 0;
		}
		else
			camFollow.velocity.set();
			
		if (FlxG.keys.pressed.E)
			coolCam.zoom += 2 * elapsed;
		if (FlxG.keys.pressed.Q)
			coolCam.zoom -= 2 * elapsed;
			
		if (coolCam.zoom < 0.1)
			coolCam.zoom = 0.1;
		if (coolCam.zoom > 5)
			coolCam.zoom = 5;
	}
	
	function reloadCharacterStuff()
	{
		if (charDropDown != null)
			remove(charDropDown);
		if (modDropDown != null)
			remove(modDropDown);
			
		remove(funnyBox);
		
		if (character != null)
		{
			remove(character);
			character.kill();
			character.destroy();
		}
		
		if (charStr == "")
			charStr = "bf";
			
		character = new Character(0, 0, charStr);
		character.shouldDance = false;
		
		@:privateAccess
		if (character.offsetsFlipWhenEnemy)
		{
			character.isPlayer = true;
			character.flipX = !character.flipX;
			character.loadOffsetFile(character.curCharacter);
		}
		
		if (character.config == null)
		{
			charStr = "bf";
			reloadCharacterStuff();
		}
		else
		{
			add(character);
			
			add(funnyBox);
			
			if (modDropDown != null)
				add(modDropDown);
			if (charDropDown != null)
				add(charDropDown);
				
			animations = character.animation.getNameList();
			
			if (animations.length < 1)
				animations = ["idle"];
				
			var coolPos:Array<Float> = stage.getCharacterPos(character.isPlayer ? 0 : 1, character);
			
			if (character.isPlayer)
				funnyBox.setPosition(stage.player_1_Point.x, stage.player_1_Point.y);
			else
				funnyBox.setPosition(stage.player_2_Point.x, stage.player_2_Point.y);
				
			character.setPosition(coolPos[0], coolPos[1]);
			
			if (animList != null)
				updateAnimList();
				
			if (healthBar != null)
				healthBar.createFilledBar(character.barColor, character.barColor);
				
			if (icons != null)
			{
				icons.changeIconSet(character.icon);
				
				icons.loadGraphic(icons.graphic);
				icons.setGraphicSize(0, 150);
				icons.updateHitbox();
			}
		}
	}
	
	function updateAnimList()
	{
		animList.text = "Animations:\n"
			+ (Std.string(animations).replace("[", "").replace("]", "").replace(",", "\n")
				+ "\n").replace(animations[curAnimation % animations.length] + "\n", '>${animations[curAnimation % animations.length]}<\n');
	}
}
