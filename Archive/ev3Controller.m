function ev3Controller
% ev3Controller runs an ev3 over bluetooth.
%%UPDATE MOTOR DIRECTIONS AND INEQUALITIES%%%%%%%%%%%%%%%%%%%%%%
[x,Fs] = audioread('imperialMarch.mp3');

%prompt user for the brickID
prompt={'Please enter the EV3 Brick ID'};
dlg_title='Brick ID';
numlines=1;
brickID=inputdlg(prompt); %get brickID
brickID = brickID{:}; %make it a str from the array to connect later

%explain the controls
uiwait(msgbox({'Instructions for Driving with Arrow Keys',...
    'Up: Forward', 'Right: Right Turn','Left: Left Turn',...
    'Down: Reverse', 'Space: Close Gripper',...
    'Enter: Open Gripper'},'Instructions'));

%load in the button image
[x1,map1] = imread('forwardButton.jpg');
im1 = imresize(x1, [200 200]);
[x2,map2] = imread('rightButton.jpg');
im2 = imresize(x2, [200 200]);
[x3,map3] = imread('leftButton.jpg');
im3 = imresize(x3, [200 200]);
[x4,map4] = imread('reverseButton.jpg');
im4 = imresize(x4, [200 200]);
[x5,map5] = imread('openGripper.jpg');
im5 = imresize(x5, [200 200]);
[x6,map6] = imread('closeGripper.jpg');
im6 = imresize(x6, [200 200]);
[x7,map7] = imread('darthVader.jpg');
im7 = imresize(x7,[140 140]);
[x8,map8] = imread('slow.jpg');
im8 = imresize(x8,[50 50]);
[x9,map9] = imread('fast.jpg');
im9 = imresize(x9,[50 50]);
motorstr = 'Speed: ';
timerstr = 'Timer: ';

%  Create and then hide the UI as it is being constructed.
hfig = figure('Visible','off','Position',[360,500,850,700],...
    'Color',[0.7 0.7 0.7],'KeyPressFcn',@keypress);
%% CONSTRUCTION OF THE FIGURE ELEMENTS
% Construct the components for movement
hforward = uicontrol('Style','pushbutton',...
    'Position',[508,480,200,200],'cdata',im1,...
    'Callback',@forward_Callback,'BackgroundColor',...
    [0.145 0.694 0.301]);
hleft = uicontrol('Style','pushbutton',...
    'Position',[390,260,200,200],'cdata',im3,...
    'Callback',@left_Callback,'BackgroundColor',...
    [0.604 0.851 0.918]);
hright = uicontrol('Style','pushbutton',...
    'Position',[625,260,200,200],'cdata',im2,...
    'Callback',@right_Callback,'BackgroundColor',...
    [0.996 0.949 0]);
hreverse = uicontrol('Style','pushbutton',...
    'Position',[508,40,200,200],'cdata',im4,...
    'Callback',@reverse_Callback,'BackgroundColor',...
    [0.929 0.106 0.141]);
%Construct the components for openeing and closing the grippers
hopen = uicontrol('Style','pushbutton',...
    'Position',[142,480,200,200],'cdata',im5,...
    'Callback',@open_Callback,'BackgroundColor',...
    [0.125 0.576 0.463]);
hclose = uicontrol('Style','pushbutton',...
    'Position',[142,180,200,200],'cdata',im6,...
    'Callback',@close_Callback,'BackgroundColor',...
    [0.216 0.498 0.301]);
% Contrsuct the components for motor speed and run time
hmotorspeed = uicontrol('Style','slider','Min',0,'Max',100,...
    'Value',50,'SliderStep',[0.05 0.1],...
    'Position',[45,45,200,65],...
    'Callback',@motorspeed_Callback,...
    'BackgroundColor',[1 0 0]);
hmotortext = uicontrol('Style','text',...
    'Position',[45,115,200,35],'String','Motor Speed',...
    'FontSize',20,'BackgroundColor',[0.7 0.7 0.7]);
hmotorslow = uicontrol('Style','pushbutton',...
    'Position',[45,115,50,50],'cdata',im8,...
    'BackgroundColor',[0.996 0.949 0]);
