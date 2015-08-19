package org.hypernovae.games.axbreaker;
import openfl.display.Sprite;
import openfl.display.GradientType;

import openfl.display.Sprite;
/**
 * ...
 * @author Alain Lompo
 */
class Brick extends Sprite
{

	public function new(color:Int) 
	{
		super();
		
		
		this.graphics.beginGradientFill(GradientType.RADIAL, [0x0000FF, color], [1, 1], [0, 255], null,
		null, null, null);
		
		this.graphics.drawRect(0, 0, 30, 15);
		this.graphics.endFill();
	}
	
}