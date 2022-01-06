function BLtask_practice
%% PTB experiment template: Image sequence
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Set up the experiment
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Screen('Preference', 'SkipSyncTests', 1);

% color: choose a number from 0 (black) to 255 (white)
backgroundColor = 255;
textColor = 0;
textSize=50;
% time of stimuli and ITI
ITIfixationDuration = 3 + 2*rand(38,1); % Lengths of fixation in seconds before every trial, with jitter
while mean(ITIfixationDuration)>4.2 || mean(ITIfixationDuration)<3.8
    ITIfixationDuration = 3 + 2*rand(38,1); % limit the total ITI time between 144.4 ~ 159.6 secs
end
objectTimeout = 4;

%from RETsetup_visual
tbl=readtable('fullStimList_practice.csv');
stimtbl=table;
stimtbl.pairID=tbl.pairID;
stimtbl.subset=tbl.subset;
stimtbl.Object=tbl.Object;
stimtbl.ObjectFile=tbl.ObjectFile;
 
%return% for testing the first cell
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Set up stimuli lists and results file
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Get the image files for the experiment
imageFolderO = 'updatedObjectsResampled_practice';
imgListO = stimtbl.ObjectFile;
%imgListS=imgListS(randperm(length(imgListS))); % randomize presentation
pdata.nTrials = size(stimtbl,1);

% Randomize the trial list
%randomizedTrials = randperm(nTrials);

%% experiment setups
% Keyboard setup
KbName('UnifyKeyNames');
%rand('state', sum(100*clock)); % Initialize the random number generator
ButOne=KbName('1!');
ButTwo=KbName('2@');
ButThr=KbName('3#');
ButFour=KbName('4$');
ButEsc = KbName('ESCAPE');
KbCheckList = [KbName('space'),ButOne,ButTwo,ButThr,ButFour,ButEsc];
RestrictKeysForKbCheck(KbCheckList);
% Screen setup
clear screen
%Screen('Preference', 'SkipSyncTests', 1);% !! REMOVE THIS LINE WHEN SCRIPT IS FINALIZED
whichScreen = max(Screen('Screens'));
[window1, rect] = Screen('Openwindow',whichScreen,backgroundColor,[0,0,800,600]);
%PsychImaging('AddTask', 'General', 'UseRetinaResolution');

slack = Screen('GetFlipInterval', window1)/2;% minor adjustment
W=rect(RectRight); % screen width
H=rect(RectBottom); % screen height
Screen(window1,'FillRect',backgroundColor);

Screen('TextSize',window1,textSize) % set text size
Screen('Flip', window1);
disp('experiment setups done')
% Screen priority
Priority(MaxPriority(window1));
Priority(2);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Run experiment
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Start screen
%Screen('DrawText',window1,'Press the space bar to begin', (W/2-300), (H/2), textColor);
%maybe load the instruction image?
imgI = imread(fullfile('instructionPics','BLinstruction.jpg'));
imageDisplayInstruction = Screen('MakeTexture', window1, imgI);
imageSizeI = size(imgI);
posI = [(W-imageSizeI(2))/2 (H-imageSizeI(1))/2 (W+imageSizeI(2))/2 (H+imageSizeI(1))/2];
Screen('DrawTexture', window1, imageDisplayInstruction, [], posI);

DrawFormattedText(window1, 'Press any key when you are ready','center', textSize+posI(4), textColor)
Screen('Flip',window1)
disp('start task screen')
% Wait for subject to press spacebar
% while 1
%    [~,~,keyCode] = KbCheck;
%    if keyCode(ButOne) || keyCode(ButTwo) || keyCode(ButThr) || keyCode(ButFour)
%        break
%    end
% end
% Screen('DrawTexture', window1, imageDisplayInstruction, [], posI);
% DrawFormattedText(window1, 'Waiting for MR technologist to start','center', textSize+posI(4), textColor)
% Screen('Flip',window1)
% % Wait for tech to start scanning
% while 1
%    [~,~,keyCode] = KbCheck;
%    if keyCode(KbName('space')) 
%        break
%    end
%    if keyCode(ButEsc)
%        sca;
%        return
%    end
% end
% Blank screen
Screen(window1, 'FillRect', backgroundColor);
Screen('Flip', window1);

countdownScreen(window1); % wait 8 secs for magnetization to normalize 20210927

tStart=GetSecs; % when working within SPM, be aware that there's 8-sec difference
                % between the start of fMRI and the start of task

% Run experimental trials
for t = 1:pdata.nTrials    % loop through trials (38 trials per run)    
    
    fileO = imgListO{t};
    imgO = imread(fullfile(imageFolderO,fileO));
    imageDisplayObject = Screen('MakeTexture', window1, imgO);
    
    % Calculate image position (center of the screen)
    imageSizeO = size(imgO);
    imageSizeO = imageSizeO*2;
    posO = [(W-imageSizeO(2))/2 (H-imageSizeO(1))/2 (W+imageSizeO(2))/2 (H+imageSizeO(1))/2];
    
    % Show fixation cross
    drawCross(window1,W,H);
    Screen('Flip', window1);
    WaitSecs(ITIfixationDuration(t)-slack);
    % Blank screen
    Screen(window1, 'FillRect', backgroundColor);
    Screen('Flip', window1);
    
    %find object image onset time
    tObjectOnset=GetSecs-tStart;
    % Show the object images
    Screen(window1, 'FillRect', backgroundColor);
    Screen('DrawTexture', window1, imageDisplayObject, [], posO);
    DrawFormattedText(window1, stimtbl.Object{t},'center', textSize+posO(4), textColor);%
    startTime = Screen('Flip', window1); % Start of trial    
    % Get keypress response
    rt = NaN;
    resp = NaN;
    while GetSecs - startTime < objectTimeout
        [~,secs, keyCode] = KbCheck;
        if keyCode(ButEsc)
            ShowCursor;
            sca;
            return
        elseif keyCode(ButOne)
            resp = 1;
            rt = secs - startTime;
        elseif keyCode(ButTwo)
            resp = 2;
            rt = secs - startTime;
        elseif keyCode(ButThr)
            resp = 3;
            rt = secs - startTime;
        elseif keyCode(ButFour)
            resp = 4;
            rt = secs - startTime;
        end
    end %end while
    
    % Blank screen
    Screen(window1, 'FillRect', backgroundColor);
    Screen('Flip', window1);
    
    pdata.trial_no{t}=t;
    pdata.object{t}=stimtbl.Object{t};
    pdata.stimID{t}=stimtbl.pairID(t)+100*stimtbl.subset(t);% a unique 3-digit ID for the stimuli pair
    
    pdata.resp{t}=resp;
    pdata.rt{t}=rt;
    pdata.tObjOnset{t}=tObjectOnset;% this is the onset of object image
    
    % Clear textures
    Screen(imageDisplayObject,'Close');
    
end
WaitSecs(3); % at the end of the trials add some time of just blank screen
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% End the experiment (don't change anything in this section)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
RestrictKeysForKbCheck([]);
Screen(window1,'Close');
close all
sca;

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Subfunctions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Draw a fixation cross (overlapping horizontal and vertical bar)
function drawCross(window,W,H)
barLength = 30; % in pixels
barWidth = 5; % in pixels
barColor = 0.3; % number from 0 (black) to 1 (white)
Screen('FillRect', window, barColor,[ (W-barLength)/2 (H-barWidth)/2 (W+barLength)/2 (H+barWidth)/2]);
Screen('FillRect', window, barColor ,[ (W-barWidth)/2 (H-barLength)/2 (W+barWidth)/2 (H+barLength)/2]);
end