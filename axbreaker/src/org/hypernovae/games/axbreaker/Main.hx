package org.hypernovae.games.axbreaker;

import haxe.Timer;
import openfl.display.Sprite;
import openfl.display.StageAlign;
import openfl.display.StageScaleMode;
import openfl.geom.Point;
import openfl.Lib;
import openfl.events.Event;
import openfl.text.TextField;
import openfl.text.TextFormat;
import openfl.text.TextFormatAlign;

import openfl.events.KeyboardEvent;

/**
 * ...
 * @author Alain Lompo
 */
class Main extends Sprite 
{
	var inited:Bool;
	private var ball:Ball;
	private var breaker:Breaker;
	private var bricks:Array<Brick>;
	private var currentBricksState:Array<BrickState>;
	
	
	private var wallX:Int = 90;
	private var wallY:Int = 40;
	private var spacingX:Int = 2;
	private var spacingY:Int = 2;
	
	private var currentGameState:GameState;
	
	private var score:Int;
	private var scoreStep:Int = 5;
	private var scoreField: TextField;
	private var messageField:TextField;
	
	private var arrowKeyLef:Bool;
	private var arrowKeyRight:Bool;
	
	private var playerSpeed:Int = 5;
	
	private var ballMovement:Point;
	private var ballSpeed:Int = 5;
	
	private var brickFallSpeed:Int = 2;
	private var fallingBricks:Map<Int, Brick>;
	
	

	function resize(e) {
		if (!inited) {
			init();
		}
	}
	
	function init() {
		if (inited) {
			return;
		}
		inited = true;
		
		breaker = new Breaker(0xafcfff);
		breaker.x = 200;
		breaker.y = 440;
		
		// from y = 460 to 500: status bar or status zone
		this.addChild(breaker);
		
		ball = new Ball();
		ball.x = 245;
		ball.y = 430;
		this.addChild(ball);
		
		// 4 rows of 10 bricks each
		var i:Int = 0;
		bricks = new Array();
		currentBricksState = new Array();
		for (i in 0...40) {
			var ligne:Int = Std.int( i / 10);
			var colonne:Int = i % 10;
			var brk:Brick = new Brick(0xf0f0f0);
			brk.x = wallX + colonne * (spacingX + brk.width) ;
			brk.y = wallY + ligne * (spacingY + brk.height);
			this.addChild(brk);
			bricks.push(brk);
			currentBricksState.push(BrickState.InRank);
			
		}
		
		var scoreFormat: TextFormat = new TextFormat("Verdana", 18, 0xbbbbbb, true);
		scoreFormat.align = TextFormatAlign.CENTER;
		
		
		scoreField = new TextField();
		scoreField.defaultTextFormat = scoreFormat;
		scoreField.selectable = false;
		
		scoreField.width = 500;
		scoreField.y = 460;
		addChild(scoreField);
		
		var messageFormat:TextFormat = new TextFormat("Verdana", 10, 0xbbbbbb, true);
		messageFormat.align = TextFormatAlign.CENTER;
		
		messageField = new TextField();
		addChild(messageField);
		messageField.width = 500;
		messageField.y = 482;
		messageField.defaultTextFormat = messageFormat;
		messageField.selectable = false;
		messageField.text = "Appuyez Espace (ou S) pour démarrer - Flêche droite et gauche pour bouger";
		
		score = 0;
		
		setGameState(Paused);
		
		stage.addEventListener(KeyboardEvent.KEY_DOWN, keyDown);
		
		arrowKeyLef = false;
		arrowKeyRight = false;
		
		stage.addEventListener(KeyboardEvent.KEY_UP, keyUp);
		
		this.addEventListener(Event.ENTER_FRAME, everyFrame);
		
		ballMovement = new Point(0, 0);
		
		fallingBricks = new Map<Int, Brick>();
		
		
	
	}
	
