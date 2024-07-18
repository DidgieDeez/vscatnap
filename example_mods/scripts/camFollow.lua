---@funkinScript

local stuff = {
  disabled = false,
  anims = {
    ['idle'] = {0, 'x'},
    ['danceleft'] = {0, 'x'},
    ['danceright'] = {0, 'x'},
    ['hey'] = {0, 'x'},
    ['singleft'] = {-50, 'x'},
    ['singdown'] = {50, 'y'},
    ['singup'] = {-50, 'y'},
    ['singright'] = {50, 'x'},
    ['idle-loop'] = {0, 'x'},
    ['danceleft-loop'] = {0, 'x'},
    ['danceright-loop'] = {0, 'x'},
    ['hey-loop'] = {0, 'x'},
    ['singleft-loop'] = {-50, 'x'},
    ['singdown-loop'] = {50, 'y'},
    ['singup-loop'] = {-50, 'y'},
    ['singright-loop'] = {50, 'x'},
  },
  check = {
    [true] = 'boyfriend',
    [false] = 'dad',
  },
}

function onUpdatePost(elapsed)
  if not stuff.disabled then
    local anim_info = stuff.anims[getProperty(stuff.check[mustHitSection]..'.animation.curAnim.name'):lower()]
    if anim_info then
      local var = ((version:find('0.7') and 'camGame.scroll' or 'camFollowPos')..'.')..(anim_info[2] or 'x')
      local currentPos = getProperty(var);
      setProperty(var,
        lerp(currentPos,
          currentPos + ((anim_info[1] or 0) * (1 / getProperty('camGame.zoom'))),
          elapsed * getProperty('cameraSpeed') * playbackRate
        )
      );
    end
  end
end

function onEvent(name, v1, v2)
    if name == 'controlcameramovescript' then
        if v1 == 'disable' then
		stuff.disabled = true
	end
	if v1 == 'enable' then
		stuff.disabled = false
	end
   end
end


function lerp(a, b, c) return a + (b - a) * c end