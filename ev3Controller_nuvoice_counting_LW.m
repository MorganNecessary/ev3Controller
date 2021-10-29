function ev3Controller_nuvoice_counting_LW
% ev3Controller_nuvoice_counting runs an ev3 over bluetooth. This
% controller connects over bluetooth to a specific ev3 brick and is able to
% count on 1x10 and 2x5 grids
%1x10: ----------
%2x5: -----
%     -----

%load in audio files for counting
[audio0,Fs0] = audioread('Sounds\imdone.mp3');
[audio1,Fs1] = audioread('Sounds\one.mp3');
[audio2,Fs2] = audioread('Sounds\two.mp3');
[audio3,Fs3] = audioread('Sounds\three.mp3');
[audio4,Fs4] = audioread('Sounds\four.mp3');
[audio5,Fs5] = audioread('Sounds\five.mp3');
[audio6,Fs6] = audioread('Sounds\six.mp3');
[audio7,Fs7] = audioread('Sounds\seven.mp3');
[audio8,Fs8] = audioread('Sounds\eight.mp3');
[audio9,Fs9] = audioread('Sounds\nine.mp3');
[audio10,Fs10] = audioread('Sounds\ten.mp3');

%set defaults
motorspeed = 40;
runtimer = 350;
counter = 0;
enablecounting = 0;
grid = '1x10';

brickID = '001653527a87';

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
    [0.145 0.694 0.301],'Units','normalized');
hleft = uicontrol('Style','pushbutton',...
    'Position',[210,270,175,175],'cdata',im3,...
    'Callback',@left_Callback,'BackgroundColor',...
    [0.996 0.949 0],'Units','normalized');
hright = uicontrol('Style','pushbutton',...
    'Position',[425,270,175,175],'cdata',im2,...
    'Callback',@right_Callback,'BackgroundColor',...
    [0.604 0.851 0.918],'Units','normalized');
hreverse = uicontrol('Style','pushbutton',...
    'Position',[318,60,175,175],'cdata',im4,...
    'Callback',@reverse_Callback,'BackgroundColor',...
    [0.929 0.106 0.141],'Units','normalized');
%Construct the components for opening and closing the grippers
hopen = uicontrol('Style','pushbutton',...
    'Position',[107,480,175,175],'cdata',im5,...
    'Callback',@open_Callback,'BackgroundColor',...
    [1 1 1],'Units','normalized');
hclose = uicontrol('Style','pushbutton',...
    'Position',[527,480,175,175],'cdata',im6,...
    'Callback',@close_Callback,'BackgroundColor',...
    [1 1 1],'Units','normalized');
% Contrsuct the components for motor speed and run time
hmotorspeed = uicontrol('Style','slider','Min',0,'Max',100,...
    'Value',40,'SliderStep',[0.05 0.05],...
    'Position',[85,65,200,65],...
    'Callback',@motorspeed_Callback,...
    'BackgroundColor',[0.7 0 1],'Units','normalized');
hmotortext = uicontrol('Style','text',...
    'Position',[85,135,200,35],'String','Motor Speed',...
    'FontSize',20,'BackgroundColor',[0.7 0.7 0.7],'Units','normalized');
hmotorslow = uicontrol('Style','pushbutton',...
    'Position',[85,135,50,50],'cdata',im8,...
    'BackgroundColor',[0.996 0.949 0],'Units','normalized');
hmotorfast = uicontrol('Style','pushbutton',...
    'Position',[235,135,50,50],'cdata',im9,...
    'BackgroundColor',[0.145 0.694 0.301],'Units','normalized');
hmotorvalue = uicontrol('Style','text',...
    'Position',[100,185,100,35],'String','Speed:40',...
    'FontSize',15,'BackgroundColor',[0.7 0.7 0.7],'Units','normalized');
hruntimer = uicontrol('Style','slider','Min',0,'Max',...
    10,'Value',1,'SliderStep',[0.01 0.05],...
    'Position',[530,65,200,65],...
    'Callback',@runtimer_Callback,...
    'BackgroundColor',[0.7 0 1],'Units','normalized');
hruntimertext = uicontrol('Style','text','Position',...
    [530,135,200,35],'String','Run Time','FontSize',20,...
    'BackgroundColor',[0.7 0.7 0.7],'Units','normalized');
