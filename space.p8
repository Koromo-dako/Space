pico-8 cartridge // http://www.pico-8.com
version 27
__lua__
debug=true

-- a table comtaining all game entities
entities = {}

function ycomparison(a,b)
		if a.position==nil or b.position==nil
		then return false end
		return a.position.y+a.position.h>
									b.position.y+b.position.h
		end

function sort(list,comparison)
		for i=2, #list do
				local j=i
				while j>1 and comparison(list[j-1],list[j]) do
				list[j],list[j-1]=list[j-1],list[j]
				j-=1
				end
			end
		end

function canwalk(x,y)
	return not fget(mget(x/8,y/8),7)
end

function touching(x1,y1,w1,h1,
																		x2,y2,w2,h2)
	return x1<x2+w2 and
								x2<x1+w1 and
								y1<y2+h2 and
								y2<y1+h1
	end

--creates and returns a new dialogue component
	function newdialogue()
		local d={}
		d.text=nil
		d.timed=false
		d.timeremaining=0
	 d.cursor=0
		d.set=function(text,timed)
	 	d.text=text
			d.timed=timed
			d.cursor=0
			if timed then d.timeremaining=30
			 end
		 end
		return d
	end

--creates abd returns a new bounding box component
function newbounds(xoff,yoff,w,h)
	local b={}
	b.xoff=xoff
	b.yoff=yoff
	b.w=w
	b.h=h
	return b
end

--creates and returns a new trigger box component
function newtrigger(xoff,yoff,w,h,f,type)
	local t={}
	t.xoff=xoff
	t.yoff=yoff
	t.w=w
	t.h=h
	t.f=f
	--type = 'once','always' or 'wait'
	t.type=type
	t.active=false
 return t
	end

--creates and returns a new control component
function newcontrol(left,right,
up,down,input)
	local c={}
	c.left=left
	c.right=right
	c.up=up
	c.down=down
	c.input=input
	return c
end

--creates and returns a new intention component
function newintention()
	local i={}
	i.left=false
	i.right=false
	i.up=false
	i.down=false
	i.moving=false
	return i
end

-- creates and returns a new position
function newposition(x,y,w,h)
 local p = {}
 p.x = x
 p.y = y
 p.w = w
 p.h = h
 return p
end

-- creates and returns a new sprite
function newsprite(sl)
  local s = {}
  s.spritelist = sl
  s.index = 1
  --s.flip = false
  return s
end

--creates and returns a state
function newstate(initialstate,r)
  local s = {}
  s.current = initialstate
  s.previous = initialstate
  s.rules = r
  return s
end

-- creates and returns animation function
function newanimation(l)
  local a = {}
  a.timer = 0
  a.delay = 3
  a.list = l
  return a
end

-- creates and returns a new entity
function newentity(componenttable)
  local e = {}
  e.position = componenttable.position or nil
  e.sprite = componenttable.sprite or nil
  e.control = componenttable.control or nil
  e.intention = componenttable.intention or nil
  e.bounds = componenttable.bounds or nil
  e.animation = componenttable.animation or nil
  e.trigger = componenttable.trigger or nil
  e.dialogue = componenttable.dialogue or nil
  e.state = componenttable.state or {current='idle'}
  return e
end

function playerinput(ent)
	ent.intention.left=btn(ent.control.left)
	ent.intention.right=btn(ent.control.right)
	ent.intention.up=btn(ent.control.up)
	ent.intention.down=btn(ent.control.down)
	--ent.intention.moving=ent.intention.left or
																						--ent.intention.right or
																						--ent.intention.up or
																						--ent.intention.down
end

