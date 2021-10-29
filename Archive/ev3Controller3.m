function ev3Controller3
% ev3Controller3 runs an ev3 over bluetooth. ev3Controller2 has a more
% central user interface than ev3Controller and ev3Controller3
% ev3Controller3 counts when c is pressed
% ev3Controller3 is has a sonic sensor proximity stop
% ev3Controller3 does not scale with screen size

[audio0,Fs0] = audioread('imperialMarch.mp3');
[audio1,Fs1] = audioread('one.mp3');
[audio2,Fs2] = audioread('two.mp3');
[audio3,Fs3] = audioread('three.mp3');
[audio4,Fs4] = audioread('four.mp3');
[audio5,Fs5] = audioread('five.mp3');
[audio6,Fs6] = audioread('six.mp3');
[audio7,Fs7] = audioread('seven.mp3');
[audio8,Fs8] = audioread('eight.mp3');
[audio9,Fs9] = audioread('nine.mp3');
[audio10,Fs10] = audioread('ten.mp3');

%set defaults
motorspeed = 50;
runtimer = 5;
counter = 0;
enablecounting = 0;
proximity = 0;

% %prompt user for the brickID
prompt = {'Please enter the EV3 Brick ID'};
title_text = 'Brick ID';
num_lines = 1;
brickID = inputdlg(prompt,title_text,[1 50]); %get brickID
brickID = brickID{:}; %make it a str from the array to connect later

%explain the controls
uiwait(msgbox({'Instructions for Driving with Arrow Keys',...
    'Up: Forward', 'Right: Right Turn','Left: Left Turn',...
    'Down: Reverse', 'Space: Close Gripper',...
    'Enter: Open Gripper','Q: Quit'},'Instructions'));

%load in the button image
[x1,map1] = imread('forwardButton.jpg');
im1 = imresize(x1, [175 175]);
[x2,map2] = imread('rightButton.jpg');
im2 = imresize(x2, [175 175]);
[x3,map3] = imread('leftButton.jpg');
im3 = imresize(x3, [175 175]);
[x4,map4] = imread('reverseButton.jpg');
im4 = imresize(x4, [175 175]);
[x5,map5] = imread('openGripper.jpg');
im5 = imresize(x5, [175 175]);
[x6,map6] = imread('closeGripper.jpg');
im6 = imresize(x6, [175 175]);
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
    'Color',[0.7 0.7 0.7],'KeyPressFcn',@keypress_Callback,'CloseRequestFcn',...
    @closefunction,'MenuBar','none');
%% CONSTRUCTION OF THE FIGURE ELEMENTS
% Construct the components for movement
hforward = uicontrol('Style','pushbutton',...
    'Position',[418,530,250,180],'cdata',im1,...
    'Callback',@forward_Callback,'BackgroundColor',...
    [0.145 0.694 0.301]);
hleft = uicontrol('Style','pushbutton',...
    'Position',[280,320,250,180],'cdata',im3,...
    'Callback',@left_Callback,'BackgroundColor',...
    [0.604 0.851 0.918]);
hright = uicontrol('Style','pushbutton',...
    'Position',[555,320,250,180],'cdata',im2,...
    'Callback',@right_Callback,'BackgroundColor',...
    [0.996 0.949 0]);
hreverse = uicontrol('Style','pushbutton',...
    'Position',[418,105,250,180],'cdata',im4,...
    'Callback',@reverse_Callback,'BackgroundColor',...
    [0.929 0.106 0.141]);
%Construct the components for openeing and closing the grippers
hopen = uicontrol('Style','pushbutton',...
    'Position',[157,530,250,180],'cdata',im5,...
    'Callback',@open_Callback,'BackgroundColor',...
    [1 1 1]);
hclose = uicontrol('Style','pushbutton',...
    'Position',[677,530,250,180],'cdata',im6,...
    'Callback',@close_Callback,'BackgroundColor',...
    [1 1 1]);
% Contrsuct the components for motor speed and run time
hmotorspeed = uicontrol('Style','slider','Min',0,'Max',100,...
    'Value',50,'SliderStep',[0.05 0.1],...
    'Position',[135,110,260,65],...
    'Callback',@motorspeed_Callback,...
    'BackgroundColor',[0.7 0 1]);
hmotortext = uicontrol('Style','text',...
    'Position',[165,180,200,35],'String','Motor Speed',...
    'FontSize',20,'BackgroundColor',[0.7 0.7 0.7]);
hmotorslow = uicontrol('Style','pushbutton',...
    'Position',[135,180,50,50],'cdata',im8,...
    'BackgroundColor',[0.996 0.949 0]);
hmotorfast = uicontrol('Style','pushbutton',...
    'Position',[345,180,50,50],'cdata',im9,...
    'BackgroundColor',[0.145 0.694 0.301]);
hmotorvalue = uicontrol('Style','text',...
    'Position',[180,230,100,35],'String','Speed:50',...
    'FontSize',15,'BackgroundColor',[0.7 0.7 0.7]);
