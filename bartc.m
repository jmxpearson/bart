function bartc(varargin)
%runs the BART task
%varargin can contain the following string-argument pairs
%outfile is a character string forming the stub of the output file
%infile is a file containing the parameters of the task and trial sequence
%(to control for randomness across runs)

%jmp created 5-18-11
%revised to break out scripts 7-16-11

%parse inputs
if mod(nargin,2)~=0
    warning('Number of arguments must be even.')
end

for ind=1:2:nargin
    varstr=varargin{ind};
    varval=varargin{ind+1};

    if ~ischar(varstr)
        warning('First input in pair must be a string.')
    end

    switch varstr
        case 'outfile'
            filename=varval;
        case 'infile'  %for specifying sequence of balloons; NOT CURRENTLY USED
            infile=varval;
    end
end

%if not all variables are supplied use some defaults
try
    if ~exist('filename','var')
        filename='test';
    end
    if ~exist('infile','var')
        infile='bart_seq'; %for specifying sequence of balloons; NOT CURRENTLY USED
    end

%add current directory to path
addpath(pwd) %make sure to grab local copies of scripts
addpath('/matlab/bartc/')
    
%setup joystick
setup_joystick

%setup plexon
if ispc
    setup_plexon
else
    plx=0;
end
    
%PTB settings (it tends to complain on PCs)
warning('off','MATLAB:dispatcher:InexactMatch');
Screen('Preference', 'SkipSyncTests',2); %disables all testing -- use only if ms timing is not at all an issue
Screen('Preference','VisualDebugLevel', 0);
Screen('Preference', 'SuppressAllWarnings', 1);
Screen('CloseAll')
HideCursor; % turn off mouse cursor
% InitializeMatlabOpenGL([],[],1);
ListenChar(2); %keeps keyboard input from going to Matlab window

%which screen do we display to?
which_screen=0;

%set random number seed
if exist('seed','var')
    RandStream.setGlobalStream(RandStream('mt19937ar','seed',seed));
else
    seed=sum(100*clock);
    RandStream.setGlobalStream(RandStream('mt19937ar','seed',seed));
end

%setup pars
setup_pars

%open window
[window, screenRect] = Screen('OpenWindow',which_screen,[0 0 0],[],32);

%setup geometry
setup_geometry

%bind keys
bind_keys

setup_data_file

%initialize data structure for recording
global data;
data=[];

%set font parameters
Screen(window,'TextFont','Helvetica');
Screen(window,'TextSize',72);

WaitSecs(1); %for some reason, PTB screws up Screen redraw the first time we use pause, so do it here
trialnum=0;

%main task loop
while continue_running
    
    %set up this balloon
    open_trial
    
    if trialnumdp>numtrials
        Screen('FillRect',window)
        DrawFormattedText(window,'Thank you.','center','center',[255 255 255]); %point value in balloon
        Screen('Flip',window);
        WaitSecs(2);
        break
    end
    
    this_balloon=this_balloon+1; %which balloon are we on?
    this_run=1; %which decision in current balloon
    trial_type=cue_seq(trialnumdp); %pull trial type from cue sequence %randi(numel(runlen)); %random balloon type
    is_control=ctrl_seq(trialnumdp);
    state.pts=min_pts;
    state.ctrltime=maxtimes(trial_type)*0.5+0.3*(maxtimes(trial_type)*0.5)*randn;
    ctrlsize=state.ctrltime*pixps;
    state.ctrlrect=origin2+baserect+ctrlsize*[-1 -1 1 1]; %size of control ring
    rad=minrad;
    state.color=cue_color(trial_type,:);
    state.rect=origin2+baserect;
    state.bkgnd=[0 0 0];
    state.hsize=0;
    state.progfrac=min(1,(trialnumdp-1)/max_progbar_trials); %fraction of necessary trials completed
    is_inflating=0;
    acc_inflate_time=0;
    acc_pts=0;
    
    keep_waiting=1;
    state.choice='';
    state.pushed=888; %i.e., nothing of importance
    trial_start_time=GetSecs;
    data(trialnum).trial_start_time=trial_start_time;
    mark_event('trial_start',plx,1);
    
    %paint screen
    if ~is_control&&(trial_type~=4)
        paint_screen(window,state,1)
    elseif trial_type==4
        paint_screen(window,state,6)
    else
        paint_screen(window,state,5)
    end
    
    %trap keyboard input
    while keep_waiting
        
        switch input_mode 
            case 1 %continuous trigger hold
                handle_input %go figure out whether something interesting happened, inflate balloon
            case 2 %start/stop trigger action
                handle_input2
        end
               
        run_outcome
        
        %did subject make a response in time?
        if (GetSecs-trial_start_time)>max_rt
            keep_waiting=0;
            line=sprintf('SUBJECT FAILED TO CHOOSE TARGET WITHIN %d SECONDS',max_rt);
            disp(line);
            result = 'no response';
            mark_event('max rt exceeded',plx,7)
            Screen(window, 'FillRect', [128 0 0], err_rect);
            Screen(window,'flip');
            WaitSecs(1);
        end
        
        esc_check %did we try to exit?
        
    end %of keep_waiting response loop
    
    
    %save trial data and print result here
    if ~(strcmp(result,'no response')||strcmp(result,'aborted'))
        out_line=sprintf('Trial %d: Balloon: %d  Level: %d Time: %2.2g Points: %d Result: %s',...
            trialnumdp,this_balloon,trial_type,acc_inflate_time,min_pts+acc_pts,result);
    else
        out_line=sprintf('Trial %d: %s',trialnumdp,result);
    end
    disp(out_line)
    
    close_trial %save variables, increment trial number
    
    esc_check %did we try to exit?
    
    
end %of main task loop

Screen('CloseAll') %close screen
if plx
    PL_Close(plx); %close plexon
end
cd(start_path) %return to start directory
ListenChar(0); %give keyboard input back to Matlab

catch q
    Screen('CloseAll') %close screen
    if plx
        PL_Close(plx); %close plexon
    end
    if exist('start_path','var')
        cd(start_path) %return to start directory
    end
    ListenChar(0) %keyboard input goes back to matlab window
    keyboard %pause for user input
end 

end