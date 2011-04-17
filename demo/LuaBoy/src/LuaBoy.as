package
{
  import flash.display.*;
  import flash.text.*;
  import flash.geom.*;
  import flash.events.*;
  import flash.utils.*;
  import flash.ui.*;

  import luaAlchemy.LuaAlchemy;
  import cmodule.lua_wrapper.CLibInit;

  [SWF(width="807", height="590", backgroundColor="0xFFFFFF", frameRate="30")]

  public class LuaBoy extends Sprite
  {
    private var myLuaAlchemy:LuaAlchemy;
    private var codeTextField:TextField;
    private var outputTextField:TextField;
    private var button:CustomSimpleButton;

    public function LuaBoy()
    {
      codeTextField = new TextField();
      outputTextField = new TextField();

      codeTextField.width = 400;
      codeTextField.height = 400;
      codeTextField.border = true;
      codeTextField.type = TextFieldType.INPUT;
      codeTextField.multiline = true;
      outputTextField.width = 400;
      outputTextField.height = 200;
      outputTextField.border = true;
      outputTextField.x = 407;
      outputTextField.y = 390;

      addChild(codeTextField);
      addChild(outputTextField);

      button = new CustomSimpleButton();
      button.y = 390;
      button.addEventListener(MouseEvent.CLICK, runLua);
      addChild(button);
    }

    private function runLua(e:Event):void
    {
      resetLua();
      outputTextField.text = "";

      var stack:Array = myLuaAlchemy.doString(getCode());

      var success:Boolean = stack.shift();

      outputTextField.text = outputTextField.text +
        (success ? "\n=== Return values ===\n" : "\n=== Error ===\n") +
        stack.join("\n") + "\n";
    }

    private function resetLua():void
    {
      if (myLuaAlchemy)
      {
        myLuaAlchemy.close();
        myLuaAlchemy = null;
      }
      myLuaAlchemy = new LuaAlchemy();
      myLuaAlchemy.setGlobal("stage", stage);
      myLuaAlchemy.setGlobal("output", outputTextField);
    }

    private function getCode():String
    {
      var rawText:String = codeTextField.htmlText.replace(/[<]\/P[>]/g, "\n"); // change all </P> to line returns
      rawText = rawText.replace(/<[a-zA-Z\/][^>]*>/g, ""); // strip all html

      var space:RegExp = /[ \t]/;

      // for each line
      var ret:String = "";
      var line:String;
      for each (line in rawText.split("\n"))
      {
        if (ret != "") // add line return if not first line
        {
          ret = ret + "\n";
        }

        // preserve beginning spaces
        for (var i:int = 0; i < line.length; i++)
        {
          if (space.test(line.charAt(i)))
          {
            ret = ret + line.charAt(i);
          }
          else
          {
            break;
          }
        }

        // use XML to transform any &quot; type escapes to raw text
        ret = ret + XML("<line>" + line + "</line>").text();
      }

      return ret;
    }
  }
}

import flash.display.DisplayObject;
import flash.display.Shape;
import flash.display.SimpleButton;

class CustomSimpleButton extends SimpleButton
{
  private var upColor:uint   = 0xFFCC00;
  private var overColor:uint = 0xCCFF00;
  private var downColor:uint = 0x00CCFF;
  private var size:uint      = 80;

  public function CustomSimpleButton()
  {
    downState      = new ButtonDisplayState(downColor, size);
    overState      = new ButtonDisplayState(overColor, size);
    upState        = new ButtonDisplayState(upColor, size);
    hitTestState   = new ButtonDisplayState(upColor, size * 2);
    hitTestState.x = -(size / 4);
    hitTestState.y = hitTestState.x;
    useHandCursor  = true;
  }
}

class ButtonDisplayState extends Shape
{
  private var bgColor:uint;
  private var size:uint;

  public function ButtonDisplayState(bgColor:uint, size:uint)
  {
    this.bgColor = bgColor;
    this.size    = size;
    draw();
  }

  private function draw():void
  {
    graphics.beginFill(bgColor);
    graphics.drawRect(0, 0, size, size);
    graphics.endFill();
  }
}