function _init()
	--creates new player
	player=newentity({
	--position
	position=newposition(64,64,8,8),
	--sprite
 sprite=newsprite({idle={images={{8,0},flip=false},
																			moveright={images={{8,8},{16,8},{24,8},{32,8},{40,8}},flip=false},
																			moveleft={images={{8,16},{16,16},{24,16},{32,16},{40,16}},flip=false},
																			moveup={images={{48,24},{56,24},{64,24},{72,24}},flip=false},
																			movedown={images={{8,24},{16,24},{24,24},{32,24}},flip=false}}}),
	--control
	control=newcontrol(0,1,2,3,playerinput),
	--intention
	intention=newintention(),
	--bounds
	bounds=newbounds(1,4,6,4),
	--animation
	animation=newanimation({idle=true,moveright=true,moveleft=true,moveup=true,movedown=true}),
	--dialogue
	dialogue=newdialogue(),
	--state
	state=newstate('idle',{moveright=function() return player.intention.right end,
																								moveleft=function() return player.intention.left end,
																								moveup=function() return player.intention.up end,
																								movedown=function() return player.intention.down end,
																								idle=function() return player.state.current=='idle' end})
	})
	add(entities,player)


 	//crate 1
 	add(entities,
 		newentity({
 			position=newposition(80,25,8,8),
 			--sprite=newsprite({{112,0}},1),
				sprite=newsprite({idle={images={{112,0}},flip=false}}),
 			bounds=newbounds(0,0,8,8),
				dialogue=newdialogue(),
				trigger=newtrigger(-1,-1,10,10,
			function(self,other)
				if other==player then
				self.dialogue.set('push',true)
			end
		end,'wait')
		 	})
 			)

 	//crate 2
 	add(entities,
 		newentity({
 			position=newposition(20,80,8,8),
 			sprite=newsprite({idle={images={{112,0}},flip=false}}),
 			bounds=newbounds(0,0,8,8)
 			})
 			)

			//crate 3
		 	add(entities,
		 		newentity({
		 			position=newposition(80,80,8,8),
		 			sprite=newsprite({idle={images={{112,0}},flip=false}}),
		 			bounds=newbounds(0,0,8,8)
		 			})
		 			)

 	//top doors
 	add(entities,
 		newentity({
 			position=newposition(48,0,16,8),
 			--sprite=newsprite({{96,0}},1),
				sprite=newsprite({idle={images={{96,0}},flip=false}}),
				bounds=newbounds(0,0,16,8),
				dialogue=newdialogue(),
				trigger=newtrigger(0,0,16,16,
			function(self,other)
				if other==player then
				other.dialogue.set('nope',true)
			end
		end,'wait')
	})
 			)

end

function _update()
--check player input
controlsystem.update()
--move entities
physics.update()
--animate entities
animation.update()
--checks entity state
statesystem.update()
--check triggers
triggersystem.update()
--update new dialogue
dialoguesystem.update()
end

function _draw()
 graphics.update()
end

-->8
graphics = {}
graphics.update = function()
  cls()
  palt(11,true)
  palt(0,false)

  sort(entities,ycomparison)

  map()

		-- draw all entities with sprites and positions
  for ent in all(entities) do

    -- draw entity
    if ent.sprite and ent.position and ent.state then

     -- reset sprite index if state has changed
     if ent.state.current != ent.state.previous then
      ent.sprite.index = 1
     end

      sspr(ent.sprite.spritelist[ent.state.current]['images'][ent.sprite.index][1],
           ent.sprite.spritelist[ent.state.current]['images'][ent.sprite.index][2],
           ent.position.w, ent.position.h,
           ent.position.x, ent.position.y,
           ent.position.w, ent.position.h,
           ent.sprite.spritelist[ent.state.current]['flip'],false)
    end


  if debug then
 	--draw bounding boxes
 		if ent.position and ent.bounds then
 		rect(ent.position.x+ent.bounds.xoff,
 							ent.position.y+ent.bounds.yoff,
 							ent.position.x+ent.bounds.xoff+ent.bounds.w-1,
 							ent.position.y+ent.bounds.yoff+ent.bounds.h-1,
 							10)
 	 end



		--draw trigger boxes
			if ent.position and ent.trigger then
				local color
				if ent.trigger.active then color=2 else color=14 end
					rect(ent.position.x+ent.trigger.xoff,
							ent.position.y+ent.trigger.yoff,
							ent.position.x+ent.trigger.xoff+ent.trigger.w-1,
							ent.position.y+ent.trigger.yoff+ent.trigger.h-1,
							color)
			end
	end
end




		camera()

		--draw dialogue boxes
		for ent in all(entities) do
			if ent.dialogue and ent.position then
				if ent.dialogue.text then
					if (ent.dialogue.timed==false) or (ent.dialogue.timed and ent.dialogue.timeremaining>0) then
						local texttodraw=sub(ent.dialogue.text,0,ent.dialogue.cursor)
					--draw outline
						for x=-1,1 do
							for y=-1,1 do
							print(texttodraw, ent.position.x+x,ent.position.y-8+y,0)
						end
						end
						--draw text
						print(texttodraw, ent.position.x,ent.position.y-8,7)
				 end
				end
			end
		end

