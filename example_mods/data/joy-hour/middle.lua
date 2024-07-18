local keepScroll = false
function onCreate()
setProperty('camHUD.visible',true)
setProperty('gf.alpha', 1)

	if getPropertyFromClass('backend.ClientPrefs', 'data.middleScroll') == true then
		keepScroll = true;
	elseif getPropertyFromClass('backend.ClientPrefs', 'data.middleScroll') == false then
		setPropertyFromClass('backend.ClientPrefs', 'data.middleScroll', true);
	end
end

function onDestroy()
	if keepScroll == false then
		setPropertyFromClass('backend.ClientPrefs', 'data.middleScroll', false);
	elseif keepScroll == true then
		keepScroll = false;
	end
end
