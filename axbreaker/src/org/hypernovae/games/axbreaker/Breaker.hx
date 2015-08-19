package org.hypernovae.games.axbreaker;

import openfl.display.Sprite;
/**
 * ...
 * @author Alain Lompo
 */
class Breaker extends Sprite
{

	public function new(color:Int) 
	{
		super();
		this.graphics.beginFill(color);
		this.graphics.drawRect(0, 0, 100, 15);
		this.graphics.endFill();
			
	}
	
	
	
}