function mark_event(eventname,plx,channel)
global data

%Plexon channels:
%1: trial start
%2: responded
%3: inflating
%4: banked
%5: popped
%6: outcome shown
%7: max rt exceeded
%8: trial over

%10: response shown

if ~exist('plx','var')
    plx=0;
end

if plx
    try
        PL_SendUserEvent(plx,channel);
    end
end

eventtime=GetSecs-data(end).trial_start_time;

if isfield(data(end),'ev')
    data(end).ev{end+1}=eventname;
    data(end).evt(end+1)=eventtime*1000;
else
    data(end).ev{1}=eventname;
    data(end).evt(1)=eventtime*1000;
end
end