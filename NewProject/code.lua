local xPos = 0
local yPos = 4
local flipH = false
local spriteId = 0
local timer
local currentId

-- telling if the command prompt is open or not
local command_prompt = false

--player information
p1=
{
	--position, representing the top left of
	--of the player sprite.
	x=0,
	y=4,
	dx=0,
	dy=0,

	--is the player standing on
	--the ground. used to determine
	--if they can jump.
	isgrounded=false,

	--how fast the player is launched
	--into the air when jumping.
	jumpvel=2.0,
}

g=
{
	grav=0.1, -- gravity per frame
}

--[[
  The Init() method is part of the game's lifecycle and called a game starts.
  We are going to use this method to configure background color,
  ScreenBufferChip and draw a text box.
]]--
function Init()

  -- Here we are manually changing the background color
  BackgroundColor(11)

  local display = Display()

  PlaySong(0, false, 0)

end

--[[
  The Update() method is part of the game's life cycle. The engine calls
  Update() on every frame before the Draw() method. It accepts one argument,
  timeDelta, which is the difference in milliseconds since the last frame.
]]--
function Update(timeDelta)
	--checking if Select is pressed to open the command prompt
	if Button(Buttons.Select, InputState.Down, 0) then
		command_prompt = true
	else
		command_prompt = false
	end

  --remember where we started
	local startx=p1.x

	--bleed off our horizontal speed from the last frame
  p1.dx *= 0.9


  --jumping
  if(Button(Buttons.A, InputState.Released, 0)) then
    if p1.isgrounded then
      PlaySound(4, 1 )
      p1.dy=-p1.jumpvel
    end

  end

	--left and right. We flip the sprite if going left
   if(Button(Buttons.left, InputState.Down, 0)) then
     p1.dx=-1
     flipH = true
     if(os.difftime(os.clock(), timer) > 0.1) then
       if(spriteId == 0 or spriteId == 38) then
         spriteId = 32
       elseif(spriteId >= 32 and spriteId < 38) then
         spriteId += 2
       end
     end
   end

   if(Button(Buttons.right, InputState.Down, 0)) then
     p1.dx=1
     flipH = false
     if(os.difftime(os.clock(), timer) > 0.1) then
       if(spriteId == 0 or spriteId == 38) then
         spriteId = 32
       elseif(spriteId >= 32 and spriteId < 38) then
         spriteId += 2
       end
     end
   end

 if(Button(Buttons.right, InputState.Down, 0) == false and Button(Buttons.left, InputState.Down, 0) == false) then
   spriteId = 0
 end


   --apply the horizontal acceleration
   p1.x=p1.x+p1.dx

   local xoffset=0 --moving left check the left side of sprite.
 	 if p1.dx>0 then xoffset=7 end --moving right, check the right side.

  --look for a wall on either the left or right of the player
 	--and at the players feet.
 	--We divide by 8 to put the location in TileMap space (rather than
 	--pixel space).
	--The flag method basically gives us the flag ID of the corresponding position
	-- in the tilemap.
 	local flag=Flag((p1.x+xoffset)/8,(p1.y+7)/8)
 	--We use flag 0  to represent solid walls. This is set in the tilemap tool
 	if flag==0 then
 		--they hit a wall so move them
 		--back to their original pos.
 		--it should really move them to
 		--the edge of the wall but this
 		--mostly works and is simpler.
 		p1.x=startx
 	end


   --accumulate gravity
   p1.dy=p1.dy+g.grav

   --apply gravity to the players position.
   p1.y=p1.y+p1.dy

   --assume they are floating
   --until we determine otherwise
   p1.isgrounded=false


   --only check for floors when
 	--moving downward
 	if p1.dy>=0 then
 		--check bottom center of the
 		--player.

 		local flag=Flag((p1.x+4)/8,(p1.y+8)/8)
  	--look for a solid tile
 		if flag==0 then
 			--place p1 on top of tile
 			p1.y = math.floor((p1.y)/8)*8
 			--halt velocity
 			p1.dy = 0
 			--allow jumping again
 			p1.isgrounded=true
    else
      if(p1.dy > 0) then
        spriteId = 68
      end
 		end
 	end



	--only check for ceilings when
	--moving up
	if p1.dy<=0 then

    if(p1.dy < -0.5) then
      spriteId = 64
    elseif(p1.dy < 0 and p1.dy > -0.5) then
      spriteid = 66
    end
		--check top center of player
		local flag=Flag((p1.x+4)/8,(p1.y)/8)
		--look for solid tile
		if flag==0 then
			--position p1 right below
			--ceiling
			p1.y = math.floor((p1.y+8)/8)*8
			--halt upward velocity
			p1.dy = 0
		end
	end
end

--[[
  The Draw() method is part of the game's life cycle. It is called after
  Update() and is where all of our draw calls should go. We'll be using this
  to render sprites to the display.
]]--
function Draw()
  Clear()
  if(spriteId == currentId) then
    DrawSpriteBlock(spriteId, p1.x, p1.y, 2, 2, flipH, false, DrawMode.Sprite)
  else
    currentId = spriteId
    DrawSpriteBlock(spriteId, p1.x, p1.y, 2, 2, flipH, false, DrawMode.Sprite)
    timer = os.clock()
  end

 --draws the whole visible tilemap.
  DrawTilemap()



  --draws command prompt
  DrawSpriteBlock(134,Display().x-32,0,4,4)

  if command_prompt == true then
	DrawTilemap(0,0,32,31,0,1808)
	DrawText("bonjour", 16, 16, DrawMode.UI, "large", 4)
  end

end
