local allowCountdown = false

 function onStartCountdown()
     luaDebugMode = true

     if not allowCountdown then
        
         startVideo('catfienecutscene');
         allowCountdown = true;
         return Function_Stop;
         
     end

     return Function_Continue;

 end