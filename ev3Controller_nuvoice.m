function ev3Controller_nuvoice
% ev3Controller runs an ev3 over bluetooth. ev3controller is the simplest
% version of the controller

[audio0,Fs0] = audioread('Sounds\imperialMarch.mp3');

%set defaults
motorspeed = 40;
runtimer = 5;
counter = 0;
enablecounting = 0;

brickID = '00165340de27';

%load in the button image
[x1,map1] = imread('Images\forwardButton.jpg');
im1 = imresize(x1, [175 175]);
[x2,map2] = imread('Images\rightButton.jpg');
im2 = imresize(x2, [175 175]);
[x3,map3] = imread('Images\leftButton.jpg');
im3 = imresize(x3, [175 175]);
[x4,map4] = imread('Images\reverseButton.jpg');
im4 = imresize(x4, [175 175]);
[x5,map5] = imread('Images\openGripper.jpg');
im5 = imresize(x5, [175 175]);
[x6,map6] = imread('Images\closeGripper.jpg');
im6 = imresize(x6, [175 175]);
[x7,map7] = imread('Images\darthVader.jpg');
im7 = imresize(x7,[140 140]);
[x8,map8] = imread('Images\slow.jpg');
im8 = imresize(x8,[50 50]);
[x9,map9] = imread('Images\fast.jpg');
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
    'Position',[318,480,175,175],'cdata',im1,...
    'Callback',@forward_Callback,'BackgroundColor',...
    [0.145 0.694 0.301]);
hleft = uicontrol('Style','pushbutton',...
    'Position',[210,270,175,175],'cdata',im3,...
    'Callback',@left_Callback,'BackgroundColor',...
    [0.604 0.851 0.918]);
hright = uicontrol('Style','pushbutton',...
    'Position',[425,270,175,175],'cdata',im2,...
    'Callback',@right_Callback,'BackgroundColor',...
    [0.996 0.949 0]);
hreverse = uicontrol('Style','pushbutton',...
    'Position',[318,60,175,175],'cdata',im4,...
    'Callback',@reverse_Callback,'BackgroundColor',...
    [0.929 0.106 0.141]);
%Construct the components for openeing and closing the grippers
hopen = uicontrol('Style','pushbutton',...
    'Position',[107,480,175,175],'cdata',im5,...
    'Callback',@open_Callback,'BackgroundColor',...
    [1 1 1]);
hclose = uicontrol('Style','pushbutton',...
    'Position',[527,480,175,175],'cdata',im6,...
    'Callback',@close_Callback,'BackgroundColor',...
    [1 1 1]);
% Contrsuct the components for motor speed and run time
hmotorspeed = uicontrol('Style','slider','Min',0,'Max',100,...
    'Value',40,'SliderStep',[0.05 0.1],...
    'Position',[85,65,200,65],...
    'Callback',@motorspeed_Callback,...
    'BackgroundColor',[0.7 0 1]);
hmotortext = uicontrol('Style','text',...
    'Position',[85,135,200,35],'String','Motor Speed',...
    'FontSize',20,'BackgroundColor',[0.7 0.7 0.7]);
hmotorslow = uicontrol('Style','pushbutton',...
    'Position',[85,135,50,50],'cdata',im8,...
    'BackgroundColor',[0.996 0.949 0]);
hmotorfast = uicontrol('Style','pushbutton',...
    'Position',[235,135,50,50],'cdata',im9,...
    'BackgroundColor',[0.145 0.694 0.301]);
hmotorvalue = uicontrol('Style','text',...
    'Position',[100,185,100,35],'String','Speed:40',...
    'FontSize',15,'BackgroundColor',[0.7 0.7 0.7]);
hruntimer = uicontrol('Style','slider','Min',0,'Max',...
    10,'Value',5,'SliderStep',[0.01 0.1],...
    'Position',[530,65,200,65],...
    'Callback',@runtimer_Callback,...
    'BackgroundColor',[0.7 0 1]);
hruntimertext = uicontrol('Style','text','Position',...
    [530,135,200,35],'String','Run Time','FontSize',20,...
    'BackgroundColor',[0.7 0.7 0.7]);
htimerslow = uicontrol('Style','pushbutton',...
    'Position',[530,135,50,50],'cdata',im8,...
    'BackgroundColor',[0.996 0.949 0]);
htimerfast = uicontrol('Style','pushbutton',...
    'Position',[680,135,50,50],'cdata',im9,...
    'BackgroundColor',[0.145 0.694 0.301]);
htimervalue = uicontrol('Style','text',...
    'Position',[565,185,100,35],'String','Timer:5',...
    'FontSize',15,'BackgroundColor',[0.7 0.7 0.7]);
hquittext = uicontrol('Style','text','Position',...
    [40,220,280,35],'String','Press X to Quit. Counting is off.',...
    'FontSize',20,'BackgroundColor',[0.7 0.7 0.7]);
%Construct the Imperial March
hvader = uicontrol('Style','pushbutton','Position',...
    [100,300,90,140],'cdata',im7,...
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
hfig.Resize = 'off';
%% CONNECT TO EV3
%initialize the ev3
myev3 = legoev3('bt',brickID);
rightmotor = motor(myev3,'A');
leftmotor = motor(myev3,'B');
grippermotor = motor(myev3,'C');
resetRotation(grippermotor);

%tell the user the connection works
uiwait(msgbox({'Connection Successful'},'Connection Successful'));
%% CALLBACK FUNCTIONS FOR THE APP
%Push button callbacks. Each callback moves the car for the run time
    function forward_Callback(source,callbackdata)
        % move both motors forward
        if enablecounting == 0
            rightmotor.Speed = motorspeed;
            leftmotor.Speed = motorspeed;
            start(leftmotor);
            start(rightmotor);
            pause(runtimer);
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
        stop(rightmotor);
        stop(leftmotor);
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
        while r1 > 5
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
            case 'uparrow' %forward
                forward_Callback();
            case 'rightarrow' %right
                right_Callback();
            case 'leftarrow' %left
                left_Callback();
            case 'downarrow' %reverse
                reverse_Callback();
            case 'c' %close
                close_Callback();
            case 'o' %open
                open_Callback();
            case 'j'
                motorspeed = motorspeed + 20;
                if motorspeed > 100
                    motorspeed = 100;
                end
                speedstr = num2str(motorspeed);
                speedstr = strcat(motorstr,speedstr);
                hmotorvalue.String = speedstr;
            case 'k'
                motorspeed = motorspeed - 20;
                if motorspeed < 0
                    motorspeed = 0;
                end
                speedstr = num2str(motorspeed);
                speedstr = strcat(motorstr,speedstr);
                hmotorvalue.String = speedstr;       
            case 'l'
                runtimer = runtimer + 1;
                if runtimer > 10
                    runtimer = 10;
                end
                
                runstr = num2str(runtimer);
                runstr = strcat(timerstr,runstr);
                htimervalue.String = runstr;
            case 's'
                runtimer = runtimer - 1;
                if runtimer < 0
                    runtimer = 0;
                end
                runstr = num2str(runtimer);
                runstr = strcat(timerstr,runstr);
                htimervalue.String = runstr;          
            case 'm'
                music_Callback();
            case 'q'
                clear sound;
            case 'x'
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
%slider callback to set run time in 
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
end