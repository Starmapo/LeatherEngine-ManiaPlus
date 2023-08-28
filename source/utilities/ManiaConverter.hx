package utilities;

import flixel.math.FlxMath;
import flixel.math.FlxRandom;
import game.Song.SwagSong;
import openfl.Assets;

class ManiaConverter
{
	public var convertedSong:SwagSong;
	
	public function new(song:SwagSong, toKeys:Int)
	{
		convertSong(song, toKeys);
	}
	
	function convertSong(fromSong:SwagSong, toKeys:Int)
	{
		final song = Reflect.copy(fromSong);
		song.eventObjects = fromSong.eventObjects;
		song.playerKeyCount = song.keyCount = toKeys;
		
		final seedText = Assets.getText(Paths.txt("maniaConverterSeed", "preload"));
		final random = new FlxRandom(Std.parseInt(seedText) ?? 1);
		
		final alg = getCombinedPicks(fromSong.keyCount, fromSong.playerKeyCount, toKeys);
		
		final noteMap:Map<Int, Array<Int>> = [];
		for (section in song.notes)
		{
			var removeNotes:Array<Dynamic> = [];
			for (note in section.sectionNotes)
			{
				final time = Std.int(note[0] ?? 0.0);
				if (!noteMap.exists(time))
					noteMap.set(time, []);
					
				final picks = alg[note[1] ?? 0];
				final lane = picks[random.int(0, picks.length - 1)];
				
				final curLanes = noteMap.get(time);
				if (!curLanes.contains(lane))
				{
					note[1] = lane;
					curLanes.push(lane);
				}
				else
					removeNotes.push(note);
			}
			
			for (note in removeNotes)
				section.sectionNotes.remove(note);
		}
		
		convertedSong = song;
	}
	
	function getCombinedPicks(input1:Int, input2:Int, output:Int)
	{
		var alg1 = getPicks(input1, output);
		var alg2 = getPicks(input2, output, output);
		for (lane in alg2)
			alg1.push(lane);
		return alg1;
	}
	
	function getPicks(input:Int, output:Int, add:Int = 0):Array<Array<Int>>
	{
		var noteArray:Array<Array<Int>> = [];
		for (i in 0...input)
			noteArray[i] = [];
			
		if (input > output)
		{
			var keyRatio:Int = Std.int(input / output);
			
			var num = 0;
			var num1 = 0;
			var num2 = 0;
			for (i in 0...input)
			{
				if (num > keyRatio - 1)
				{
					num = 0;
					num1 = i;
					if (num2 < output - 1)
						num2++;
				}
				noteArray[num + num1] = [num2 + add];
				num++;
			}
		}
		else
		{
			var num = 0;
			for (i in 0...output)
			{
				if (num > input - 1)
					num = 0;
				noteArray[num].push(i + add);
				num++;
			}
		}
		
		return noteArray;
	}
	
	function getPicksNew(input:Int, output:Int, add:Int = 0):Array<Array<Int>>
	{
		var noteArray:Array<Array<Int>> = [];
		for (i in 0...input)
			noteArray[i] = [];
			
		function round(a:Float)
		{
			return input > output ? Math.ceil(a) : Math.round(a);
		}
		
		for (i in 0...input)
		{
			var bottom = Math.floor(FlxMath.remapToRange(i, 0, input, 0, output));
			var top = Std.int(FlxMath.bound(round(FlxMath.remapToRange(i + 1, 0, input, 0, output)) - 1, 0, output - 1));
			for (j in bottom...top + 1)
				noteArray[i].push(j + add);
		}
		
		return noteArray;
	}
}
