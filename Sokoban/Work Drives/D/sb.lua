--Sokoban By RamiLego4Game

local startlvl = (...)
if not tonumber(startlvl or "") then startlvl = 1 else startlvl = tonumber(startlvl) end

local levels = {
  --X,Y, Width, Height
  {0,0, 22,11}, --1
  {22,0, 14,10}, --2
  {36,0, 17,10}, --3
  {53,0, 22,13}, --4
  {75,0, 17,13}, --5
  {92,0, 12,11}, --6
  {104,0, 13,12}, --7
  {117,0, 19,15}, --11
  {0,11, 13,16}, --12
  {13,11, 20,13}, --13
  {33,10, 17,13}, --14
  {50,13, 14,15}, --16
  {64,13, 18,16}, --17
  {82,13, 22,13}, --18
  {104,15, 16,14}, --21
  {120,15, 15,15}, --26
  {0,27, 23,13}, --27
  {23,24, 24,11}, --29
  {47,28, 15,12}, --31
  {62,29, 18,16}, --32
  {82,26, 13,15}, --33
  {95,29, 12,15}, --34
  {107,30, 20,16}, --35
  {0,40, 21,15}, --37
  {23,35, 14,15}, --38
  {37,40, 11,11}, --40
  {48,45, 20,15}, --41
  {68,45, 17,16}, --43
  {85,46, 19,11}, --45
  {104,46, 19,15}, --47
  {127,30, 16,15}, --48
  {123,45, 19,16}, --49
  {0,55, 21,16}, --50
  {21,50, 16,14}, --51
  {37,60, 21,14}, --52
  {58,61, 22,15}, --55
  {85,57, 14,16}, --56
  {99,61, 18,11} --57
}

local wallbase = SpriteMap:extract(6)

local sw, sh = screenSize()

local boxtid = 1
local goaltid = 2
local spawntid = 3
local walltid = 5

local maps, wimgs, gslots, spawns = {}, {}, {}, {}

--ImageUtils.queuedFill minified, source code is at C:/APIS/ImageUtils.lua
local function queuedFill(b,c,d,e,f,g,h,i)local j=b.getPixel;local k=b.setPixel;local l=j(b,c,d)if l==e then return end;local m,n,o={},0,0;k(b,c,d,e)n=n+1;m[n]={c,d}local function p(q,r)if f and(q<f or r<g or q>h or r>i)then return end;if j(b,q,r)==l then k(b,q,r,e)n=n+1;m[n]={q,r}end end;while o<n do o=o+1;local s=m[o]local q,r=s[1],s[2]p(q-1,r)p(q+1,r)p(q,r-1)p(q,r+1)end end

--Outline map walls image
local function outlineImage(img,col)
  local iw, ih = img:size(); iw, ih = iw-1, ih -1
  img:map(function(x,y,c)
    if c > 0 then
      if x == 0 or y == 0 or x == iw or y == ih then return col end
      for iy=-1,1 do
        for ix=-1,1 do
          if img:getPixel(x+ix,y+iy) == 0 then
            return col
          end
        end
      end
    end
    
    return c
  end)
end

--Convert th levels into Maps
for id, level in ipairs(levels) do
  local x,y,w,h = unpack(level)

  maps[id] = TileMap:cut(x,y,w,h)
  gslots[id] = {}
  spawns[id] = {0,0}
  
  local img = imagedata(w*8,h*8)

  maps[id]:map(function(tx,ty,tid)
    if tid == spawntid then
      spawns[id] = {tx,ty}
      return 0
    end
    
    if tid == goaltid then
      table.insert(gslots[id], {tx,ty})
      return 0
    end

    if tid == walltid then --Wall piece
      img:paste(wallbase, tx*8, ty*8)
    end
    
    return tid
  end)
  
  --Outline walls image
  outlineImage(img,7)
  
  --FloodFill the level starting from player position
  queuedFill(img, spawns[id][1]*8,spawns[id][2]*8, 5)
  
  wimgs[id] = img:image() --Convert it into a drawable image.
end

local px, py = 0,0
local prot, pinv, pflag = false,false,false
local lvlid = 1
local lvl = maps[lvlid]:cut()
local lvlimg = wimgs[lvlid]
local lvlox, lvloy --Drawing offset

local function playLevel(lid)
  lvlid = lid or lvlid
  lvl = maps[lvlid]:cut()
  lvlimg = wimgs[lvlid]
  px, py = unpack(spawns[lvlid])
  lvlox = -(levels[lvlid][3]*8-sw)/2
  lvloy = -(levels[lvlid][4]*8-sh)/2
end

local function checkGoals()
  for id, goal in pairs(gslots[lvlid]) do
    if lvl:cell(goal[1],goal[2]) ~= boxtid then return end
  end
  
  return true
end

local function checkLevel()
  if checkGoals() then
    if lvlid == #levels then
      exit("Game complete")
    end
    playLevel(lvlid + 1)
  end
end

function _init()
  colorPalette(0,10,10,10)
  playLevel(startlvl)
end

local function drawGoals()
  for gid, goal in pairs(gslots[lvlid]) do
    local x, y = unpack(goal)
    Sprite(goaltid,x*8,y*8)
  end
end

local function mapDrawIter(x,y,tid)
  if tid ~= walltid and tid > 0 then
    Sprite(tid,x*8,y*8)
  end
end

local function drawMap()
  lvlimg:draw(0,0)
  drawGoals()
  lvl:map(mapDrawIter)
end

local function drawPlayer()
  pal(1,pflag and 1 or 15) palt(1,pflag)
  pal(2,pflag and 15 or 2) palt(2,not pflag)
  local r = prot and math.pi/2 or 0
  local s = pinv and -1 or 1
  local o = pinv and 8 or 0
  local ox, oy = prot and o+8 or o,o
  if prot and pinv then ox = 0 end
  Sprite(4, px*8+ox,py*8+oy,r,s,s)
  pal() palt()
end

local function drawUI()
  color(0) print("Level: "..lvlid,0,sh-6)
  print("Level: "..lvlid,2,sh-6)
  print("Level: "..lvlid,1,sh-5)
  print("Level: "..lvlid,1,sh-7)
  color(7) print("Level: "..lvlid,1,sh-6)
end

function _draw()
  clear()
  cam("translate",lvlox,lvloy)
  drawMap()
  drawPlayer()
  cam()
  drawUI()
end

local function movePlayer(dx,dy)
  pflag = not pflag

  if dx ~= 0 then
    prot = true
    pinv = dx < 0
  else
    prot = false
    pinv = dy > 0
  end

  local tile = lvl:cell(px+dx,py+dy)
  if tile == walltid then return end
  if tile == boxtid then
    local ntile = lvl:cell(px+dx*2,py+dy*2)
    if ntile == 0 then
      lvl:cell(px+dx*2,py+dy*2,boxtid)
      lvl:cell(px+dx,py+dy,0)
    else
      return
    end
  end

  px,py = px+dx, py+dy
  
  checkLevel()
end

local function checkControls()
  if btnp(1) then movePlayer(-1,0) end
  if btnp(2) then movePlayer(1,0) end
  if btnp(3) then movePlayer(0,-1) end
  if btnp(4) then movePlayer(0,1) end
  
  if btnp(7) then playLevel(lvlid) end --Restart the level
end

function _update()
  checkControls()
end