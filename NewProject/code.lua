local xPos = 0
local yPos = 4
local flipH = false
local spriteId = 0
local timer
local currentId
local showInteract = false

-- telling if the command prompt is open or not
local command_prompt = false

-- determine which screen the player is on (true: user is on current screen)
local main_menu = true
local game_play = false
local game_over = false

-- determine which level the player is on
local level = 1

-- blinking text timer
local blink = 0



--player information
p1=
{
	--position, representing the top left of
	--of the player sprite.
	x=4,
	y=10,
	dx=0,
	dy=0,

	--is the player standing on
	--the ground. used to determine
	--if they can jump.
	isgrounded=false,

	--how fast the player is launched
	--into the air when jumping.
	jumpvel=2.1,
}

chest=
{
	x=16,
	y=20,
	locked=true,
	opened=false,
	id=100,
}

door=
{
	x=29,
	y=1,
	locked=true,
	id=96
}

g=
{
	grav=0.1, -- gravity per frame
}



function Init()
	BackgroundColor(11)
	local display = Display()
	PlaySong(0, false, 0)
end





function Update(timeDelta)
	-- MAIN MENU
	if main_menu == true then
		-- If A is pressed (default x) then the user moves to the game
		if Button(Buttons.A, InputState.Down, 0) then
			main_menu = false
			game_play = true
		end

		-- Increase blink timer
		blink = blink + 1
	end



	-- GAMEPLAY
	if game_play == true then
		-- if Select (default a) is pressed, open the command prompt
		if Button(Buttons.Select, InputState.Down, 0) then
			command_prompt = true
		else
			command_prompt = false
		end



		-- get start location
		local startx=p1.x

		-- bleed off our horizontal speed from the last frame
	 	p1.dx *= 0.9

		-- jumping
		if(Button(Buttons.B, InputState.Down, 0)) then
			if p1.isgrounded then
				PlaySound(4, 1 )
				p1.dy=-p1.jumpvel
			end
		end

		-- horizontal movement of player. We flip the sprite if going left
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

		-- if the player is standing still
		if(Button(Buttons.right, InputState.Down, 0) == false and Button(Buttons.left, InputState.Down, 0) == false) then
			spriteId = 0
		end


		-- apply the horizontal acceleration
		p1.x=p1.x+p1.dx


		local xoffset=3 --moving left check the left side of sprite.
		if p1.dx>0 then xoffset=11 end --moving right, check the right side.
		local flag=Flag((p1.x+xoffset)/8,(p1.y+11)/8)
		--[[ look for a wall on either the left or right of the player and at the players feet.
		We divide by 8 to put the location in TileMap space (rather than pixel space).
		The flag method basically gives us the flag ID of the corresponding position in the tilemap. --]]

	 	-- We use flag 0  to represent solid walls. This is set in the tilemap tool
	 	if flag==0 or (flag==5 and chest.opened) or (flag==3 and chest.opened == false) then
	 		--[[ they hit a wall so move them back to their original pos.
	 		it should really move them to the edge of the wall but this
	 		mostly works and is simpler. --]]
	 		p1.x=startx
	 	end

		if flag==1 then
			showInteract = true
		else
			showInteract = false
		end



		-- accumulate gravity
		p1.dy=p1.dy+g.grav

		-- apply gravity to the players position.
		p1.y=p1.y+p1.dy

		-- assume they are floating until we determine otherwise
		p1.isgrounded=false


		--only check for floors when moving downward
		if p1.dy>=0 then
			--check bottom center of the player.
	 		local flag=Flag((p1.x+4)/8,(p1.y+16)/8)
	  		--look for a solid tile
	 		if flag==0 or (flag==5 and chest.opened) or (flag==3 and chest.opened == false) then
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
			if flag==0 or (flag==5 and chest.opened) or (flag==3 and chest.opened == false) then
				--position p1 right below
				--ceiling
				p1.y = math.floor((p1.y+8)/8)*8
				--halt upward velocity
				p1.dy = 0
			end
		end

		-- check if tiles are being interacted with
		if(Button(Buttons.A, InputState.Down, 0)) then
			if((math.abs(chest.x - (p1.x)/8) < 2) and (math.abs(chest.y - (p1.y)/8) < 2)) then
				chest.id = 102
				chest.opened = true
			end
			if((math.abs(door.x - (p1.x)/8) < 2) and (math.abs(door.y - (p1.y)/8) < 2) and (chest.opened == true)) then
				door.id = 98
				level = level + 1
			end
		end
	end



	-- GAME OVER
	if game_over == true then
		-- If A is pressed (default x) then the user moves back to the main menu
		if Button(Buttons.A, InputState.Released, 0) then
			game_over = false
			main_menu = true
		end

		-- Increase blink timer
		blink = blink + 1
	end
