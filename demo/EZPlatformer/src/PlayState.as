package {
	import flash.utils.setTimeout;
	
	import luaAlchemy.LuaAlchemy;
	
	import org.flixel.FlxG;
	import org.flixel.FlxState;
	
	public class PlayState extends FlxState {
		public static var lua : LuaAlchemy;
		
		//------------------------------------------------------------------- 
		
		override public function create() : void {
			lua.setGlobal("this", this);
			lua.setGlobal("keys", FlxG.keys);
			const res : Array = lua.doString("create()");
//			trace("create: res: " + res);
		}
		
		override public function update() : void {
			beforeUpdate();
			
			super.update();
			
			afterUpdate();
		}

		private function beforeUpdate() : void {
			const res : Array = lua.doString("beforeUpdate()");
//			trace("beforeUpdate: res: " + res);
		}
		
		private function afterUpdate() : void {
			const res : Array = lua.doString("afterUpdate()");
//			trace("afterUpdate: res: " + res);
		}
		
		public function restart() : void {
			setTimeout(function () : void {
				FlxG.state = new PlayState();
			}, 1);
		}
	}
}
