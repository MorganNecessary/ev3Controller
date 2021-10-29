function ev3Controller_nuvoice_counting_4
% ev3Controller_nuvoice_counting runs an ev3 over bluetooth. This
% controller connects over bluetooth to a specific ev3 brick and is able to
% count on 1x10 and 2x5 grids
%1x10: ----------
%2x5: -----
%     -----
%the robot can follow a line and the interface works with single switch scanning

%load in audio files for counting
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
runtimer = 1;
counter = 0;
enablecounting = 0;
grid = '1x10';
colortryR = 0;
rightsensor = 0;
colortryL = 0;
leftsensor = 0;
color = 'blorp';
color2 = 'blopr';
right = 0;
left = 0;
scancounter = 0;
colorbuffer = [0 0 0];

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
    [0.145 0.694 0.301],'Units','normalized');
hleft = uicontrol('Style','pushbutton',...
    'Position',[210,270,175,175],'cdata',im3,...
    'Callback',@left_Callback,'BackgroundColor',...
    [0.604 0.851 0.918],'Units','normalized');
hright = uicontrol('Style','pushbutton',...
    'Position',[425,270,175,175],'cdata',im2,...
    'Callback',@right_Callback,'BackgroundColor',...
    [0.996 0.949 0],'Units','normalized');
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
    'Value',40,'SliderStep',[0.05 0.1],...
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
    10,'Value',1,'SliderStep',[0.01 0.1],...
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
%connect the right color sensor
try
    csensorR();
catch
    csensorR();
end
%connect the left color sensor
try
    csensorL();
catch
    csensorL();
end
%tell the user the connection works
uiwait(msgbox({'Connection Successful'},'Connection Successful'));
while true
    switch scancounter
        case 0
            colorbuffer = hforward.BackgroundColor;
            hforward.BackgroundColor = [1 0 0];
            pause(3);
            hforward.BackgroundColor = colorbuffer;
            scancounter = scancounter + 1;
        case 1
            colorbuffer = hclose.BackgroundColor;
            hclose.BackgroundColor = [1 0 0];
            pause(3);
            hclose.BackgroundColor = colorbuffer;
            scancounter = scancounter + 1;
        case 2
            colorbuffer = hright.BackgroundColor;
            hright.BackgroundColor = [1 0 0];
            pause(3);
            hright.BackgroundColor = colorbuffer;
            scancounter = scancounter + 1;
        case 3
            colorbuffer = hreverse.BackgroundColor;
            hreverse.BackgroundColor = [1 0 0];
            pause(3);
            hreverse.BackgroundColor = colorbuffer;
            scancounter = scancounter + 1;
        case 4
            colorbuffer = hleft.BackgroundColor;
            hleft.BackgroundColor = [1 0 0];
            pause(3);
            hleft.BackgroundColor = colorbuffer;
            scancounter = scancounter + 1;            
        case 5
            colorbuffer = hopen.BackgroundColor;
            hopen.BackgroundColor = [1 0 0];
            pause(3);
            hopen.BackgroundColor = colorbuffer;
            scancounter = 0;            
    end
