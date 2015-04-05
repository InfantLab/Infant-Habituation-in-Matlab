function [Success, TrialLength, AllData] = SingleTrial(window,stimulus,maxTrialLength,maxSingleLookAway,maxTotalLookAway)

%SINGLE TRIAL 

Success = 0;
TrialLength = 0;
space = KbName('space');
esc = KbName('escape');
key_a = KbName('a');
key_b = KbName('b');
key_n = KbName('n');
key_x = KbName('x');

nexttrial = false; %must press 'n' before can start this trial
port=2;

y=wavread('boing.wav'); 
% try
    
    while 1  % wait for the keypress to start trial 
        % Sleep few milliseconds after each check, so we don't
        % overload the system in Rush or Priority > 0
        WaitSecs(0.005);
        %press & hold space bar to start
        [keyIsDown,timeSecs,keyCode] = KbCheck;
        if keyIsDown
            if keyCode(space) && nexttrial
                break;
            elseif keyCode(key_n)
                nexttrial = true;
            elseif keyCode(key_a)
                attnget(window);
            elseif keyCode(key_x)
                Success = -1;
                TrialLength = 0;
                AllData = [-1 -1 -1 -1];
                WaitSecs(0.15); 
                return;
            elseif keyCode(esc)
                Success = 0;
                TrialLength = 0;
                AllData = [0 0 0 0];
                return;
            end
        end
    end

    %titler(port, 'clearline',4);
    %titler(port,'msg',4,1,'start look');	

%    beep 
%    waitsecs(0.15);
    sound(y);
    
    Screen('DrawTexture', window, stimulus);
    Screen(window,'Flip');
    tStart=GetSecs;
    tEnd=tStart+maxTrialLength;

    totallookaway =0;
    thislookaway =0;
    numlookaways =0;
    lookedaway =0;
    looking =false;

    while 1
        WaitSecs(0.001);
        %press & hold space bar to start
        [keyIsDown,timeSecs,keyCode] = KbCheck;   
        if timeSecs>tEnd
           totallookaway = totallookaway + thislookaway;
           %titler(port, 'clearline',4);
           %titler(port,'msg',4,1,'reached max time');	
           break;  % end of trial
        elseif keyIsDown
            lookedaway = 0; %not looking away
            if keyCode(space)
                %still looking - all is well carry on
                if ~looking 
                    %titler(port, 'clearline',4);
                    %titler(port,'msg',4,1,'look');	
                    looking = true;
                end
            else 
                %TODO
                %maybe some other key condition
                %leads to certain behaviour
            end
        else %key is up - infant looking away
            if lookedaway > 0 %already looking away.. check cumulative scores
               thislookaway = timeSecs - lookedaway;
               if thislookaway > maxSingleLookAway 
                   %looked away for long enough to end trial
                   totallookaway = totallookaway + thislookaway;
                   %titler(port, 'clearline',4);
                   %titler(port,'msg',4,1,'long single lookaway');	
                   break;
               end
            else % new look away add last one to total
               numlookaways=numlookaways+1;
               totallookaway = totallookaway + thislookaway;
               thislookaway  = 0; % reset
               lookedaway = timeSecs;
               looking = false;
               %titler(port, 'clearline',4);
               %titler(port,'msg',4,1,'away');	
            end 
            %check cumulative total
            if totallookaway + thislookaway > maxTotalLookAway
                %titler(port, 'clearline',4);
                %titler(port,'msg',4,1,'long total lookaway');	
                break;
            end
        end
    end
    
%   Screen('close', stimulus);


%    fprintf('\nTrial length\n');
    TrialLength = timeSecs - tStart
%    fprintf('\nlast look away\n');
    thislookaway
%    fprintf('\nTotal look away\n');
    totallookaway
%    fprintf('\nTotal number look away\n');
    numlookaways
    
    AllData = [TrialLength numlookaways totallookaway thislookaway];
    Success = 1;
    
% catch
%     Success = false;
% end