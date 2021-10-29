                                                                                                                                                                                                                                                                                                                                                                                                                                                                   function ev3Controller_scanning
% ev3Controller_nuvoice_counting runs an ev3 over bluetooth. This
% controller connects over bluetooth to a specific ev3 brick and is able to
% scan

%set defaults
motorspeed =60;
runtimer = 2;
scancounter = 0;
opencounter = 0;
colorbuffer = [0.996 0.949 0];
time = 0;

brickID = '00165340de27'; 
%'001653527a87'; L's robot
%'00165340de27'; Glenrose robot

%load in the button images
[x1,map1] = imread('Images\forwardButton.jpg');
im1 = imresize(x1, [175 175]);
[x2,map2] = imread('Images\rightButton.jpg');
im2 = imresize(x2, [175 175]);
[x3,map3] = imread('Images\leftButton.jpg');
im3 = imresize(x3, [175 175]);
[x4,map4] = imread('Images\reverseButton2.jpg');
im4 = imresize(x4, [175 175]);

%  Create and then hide the UI as it is being constructed.
hfig = figure('Visible','off','Position',[360,500,850,700],...
    'Color',[0.7 0.7 0.7],'KeyPressFcn',@keypress_Callback,'CloseRequestFcn',...
    @closefunction,'MenuBar','none');
%% CONSTRUCTION OF THE FIGURE ELEMENTS
% Construct the components for movement
hforward = uicontrol('Style','pushbutton',...
    'Position',[25,445,175,175],'cdata',im1,...
    'Callback',@forward_Callback,'BackgroundColor',...
    [0.145 0.694 0.301],'Units','normalized');
hleft = uicontrol('Style','pushbutton',...
    'Position',[425,445,175,175],'cdata',im3,...
    'Callback',@left_Callback,'BackgroundColor',...
    [0.604 0.851 0.918],'Units','normalized');
hright = uicontrol('Style','pushbutton',...
    'Position',[625,445,175,175],'cdata',im2,...
    'Callback',@right_Callback,'BackgroundColor',...
    [0.996 0.949 0],'Units','normalized');
hreverse = uicontrol('Style','pushbutton',...
    'Position',[225,445,175,175],'cdata',im4,...
    'Callback',@reverse_Callback,'BackgroundColor',...
    [0.639 0.286 0.643],'Units','normalized');
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
myev3 = legoev3('usb');
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
     r3 = 0;
         resetRotation(rightmotor);
         rightmotor.Speed = motorspeed;
         leftmotor.Speed = motorspeed;
         start(leftmotor);
         start(rightmotor);
        pause(0.1);
         stop(leftmotor,1);
         stop(rightmotor,1);
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
%this callback controls the robot with the keyboard
    function keypress_Callback(source,callbackdata)
        %callbackdata.Key %this line tells me what key I am pressing
        switch callbackdata.Key
            case 'uparrow' %forward
                forward_Callback();
            case 'rightarrow' %right
                right_Callback();
            case 'leftarrow' %left
                left_Callback();
            case 'downarrow' %reverse
                %reverse_Callback();
                if opencounter == 0
                    open_Callback();
                    opencounter = 1;
                else
                    close_Callback();
                    opencounter = 0;
                end
            case 'b'
                stop(rightmotor);
                stop(leftmotor);
            case 'x'
                delete(source);
                exit
            case 'o'
                open_Callback();
            case 'c'
                close_Callback();
            case 'return'
                switch scancounter
                    case 1
                        forward_Callback();
                    case 2
                        reverse_Callback();
                    case 3
                        left_Callback();
                    case 0
                        right_Callback();                        
                end
            case 'space'
                switch scancounter
                    case 0 %change fwd
                        hright.BackgroundColor = colorbuffer;
                        colorbuffer = hforward.BackgroundColor;
                        hforward.BackgroundColor = [1 0 0];
                        drawnow
                        scancounter = scancounter + 1;
                    case 1 %change reverse
                        hforward.BackgroundColor = colorbuffer;
                        colorbuffer = hreverse.BackgroundColor;
                        hreverse.BackgroundColor = [1 0 0];
                        drawnow
                        scancounter = scancounter + 1;
                    case 2 %change left
                        hreverse.BackgroundColor = colorbuffer;
                        colorbuffer = hleft.BackgroundColor;
                        hleft.BackgroundColor = [1 0 0];
                        drawnow                        
                        scancounter = scancounter + 1;
                    case 3 %change right
                        hleft.BackgroundColor = colorbuffer;
                        colorbuffer = hright.BackgroundColor;
                        hright.BackgroundColor = [1 0 0];
                        drawnow
                        scancounter = 0;
                end
        end
    end
%disable accidentally hitting the close button (yes it is supposed to be
%empty)
    function closefunction(source,callbackdata,handles)
    end
end