end


-->8
physics={}
physics.update=function()
	for ent in all(entities) do
		if ent.position and ent.bounds then

		local newx=ent.position.x
		local newy=ent.position.y


		if ent.intention then
			if ent.intention.left then newx-=1 end
			if ent.intention.right then newx+=1 end
			if ent.intention.up then newy-=1 end
			if ent.intention.down then newy+=1 end

		end

	local canmovex=true
	local canmovey=true

//map collision

--update x position if able to move
if not canwalk(newx+ent.bounds.xoff,ent.position.y+ent.bounds.yoff) or
			not canwalk(newx+ent.bounds.xoff+ent.bounds.w-1,ent.position.y+ent.bounds.yoff+ent.bounds.h-1) or
			not canwalk(newx+ent.bounds.xoff,ent.position.y+ent.bounds.yoff) or
			not canwalk(newx+ent.bounds.xoff+ent.bounds.w-1,ent.position.y+ent.bounds.yoff+ent.bounds.h-1) then

			canmovex=false
end

if not canwalk(ent.position.x+ent.bounds.xoff,newy+ent.bounds.yoff) or
			not canwalk(ent.position.x+ent.bounds.xoff+ent.bounds.w-1,newy+ent.bounds.yoff) or
			not canwalk(ent.position.x+ent.bounds.xoff+ent.bounds.w-1,newy+ent.bounds.yoff+ent.bounds.h-1) or
			not canwalk(ent.position.x+ent.bounds.xoff+ent.bounds.w-1,newy+ent.bounds.yoff+ent.bounds.h-1) then

			canmovey=false
end

//entity collision

--check x
	for o in all(entities) do
		if o.position and o.bounds then
			if o~=ent and
				touching(newx+ent.bounds.xoff,
													ent.position.y+ent.bounds.yoff,
													ent.bounds.w,
													ent.bounds.h,
													o.position.x+o.bounds.xoff,
													o.position.y+o.bounds.yoff,
													o.bounds.w,
													o.bounds.h)
			then
			canmovex=false
			end
		end
	end

--check y
	for o in all(entities) do
		if o.position and o.bounds then
			if o~=ent and
				touching(ent.position.x+ent.bounds.xoff,
												 newy+ent.bounds.yoff,
													ent.bounds.w,
													ent.bounds.h,
													o.position.x+o.bounds.xoff,
													o.position.y+o.bounds.yoff,
													o.bounds.w,
													o.bounds.h)
			then
			canmovey=false
			end
		end
	end


--interaction with crates
--check x
--right
	for o in all(entities) do
		if o~=ent then
			if touching(newx+ent.bounds.xoff,
												ent.position.y+ent.bounds.yoff,
												ent.bounds.w,
												ent.bounds.h,
												o.position.x+o.bounds.xoff,
												o.position.y+o.bounds.yoff,
												o.bounds.w,
												o.bounds.h)
		and btn(5) and ent.intention.right
		then		o.position.x+=1
			end
		end


--left
		if o~=ent and
			touching(newx+ent.bounds.xoff,
												ent.position.y+ent.bounds.yoff,
												ent.bounds.w,
												ent.bounds.h,
												o.position.x+o.bounds.xoff,
												o.position.y+o.bounds.yoff,
												o.bounds.w,
												o.bounds.h)
		and btn(5) and ent.intention.left
		then		o.position.x-=1
		end


--check y
--down
		if o~=ent and
			touching(ent.position.x+ent.bounds.xoff,
											 newy+ent.bounds.yoff,
												ent.bounds.w,
												ent.bounds.h,
												o.position.x+o.bounds.xoff,
												o.position.y+o.bounds.yoff,
												o.bounds.w,
												o.bounds.h)
				and btn(5) and ent.intention.down
		then
		o.position.y+=1
		end


	--up
			if o~=ent and
				touching(ent.position.x+ent.bounds.xoff,
												 newy+ent.bounds.yoff,
													ent.bounds.w,
													ent.bounds.h,
													o.position.x+o.bounds.xoff,
													o.position.y+o.bounds.yoff,
													o.bounds.w,
													o.bounds.h)
					and btn(5) and ent.intention.up
			then
			o.position.y-=1
			end


	end

	if canmovex then ent.position.x=newx end
	if canmovey then ent.position.y=newy end


		end
	end
end

