function onEvent(n,v1,v2)


	if n == 'redflash' then

	   makeLuaSprite('flash', '', 0, 0);
        makeGraphic('flash',1280,720,'ff0000')
	      addLuaSprite('flash', true);
	      setLuaSpriteScrollFactor('flash',0,0)
	      setProperty('flash.scale.x',2)
	      setProperty('flash.scale.y',2)
	      setProperty('flash.alpha',0)
		setProperty('flash.alpha',1)
		doTweenAlpha('flTw','flash',0,v1,'linear')
		setObjectCamera('flash', 'other');
	end



end