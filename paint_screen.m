function paint_screen(window,state,mode)
%draws the output for the task
%window is a ptr to the appropriate window
%state contains screen info
%mode is vector of effects to include:
%0: balloon and its value 
%1: balloon and response targets
%2: chosen response colored in
%3: banked (balloon turns green, number floats up)
%4: popped (background flashes, hole opens up)
%5: control trials (draw an extra circle on the outside)
%6: no-reward trials (control circle plus no point increase)

if ~exist('mode','var')
    mode=0;
end

bord=15*[-1 -1 1 1];

Screen('FillRect',window) %clear background (necessary because TextBounds writes to screen)

%draw total score
DrawFormattedText(window,['Total Points: ' num2str(state.score)],0,0,[255 255 255]); %total score
%draw progress bar
pbx=state.pbar([1 3]);
pbar_rect=[state.pbar(1:2) pbx(1)+state.progfrac*(diff(pbx)) state.pbar(4)];
Screen('FrameRect',window,[255 255 255],state.pbar+bord,15)
Screen('FillRect',window,[0 0 255],pbar_rect)

switch mode
    case 0
        Screen('FillOval',window,state.color,state.rect) %balloon
        DrawFormattedText(window,num2str(state.pts),'center','center',[255 255 255]); %point value in balloon
    case 1
        Screen('FillOval',window,state.color,state.rect) %balloon
        DrawFormattedText(window,num2str(state.pts),'center','center',[255 255 255]); %point value in balloon
    case 2
        Screen('FillOval',window,state.color,state.rect) %balloon
        DrawFormattedText(window,num2str(state.pts),'center','center',[255 255 255]); %point value in balloon

    case 3
        Screen('FillOval',window,state.bank_color,state.rect) %green balloon %should this gradually transition to green?
        DrawFormattedText(window,'$$$','center','center',[255 255 255]);
        DrawFormattedText(window,num2str(state.pts),'center',state.vpos,state.bank_txt_color); %point value at vertical offset

    case 4
        Screen('FillRect',window,state.bkgnd) %specified background color
        
        Screen('FillOval',window,state.color,state.rect) %balloon
        
        holestart=repmat(state.rect(1:2),1,2);
        holerel=state.rect-holestart;
        holerect=holestart+state.hsize.*holerel;
        Screen('FillOval',window,state.bkgnd,holerect) %overlay the hole for popping
        
        DrawFormattedText(window,num2str(state.pts),'center','center',[255 255 255]); %point value in balloon
        
    case 5
        Screen('FrameOval',window,[150 150 150],state.ctrlrect,5); %force trial target
        Screen('FillOval',window,state.color,state.rect) %balloon
        DrawFormattedText(window,num2str(state.pts),'center','center',[255 255 255]); %point value in balloon
        
    case 6
        Screen('FrameOval',window,[150 150 150],state.ctrlrect,5); %force trial target
        Screen('FillOval',window,state.color,state.rect) %balloon
        DrawFormattedText(window,'0','center','center',[255 255 255]); %point value in balloon

        
end

%flip
Screen(window,'flip');
end