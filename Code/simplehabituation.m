 function simplehabituation
% standard experimenter controlled habituation script
% used to test if babies are fast or slow habituators
% Makes use of PsychToolBox
%
% Caspar Addyman, Centre for Brain and Cognitive Development
% infantologist@gmail.com
% =========================================================================
% Version 1 - same checkerboard stimulus shown each trial.


%initially just try to display one pict (house1111.gif) on screen 
%and control it with keyboard
KbName('UnifyKeyNames');
space = KbName('space');
esc = KbName('escape');
key_n = KbName('n');
key_x = KbName('x');

%This sets the current directory 
basedir = strcat('/Users/caspar/Dropbox/matlab/Infant-Habituation-in-Matlab/');
codedir = strcat(basedir, 'Code/'); %subdirectory where code (this file) is found
datadir = strcat(basedir, 'Data/'); %subdirectory where data is stored


minHabitTrials = 6;         % minumum number of trials the infant must see. 
maxHabitTrials = 12;        % max number of familiarization pics infant can see
maxTotalLookAway = 2;       % stop trial when looked away total of 2 sec
maxSingleLookAway = 0.5;    % stop trial if single look away of .5 sec
maxHabitTrialLength = 20;   % maximum length of habit trials
maxTestTrialLength = 20;    % maximum length of test trials
habitCriterion = 0.5;       % 50% decrease in looking
habitWindowSize = 2;        % 2 or 3 item window

subj=input('What is the Participant ID? ','s');
subjinfofile = fullfile(datadir, strcat('habit_', subj, '.txt'));
subjdatafile = fullfile(datadir, strcat('habit_', subj, '.csv'));
S = 1;
S = str2double(subj);

picture  = input('What image will you use checkerboard (1 -default) or target (2)? ', 's');
whichpic = str2double(picture);
if ~isnumeric(whichpic)
    whichpic = 1;
end

novelimage = input('Include novel image? [n] or y? ' , 's');
if strcmpi(novelimage,'y')
    includeNovel = true;
else
    includeNovel = false;
end

itemspath = strcat(codedir, 'images/');  % path to house images
if whichpic == 1
    habitimagefile = 'checkerboard.jpg';
    novelimagefile = 'target.jpg';
    novelimagefile = 'rabbit.jpg';
else
    habitimagefile = 'target.jpg';
    novelimagefile = 'checkerboard.jpg';
    novelimagefile = 'rabbit.jpg';
end
habitimagestr = strcat(itemspath, habitimagefile);

novelimagestr = strcat(itemspath, novelimagefile);
% rand('state', J);

%Specifies serial port for %titler
% port=2;
%Initialises %titler 
%titler(port,'open');
%titler(port,'clearscreen');
%titler(port,'timeoff');
%titler(port,'datepos',0,0);

cond=strcat('subj=',subj);
%titler(port,'msg',1,12,cond);
%sets experiment info
cond=strcat('CBCD Simple Habituation');
%titler(port,'msg',2,1,cond);


%create the data file 
fid = fopen(subjinfofile ,'w+');
fprintf(fid,'Simple Habituation Subject Data File\n');
fprintf(fid, datestr(now));
fprintf(fid,'\nParticipant %d\n',S);
% fprintf(fid,'Random Seed %d\n',J);

disp('***********************************************');
disp('* Start Quicktime. Choose File, New Recording *');
disp('* But do not press the record button          *');
disp('* Start Screenflow. Start recording           *');
disp('***********************************************');


% try 
    nr=max(Screen('Screens'));
  % nr=1;
    [window, screenRect]=Screen('OpenWindow',nr, 0,[],32,2); % open screen

    fprintf('\nHELLO.. AND OFF WE GO... \n');
    disp('Press n to initialise each trial');
    disp('Press a to show an attention getter');
    disp('Press x to redo previous trial');
    disp('Press and hold space when baby is watching');

    blankstr = strcat(itemspath, 'blank800600.jpg');
    blankpic = imread(blankstr, 'JPG');
    blankscr=Screen('MakeTexture', window,blankpic);    
    Screen('DrawTexture', window, blankscr);
    Screen(window,'Flip');
    
    centreRect = [220 320 380 480];
    
    fprintf(fid,'simple habituation\n');
    habitpic = imread(habitimagestr, 'jpg');
    
    stimulus(1)=Screen('MakeTexture', window,blankpic);
    stimulus=Screen('MakeTexture', window,habitpic);

    novelpic = imread(novelimagestr, 'JPG');