hruntimer = uicontrol('Style','slider','Min',0,'Max',...
    10,'Value',5,'SliderStep',[0.01 0.1],...
    'Position',[690,110,260,65],...
    'Callback',@runtimer_Callback,...
    'BackgroundColor',[0.7 0 1]);
hruntimertext = uicontrol('Style','text','Position',...
    [720,180,200,35],'String','Run Time','FontSize',20,...
    'BackgroundColor',[0.7 0.7 0.7]);
htimerslow = uicontrol('Style','pushbutton',...
    'Position',[690,180,50,50],'cdata',im8,...
    'BackgroundColor',[0.996 0.949 0]);
htimerfast = uicontrol('Style','pushbutton',...
    'Position',[900,180,50,50],'cdata',im9,...
    'BackgroundColor',[0.145 0.694 0.301]);
htimervalue = uicontrol('Style','text',...
    'Position',[735,230,100,35],'String','Timer:5',...
    'FontSize',15,'BackgroundColor',[0.7 0.7 0.7]);
hquittext = uicontrol('Style','text','Position',...
    [130,265,200,35],'String','Press Q to Quit','FontSize',20,...
    'BackgroundColor',[0.7 0.7 0.7]);
%Construct the Imperial March
hvader = uicontrol('Style','pushbutton','Position',...
    [150,320,110,160],'cdata',im7,...
    'Callback',@music_Callback,'BackgroundColor',...
    [0 0 0]);
% Initialize the UI.
% Assign the a name to appear in the window title.
hfig.Name = 'EV3 Controller';
% Move the window to the center of the screen.
movegui(hfig,'center')
set(hfig,'units','normalized','outerposition',[0 0 1 1])

% Make the window visible.
hfig.Visible = 'on';
hfig.Resize = 'off';
%% CONNECT TO EV3
%initialize the ev3
myev3 = legoev3('bt',brickID);

rightmotor = motor(myev3,'A');
leftmotor = motor(myev3,'B');
grippermotor = motor(myev3,'C');
resetRotation(grippermotor);

mysonicsensor = sonicSensor(myev3,1);

%tell the user the connection works
uiwait(msgbox({'Connection Successful'},'Connection Successful'));
%% CALLBACK FUNCTIONS FOR THE APP
%Push button callbacks. Each callback moves the car for the run time
    function forward_Callback(source,callbackdata)
        if enablecounting == 0
            rightmotor.Speed = motorspeed;
            leftmotor.Speed = motorspeed;
            start(leftmotor);
            start(rightmotor);
            proximity_stop();
            stop(leftmotor);
            stop(rightmotor);
        else
            counting_function();
        end
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
        stop(leftmotor);
        stop(rightmotor);
    end
    function open_Callback(source,callbackdata)
        grippermotor.Speed = 40;
        r1 = readRotation(grippermotor);
        while r1 < 800;
            start(grippermotor);
            r1 = readRotation(grippermotor);
        end
        stop(grippermotor);
    end
    function close_Callback(source,callbackdata)
        grippermotor.Speed = -40;
        r1 = readRotation(grippermotor);
        while r1 > 1
            start(grippermotor);
            r1 = readRotation(grippermotor);
        end
        stop(grippermotor);
    end
    function music_Callback(source,callbackdata)
        clear sound;
        sound(audio0,Fs0);
    end
%this callback controls the robot with the keyboard
    function keypress_Callback(source,callbackdata)
        switch callbackdata.Key
            case 'c' %toggles counting
                if enablecounting == 0;
                    enablecounting = 1;
                else
                    enablecounting = 0;
                end
            case 'uparrow' %forward
                forward_Callback();
            case 'rightarrow' %right
                right_Callback();
            case 'leftarrow' %left
                left_Callback();
            case 'downarrow' %reverse
                reverse_Callback();
            case 'space' %close
                close_Callback();
            case 'return' %open
                open_Callback();
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
                delete(source);
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
%disable accidentally hitting the close button (yes it is supposed to be
%empty)
    function closefunction(source,callbackdata,handles)
    end
%stops the car if a collision is imminent or time has expired
    function proximity_stop()
       timecheck = 0;
       tic;
       while(1)
           timecheck = toc;
           if timecheck >= runtimer
               break
           end
           proximity = readDistance(mysonicsensor);
           if proximity <= 0.14
               break
           end
       end
    end
%this function will count when called 
    function counting_function()
        clear sound;
        counter = counter + 1;
        rightmotor.Speed = motorspeed;
        leftmotor.Speed = motorspeed;
        start(leftmotor);
        start(rightmotor);
        proximity_stop();
        stop(leftmotor);
        stop(rightmotor);
        right_Callback();
        switch counter
            case 1
                sound(audio1,Fs1);
            case 2
                sound(audio2,Fs2);
            case 3
                sound(audio3,Fs3);
            case 4
                sound(audio4,Fs4);
            case 5
                sound(audio5,Fs5);
            case 6
                sound(audio6,Fs6);
            case 7
                sound(audio7,Fs7);
            case 8
                sound(audio8,Fs8);
            case 9
                sound(audio9,Fs9);
            case 10
                sound(audio10,Fs10);
        end
        if counter == 10
            counter = 0;
        end
        pause(2);
        left_Callback();
    end 
end