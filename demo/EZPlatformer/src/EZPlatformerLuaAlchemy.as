package {
	import flash.utils.ByteArray;
	
	import luaAlchemy.LuaAlchemy;
	
	import org.flixel.FlxG;
	import org.flixel.FlxGame;
	import org.flixel.FlxGroup;
	import org.flixel.FlxSprite;
	import org.flixel.FlxState;
	import org.flixel.FlxText;
	import org.flixel.FlxTilemap;
	import org.flixel.FlxU;
	
	[SWF(width="640", height="480", backgroundColor="#000000")]
	
	public class EZPlatformerLuaAlchemy extends FlxGame {
		[Embed(source="../assets/PlayState.lua", mimeType="application/octet-stream")]
		private static const PLAY_STATE_LUA_REF : Class;
		
		//------------------------------------------------------------------- 
		
		public function EZPlatformerLuaAlchemy() {
			super(320,240,PlayState,2);
			initLua();
		}

		private function initLua() : void {
			importClassesForLua();
			
			const luaAsset:ByteArray = new PLAY_STATE_LUA_REF() as ByteArray;
			const luaString:String = luaAsset.readUTFBytes(luaAsset.bytesAvailable);
			const lua : LuaAlchemy = new LuaAlchemy();
			const res : Array = lua.doString(luaString);
			if(res[0] === false){
				throw new Error("Error executing lua main script")
			}
			PlayState.lua = lua;
		}

		private function importClassesForLua() : void {
			FlxState
			FlxTilemap
			FlxSprite
			FlxGroup
			FlxText
			FlxG
			FlxU
		}
	}
}