hmotorfast = uicontrol('Style','pushbutton',...
    'Position',[195,115,50,50],'cdata',im9,...
    'BackgroundColor',[0.145 0.694 0.301]);
hmotorvalue = uicontrol('Style','text',...
    'Position',[25,180,100,35],'String','Speed:50',...
    'FontSize',15,'BackgroundColor',[0.7 0.7 0.7]);
hruntimer = uicontrol('Style','slider','Min',0,'Max',...
    10,'Value',5,'SliderStep',[0.01 0.1],...
    'Position',[290,45,200,65],...
    'Callback',@runtimer_Callback,...
    'BackgroundColor',[1 0 0]);
hruntimertext = uicontrol('Style','text','Position',...
    [290,115,200,35],'String','Run Time','FontSize',20,...
    'BackgroundColor',[0.7 0.7 0.7]);
htimerslow = uicontrol('Style','pushbutton',...
    'Position',[290,115,50,50],'cdata',im8,...
    'BackgroundColor',[0.996 0.949 0]);
htimerfast = uicontrol('Style','pushbutton',...
    'Position',[440,115,50,50],'cdata',im9,...
    'BackgroundColor',[0.145 0.694 0.301]);
htimervalue = uicontrol('Style','text',...
    'Position',[25,220,100,35],'String','Timer:5',...
    'FontSize',15,'BackgroundColor',[0.7 0.7 0.7]);
hquittext = uicontrol('Style','text','Position',...
    [142,415,200,35],'String','Press Q to Quit','FontSize',20,...
    'BackgroundColor',[0.7 0.7 0.7]);
%Construct the Imperial March
hvader = uicontrol('Style','pushbutton','Position',...
    [25,360,90,140],'cdata',im7,...
    'Callback',@music_Callback,'BackgroundColor',...
    [0 0 0]);
% Initialize the UI.
% Change units to normalized so components resize automatically
hfig.Units = 'normalized';
hforward.Units = 'normalized';
hright.Units = 'normalized';
hleft.Units = 'normalized';
hreverse.Units = 'normalized';
hopen.Units = 'normalized';
hclose.Units = 'normalized';
hmotorspeed.Units = 'normalized';
hmotortext.Units = 'normalized';
hmotorslow.Units = 'normalized';
hmotorfast.Units = 'normalized';
hmotorvalue.Units = 'normalized';
hruntimer.Units = 'normalized';
hruntimertext.Units = 'normalized';
htimerslow.Units = 'normalized';
htimerfast.Units = 'normalized';
htimervalue.Units = 'normalized';
hquittext.Units = 'normalized';
hvader.Units = 'normalized';
% Assign the a name to appear in the window title.
hfig.Name = 'EV3 Controller';
% Move the window to the center of the screen.
movegui(hfig,'center')
set(hfig,'units','normalized','outerposition',[0 0 1 1])

% Make the window visible.
hfig.Visible = 'on';
%% CONNECT TO EV3
%initialize the ev3
% myev3 = legoev3('bt',brickID);
% rightmotor = motor(myev3,'A');
% leftmotor = motor(myev3,'B');
% grippermotor = motor(myev3,'C');
% resetRotation(grippermotor);

