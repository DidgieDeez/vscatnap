function onEvent(name,value1,value2)
	if name == 'byehud' then
		doTweenAlpha('hudalpha', 'camHUD', tonumber(value1), tonumber(value2), 'linear');
		--debugPrint('Event triggered: ', name, duration, targetAlpha);
	end
end