end





function Draw()
	Clear()

	-- MAIN MENU
	if main_menu == true then
		-- loading background
		BackgroundColor(11)
		DrawTilemap(0,0,32,31,256,1808)

		-- loading text box and displaying game title
		local title = "Placeholder Title"
		DrawText(title, 30, 70, DrawMode.UI, "large", 7)

		-- displaying "press to start" text and making it blink
		if blink >= 30 and blink < 60 then
			DrawText("Press x to start", 60, 200, DrawMode.UI, "large", 4)
		elseif blink >= 60 then
			blink = 0
		end
	end



	-- GAMEPLAY
	if game_play == true then
		if command_prompt == false then
			-- displays the player sprite
		 	if(spriteId == currentId) then
		    	DrawSpriteBlock(spriteId, p1.x, p1.y, 2, 2, flipH, false, DrawMode.Sprite)
		 	else
		    	currentId = spriteId
		    	DrawSpriteBlock(spriteId, p1.x, p1.y, 2, 2, flipH, false, DrawMode.Sprite)
		    	timer = os.clock()
		  	end



			if level == 1 then
				-- displays sprites that can be interacted with (non-tilemap sprites)
				DrawSpriteBlock(chest.id, chest.x, chest.y, 2, 2, false, false, DrawMode.Tile)
				DrawSpriteBlock(door.id, door.x, door.y, 2, 3, false, false, DrawMode.Tile)

				-- offset of the level on the tilemap
				local l_map_x = 0
				local l_map_y = 0

			elseif level == 2 then
				-- displays sprites that can be interacted with (non-tilemap sprites)
				DrawSpriteBlock(chest.id, chest.x, chest.y, 2, 2, false, false, DrawMode.Tile)
				DrawSpriteBlock(door.id, door.x, door.y, 2, 3, false, false, DrawMode.Tile)

				-- offset of the level on the tilemap
				local l_map_x = 256
				local l_map_y = 0
			end



			-- show cross above the tile if player can interact with it
			if showInteract == true then
				DrawSpriteBlock( 132, p1.x, p1.y - 12, 2, 1, false, false, DrawMode.Sprite)
			end

			-- draws the tilemap of the level.
			DrawTilemap(0,0,32,32,l_map_x,l_map_y)

			-- shows the current level
			DrawText(level,16,16,DrawMode.UI,"large")

			-- draws command prompt icon in the top right of the screen
			DrawSpriteBlock(134,Display().x-32,0,4,4)



		-- if the command prompt is open
		elseif command_prompt == true then
			DrawTilemap(0,0,32,31,0,1808)

			-- choosing the code snippet to display based on the level
			local cp_msg = {}
			if level == 1 then
				cp_msg = {"while !power:","\t\tdoor_unlocked = false"}
			elseif level == 2 then
				cp_msg = {"door_unlocked = false","","while True:","\t\tif fire == false:","\t\t\t\tdoor_unlocked = true"}
			end

			-- displaying the code snippet
			for i=1, #cp_msg, 1 do
				DrawText(cp_msg[i], 24, 24 + ((i-1)*15), DrawMode.UI, "large", 7)
			end
		end
	end



	-- GAME OVER
	if game_over == true then
		BackgroundColor(3)
		DrawText("YOU ESCAPED!", 80, 100, DrawMode.UI, "large", 11)

		-- displaying "press to play again" text and making it blink
		if blink >= 30 and blink < 60 then
			DrawText("Press x to play again", 40, 200, DrawMode.UI, "large", 11)
		elseif blink >= 60 then
			blink = 0
		end
	end
end