%tell the user the connection works
uiwait(msgbox({'Connection Successful'},'Connection Successful'));
%% CALLBACK FUNCTIONS FOR THE APP
%Push button callbacks. Each callback moves the car for the run time
    function forward_Callback(source,callbackdata)
        % move both motors forward
        rightmotor.Speed = motorspeed;
        leftmotor.Speed = motorspeed;
        start(rightmotor);
        start(leftmotor);
        pause(runtimer);
        stop(rightmotor);
        stop(leftmotor);
    end
    function right_Callback(source,callbackdata)
        % move right forward, left reverse
        rightmotor.Speed = -50;
        leftmotor.Speed = 50;
        start(rightmotor);
        start(leftmotor);
        pause(0.2);
        stop(rightmotor);
        stop(leftmotor);
    end
    function left_Callback(source,callbackdata)
        % move left forward, right reverse
        rightmotor.Speed = 50;
        leftmotor.Speed = -50;
        start(rightmotor);
        start(leftmotor);
        pause(0.2);
        stop(rightmotor);
        stop(leftmotor);
    end
    function reverse_Callback(source,callbackdata)
        % move both reverse
        rightmotor.Speed = -motorspeed;
        leftmotor.Speed = -motorspeed;
        start(leftmotor);
        start(rightmotor);
        pause(runtimer);
        stop(rightmotor);
        stop(leftmotor);
    end
    function open_Callback(source,callbackdata)
        grippermotor.Speed = 40;
        r1 = readRotation(grippermotor);
        while r1 > -800;
            start(grippermotor);
            r1 = readRotation(grippermotor);
        end
        stop(grippermotor);
    end
    function close_Callback(source,callbackdata)
        grippermotor.Speed = -40;
        r1 = readRotation(grippermotor);
        while r1 < 0
            start(grippermotor);
            r1 = readRotation(grippermotor);
        end
        stop(grippermotor);
    end
    function music_Callback(source,callbackdata)
        sound(x,Fs);
    end
%these functions will drive the car with arrow keys
    function keypress(source,callbackdata)
        switch callbackdata.Key
            case 'uparrow' %forward
                rightmotor.Speed = motorspeed;
                leftmotor.Speed = motorspeed;
                start(rightmotor);
                start(leftmotor);
                pause(runtimer);
                stop(rightmotor);
                stop(leftmotor);
            case 'rightarrow' %right
                rightmotor.Speed = -50;
                leftmotor.Speed = 50;
                start(rightmotor);
                start(leftmotor);
                pause(0.2);
                stop(rightmotor);
                stop(leftmotor);
            case 'leftarrow' %left
                rightmotor.Speed = 50;
                leftmotor.Speed = -50;
                start(rightmotor);
                start(leftmotor);
                pause(0.2);
                stop(rightmotor);
                stop(leftmotor);
            case 'downarrow' %reverse
                rightmotor.Speed = -motorspeed;
                leftmotor.Speed = -motorspeed;
                start(rightmotor);
                start(leftmotor);
                pause(runtimer);
                stop(rightmotor);
                stop(leftmotor);
            case 'space' %close
                grippermotor.Speed = -50;
                start(grippermotor);
                pause(0.1);
                stop(grippermotor);
            case 'return' %open
                grippermotor.Speed = 50;
                start(grippermotor);
                pause(0.1);
                stop(grippermotor);
            case 'f'
                motorspeed = motorspeed + 5;
                if motorspeed > 100
                    motorspeed = 100;
                end
                speedstr = num2str(motorspeed);
                speedstr = strcat(motorstr,speedstr);
                hmotorvalue.String = speedstr;
            case 'i'
                uiwait(msgbox({'Instructions for Driving with Arrow Keys',...
                    'Up: Forward', 'Right: Right Turn','Left: Left Turn',...
                    'Down: Reverse', 'Space: Close Gripper',...
                    'Enter: Open Gripper'},'Instructions'));
            case 'v'
                motorspeed = motorspeed - 5;
                if motorspeed < 0
                    motorspeed = 0;
                end
                speedstr = num2str(motorspeed);
                speedstr = strcat(motorstr,speedstr);
                hmotorvalue.String = speedstr;
            case 'm'
                sound(x,Fs);
            case 'q' %exit
                exit
        end
    end
%slider callback to set motor speed
    function motorspeed_Callback(source,callbackdata)
        % get the motor speed from the slider
        motorspeed = source.Value;
        motorspeed = round(motorspeed,1);
        speedstr = num2str(motorspeed);
        speedstr = strcat(motorstr,speedstr);
        hmotorvalue.String = speedstr;
    end
%slider callback to set run time in seconds
    function runtimer_Callback(source,callbackdata)
        % get the gripper speed from the slider
        runtimer = source.Value;
        runtimer = round(runtimer,1);
        runstr = num2str(runtimer);
        runstr = strcat(timerstr,runstr);
        htimervalue.String = runstr;
    end
end