htimerslow = uicontrol('Style','pushbutton',...
    'Position',[530,135,50,50],'cdata',im8,...
    'BackgroundColor',[0.996 0.949 0],'Units','normalized');
htimerfast = uicontrol('Style','pushbutton',...
    'Position',[680,135,50,50],'cdata',im9,...
    'BackgroundColor',[0.145 0.694 0.301],'Units','normalized');
htimervalue = uicontrol('Style','text',...
    'Position',[565,185,100,35],'String','Timer:1',...
    'FontSize',15,'BackgroundColor',[0.7 0.7 0.7],'Units','normalized');
hgridtext = uicontrol('Style','text',...
    'Position',[565,220,180,35],'String','Grid Size: 1x10',...
    'FontSize',20,'BackgroundColor',[0.7 0.7 0.7],'Units','normalized');
hquittext = uicontrol('Style','text','Position',...
    [40,220,280,35],'String','Press X to Quit. Counting is off.',...
    'FontSize',20,'BackgroundColor',[0.7 0.7 0.7],'Units','normalized');
%Construct the Imperial March
hvader = uicontrol('Style','pushbutton','Position',...
    [100,300,90,140],'cdata',im7,...
    'Callback',@music_Callback,'BackgroundColor',...
    [0 0 0],'Units','normalized');
% Initialize the UI.
% Change units to normalized so components resize automatically
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
pointermotor = motor(myev3,'D');
resetRotation(grippermotor);
resetRotation(pointermotor);

%tell the user the connection works
uiwait(msgbox({'Connection Successful'},'Connection Successful'));
%% CALLBACK FUNCTIONS FOR THE APP
%Push button callbacks. Each callback moves the car for the run time
    function forward_Callback(source,callbackdata)
        % move both motors forward
        if enablecounting == 0
            r3 = 0;
            resetRotation(rightmotor);
            rightmotor.Speed = motorspeed;
            leftmotor.Speed = motorspeed;
            while r3 < runtimer
                start(leftmotor);
                start(rightmotor);
                r3 = readRotation(rightmotor);
            end
            stop(leftmotor,1);
            stop(rightmotor,1);
        else
            counting_function();
        end
    end
    function right_Callback(source,callbackdata)
        % move right forward, left reverse
        rightmotor.Speed = -40;
        leftmotor.Speed = 40;
        start(rightmotor);
        start(leftmotor);
        pause(0.2);
        stop(rightmotor);
        stop(leftmotor);
    end
    function left_Callback(source,callbackdata)
        % move left forward, right reverse
        rightmotor.Speed = 40;
        leftmotor.Speed = -40;
        start(rightmotor);
        start(leftmotor);
        pause(0.2);
        stop(rightmotor);
        stop(leftmotor);
    end
    function reverse_Callback(source,callbackdata)
        % move both reverse
        r4 = 0;
        resetRotation(rightmotor);
        rightmotor.Speed = -motorspeed;
        leftmotor.Speed = -motorspeed;
        while r4 > -runtimer
            start(leftmotor);
            start(rightmotor);
            r4 = readRotation(rightmotor);
        end
        stop(leftmotor,1);
        stop(rightmotor,1);
    end
    function open_Callback(source,callbackdata)
        grippermotor.Speed = 40;
        r1 = readRotation(grippermotor);
        while r1 < 800; %100
            start(grippermotor);
            r1 = readRotation(grippermotor);
        end
        stop(grippermotor);
    end
    function close_Callback(source,callbackdata)
        grippermotor.Speed = -40;
        r1 = readRotation(grippermotor);
        while r1 > 9
            start(grippermotor);
            r1 = readRotation(grippermotor);
        end
        stop(grippermotor);
    end
    function pointer_Callback(source,callbackdata)
        pointermotor.Speed = -15;
        r2 = readRotation(pointermotor);
        while r2 > -70; %100
            start(pointermotor);
            r2 = readRotation(pointermotor);
        end
        stop(pointermotor);
        pause(1);        
        pointermotor.Speed = 15;
        r2 = readRotation(pointermotor);
        while r2 < -10; %100
            start(pointermotor);
            r2 = readRotation(pointermotor);
        end
        stop(pointermotor);
    end
    function music_Callback(source,callbackdata)
        clear sound;
        sound(audio0,Fs0);
    end
    function counting_function(source,callbackdata)
        clear sound;
        counter = counter + 1;
        r3 = 0;
        resetRotation(rightmotor);
        rightmotor.Speed = motorspeed;
        leftmotor.Speed = motorspeed;
        while r3 < runtimer
            start(leftmotor);
            start(rightmotor);
            r3 = readRotation(rightmotor);
        end
        stop(leftmotor,1);
        stop(rightmotor,1);
        switch grid
            case '1x10' %the 1x10 grid size
                pointermotor.Speed = -15;
                r2 = readRotation(pointermotor);
                while r2 > -70; %100
                    start(pointermotor);
                    r2 = readRotation(pointermotor);
                end
                stop(pointermotor);