end % scanning
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
            %counting_function();
            colormove();
        end
    end
    function right_Callback(source,callbackdata)
        % move right forward, left reverse
        rightmotor.Speed = -50;
        leftmotor.Speed = 50;
        start(rightmotor);
        start(leftmotor);
        pause(0.4);
        stop(rightmotor);
        stop(leftmotor);
    end
    function left_Callback(source,callbackdata)
        % move left forward, right reverse
        rightmotor.Speed = 50;
        leftmotor.Speed = -50;
        start(rightmotor);
        start(leftmotor);
        pause(0.4);
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
    function counting_function(source,callbackdata)
        clear sound;
        counter = counter + 1;
        switch grid
            case '1x10' %the 1x10 grid size
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
                pause(2);
                left_Callback();
            case '2x5a' %the 2x5 grid size - travels in the middles
                switch counter
                    case 1
                        right_Callback();
                        sound(audio1,Fs1);
                        pause(2);
                        left_Callback();
                    case 2
                        right_Callback();
                        sound(audio2,Fs2);
                        pause(2);
                        left_Callback();
                    case 3
                        right_Callback();
                        sound(audio3,Fs3);
                        pause(2);
                        left_Callback();
                    case 4
                        right_Callback();
                        sound(audio4,Fs4);
                        pause(2);
                        left_Callback();
                    case 5
                        right_Callback();
                        sound(audio5,Fs5);
                        pause(2);
                        left_Callback();
                        rightmotor.Speed = -motorspeed;
                        leftmotor.Speed = -motorspeed;
                        start(leftmotor);
                        start(rightmotor);
                        pause(6);
                        stop(rightmotor);
                        stop(leftmotor);
                    case 6
                        left_Callback();
                        sound(audio6,Fs6);
                        pause(2);
                        right_Callback();
                    case 7
                        left_Callback();
                        sound(audio7,Fs7);
                        pause(2);
                        right_Callback();
                    case 8
                        left_Callback();
                        sound(audio8,Fs8);
                        pause(2);
                        right_Callback();
                    case 9
                        left_Callback();
                        sound(audio9,Fs9);
                        pause(2);
                        right_Callback();
                    case 10
                        left_Callback();
                        sound(audio10,Fs10);
                        pause(2);
                        right_Callback();
                        rightmotor.Speed = -motorspeed;
                        leftmotor.Speed = -motorspeed;
                        start(leftmotor);
                        start(rightmotor);
                        pause(6);
                        stop(rightmotor);
                        stop(leftmotor);
                end
            case '2x5b' %the 2x5 grid size - travels counterclockwise
                switch counter
                    case 1
                        left_Callback();
                        sound(audio1,Fs1);
                        pause(2);
                        right_Callback();
                    case 2
                        left_Callback();
                        sound(audio2,Fs2);
                        pause(2);
                        right_Callback();
                    case 3
                        left_Callback();
                        sound(audio3,Fs3);
                        pause(2);
                        right_Callback();
                    case 4
                        left_Callback();
                        sound(audio4,Fs4);
                        pause(2);
                        right_Callback();
                    case 5
                        left_Callback();
                        sound(audio5,Fs5);
                        pause(2);
                        right_Callback();
                        rightmotor.Speed = motorspeed;
                        leftmotor.Speed = motorspeed;
                        start(leftmotor);
                        start(rightmotor);
                        pause(4);
                        stop(rightmotor);
                        stop(leftmotor);
                        for i = 1:4
                            left_Callback();
                            pause(1);
                        end
                        rightmotor.Speed = motorspeed;
                        leftmotor.Speed = motorspeed;
                        start(leftmotor);
                        start(rightmotor);
                        pause(4);
                        stop(leftmotor);
                        stop(rightmotor);
                        for i = 1:4
                            left_Callback();
                            pause(1)
                        end
                    case 6
                        left_Callback();
                        sound(audio6,Fs6);
                        pause(2);
                        right_Callback();
                    case 7
                        left_Callback();
                        sound(audio7,Fs7);
                        pause(2);
                        right_Callback();
                    case 8
                        left_Callback();
                        sound(audio8,Fs8);
                        pause(2);
                        right_Callback();
                    case 9
                        left_Callback();
                        sound(audio9,Fs9);
                        pause(2);
                        right_Callback();
                    case 10
                        left_Callback();
                        sound(audio10,Fs10);
                        pause(2);
                        right_Callback();
                end
        end
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
            case't' %toggle enable/disable counting
                if enablecounting == 0;
                    enablecounting = 1;
                    hquittext.String = 'Press X to Quit. Counting is on.';
                else
                    enablecounting = 0;
                    counter = 0;
                    hquittext.String = 'Press X to Quit. Counting is off.';
                end
            case 'r' %reset counting
                counter = 0;
            case'g'
                switch grid
                    case '1x10'
                        grid = '2x5a';
                        counter = 0;
                        hgridtext.String = 'Grid Size: 2x5a';
                    case '2x5a'
                        grid = '2x5b';
                        counter = 0;
                        hgridtext.String = 'Grid Size: 2x5b';
                    case '2x5b'
                        grid = '1x10';
                        counter = 0;
                        hgridtext.String = 'Grid Size: 1x10';
                end
            case 'x'
                delete(source);
                exit
            case 'return'
                switch scancounter
                    case 0
                        forward_Callback();
                    case 1
                        close_Callback();
                    case 2
                        right_Callback();
                    case 3
                        reverse_Callback();
                    case 4
                        left_Callback();
                    case 5
                        open_Callback();
                end
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
%These two functions are used to connect the color sensors

    function csensorR()
        if colortryR == 0
            try
                rightsensor = colorSensor(myev3, 1);
                colortryR = 1;
            catch
                rightsensor = colorSensor(myev3, 1);
                colortryR = 1;
            end
        end
    end %sets up the right color sensor in port 1
    function csensorL()
        if colortryL == 0
            try
                leftsensor = colorSensor(myev3, 2);
                colortryL = 1;
            catch
                leftsensor = colorSensor(myev3, 2);
                colortryL = 1;
            end
        end
    end %sets up the left color sensor in port 2
%This function tell the robot to follow a line
    function colormove()
        right = 0;
        left = 0;
        rightmotor.Speed = motorspeed;
        leftmotor.Speed = motorspeed;
        start(rightmotor);
        start(leftmotor);
        color = readColor(rightsensor);
        i=0;
        while true
            color = readColor(rightsensor);
            if strcmp(color,'blue') == 1
                stop(leftmotor);
                start(rightmotor);
            end
            if strcmp(color,'brown') == 1
                stop(rightmotor);
                start(leftmotor);
            end
            if i == 300
                break
            end
            color2 = readColor(leftsensor);
            %try to square off on the red line
            if strcmp(color,'red') == 1
                stop(rightmotor);
                stop(leftmotor);
                if right ~= 1
                    right = 1;
                    start(leftmotor);
                end
            end
            if strcmp(color2,'red') == 1
                stop(rightmotor);
                stop(leftmotor);
                if left ~= 1
                    left = 1;
                    start(rightmotor);
                end                
            end
            %On the red line, end the movement
            if right == 1 && left == 1
                break
            end
            i = i+1;
        end
        counting_function();
    end
end