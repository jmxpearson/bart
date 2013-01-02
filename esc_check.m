%esc_check.m

%check to see if we should abort program
[keyIsDown,secs,keyCode] = KbCheck;
if keyCode(stopkey)
    if continue_running
        disp('esc pressed while waiting for selection')
    end
    result='aborted';
    keep_waiting=0;
    continue_running=0;
end