%close_trial.m
%end of trial bookkeeping; save data

curtime=GetSecs;

%for now, no iti, since outcome period pauses action
%if we use an iti, blank screen
%         mark_event('iti_begin',plx,XXX);
%
%         while (GetSecs-curtime < (iti+rand*iti_jitter))
%             esc_check();
%         end;
mark_event('trial_over',plx,8)

%record data
data(trialnum).this_balloon=this_balloon;
data(trialnum).trial_type=trial_type;
data(trialnum).is_control=is_control;
data(trialnum).ctrltime=state.ctrltime;
data(trialnum).points=pts_inc+acc_pts;
data(trialnum).inflate_time=acc_inflate_time;
data(trialnum).this_run=this_run;
data(trialnum).result = result;
data(trialnum).rt=rt;
data(trialnum).score=score;

save(fname,'data','pars');