triggersystem={}
triggersystem.update=function()
	for ent in all(entities) do
		if ent.position and ent.trigger then
			local triggered=false
			for o in all(entities) do
				if ent~= o and o.position and o.bounds then
					if touching(ent.position.x+ent.trigger.xoff,
														ent.position.y+ent.trigger.yoff,
														ent.trigger.w,
														ent.trigger.h,
														o.position.x+o.bounds.xoff,
														o.position.y+o.bounds.yoff,
														o.bounds.w,
														o.bounds.h)
					then
						--trigger is activated
						triggered=true

						if ent.trigger.type=='once' then
						ent.trigger.f(ent,o)
						ent.trigger=nil
							break
					 end
						if ent.trigger.type=='always' then
						ent.trigger.f(ent,o)
						ent.trigger.active=true
						end
						if ent.trigger.type=='wait' then
							if ent.trigger.active==false then
								ent.trigger.f(ent,o)
								ent.trigger.active=true
							end
						end
					end
				end
			end

if triggered==false then
ent.trigger.active=false
end

		end
	end
end

dialoguesystem={}
dialoguesystem.update=function()
	for ent in all(entities) do
		if ent.dialogue then
			if ent.dialogue.text then
					if ent.dialogue.cursor<#ent.dialogue.text then
						ent.dialogue.cursor+=1
					end
				if ent.dialogue.timed and
				 ent.dialogue.timeremaining>0 then
					ent.dialogue.timeremaining-=1
			 end
		 end
		end
	end
end
-->8


controlsystem={}
controlsystem.update=function()
	for ent in all(entities) do
		if ent.control~=nil
		and ent.intention~=nil
		then ent.control.input(ent)
		end
	end
end

-->8
animation = {}
animation.update = function()
  for ent in all(entities) do
    if ent.sprite and ent.animation and ent.state then

      if ent.animation.list[ent.state.current] then
       -- increment timer
       ent.animation.timer += 1
       -- if timer is higher than the delay
       if ent.animation.timer > ent.animation.delay then
        -- increment the index and reset the timer
        ent.sprite.index += 1
        if ent.sprite.index > #ent.sprite.spritelist[ent.state.current]['images'] then
         ent.sprite.index = 1
        end
        ent.animation.timer = 0
       end
      end

    end
  end

end

statesystem = {}
statesystem.update = function()
 for ent in all(entities) do
  if ent.state and ent.state.rules then

   ent.state.previous = ent.state.current

   for s,r in pairs(ent.state.rules) do
    if r() then ent.state.current = s end
   end

  end
 end
end


