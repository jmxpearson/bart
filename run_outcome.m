%run_outcome.m

%handle all the drawing, saving, etc. from input

%update screen, display result, and record data
switch result
    case 'safe'
        state.rect=origin2+rad*[-1 -1 1 1];
        if ~is_control&&(trial_type~=4)
            paint_screen(window,state,2)
        elseif trial_type==4
            paint_screen(window,state,6)
        else
            paint_screen(window,state,5)
        end
    case 'banked'
        state.rect=origin2+rad*[-1 -1 1 1];
        mark_event('banked',plx,4);
        PsychPortAudio('Stop',pahandle);
        PsychPortAudio('FillBuffer',pahandle,cashsnd');
        PsychPortAudio('Start',pahandle);
        t_now=GetSecs;
        if trial_type==4 %for no-reward trials, kill accumulated points
            state.pts=0;
        end
        while (GetSecs-t_now)<bank_dur
            %banked points float up and fade
            frac=(GetSecs-t_now)/bank_dur;
            state.vpos=min_vpos+(max_vpos-min_vpos)*frac;
            state.bank_txt_color=(1-frac)*255*[1 1 1];
            state.bank_color=frac*255*[0 1 0]+(1-frac)*state.color;
            state.score=score+state.pts;
            paint_screen(window,state,3)
        end
        state.vpos=max_vpos;
        state.bank_txt_color=[0 0 0];
        state.bank_color=[0 255 0];
        score = score+state.pts;
        state.score=score;
        paint_screen(window,state,3)
        mark_event('outcome',plx,6);
        WaitSecs(disp_outcome+rand*disp_outcome_jitter);
    case 'popped'
        state.rect=origin2+rad*[-1 -1 1 1];
        t_now=GetSecs;
        state.hsize=0;
        lostpts=state.pts;
        mark_event('popped',plx,5);
        PsychPortAudio('Stop',pahandle);
        PsychPortAudio('FillBuffer',pahandle,popsnd');
        PsychPortAudio('Start',pahandle);
        while (GetSecs-t_now)<pop_dur
            frac=(GetSecs-t_now)/pop_dur;
            state.pts=round((1-frac)*lostpts);
            state.hsize=min(frac,1); %relative size of hole
            state.bkgnd=abs(sin((GetSecs-t_now)*2*pi*flicker_freq))*[255 255 255];
            paint_screen(window,state,4)
        end
        state.hsize=1;
        state.pts=0;
        state.bkgnd=[0 0 0];
        paint_screen(window,state,4)
        mark_event('outcome',plx,6);
        WaitSecs(disp_outcome+rand*disp_outcome_jitter);
end