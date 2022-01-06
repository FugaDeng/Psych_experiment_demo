function countdownScreen(window)%20210927
tmpstr=repmat('-',1,7);
for i=1:7
    DrawFormattedText(window, tmpstr( 1:(8-i) ),'center', 'center', 0);
    Screen('Flip',window);
    WaitSecs(0.8);
end
Screen(window, 'FillRect', 255);
Screen('Flip', window);
end

