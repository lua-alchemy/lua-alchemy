local FlxState = as3.class.org.flixel.FlxState
local FlxTilemap = as3.class.org.flixel.FlxTilemap
local FlxSprite = as3.class.org.flixel.FlxSprite
local FlxGroup = as3.class.org.flixel.FlxGroup
local FlxText = as3.class.org.flixel.FlxText
local FlxG = as3.class.org.flixel.FlxG
local FlxObject = as3.class.org.flixel.FlxObject

local level   -- : FlxTilemap
local exit    -- : FlxSprite
local coins   -- : FlxGroup
local player  -- : FlxSprite
local score   -- : FlxText
local status  -- : FlxText

local function createCoin(x, y)
  local coin = FlxSprite.new(x*8+3, y*8+2)
  coin.makeGraphic(2, 4, 0xffffff00)
  coins.add(coin)
end

-- Called whenever the player touches a coin
local function getCoin(coin, player)
  coin.kill()
  score.text = "SCORE: " .. (as3.tolua(coins.countDead())*100)
  if as3.tolua(coins.countLiving()) == 0 then
    status.text = "Find the exit."
    exit.exists = true
  end
end

-- Called whenever the player touches the exit
local function win(exit, player)
  status.text = "Yay, you won!"
  score.text = "SCORE: 5000"
  player.kill()
end

function create()
  -- Set the background color to light gray (0xAARRGGBB)
  FlxG.bgColor = 0xffaaaaaa

  -- Design your platformer level with 1s and 0s (at 40x30 to fill 320x240 screen)
  local data = {
    1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
    1, 1, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 1, 1, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1,
    1, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 1, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1,
    1, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1,
    1, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1,
    1, 0, 0, 1, 1, 1, 0, 0, 1, 1, 1, 1, 1, 1, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1,
    1, 0, 0, 0, 1, 1, 0, 0, 1, 1, 1, 1, 1, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 0, 0, 0, 0, 1,
    1, 0, 0, 0, 1, 1, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 1,
    1, 1, 0, 0, 1, 1, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1,
    1, 0, 0, 0, 0, 1, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1,
    1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1,
    1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1,
    1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 1,
    1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 1,
    1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1,
    1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1,
    1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1,
    1, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1,
    1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 0, 0, 0, 0, 1,
    1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 0, 0, 0, 0, 1,
    1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 0, 0, 1, 1, 1, 1, 1, 0, 0, 1,
    1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
    1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
    1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1,
    1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1,
    1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1,
    1, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1,
    1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 0, 0, 0, 1, 1, 1, 1, 1, 0, 1, 0, 1, 1, 1, 1, 1, 0, 0, 0, 1, 1, 1, 1, 0, 1,
    1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 1,
    1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1 }


  -- Create a new tilemap using our level data
  level = FlxTilemap.new()
  level.loadMap(FlxTilemap.arrayToCSV(as3.toarray(data), 40), FlxTilemap.ImgAuto, 0, 0, FlxTilemap.AUTO)
  this.add(level)

  -- Create the level exit, a dark gray box that is hidden at first
  exit = FlxSprite.new(35*8+1, 25*8)
  exit.makeGraphic(14, 16, 0xff3f3f3f)
  exit.exists = false
  this.add(exit)

  -- Create coins to collect (see createCoin() function below for more info)
  coins = FlxGroup.new()
  -- Top left coins
  createCoin(18,4)
  createCoin(12,4)
  createCoin(9,4)
  createCoin(8,11)
  createCoin(1,7)
  createCoin(3,4)
  createCoin(5,2)
  createCoin(15,11)
  createCoin(16,11)

  -- Bottom left coins
  createCoin(3,16)
  createCoin(4,16)
  createCoin(1,23)
  createCoin(2,23)
  createCoin(3,23)
  createCoin(4,23)
  createCoin(5,23)
  createCoin(12,26)
  createCoin(13,26)
  createCoin(17,20)
  createCoin(18,20)

  -- Top right coins
  createCoin(21,4)
  createCoin(26,2)
  createCoin(29,2)
  createCoin(31,5)
  createCoin(34,5)
  createCoin(36,8)
  createCoin(33,11)
  createCoin(31,11)
  createCoin(29,11)
  createCoin(27,11)
  createCoin(25,11)
  createCoin(36,14)

  -- Bottom right coins
  createCoin(38,17)
  createCoin(33,17)
  createCoin(28,19)
  createCoin(25,20)
  createCoin(18,26)
  createCoin(22,26)
  createCoin(26,26)
  createCoin(30,26)

  this.add(coins);

  -- Create player (a red box)
  player = FlxSprite.new(as3.tolua(FlxG.width)/2 - 5)
  player.makeGraphic(10, 12, 0xffaa1111)
  player.maxVelocity.x = 80
  player.maxVelocity.y = 200
  player.acceleration.y = 200
  player.drag.x = as3.tolua(player.maxVelocity.x) * 4
  this.add(player);

  score = FlxText.new(2, 2, 80)
  score.shadow = 0xff000000;
  score.text = "SCORE: " .. (as3.tolua(coins.countDead())*100)
  this.add(score);

  status = FlxText.new(as3.tolua(FlxG.width)-160-2, 2, 160);
  status.shadow = 0xff000000
  status.alignment = "right"
  local score = as3.tolua(FlxG.score)
  if score == 0 then
    status.text = "Collect coins."
  elseif score == 1 then
    status.text = "Aww, you died!"
  end
  this.add(status)
end

function beforeUpdate()
  -- Player movement and controls
  player.acceleration.x = 0

  if as3.tolua(keys.LEFT) then
    player.acceleration.x = -as3.tolua(player.maxVelocity.x) * 4
  end
  if as3.tolua(keys.RIGHT) then
    player.acceleration.x = as3.tolua(player.maxVelocity.x) * 4
  end
  if as3.tolua(keys.justPressed("SPACE")) and as3.tolua(player.isTouching(FlxObject.FLOOR)) then
    player.velocity.y = -as3.tolua(player.maxVelocity.y) / 2
  end
end

function afterUpdate()
  -- Check if player collected a coin or coins this frame
  FlxG.overlap(coins,player,getCoin)

  --Check to see if the player touched the exit door this frame
  FlxG.overlap(exit,player,win)

  -- Finally, bump the player up against the level
  FlxG.collide(level,player);

  -- Check for player lose conditions
  if as3.tolua(player.y) > as3.tolua(FlxG.height) then
    FlxG.score = 1 -- sets status.text to "Aww, you died!"
    FlxG.resetState()
    return
  end
end