%                 switch counter
%                     case 1
%                         sound(audio1,Fs1);
%                     case 2
%                         sound(audio2,Fs2);
%                     case 3
%                         sound(audio3,Fs3);
%                     case 4
%                         sound(audio4,Fs4);
%                     case 5
%                         sound(audio5,Fs5);
%                     case 6
%                         sound(audio6,Fs6);
%                     case 7
%                         sound(audio7,Fs7);
%                     case 8
%                         sound(audio8,Fs8);
%                     case 9
%                         sound(audio9,Fs9);
%                     case 10
%                         sound(audio10,Fs10);
%                 end
%             case '2x5' %the 2x5 grid size
%                 switch counter
%                     case 1
%                         pointer_Callback();
%                         sound(audio1,Fs1);
%                     case 2
%                         pointer_Callback();
%                         sound(audio2,Fs2);
%                     case 3
%                         pointer_Callback();
%                         sound(audio3,Fs3);
%                     case 4
%                         pointer_Callback();
%                         sound(audio4,Fs4);
%                     case 5
%                         pointer_Callback();
%                         sound(audio5,Fs5);
%                     case 6
%                         pointer_Callback();
%                         sound(audio6,Fs6);
%                     case 7
%                         pointer_Callback();
%                         sound(audio7,Fs7);
%                     case 8
%                         pointer_Callback();
%                         sound(audio8,Fs8);
%                     case 9
%                         pointer_Callback();
%                         sound(audio9,Fs9);
%                     case 10
%                         pointer_Callback();
%                         sound(audio10,Fs10);
%                 end
        end
        pointermotor.Speed = 15;
        r2 = readRotation(pointermotor);
        while r2 < -10; %100
            start(pointermotor);
            r2 = readRotation(pointermotor);
        end
        stop(pointermotor);
        if counter == 10
            counter = 0;
        end    
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
            case '0' %reset counting
                counter = 0;
            case '1'
                counter = 1;
            case '2'
                counter = 2;
            case '3'
                counter = 3;
            case '4'
                counter = 4;
            case '5'
                counter = 5;
            case '6'
                counter = 6;
            case '7'
                counter = 7;
            case '8'
                counter = 8;
            case '9'
                counter = 9;
            case 'o' %open
                open_Callback();
            case 'p'
                pointer_Callback();
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
            case't' %toggle enable/disable counting
                if enablecounting == 0;
                    enablecounting = 1;
                    hquittext.String = 'Press X to Quit. Counting is on.';
                else
                    enablecounting = 0;
                    counter = 0;
                    hquittext.String = 'Press X to Quit. Counting is off.';
                end
            case'g'
                switch grid
                    case '1x10'
                        grid = '2x5'
                        counter = 0;
                        hgridtext.String = 'Grid Size: 2x5';
                    case '2x5'
                        grid = '1x10'
                        counter = 0;
                        hgridtext.String = 'Grid Size: 1x10';
                end
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
        runtimer = round(runtimer,2);
        runstr = num2str(runtimer);
        runstr = strcat(timerstr,runstr);
        htimervalue.String = runstr;
        runtimer = runtimer * 350;
    end
%disable accidentally hitting the close button (yes it is supposed to be
%empty)
    function closefunction(source,callbackdata,handles)
    end
end