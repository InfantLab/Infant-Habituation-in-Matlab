function attnget(window);

if nargin < 1
    screens=Screen('Screens');
    screenNumber=max(screens);
    [w,windowRect]=Screen(screenNumber,'OpenWindow',0,[],32,2);
else
    w=window;
    windowRect = [0 0 800 600];
end

key_a = KbName('a');
key_b = KbName('b');
green=[0 255 0];
grey = [200 200 200];

port=2;


while 1
    
    beep;
   [keyIsDown,timeSecs,keyCode] = KbCheck;   
        if keyIsDown
        else
            return;
        end
	n=200;
	rect=[0 0 n n];
	rect2=CenterRect(rect,windowRect);
	
	for i=[1:n/4, n/4:-1:1]
		r=[0 0 4 4]*(i);
    	r2=CenterRect(r,windowRect);
    	Screen(w,'FillRect',grey,windowRect);
    	Screen(w,'FillOval',green,r2);
        Screen(w, 'Flip');
    end

  
  
end 
      
  
  