%     novelstimulus(1)=Screen('MakeTexture', window,blankpic);
    novelstimulus=Screen('MakeTexture', window,novelpic);
   
  
    
%%%% HABITUATION LOOP %%%%
    AllData = [];
    i=0;
    while 1  
       i=i+1; 
       fprintf('\nTRIAL -- %i',i);
       fprintf(fid,'TRIAL -- %i\n',i);
       msg=strcat('H-', num2str(i), ' Checkerboard');
       %titler(port, 'clearline',3);
       %titler(port,'msg',3,1,msg);	
       fprintf(fid,'%s\n',msg);
       
       Screen('DrawTexture', window, blankscr);
       Screen(window,'Flip');
        [Success, TrialLength(i), AllData(i,:)] = singletrial(window, stimulus,maxHabitTrialLength,maxSingleLookAway,maxTotalLookAway);
        if Success == 0
            i = i -1; %redo this one
        elseif Success == -1
            i=i-2;  %redo the one before 
        else
            fprintf(fid,'%5.3f\t,%d\t,%5.3f\t,%5.3f\n', AllData(i,:));
            if habitWindowSize == 2
                if i ==2  %find baseline
                   InitialLookingTime = TrialLength(1)+TrialLength(2);
                elseif i >= 6 % check for habituation
                    lastThreeTrials = TrialLength(i-1)+TrialLength(i)
                    if lastThreeTrials < habitCriterion * InitialLookingTime 
                        Habituated = true;
                        break;
                    end
                end
            else
                if i ==3  %find baseline
                   InitialLookingTime = TrialLength(1)+TrialLength(2)+TrialLength(3);
                elseif i >= 6 % check for habituation
                    lastThreeTrials = TrialLength(i-2)+TrialLength(i-1)+TrialLength(i)
                    if lastThreeTrials < habitCriterion * InitialLookingTime 
                        Habituated = true;
                        break;
                    end
                end
            end
        end
        if i == maxHabitTrials
            break;
        end
   end
   
   totalhabittrials = i;

    blankstr = strcat(itemspath, 'blank800600.jpg');
    temppic = imread(blankstr, 'JPG');
    blankscr=Screen('MakeTexture', window,temppic);    
    Screen('DrawTexture', window, blankscr);
    Screen(window,'Flip');


  if includeNovel 
      %show the bunny rabbit at the end
      temppic = imread(novelimagestr);
      novelimage =Screen('MakeTexture', window,temppic);

      fprintf('\nTEST TRIAL -- NOVEL');
      msg=strcat('T-NOVEL', ' Im-Rabbit');
      %titler(port, 'clearline',3);
      %titler(port,'msg',3,1,msg);	
      fprintf(fid,'%s\n',msg);

      Success = -1;
      while Success ~= 1
           [Success, TestLength(3), AllData(totalhabittrials+5,:)] = singletrial(window,novelimage ,maxTestTrialLength,maxSingleLookAway,maxTotalLookAway);
           Screen('DrawTexture', window, blankscr);
           Screen(window,'Flip');
      end
      fprintf(fid,'%5.3f\t,%d\t,%5.3f\t,%5.3f\n', AllData(totalhabittrials+5,:));
   end
  
  
  csvwrite(subjdatafile, AllData);
  status = fclose(fid);
  
  Screen('DrawText', window, 'Finished! Press Esc to exit', 50, 100, 255);
  Screen(window,'Flip');

  
    while 1  % wait for the keypress to start trial 
        % Sleep few milliseconds after each check, so we don't
        % overload the system in Rush or Priority > 0
        WaitSecs(0.005);
        %press & hold space bar to start
        [keyIsDown,timeSecs,keyCode] = KbCheck;
        if keyIsDown
            if keyCode(esc)
                break;
            end
        end
    end  

  
Screen('CloseAll');

disp('***********************************************');
disp('* Remember to save the Screenflow recording!  *');
disp('***********************************************');