__gfx__
00000000bbccc7bbbb9999bbbbccc7bbbbcc799bb99cc7bbbbcc799bb99cc7bbb99cc7bbbbcc799b000000000000000056677777777776658847788856666666
00000000bccc7ccbb999999bbccc7ccbbcc7c99bb99c7ccbbcc7c99bb99c7ccbb99c7ccbbcc7c99b000000000000000055566777777665558847788875666667
00700700bccccccbb999999bbccccccbbcccc99bb99ccccbbcccc99bb99ccccbb99ccccbbcccc99b000000000000000057755667766557758884488877566677
00077000b999999bb999999bb999999bb999999bb999999bb999999bb999999bb999999bb999999b000000000000000057777556655777757777777777566677
00077000577777755777777557777775b777757bb757777bb777777bb777777bb777777bb777777b000000000000000057777776677777754444444477566677
00700700599999955999999559999995b999959bb959999bb999999bb999999bb999999bb999999b000000000000000057777665566777758888888877566677
00000000b9bbbb9bb9bbbb9bb9bbbb9bbb9bbb9bb9bbb9bbbb9bbb9bb9bbb9bbb9bbb9bbbb9bbb9b000000000000000057766557755667758888888875666667
00000000b9bbbb9bb9bbbb9bb9bbbb9bb99bb99bb99bb99bb99bb99bb99bb99bb99bb99bb99bb99b000000000000000056655777777556658888888856666666
00000000b99cc7bbb99cc7bbb99cc7bbb99cc7bbb99cc7bb00000000000000000000000000000000000000000000000000000000000000000000000088888888
00000000b99c7ccbb99c7ccbb99c7ccbb99c7ccbb99c7ccb000000000000000000000000000000000000000000000000000000000000000000000000aaaaaaaa
00000000b99ccccbb99ccccbb99ccccbb99ccccbb99ccccb00000000000000000000000000000000000000000000000000000000000000000000000056556556
00000000b999999bb999999bb999999bb999999bb999999b00000000000000000000000000000000000000000000000000000000000000000000000066666666
00000000b757777bb757777bb755777bb755777bb757777b00000000000000000000000000000000000000000000000000000000000000000000000055555555
00000000b959999bb995999bb999999bb999999bb995999b00000000000000000000000000000000000000000000000000000000000000000000000066656665
00000000b9bbb9bbbb9b9bbbbbb99bbbbbb9bbbbbb9b9bbb00000000000000000000000000000000000000000000000000000000000000000000000066656665
00000000b99bb99bbb9999bbbbb999bbbbb99bbbbb9999bb00000000000000000000000000000000000000000000000000000000000000000000000066656665
00000000bbcc799bbbcc799bbbcc799bbbcc799bbbcc799b00000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000bcc7c99bbcc7c99bbcc7c99bbcc7c99bbcc7c99b00000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000bcccc99bbcccc99bbcccc99bbcccc99bbcccc99b00000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000b999999bb999999bb999999bb999999bb999999b00000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000b777757bb777757bb777557bb777557bb777757b00000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000b999959bb999599bb999999bb999999bb999599b00000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000bb9bbb9bbbb9b9bbbbb99bbbbbbb9bbbbbb9b9bb00000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000b99bb99bbb9999bbbb999bbbbbb99bbbbb9999bb00000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000bbccc7bbbbccc7bbbbccc7bbbbccc7bb00000000bb9999bbbb9999bbbb9999bbbb9999bb000000000000000000000000000000000000000000000000
00000000bccc7ccbbccc7ccbbccc7ccbbccc7ccb00000000b999999bb999999bb999999bb999999b000000000000000000000000000000000000000000000000
00000000bccccccbbccccccbbccccccbbccccccb00000000b999999bb999999bb999999bb999999b000000000000000000000000000000000000000000000000
00000000b999999bb999999bb999999bb999999b00000000b999999bb999999bb999999bb999999b000000000000000000000000000000000000000000000000
00000000577777755777777557777775577777750000000057777775577777755777777557777775000000000000000000000000000000000000000000000000
0000000059999995b99999955999999b5999999500000000599999955999999bb999999559999995000000000000000000000000000000000000000000000000
00000000b9bbbb9bb9bbbb9bb9bbbb9bb9bbbb9b00000000b9bbbb9bb9bbbb9bb9bbbb9bb9bbbb9b000000000000000000000000000000000000000000000000
00000000b9bbbb9bb9bbbbbbbbbbbb9bb9bbbb9b00000000b9bbbb9bbbbbbb9bb9bbbbbbb9bbbb9b000000000000000000000000000000000000000000000000
66777777777777777777777777777776000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
56677777777777777777777777777766000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
75667777777777777777777777777667000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
77566777777777777777777777776677000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
77756677777777777777777777766777000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
77775667777777777777777777667777000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
77777566777777777777777776677777000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
77777756677777777777777766777777000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
77777775667777777777777667777777000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
77777777566777777777776677777777000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
77777777756677777777766777777777000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
77777777775667777777667777777777000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
77777777777566777776677777777777000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
77777777777756677766777777777777000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
77777777777775667667777777777777000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
77777777777777566677777777777777000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
66666666666666666666666666666666000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
55555555555555566655555555555555000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
77777777777777665667777777777777000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
77777777777776677566777777777777000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
77777777777766777756677777777777000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
77777777777667777775667777777777000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
77777777776677777777566777777777000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
77777777766777777777756677777777000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
77777777667777777777775667777777000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
77777776677777777777777566777777000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
77777766777777777777777756677777000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
77777667777777777777777775667777000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
77776677777777777777777777566777000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
77766777777777777777777777756677000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
77667777777777777777777777775667000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
66677777777777777777777777777566000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__gff__
0000000000000000000000000000008000000000000000000000000000000080000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0f0f0f0f0f0f00000f0f0f0f0f0f0f0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0f404142434041424340414243400f0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0f505152535051525350515253500f0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0f606162636061626360616263600f0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0f707172737071727370717273700f0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0f404142434041424340414243400f0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0f505152535051525350515253500f0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0f606162636061626360616263600f0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0f707172737071727370717273700f0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0f404142434041424340414243400f0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0f505152535051525350515253500f0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0f606162636061626360616263600f0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0f707172737071727370717273700f0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0f404142434041424340414243400f0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
