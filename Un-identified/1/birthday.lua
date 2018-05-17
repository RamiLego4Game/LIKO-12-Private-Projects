--Piano Player [Birthday]

Controls("Keyboard")

local notes = {
 "C","C#","D","D#","E","F","F#",
 "G","G#","A","A#","B"
}

for k,v in ipairs(notes) do notes[v] = k end

local waves = 5
local wname = {
 "Sin", "Square", "Pulse","Sawtooth",
 "Triangle", "Noise"
}  

--Notes go from 1 to 12
--Oct goes from 0 to 8
local function calcHz(note,oct)
 local c = 2^(1/12)
 
 local notepos = (oct)*12+note
 local notedist = notepos - 58
 local notehz = 440 --A4
 
 if notedist < 0 then
  for i=1,-notedist do
   notehz = notehz/c
  end
 elseif notedist > 0 then
  for i=1,notedist do
   notehz = notehz*c
  end
 end
 
 return math.floor(notehz)
end

local oct = 4
local hz = 0
local note
local wave = 0

function _draw()
 clear(0)
 rect(0,32,192,64,false,5)
 _drawPiano()
 
 color(12)
 print("Piano Player [ Happy Birthday ]",5,37)
 
 color(7)
 print("OCT: "..oct,5,55)
 print("NOTE: "..(note and notes[note]..oct or "-"),5,65)
 print("Frequency: "..hz.."Hz",5,75)
 print("Wave: "..wname[wave+1],5,85)
end

local cpiano = {7,13,7,13,7,7,13,7,13,7,13,7}

function _drawPiano()
 for i=4,15 do
  local c = cpiano[i-3]
  if note and note == i-3 then
   c = (c == 13) and 2 or 6
  end
  
  pal(i,c)
 end
 SpriteGroup(1,192-8*8,48, 8,4)
 pal()
end

--Format: Note, time hold, time released
-- [=] Don't change Octave, [-] decrease the Octave, [+] increase the Octave
local music = {
  "G=",0.2,0.1, "G=",0.2,0.1, "A=",0.4,0.1, "G=",0.5,0.1, "C=",0.2,0.1, "B=",0.7,0.6,
  "G=",0.2,0.1, "G=",0.2,0.1, "A=",0.4,0.1, "G=",0.5,0.1, "D=",0.2,0.1, "C=",0.7,0.6,
  "G=",0.2,0.1, "G=",0.2,0.1, "G+",0.4,0.1, "E-",0.5,0.1, "C=",0.3,0.1, "B=",0.1,0.1, "A=",0.1,0.6,
  "F=",0.2,0.1, "F=",0.2,0.1, "E=",0.4,0.1, "C=",0.5,0.1, "D=",0.2,0.1, "C=",0.7,1
}

local musicPos = 0
local musicIter = function()
  musicPos = musicPos + 1
  return music[musicPos]
end

local timer = 0
local timerelease = 0

function _update(dt)
  timer = timer - dt
  
  if btnp(7) then Audio.generate() exit() end
  if timer <= 0 then
    if timerelease == 0 then --Next Note
      local notestr = musicIter()
      if notestr then
        timer = musicIter()
        timerelease = musicIter()
        
        local octstr = notestr:sub(-1,-1)
        if octstr == "+" then
          oct = oct + 1
        elseif octstr == "-" then
          oct = oct - 1
        end
        
        note = notes[notestr:sub(1,-2)]
        hz = calcHz(note,oct)
        Audio.generate(wave,hz,1)
      else
        exit()
      end
    else --Release Time
      timer = timerelease
      timerelease = 0
      note = false
      hz = 0
      Audio.generate()
    end
  end
end

clearEStack()