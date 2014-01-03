%setup_pars.m

%pre-configure task parameters; save all relevant parameters to the pars
%structure for saving to disk

%%%%%%%%%%%%%%%%% trial parameters %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
trialnum=0;
trialnumdp=0;
numtrials=50000;
continue_running=1; %loop parameter

if exist('invars','var')
    numtrials=invars.numtrials;
end

%%%%%%%%%%%%%%%% sound parameters %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
setup_audio
[popsnd,popF]=wavread('pop.wav');
[inflatesnd,inflateF]=wavread('inflate.wav');
[cashsnd,cashF]=wavread('cash.wav');

%%%%%%%%%%%%%%%% bart parameters %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if exist('invars','var')
    hazard=invars.hazard;
    seed=invars.seed;
    minrad=invars.minrad;
end

%set up trial type breakdown
type_blk=[12 12 12 6]; %number of each trial in pseudo-block
ctrl_blk=[9 9 9 0 ; 3 3 3 6]; %pseudo-block control breakdown: bottom is controls
runlen=[12 8 4 8]; %maximum number of pumps on each balloon type; last type is no reward
blk=[]; %make pseudo-block
ctrl=[];
for ind=1:length(type_blk)
    blk = [blk ind*ones(1,type_blk(ind))];
    ctrl = [ctrl zeros(1,ctrl_blk(1,ind)) ones(1,ctrl_blk(2,ind))];
end
%now make matrix of trial types: each column is a pseudo-block
all_blk=repmat(blk(:),1,ceil(numtrials/length(blk)));
all_ctrl=repmat(ctrl(:),1,ceil(numtrials/length(blk)));
[cue_seq,idx]=Shuffle(all_blk); %randomly shuffle a whole bunch of pseudo-blocks
cue_seq=cue_seq(:); %vectorize
ctrl_seq=all_ctrl(idx); %shuffle control trials in same way
ctrl_seq=ctrl_seq(:); %vectorize

pts_inc=50; %how many pts per pump?
runpts=runlen*pts_inc; %run length in points
minrad=60; %balloon start radius
pump_inc=25; %how much does the radius grow each pump
pixps=15; %how rapidly does the balloon grow (pixels per second)
ptsps=(pts_inc/pump_inc)*pixps; %pts per pump / pixels per pump * pixels per sec = points per sec
pixperpt=pump_inc/pts_inc; %pixels per pump/pts per pump
maxtimes=runpts/ptsps;
min_pts=0; %initial value of the balloon
hazard_type=2; %what form should hazard rate take
switch hazard_type
    case 1
        hazard=@(x)(1./(maxtimes-x)); %calculates hazard rate (to be multiplied by bin dt) at a given time
    case 2
        hazard=@(x)(normpdf(x,maxtimes/2,0.3*maxtimes/2)./(1-normcdf(x,maxtimes/2,0.3*maxtimes/2))); %normally distributed pops with weber law variance
end
state.pts=0; %balloon point value
this_balloon=0;

%%%%%%%%%%%%%%%%% response parameters, points, etc. %%%%%%%%%%%%%%%
input_mode=2;
max_rt = 30000; %maximum reaction time (basically inf)
iti=1; %inter-trial interval (not currently used)
iti_jitter=0.25; %jitter for iti
disp_resp=0.5; %interval for displaying response
disp_resp_jitter=0.25;
disp_outcome=0.75; %outcome display period (post-shrink, pop, or blank)
disp_outcome_jitter=0.25;
pop_dur=0.75; %how long does the pop last?
bank_dur=1;%how long does "banking" take?
flicker_freq=2; %frequency of pop screen flicker (Hz)
score=0;
state.score=0;
rt=0;
result='first_trial';
this_run=0;
max_progbar_trials=240; %maximum trials registered by progress bar

%things that don't really change trial-to-trial
pars.hazard_type=hazard_type;
pars.input_mode=input_mode;
pars.type_blk=type_blk;
pars.ctrl_blk=ctrl_blk;
pars.runlen=runlen;
pars.runpts=runpts;
pars.pump_inc=pump_inc;
pars.pixps=pixps;
pars.ptsps=ptsps;
pars.pixperpt=pixperpt;
pars.maxtimes=maxtimes;
pars.max_rt=max_rt;
pars.iti=iti;
pars.iti_jitter=iti_jitter;
pars.disp_resp=disp_resp;
pars.disp_resp_jitter=disp_resp_jitter;
pars.disp_outcome=disp_outcome;
pars.disp_outcome_jitter=disp_outcome_jitter;
pars.pop_dur=pop_dur;
pars.bank_dur=bank_dur;
pars.pts_inc=pts_inc;
pars.flicker_freq=flicker_freq;
pars.min_pts=min_pts;
pars.seed=seed;
pars.max_progbar_trials=max_progbar_trials;