function onCreate()
    makeLuaSprite('sky', 'nightsky', -300, -400);
    setScrollFactor('sky', 0.1, 0.3);
    scaleObject('sky', 10.8, 2.3)
    screenCenter('sky', 'xy')
    addLuaSprite('sky', false);
    setSpriteShader('sky', 'colors')
end

function onUpdatePost()
    setShaderFloat('sky', 'uTime', getSongPosition() * 0.0005)
    setShaderFloat('sky', 'iTime', getSongPosition() * 0.0005)
end

function onUpdate(elapsed)
	elapsedTime = elapsedTime + elapsed
	setShaderFloat('sky', 'uWaveAmplitude', 0.9)
	  setShaderFloat('sky', 'uFrequency', 100)
	  setShaderFloat('sky', 'uSpeed', 2.25)
	setShaderFloat('sky', 'uTime', elapsedTime)
  end