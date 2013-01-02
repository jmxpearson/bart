%handle_input.m
%use continuous trigger input to control inflation

%get keyboard input
[keyIsDown,secs,keyCode] = KbCheck;
pushed=find(keyCode,1);

if joy_present
    [jx,jy,jz,buttons]=WinJoystickMex(0);
    jclicked=find(buttons);
else
    jclicked=[];
end


%break 'ties' by randomly sorting keypresses and choosing first
all_in=[pushed(:) ; jclicked(:)];
all_in=all_in(randperm(numel(all_in)));
%this_key=all_in(1);
this_key=all_in;

any_inflate=any(ismember(this_key,[Lkey Rkey JTrig])); %any of these will start/continute inflation
stopnow=ismember(stopkey,this_key);

if is_inflating&&any_inflate %if already inflating, and want to keep inflating
    curr_time=GetSecs;
    acc_inflate_time=curr_time-inflate_start_time; %accumulated inflation time
    dt=curr_time-last_inflate_time;
    acc_pts=floor(acc_inflate_time*ptsps); %accumulated points
    hh=hazard(acc_inflate_time)*dt; %probability of popping in this interval
    hh=hh(trial_type); %get correct hazard rate for this balloon
    
    if ~is_control %if it's not a control trial, handle normally
        if (rand<hh)||(hh<0) %second conditional happens if t>tmax
            result='popped';
            is_inflating=0;
            keep_waiting=0;
        else
            result='safe';
            last_inflate_time=curr_time;
            state.pts=acc_pts+min_pts; %accumulated points plus starting points
            rad=minrad+state.pts*pixperpt; %new radius
        end
    else %is a control trial
        if acc_inflate_time > state.ctrltime %success! bank reward
            mark_event('stop inflating',plx,3);
            inflate_time=GetSecs-inflate_start_time;
            inflate_stop_time=GetSecs;
            result='banked';
            is_inflating=0; %stop inflating
            keep_waiting=0;
        else
            result='safe';
            last_inflate_time=curr_time;
            state.pts=acc_pts+min_pts; %accumulated points plus starting points
            rad=minrad+state.pts*pixperpt; %new radius
        end
    end
    
    
elseif ~is_inflating&&any_inflate %if not already inflating...
    mark_event('start inflating',plx,2);
    rt=GetSecs-trial_start_time;
    inflate_start_time=GetSecs;
    last_inflate_time=inflate_start_time;
    result='safe';
    is_inflating=1; %start inflating
    PsychPortAudio('FillBuffer',pahandle,inflatesnd');
    PsychPortAudio('SetLoop',pahandle);
    PsychPortAudio('Start',pahandle,1.5*max(maxtimes)); %repeat an obscene number of times, until stopped
    
elseif is_inflating&&~any_inflate %if already inflating, but no inflate input
    mark_event('stop inflating',plx,3);
    inflate_time=GetSecs-inflate_start_time;
    inflate_stop_time=GetSecs;
    result='banked';
    is_inflating=0; %stop inflating
    keep_waiting=0;
    
end

if stopnow
    if continue_running
        disp('esc pressed while waiting for selection')
    end
    result='aborted';
    keep_waiting=0;
    continue_running=0;
end

