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
			if(res[0] === false){
				throw new Error("Error executing 'create' lua function ")
			}
		}
		
		override public function update() : void {
			beforeUpdate();
			
			super.update();
			
			afterUpdate();
		}

		private function beforeUpdate() : void {
			const res : Array = lua.doString("beforeUpdate()");
			if(res[0] === false){
				throw new Error("Error executing 'beforeUpdate' lua function ")
			}
		}
		
		private function afterUpdate() : void {
			const res : Array = lua.doString("afterUpdate()");
			if(res[0] === false){
				throw new Error("Error executing 'afterUpdate' lua function ")
			}
		}
		
	}
}