	private function everyFrame(Event:Event):Void {
		if (currentGameState == Playing) {
			
			// See all the bricks that are falling and make them fall some more
			var fallIndexes:Iterator<Int> = fallingBricks.keys();
			
			while (fallIndexes.hasNext()) {
				var brickIndex:Int = fallIndexes.next();
				if (currentBricksState[brickIndex] == BrickState.Falling) {
					bricks[brickIndex].y += brickFallSpeed;
					if (bricks[brickIndex].y > 460) {
						currentBricksState[brickIndex] = BrickState.Fallen;
						bricks[brickIndex].visible = false;
						fallingBricks.remove(brickIndex);
					}
				}
				
				
			}
			
			
			if (arrowKeyLef) {
				breaker.x -= playerSpeed;
			} 
			if (arrowKeyRight) {
				breaker.x += playerSpeed;
			}
			
			if (breaker.x < 5) {
				breaker.x = 5;
			}
			
			if (breaker.x > 395) {
				breaker.x = 395;
			}
			
			ball.x += ballMovement.x;
			ball.y += ballMovement.y;
			
			if (ball.y < 5 || ball.y > 495) {
				ballMovement.y *= -1;
				
			}
			
			if (ball.x < 5 || ball.x > 495) {
				ballMovement.x *= -1;
			}
			
			if (ballMovement.y > 0 && ball.y > breaker.y -5 && ball.x >= breaker.x && ball.x <= breaker.x + breaker.width) {
				bounceBall();
				ball.y = breaker.y -5;
			}
			
			// Entering wall
			if (ball.x -5 >= wallX && ball.x -5 <= wallX + 10 * 30 + 9 * 2
				&& ball.y -5 >= wallY
				&& ball.y -5 <= wallY + 4 * 15 + 3 * 2) {
					
					
					var targetLine:Int = Std.int((ball.y - 5 - wallY-6 ) / (15));
					var targetColumn:Int = Std.int((ball.x - 5 - wallX - 18) / (30));
					
					var index = targetLine * 10 + targetColumn;
					
					// What is the state of that brick?
					if (currentBricksState[index] == BrickState.InRank) {
						
						// We can then make it fall by simply changing its state
						
						currentBricksState[index] = BrickState.Falling;
						fallingBricks.set(index, bricks[index]);
						
						bounceBall();
						
						score += scoreStep;
						updateScore();
						
					}
					
					
				}
		}
		
	}
	
	private function keyUp(event:KeyboardEvent): Void {
		if (event.keyCode == 37) {
			arrowKeyRight = false;
		} else if (event.keyCode == 39) {
			arrowKeyLef = false;
		}
	}
	
	
	private function keyDown(event:KeyboardEvent):Void {
		if (currentGameState == Paused && (event.keyCode == 32 || event.keyCode == 64)) {
			setGameState(Playing);
			
		} else if (event.keyCode == 37) {
			arrowKeyLef = true;
		} else if (event.keyCode == 39) {
			arrowKeyRight = true;
		} else if (event.keyCode == 38 || event.keyCode == 40) {
			arrowKeyLef = false;
			arrowKeyRight = false;
		}
	}
	private function updateScore():Void {
		scoreField.text = "Score: " + score;
		
	}
	
	private function setGameState(state:GameState): Void {
		currentGameState = state;
		updateScore();
		if (state == Paused) {
			messageField.alpha = 1;
		} else {
			messageField.alpha = 0;
			
			breaker.x = 200;
			breaker.y = 440;
			
			ball.x = 245;
			ball.y = 430;
			
			/*var randomAngle:Float = Math.random() * 2 * Math.PI;
			ballMovement.x = Math.cos(randomAngle) * ballSpeed;
			ballMovement.y = Math.sin(randomAngle) * ballSpeed;*/
			
			var direction:Int = (Math.random() > .5)?(1):( -1);
			var randomAngle:Float = (Math.random() * Math.PI / 2) - Math.PI/8;
			ballMovement.x = direction * Math.cos(randomAngle) * ballSpeed;
			ballMovement.y = Math.sin(randomAngle) * ballSpeed;
			if (0 < ballMovement.y) {
				ballMovement.y *= -1;
			}
			
			
			
		}
		
		
		
	}
	
	private function bounceBall():Void {
		
		var directionX:Int = (ballMovement.x > 0)?( -1):(1);
		var directionY:Int = (ballMovement.y > 0)?( -1):(1);
		
		var randomAngle:Float = (Math.random() * Math.PI / 2) - Math.PI/8;
		ballMovement.x = directionX * Math.cos(randomAngle) * ballSpeed;
		ballMovement.y = directionY * Math.sin(randomAngle) * ballSpeed;
		
	}
	
	
	public function new() 
	{
		super();
		
		// Assets:
		// openfl.Assets.getBitmapData("img/assetname.jpg");
		addEventListener(Event.ADDED_TO_STAGE, added);
	}
	
	function added(e) {
		removeEventListener(Event.ADDED_TO_STAGE, added);
		stage.addEventListener(Event.RESIZE, resize);
		#if ios
		Timer.delay(init, 100);
		#else
		init();
		#end
	}
	
	public static function main() {
		Lib.current.stage.align = StageAlign.TOP_LEFT;
		Lib.current.stage.scaleMode = StageScaleMode.NO_SCALE;
		Lib.current.addChild(new Main());
	}
	
	

}

enum GameState {
	Paused;
	Playing;
}

enum BrickState {
	InRank;
	Falling;
	Fallen;
	
}
