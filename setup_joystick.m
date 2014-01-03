%setup_joystick.m
%uses a try...catch to test for the presence of a joystick

%get sample joystick position
%JOYSTICK MUST BE CENTERED
try
    [jx,jy,jz,buttons]=WinJoystickMex(0);
    
    %joystick x=0, y=0 is upper left corner
    jcenter=[jx jy];
    jrange=2*jcenter;
    
    %set a tolerance equal to a percentage of the half-range
    %deviation; more than this will count as a choice
    tfrac=0.75;
    jtoler=tfrac*jcenter;
    joy_present=1;
catch
    joy_present=0;
end