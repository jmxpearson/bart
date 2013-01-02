%open_trial.m

%perform basic bookkeeping before trial starts
        

if ~strcmp(result, 'no response') %increment trial number
    trialnumdp=trialnumdp+1;
end
trialnum=trialnum+1;
result='';