% dev version 2.1.1
% date: Dec 11, 2015

function varargout = MMControl(varargin)
% MMCONTROL MATLAB code for MMControl.fig
%      MMCONTROL, by itself, creates a new MMCONTROL or raises the existing
%      singleton*.
%
%      H = MMCONTROL returns the handle to a new MMCONTROL or the handle to
%      the existing singleton*.
%
%      MMCONTROL('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MMCONTROL.M with the given input arguments.
%
%      MMCONTROL('Property','Value',...) creates a new MMCONTROL or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before MMControl_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to MMControl_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help MMControl

% Last Modified by GUIDE v2.5 01-Mar-2016 18:27:59

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @MMControl_OpeningFcn, ...
                   'gui_OutputFcn',  @MMControl_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before MMControl is made visible.
function MMControl_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to MMControl (see VARARGIN)

libdir = fullfile(pwd,'lib');
if exist(libdir,'dir')
    addpath(genpath(libdir));
end

% Choose default command line output for MMControl
handles.output = hObject;

% Initialize log
setappdata(handles.main_figure,'log',cell(0));
updatestatus(handles.main_figure,'Welcome!');
[handles.mDir,handles.mName,ext] = fileparts(mfilename('fullpath'));

%%%%% Initialize variables
% Load scalar variables
handles.varsFileName = [handles.mName '_vars.xlsx'];
vars = readVarScalars(handles.varsFileName);
for iKey=1:length(vars.keys)
    key = vars.keys{iKey};
    handles.(key) = vars.(key);
    updatestatus(handles.main_figure,['Set variable ' key ' specified in ' handles.varsFileName ' to: ' vars.varStr.(key)]);
end

% Load vector variables
vars = readVarVectors(handles.varVectorsFileName,1);
for iKey=1:length(vars.keys)
    key = vars.keys{iKey};
    handles.(key) = vars.(key);
    updatestatus(handles.main_figure,['Set variable ' key ' specified in ' handles.varVectorsFileName ' to:']);
    updatestatus(handles.main_figure,vars.varStr.(key));
end

set(handles.acqProfiles_popupmenu,'String',handles.acqProfiles);
set(handles.yLabel_popupmenu,'String', handles.trackHeader);

if exist(handles.guivarsFileName ,'file')
    load(handles.guivarsFileName ,'guiVars');
end

for iVar=1:length(handles.savedVars)
    var = handles.savedVars{iVar};
    if isfield(guiVars,var)
        handles.(var) = guiVars.(var);
        updatestatus(handles.main_figure,['Update variable ' var ' from guiVars.']);
        guiName = handles.guiName{iVar};
        if ~isempty(guiName)
            set(handles.(guiName),handles.guiType{iVar},handles.(var));
        end
    end
end


defaultBackground = get(0,'defaultUicontrolBackgroundColor');
set(handles.main_figure,'Color',defaultBackground);

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes MMControl wait for user response (see UIRESUME)
% uiwait(handles.main_figure);


% --- Outputs from this function are returned to the command line.
function varargout = MMControl_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
if (isfield(handles,'closeFigure') && handles.closeFigure)
    varargout{1} = 0;
    main_figure_CloseRequestFcn(handles.main_figure, eventdata, handles);
else
    varargout{1} = handles.output;
end


% --- Executes on button press in exit_pushbutton.
function exit_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to exit_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% delete(handles.main_figure);
main_figure_CloseRequestFcn(handles.main_figure, eventdata, handles);


% --- Executes when user attempts to close main_figure.
function main_figure_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to main_figure (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
if ~(isfield(handles,'closeFigure') && handles.closeFigure)
    promptMessage = sprintf('Do you want to Continue exiting?\n(Click Cancel to stay running)');
    selectedButton = questdlg(promptMessage, 'Exit Dialog','Continue exiting', 'Cancel', 'Continue exiting');
    if strcmp(selectedButton, 'Cancel')        % Stay in the program. Do not exit.
        return;
    end
end

% save gui variables
guiVars = struct;
for iVar=1:length(handles.savedVars)
    var = handles.savedVars{iVar};
    if isfield(handles,var)
        guiVars.(var) = handles.(var);
    end
end
save(handles.guivarsFileName,'guiVars');

% delete timer
if isfield(handles,'timer') && isvalid(handles.timer)
    if strcmp(get(handles.timer, 'Running'), 'on')
        stopTimer(handles);
    end
    delete(handles.timer);
end

updatestatus(handles.main_figure,'Goodbye!');

if handles.isLog
    saveLog(handles);
end

libdir = fullfile(pwd,'lib');
if exist(libdir,'dir')
    rmpath(genpath(libdir));
end

% Continue to exit by deleting this GUI
delete(hObject);


% --- Executes during object creation, after setting all properties.
function filedir_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to filedir_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in browse_pushbutton.
function browse_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to browse_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
dirstr = uigetdir(handles.filedir,'Specify the first image file...');
if ~ischar(dirstr)
    updatestatus(handles.main_figure,'Not a valid file path.');
    return;
end

%Always use / to separate folders
%No ending slash
handles.filedir = [strrep(dirstr,'\','/') '/'];
set(handles.filedir_edit,'String',handles.filedir);

guidata(hObject, handles);


function filedir_edit_Callback(hObject, eventdata, handles)
% hObject    handle to filedir_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of filedir_edit as text
%        str2double(get(hObject,'String')) returns contents of filedir_edit as a double
filedir = get(handles.filedir_edit,'String');

status = 1;
if ~exist(filedir,'dir')
    promptMessage = sprintf('Directory does not exist. Do you want to create it?\n(Click Cancel to stay running)');
    selectedButton = questdlg(promptMessage, 'Create Directory Dialog','Create', 'Cancel', 'Cancel');
    if strcmp(selectedButton, 'Create')
        status = mkdir(filedir);
        if ~status
            updatestatus(handles.main_figure,'Cannot create directory.');
        end
    else
        status = 0;
    end
end

if ~status
    set(handles.filedir_edit,'String',handles.filedir);
    updatestatus(handles.main_figure,'Invalid directory.');
    return;
end

filedir = strrep(filedir,'\','/');
if filedir(end) ~= '/'
    handles.filedir = [filedir '/'];
else
    handles.filedir = filedir;
end

% reset batch index
handles.iBatch = 0;

set(handles.filedir_edit,'String',handles.filedir);
updatestatus(handles.main_figure,'File directory has been updated.');

guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function left_axes_CreateFcn(hObject, eventdata, handles)
% hObject    handle to left_axes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate left_axes
set(0,'defaultaxeslinewidth',1);


% --- Executes during object creation, after setting all properties.
function right_axes_CreateFcn(hObject, eventdata, handles)
% hObject    handle to right_axes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate right_axes
set(0,'defaultaxeslinewidth',1);


% --- Executes on button press in isAutoContrast_checkbox.
function isAutoContrast_checkbox_Callback(hObject, eventdata, handles)
% hObject    handle to isAutoContrast_checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of isAutoContrast_checkbox
state = get(hObject,'Value');
handles.isAutoContrast = state;
updatestatus(handles.main_figure,['isAutoContrast has been set to: ' num2str(state)]);
guidata(hObject, handles);


% --- Executes on button press in snap_pushbutton.
function snap_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to snap_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.mmc.setExposure(handles.exposure);
handles.imgLeft = snapSingleImage(handles);
dispImage(handles.imgLeft,handles);
guidata(hObject, handles);


% --- Executes on mouse press over figure background, over a disabled or
% --- inactive control, or over an axes background.
function main_figure_WindowButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to main_figure (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
mousepos = get(handles.left_axes,'Currentpoint');
xpos = mousepos(1,1)-1;
ypos = mousepos(1,2)-1;

if ~isfield(handles,'imgLeft')
    updatestatus(handles.main_figure,'No image has been loaded to the left axes.');
    return;
end

[width,height] = size(handles.imgLeft);
if xpos<1 || xpos>width
    updatestatus(handles.main_figure,'X position is out of range.');
    return;
end
if ypos<1 || ypos>height
    updatestatus(handles.main_figure,'Y position is out of range.');
    return;
end
     
% convert y coordinate from image to axes. In matlab these two go different ways
%ypos = handles.imheight - ypos;

% % Now we find out which mouse button was clicked, and whether a
% % keyboard modifier was used, e.g. shift or ctrl
switch get(gcf,'SelectionType')
  case 'normal' % Click left mouse button.
      xpos = round(xpos);
      ypos = round(ypos);
      updatestatus(handles.main_figure,['Current position: (x,y,value) = (' num2str(xpos) ',' num2str(ypos) ',' num2str(handles.imgLeft(ypos,xpos)) ').']);
  case 'alt' % Ctrl - click left mouse button or click right mouse button.
       % find nearest cell near mouse click and toggle the selection
      handles.selectedPos = [xpos,ypos];
      if isfield(handles,'uncagingPos')
          distanceum = sqrt((xpos-handles.uncagingPos(3))^2+(ypos-handles.uncagingPos(4))^2)*handles.pix2um;
          updatestatus(handles.main_figure,['Selected position: (x,y) = (' num2str(xpos) ',' num2str(ypos) '), ' num2str(round(distanceum)) ' um from uncaging spot.']);
      else
          updatestatus(handles.main_figure,['Selected position: (x,y) = (' num2str(xpos) ',' num2str(ypos) ').']);
      end
  case 'extend' % Shift - click left mouse button or click both left and right mouse buttons.
      % find nearest cell near mouse click and toggle the selection
  case 'open'   % Double-click any mouse button.
      handles.stagePosArray = addPos_pushbutton_Callback(handles.main_figure, [xpos ypos], handles);
end
guidata(hObject, handles);


function newPos = updatePos(handles,posVar)
% Get current position
newPos = [];
isShow = get(handles.showPos_togglebutton,'Value');

if isShow
    if ~isfield(handles,posVar)
        updatestatus(handles.main_figure,'Position variable does not exist.');
        return;
    else
        showPos = handles.(posVar);
    end
else
    % Save the stage position if marking uncaging
    if strcmp(posVar,'uncagingPos')
        % positions read from micro-manager has opposite sign of that from the
        % image display
        [xStage, yStage] = getStagePos(handles);
    else
        xStage = 0;
        yStage = 0;
    end

    if ~isfield(handles,'selectedPos')
        cellPos = [256,256];
    else
        cellPos = handles.selectedPos;
    end

    newPos = [xStage,yStage,cellPos];
    showPos = newPos;
    buttonName = [posVar '_pushbutton'];
    set(handles.(buttonName),'ForegroundColor',[0,0.5,0]);
end

hold(handles.left_axes,'on');
plot(handles.left_axes,showPos(3),showPos(4),'g+');
hold(handles.left_axes,'off');

if ~isempty(newPos)
    handles.(posVar) = newPos;
    updatestatus(handles.main_figure,['New value for ' posVar ': [' regexprep(num2str(newPos), '\s*', ',') '].']);
    guidata(handles.main_figure, handles);
end


% --- Executes on button press in uncagingPos_pushbutton.
function uncagingPos_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to uncagingPos_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
updatePos(handles,'uncagingPos');


% --- Executes on button press in findspot_pushbutton.
function handles = findspot_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to findspot_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if ~isfield(handles,'imgLeft')
    updatestatus(handles.main_figure,'No image has been loaded to the left axes.');
    return;
end

inVars = struct;
inVars.isPassImages = true;
inVars.imYFP = handles.imgLeft;
inVars.imCFP = handles.imgLeft;

outVars = getFRETZ(inVars);
allSpots = outVars.tracks;
masks = outVars.masks; 
    
numSpots = length(allSpots);
if (numSpots ==0) || (numSpots ==1 && isempty(allSpots(1).x))
    updatestatus(handles.main_figure,'No spot has been detected.');
    return;
end

allPos = [allSpots(:).x;allSpots(:).y]';
index = nearest(allPos,handles.selectedPos);

selectedSpot = allSpots(index);
selectedPos = allPos(index,:);
posStr = ['(' num2str(round(selectedPos(1))) ',' num2str(round(selectedPos(2))) ')'];

if handles.isUpdateImages
    handles.imgRight = handles.imgLeft;
    allMasks = zeros(size(handles.imgRight));
    for iMask=1:length(masks)
        allMasks = allMasks|masks{iMask};
    end
    handles.imgRight(allMasks) = 65535;

    imshow(handles.imgRight,'Parent',handles.right_axes);
    hold(handles.right_axes,'on');
    plot(handles.right_axes,allPos(:,1),allPos(:,2),'r+');
    plot(handles.right_axes,selectedPos(1),selectedPos(2),'g+');
    hold(handles.right_axes,'off');
end

updatestatus(handles.main_figure,['Spot number ' num2str(index) ' at position ' posStr ' has been selected.']);

handles.selectedPos = [selectedSpot.x,selectedSpot.y];
guidata(hObject, handles);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%   MAIN ACQUISITION   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function acq = getTrackResults(figHandles,acq,images)
% Analyze images from images, compare with the previous cell positions in
% acq and get trajectories
for iStage=1:acq.numStagePos
    if acq.isImgThisFrame(iStage)
        posCurrent = acq.stagePosArray(iStage,:);
        xStage = posCurrent(1); yStage = posCurrent(2); % stage position
        xCell= posCurrent(3); yCell = posCurrent(4); % cell position in the image

        inVars = struct;
        inVars.isPassImages = true;

        % the default image for CFP-YFP,CFP-CFP and YFP-YFP images is the first
        % acquired image
        inVars.imYFP = images{iStage,1};
        if length(acq.acqConfigs)>=2 && strcmp(acq.acqConfigs{2}(1:3),'CFP') && strcmp(acq.acqConfigs{2}(end-2:end),'CFP')
            inVars.imCFP = images{iStage,2};
        else
            inVars.imCFP = images{iStage,1};
        end

        if length(acq.acqConfigs)>=3 && strcmp(acq.acqConfigs{3}(1:3),'YFP') && strcmp(acq.acqConfigs{3}(end-2:end),'YFP')
            inVars.imYYFP = images{iStage,3};
        else
            inVars.imYYFP = images{iStage,1};
        end

        outVars = getFRETZ(inVars);
        allPos = [outVars.tracks(:).x;outVars.tracks(:).y]';

        % Find the position that is closest to the previous position
        index = nearest(allPos,[xCell,yCell]);
        newPos = allPos(index,:);
        thisTrack = outVars.tracks(index);

        newLine = [];
        if figHandles.isPinCell
            % Stage's y-axis convention is opposite that in Matlab image
            % Image is flipped horizonally, but x-axis has been inverted by
            % hand, so it's OK
            if figHandles.isPinUncage && acq.isUncageFrameRange_NextFrame
                dx = (newPos(1) - figHandles.pinUncagePos(3))*acq.pix2um;
                dy = (newPos(2) - figHandles.pinUncagePos(4))*acq.pix2um;
                xCell = figHandles.pinUncagePos(3);
                yCell = figHandles.pinUncagePos(4);
            else
                dx = (newPos(1) - figHandles.pinPos(3))*acq.pix2um;
                dy = (newPos(2) - figHandles.pinPos(4))*acq.pix2um;
                xCell = figHandles.pinPos(3);
                yCell = figHandles.pinPos(4);
            end
            xStage = xStage + dx;
            yStage = yStage + dy;
        else
            xCell = newPos(1);
            yCell = newPos(2);
        end

        newLine = [acq.iImage acq.interval]; % col 1
        newLine = [newLine newPos(1)*acq.pix2um newPos(2)*acq.pix2um]; % col 3
        newLine = [newLine thisTrack.yfp thisTrack.cfp thisTrack.ratio thisTrack.rawy thisTrack.rawc thisTrack.rawr]; % col 5
        newLine = [newLine thisTrack.area thisTrack.round]; %col 11
        newLine = [newLine newPos(1) newPos(2)]; % col 13
        newLine = [newLine acq.pix2um]; % col 15
        if figHandles.isPinCell
            if figHandles.isPinUncage && acq.isUncageFrameRange_ThisFrame
                newLine = [newLine figHandles.pinUncagePos(3) figHandles.pinUncagePos(4)]; % col 16
            else
                newLine = [newLine figHandles.pinPos(3) figHandles.pinPos(4)]; % col 16
            end
            newLine = [newLine dx dy]; % col 18
        else
            newLine = [newLine -1 -1]; % col 16
            newLine = [newLine 0 0]; % col 18
        end
        newLine = [newLine xStage yStage]; % col 20
        newLine = [newLine acq.acqTime(iStage) acq.isUncageThisFrame(iStage)]; % col 22
        newLine = [newLine figHandles.uncageDuration figHandles.isPreRelease]; % col 24

        acq.results{iStage} = [acq.results{iStage};newLine];
        acq.stagePosArray(iStage,:) = [xStage yStage xCell yCell];
    end
end


% Acquire images for the current frame
function acq = imageAcq(handles,acq)
% elapsed time in seconds
acq.acqTime = [];
acq.images = cell(acq.numStagePos,acq.numConfigs);

for iStage=1:acq.numStagePos
    if acq.isImgThisFrame(iStage)
        if acq.numStagePos>1 || handles.isPinCell
            posCurrent = acq.stagePosArray(iStage,:);
            moveStage(handles,posCurrent(1:2));
            if iStage==1
                pause(5);
            else
                pause(0.5);
            end
            updatestatus(handles.main_figure,['Move to position #' num2str(iStage) ': [' regexprep(num2str(acq.stagePosArray(iStage,:)), '\s*', ',') '].']);
        end

        % Record time before imaging
        acq.acqTime(iStage) = round(etime(clock,acq.startTime));

        % Snap all images for each config
        imgAllConfigs = cell(1,acq.numConfigs);
        for iConfig=1:acq.numConfigs
            handles.mmc.setConfig(handles.configGroup,acq.acqConfigs{iConfig});
            handles.mmc.waitForConfig(handles.configGroup,acq.acqConfigs{iConfig});
        %     pause(.5);
            handles.mmc.setExposure(acq.exposure(iConfig));
            imgAllConfigs{iConfig} = snapSingleImage(handles);
            updatestatus(handles.main_figure,['Taking image with config: ' acq.acqConfigs{iConfig}]);
        end
        handles.mmc.setConfig(handles.configGroup,acq.acqConfigs{1});

        acq.images(iStage,:) = imgAllConfigs;
        dispImage(imgAllConfigs{handles.iConfigToDisplay},handles);
    end
end

% Save images in separate loop to save time for the image acquisition loop
for iStage=1:acq.numStagePos
    if acq.isImgThisFrame(iStage)
        % Save images into folder and pattern given by prefix with config names specified in filenames
        for iConfig=1:acq.numConfigs
            outfilePath = fullfile(acq.outfileDirArray{iStage},['img_' num2str(acq.iImage,'%09d') '_' acq.acqConfigs{iConfig} '_000.tif']);
            imwrite(acq.images{iStage,iConfig},outfilePath);
        end
    end
end



function acq = acqDisplay(handles,acq)
% display the image from the specified position
iPosDispImg = handles.iPos-1;
if iPosDispImg<1 || iPosDispImg>acq.numStagePos
    iPosDispImg = 1;
elseif ~acq.isImgThisFrame(iPosDispImg)
    iPosDispImg = find(acq.isImgThisFrame,1,'first')
end

isUncage = any(acq.isUncageThisFrame);
if isUncage
    acq.imgLeft = acq.imgUncage;
    updatestatus(handles.main_figure,'Display image from the position with uncaging');
elseif acq.isImgThisFrame(iPosDispImg)
    acq.imgLeft = acq.images{iPosDispImg,handles.iConfigToDisplay};
    updatestatus(handles.main_figure,['Display image from position: ' num2str(iPosDispImg)]);
end
dispImage(acq.imgLeft,handles);

if acq.isTrackCell
    % Plot all tracks
    handles.acq = acq; % assignment is used for plotting
    plotTracks_pushbutton_Callback([], [], handles);

%     yLim = get(handles.left_axes,'YLim');
%     offset = (yLim(2)-yLim(1))*0.1;
%     yData = [yLim(1)+offset, yLim(2)-offset];
%     
%     colFrame = 1; colUncage = 23;
%     numColors = length(handles.acq.colors);
%     for iStage=1:acq.numStagePos
%         iUncage = find(acq.results{iStage}(:,colUncage));
%         xData = acq.results{iStage}(:,colFrame);
%         xData = xData(iUncage)*acq.interval/60; % time in minute
%         color = acq.colors(mod(iStage-1,numColors)+1,:);
%         plot(handles.right_axes,xData,yData,handles.plotOptions,'Color',color,'LineWidth',0.7,'MarkerSize',2);
%         for x=xData
%             line([x x],yData,'LineStyle','--','Color',color,'LineWidth',0.5,'Parent',handles.left_axes);
%         end
%     end

    acq.cellPos = [0,0,[acq.results{iPosDispImg}(end,13:14)]];
%     if ~isUncage
        % Show cell position
    hold(handles.left_axes,'on');
    plot(handles.left_axes,acq.cellPos(3),acq.cellPos(4),'r+');
    hold(handles.left_axes,'off');
%     end
end

if acq.numConfigs >=4 && strcmp(acq.acqConfigs{4}(end-1:end),'TR')
    dispImageRight(acq.images{iPosDispImg,4},handles);
end


function runAcquisition(hObject,eventdata,hfigure)
% Run one acquisition when timer fires

% Save figure handles to use within this function before updating the main
% handles at the end
figHandles = guidata(hfigure);
acq = figHandles.acq;

% acq.refFramesUncage = figHandles.refFrame+(0:acq.numStagePos-1)*figHandles.uncageIntervalBetweenPos;
acq.refFramesUncage = figHandles.refFrame*ones(acq.numStagePos);
acq.refFramesImg = figHandles.refFrame+(0:acq.numStagePos-1)*figHandles.imgIntervalBetweenPos;

if acq.iImage>figHandles.numImages
    updatestatus(figHandles.main_figure,'Acquisition has finished');
    figHandles.isAcqRunning = false;
    set(figHandles.acquire_pushbutton,'String','Acquire','ForegroundColor',[0,0,0]);
    guidata(hObject, figHandles);
end

% Also take care of situation when user hit the Stop Acquisition button
if ~figHandles.isAcqRunning
    stopTimer(figHandles);
    return;
end

updatestatus(figHandles.main_figure,' ');
updatestatus(figHandles.main_figure,['#####   Processing frame ' num2str(acq.iImage) '/' num2str(figHandles.numImages) '   #####']);

% Acquire images
acq.isImgThisFrame = acq.imgOrderArray(mod(acq.iImage-acq.refFramesImg,acq.imgPeriod)+1);
if any(acq.isImgThisFrame)
    acq = imageAcq(figHandles,acq);
else
    updatestatus(figHandles.main_figure,'No image is acquired for this frame.');
end

% change the start frame whenever new period is specified
% find out which position needs stimulus released
uncageOrderArray = acq.iImage-acq.refFramesUncage;
maxFrameUncage = 6000;
acq.isUncageThisFrame = figHandles.isAutoUncage & (acq.iImage < maxFrameUncage) & (uncageOrderArray >= 0) & (mod(uncageOrderArray,figHandles.uncagePeriod)<1);
acq.isUncageNextFrame = figHandles.isAutoUncage & (acq.iImage < maxFrameUncage) & (uncageOrderArray+1 >= 0) & (mod(uncageOrderArray+1,figHandles.uncagePeriod)<1);
% acq.isUncageThisFrame = figHandles.isAutoUncage & (uncageOrderArray >= 0) & (mod(uncageOrderArray,figHandles.uncagePeriod)<1);
% acq.isUncageNextFrame = figHandles.isAutoUncage & (uncageOrderArray+1 >= 0) & (mod(uncageOrderArray+1,figHandles.uncagePeriod)<1);
% updatestatus(figHandles.main_figure,['Test: showing maxFrameUncage =' num2str(maxFrameUncage)]);

uncageOrderArrayMod = mod(uncageOrderArray,figHandles.uncagePeriod);
extraStimuliMod = mod(uncageOrderArrayMod,figHandles.periodExtraStimuli);
extraStimuliIndex = floor(uncageOrderArrayMod/figHandles.periodExtraStimuli);
acq.isUncageThisFrameExtra = figHandles.isAutoUncage & (uncageOrderArray >= 0) & (extraStimuliMod==0) & (extraStimuliIndex>0) & (extraStimuliIndex<=figHandles.numExtraStimuli);

% prepare stage to uncaging position if the next frame is is the uncaging
% frame range
acq.isUncageFrameRange_ThisFrame = figHandles.isAutoUncage & (uncageOrderArray >= 0) & (mod(uncageOrderArray,figHandles.uncagePeriod)<figHandles.numFramesUncage);
acq.isUncageFrameRange_NextFrame = figHandles.isAutoUncage & (uncageOrderArray+1 >= 0) & (mod(uncageOrderArray+1,figHandles.uncagePeriod)<figHandles.numFramesUncage);

if figHandles.isPreRelease && acq.isUncageNextFrame(1)
    updatestatus(figHandles.main_figure,['Pre-release at uncaging position: [' num2str(figHandles.uncagingPos(1:2)) '].']);
%     uncage_injector(figHandles,figHandles.uncagingPos(1:2),5,1,[]);
    uncage_injector(figHandles,figHandles.uncagingPos(1:2),1,1,[]);
end

for iStage=1:acq.numStagePos
%     if acq.isUncageThisFrame(iStage) && (iStage==1)
    if ((iStage==1)||(iStage==acq.numStagePos))
        if acq.isUncageThisFrame(iStage) || (acq.isUncageThisFrameExtra(iStage))
            posInject = acq.stagePosArray(iStage,:);
            if acq.isUncageThisFrame(iStage)
                numTrains = floor(figHandles.uncageDuration/figHandles.injectUnitTime);
            else
                numTrains = floor(figHandles.durationExtraStimuli/figHandles.injectUnitTime);
            end            
    %         if figHandles.isPinUncage
    %             % outside minus sign is due to peculiarities in the stage
    %             % coordinates compared to those of the image
    %             posInject(1:2) = posInject(1:2) - (figHandles.pinUncagePos(3:4) - figHandles.pinPos(3:4)) * figHandles.pix2um;
    %         end
            updatestatus(figHandles.main_figure,['Uncage at position #' num2str(iStage) ': [' num2str(posInject) '].']);
            uncage_injector(figHandles,posInject,numTrains,figHandles.isMonitorUncage,[]);
            acq.imgUncage = snapSingleImage(figHandles);
        end
    end
end
    
% Find out which position needs uncaging in this frame
if any(acq.isImgThisFrame) && acq.isTrackCell
    acq = getTrackResults(figHandles,acq,acq.images);
end

if figHandles.isUpdateImages
    acq = acqDisplay(figHandles,acq);
end

updatestatus(figHandles.main_figure,['#####   Frame ' num2str(acq.iImage) ' has finished   #####']);
acq.iImage = acq.iImage+1;

% Only update handles.acq and imgLeft, other variables of handles can be
% changed in the GUI safely while acquisition timer is triggered
tmpHandles = guidata(hfigure);
tmpHandles.acq = acq;
if figHandles.isUpdateImages
    tmpHandles.imgLeft = acq.imgLeft;
end
guidata(hfigure, tmpHandles);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes on button press in acquire_pushbutton.
function acquire_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to acquire_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Check if acquisition status, stop timer if it's running
if handles.isAcqRunning 
    if strcmp(get(handles.timer, 'Running'), 'on')
        % timer is stopped but acquisition status says it's running. It must have
        % run into an error
        updatestatus(handles.main_figure,'Acquisition will be stopped after this frame.');
        handles.isAcqRunning = false;
        set(hObject,'String','Acquire','ForegroundColor',[0,0,0]);
        guidata(hObject, handles);
        return;
    else
        updatestatus(handles.main_figure,'Acquisition has been stopped unexpectedly');
        saveRightImg_pushbutton_Callback([], 1, handles);
        if handles.isAutoSaveTrack && handles.isTrackCell
            savetrack_pushbutton_Callback([], [], handles);
        end
    end
end

% Start new acquisition run
handles.isAcqRunning = true;
set(hObject,'String','Stop','ForegroundColor',[0,0.5,0]);
handles.iBatch = handles.iBatch+1;

updatestatus(handles.main_figure,' ');
updatestatus(handles.main_figure,'############################################');
updatestatus(handles.main_figure,['#####   Starting acquisition run #' num2str(handles.iBatch) '   #####']);
updatestatus(handles.main_figure,'############################################');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Parameters that cannot be changed by user during acquisition
handles.acq = struct;
handles.acq.iImage = 1;

% keep track of when logging for the current acquisition begins
handles.acq.ilogStart = length(getappdata(handles.main_figure,'log'))+1;

% Set default acquisition options the beginning
if ~handles.isAutoUncage
    updatestatus(handles.main_figure,'AutoUncage is not set, deselect Pre-release, Monitor Uncage and Pin Cell Uncage');
    handles.isPreRelease = 0;
    handles.isMonitorUncage = 0;
    handles.isPinUncage = 0;
    set(handles.isPreRelease_checkbox,'Value',handles.isPreRelease);
    set(handles.isMonitorUncage_checkbox,'Value',handles.isMonitorUncage);
    set(handles.isPinUncage_checkbox,'Value',handles.isPinUncage);
end

if handles.isPinCell && ~isfield(handles,'pinPos')
    updatestatus(handles.main_figure,'Pin position is not specified. Set to default.');
    handles.pinPos = [0 0 256 256];
end

if handles.isPinUncage && ~isfield(handles,'pinUncagePos')
    updatestatus(handles.main_figure,'Pin uncage position is not specified. Set to default.');
    handles.pinUncagePos = handles.pinPos;
end

updatestatus(handles.main_figure,['isPreRelease is currently set to ' num2str(handles.isPreRelease) '.']);
updatestatus(handles.main_figure,['isAutoUncage is currently set to ' num2str(handles.isAutoUncage) '.']);

handles.acq.interval = handles.interval;
updatestatus(handles.main_figure,['Frame interval: ' num2str(handles.acq.interval) ' s.']);

updatestatus(handles.main_figure,['uncagePeriod is currently set to ' num2str(handles.uncagePeriod) '.']);
updatestatus(handles.main_figure,['injectUnitTime is currently set to ' num2str(handles.injectUnitTime) ' (s).']);

handles.acq.pix2um = handles.pix2um;
updatestatus(handles.main_figure,['Length calibration: 1 pixel = ' num2str(handles.acq.pix2um) ' um.']);

handles.acq.acqConfigs = handles.acqConfigs;
updatestatus(handles.main_figure,['Acquisition configs: [' strjoin(handles.acq.acqConfigs,',') ']']);

handles.acq.numConfigs = length(handles.acq.acqConfigs);
handles.acq.exposure = handles.acqExpRatios*handles.exposure;
% handles.acq.exposure = ones(1,handles.acq.numConfigs)*handles.exposure;
updatestatus(handles.main_figure,'Illumination exposures for acquisition configs (ms):');
updatestatus(handles.main_figure,['[' num2str(handles.acq.exposure) ']']);

handles.acq.outfileDir = [handles.filedir strtrim(handles.prefix) '_' num2str(handles.iBatch) '/'];
if ~exist(handles.acq.outfileDir,'dir')
    mkdir(handles.acq.outfileDir);
end
updatestatus(handles.main_figure,['Acquired images are to be saved in folder: ' handles.acq.outfileDir]);

[xStage, yStage] = getStagePos(handles);
% if handles.isPreRelease && ~isfield(handles,'uncagingPos')
if ~isfield(handles,'uncagingPos')
    handles.uncagingPos = [xStage,yStage,256,256];
end
updatestatus(handles.main_figure,['uncagingPos:  ' num2str(handles.uncagingPos)]);
% Add current position to the list if none has been added
if ~handles.isMultiPos || size(handles.stagePosArray,1)<1
    handles.acq.stagePosArray = [xStage,yStage,256,256];
    updatestatus(handles.main_figure,'Position array is empty. Acquire images at current position.');
else
    handles.acq.stagePosArray = handles.stagePosArray;
end
handles.acq.numStagePos = size(handles.acq.stagePosArray,1);
for iStage = 1:handles.acq.numStagePos
    updatestatus(handles.main_figure,['Position #' num2str(iStage) ' | ' num2str(handles.acq.stagePosArray(iStage,:))]);
end

handles.acq.outfileDirArray = {};
if handles.acq.numStagePos == 1
    handles.acq.outfileDirArray{1} = handles.acq.outfileDir;
    updatestatus(handles.main_figure,['Images are to be saved in folder: ' handles.acq.outfileDir]);
else
    for iStage = 1:handles.acq.numStagePos
        outfileDir = [handles.acq.outfileDir 'Pos_' num2str(iStage) '/'];
        if ~exist(outfileDir,'dir')
            mkdir(outfileDir);
        end
        handles.acq.outfileDirArray{iStage} = outfileDir;
        updatestatus(handles.main_figure,['Images for position #' num2str(iStage) ' are to be saved in folder: ' outfileDir]);
    end
end

handles.acq.isTrackCell = handles.isTrackCell;
updatestatus(handles.main_figure,['isTrackCell this acquisition is set to ' num2str(handles.acq.isTrackCell) '.']);

% initialize track results
handles.acq.results = cell(1,handles.acq.numStagePos);

% Color map for plotting multiple curves
handles.acq.colors = lines(7);

if handles.isImgAll
    handles.acq.imgPeriod = handles.uncagePeriod;
    strBin = repmat('1',1,handles.acq.imgPeriod);
    handles.acq.imgOrderArray = ones(1,handles.acq.imgPeriod);
else
    strBin = getBinArray(handles.imgOrder)
    handles.acq.imgPeriod = length(strBin);
    handles.acq.imgOrderArray = (strBin=='1'); % convert to binary array
end
updatestatus(handles.main_figure,'Images will be acquired at the following order:');
updatestatus(handles.main_figure,strBin);
updatestatus(handles.main_figure,['Period for image acquisition: ' num2str(handles.acq.imgPeriod) '.']);
% Set reference frame to after one period
handles.refFrame = handles.acq.iImage+handles.acq.imgPeriod;
set(handles.refFrame_edit,'String',num2str(handles.refFrame));
updatestatus(handles.main_figure,['refFrame is currently set to ' num2str(handles.refFrame) '.']);

handles.acq.startTime = clock;
t = round(handles.acq.startTime);
strTime = [num2str(t(1),'%04d') '-' num2str(t(2),'%02d') '-' num2str(t(3),'%02d') ' ' num2str(t(4),'%02d') ':' num2str(t(5),'%02d') ':' num2str(t(6),'%02d')];
updatestatus(handles.main_figure,['Acquisition starts at ' strTime]);
guidata(hObject, handles);

% Start timer after guidata so that new values in handles are updated
set(handles.timer,'Period',handles.acq.interval);
set(handles.timer,'StartDelay',0.1);
start(handles.timer);


function stopTimer(handles)
% Clean up when timer is stopped

stop(handles.timer);

% if handles.isAutoUncage
%     handles.mmc.setConfig(handles.shutterUncage,'Close');
% end

updatestatus(handles.main_figure,' ');

saveRightImg_pushbutton_Callback([], 1, handles);
if handles.isAutoSaveTrack && handles.isTrackCell
    savetrack_pushbutton_Callback([], [], handles);
end

log = getappdata(handles.main_figure,'log');
logAcq = log(handles.acq.ilogStart:end);
log = log(1:handles.acq.ilogStart-1);
setappdata(handles.main_figure,'log',log);

logFilePath = fullfile(handles.acq.outfileDir,'MMControl_acq_log.txt');
updatestatus(handles.main_figure,['Acquisition log is saved to: ' logFilePath]);
fid = fopen(logFilePath,'wt');
fprintf(fid, '%s\n', logAcq{:});
fclose(fid);

updatestatus(handles.main_figure,'########   TIMER HAS BEEN STOPPED   ########');


function dispImage(img,handles)
% display image on the axes
if handles.isUpdateImages
    if handles.isAutoContrast
        img = autocontrast(img,handles.bitDepth);
    end
    imshow(img,'Parent',handles.left_axes);
end

function dispImageRight(img,handles)
% display image on the axes
if handles.isUpdateImages
    if handles.isAutoContrast
        img = autocontrast(img,handles.bitDepth);
    end
    imshow(img,'Parent',handles.right_axes);
end


function numImages_edit_Callback(hObject, eventdata, handles)
% hObject    handle to numImages_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of numImages_edit as text
%        str2double(get(hObject,'String')) returns contents of numImages_edit as a double
edit_number(hObject, handles, 'numImages','int')


% --- Executes during object creation, after setting all properties.
function numImages_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to numImages_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function interval_edit_Callback(hObject, eventdata, handles)
% hObject    handle to interval_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of interval_edit as text
%        str2double(get(hObject,'String')) returns contents of interval_edit as a double
edit_number(hObject, handles, 'interval','double')


% --- Executes during object creation, after setting all properties.
function interval_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to interval_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in cellPos_pushbutton.
function cellPos_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to cellPos_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
updatePos(handles,'cellPos');


% --- Executes on button press in isTrackCell_checkbox.
function isTrackCell_checkbox_Callback(hObject, eventdata, handles)
% hObject    handle to isTrackCell_checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of isTrackCell_checkbox
state = get(hObject,'Value');
handles.isTrackCell = state;
updatestatus(handles.main_figure,['isTrackCell has been set to: ' num2str(state)]);
guidata(hObject, handles);


% --- Executes on button press in pinPos_pushbutton.
function pinPos_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to pinPos_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
updatePos(handles,'pinPos');


% --- Executes on button press in savetrack_pushbutton.
function savetrack_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to savetrack_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
updatestatus(handles.main_figure,'Saving track results:');
if ~isfield(handles,'acq') && ~isfield(handles.acq,'results')
    updatestatus(handles.main_figure,'No track results found.');
    return;
end

if isfield(handles.acq,'results')
    for iStage=1:handles.acq.numStagePos
        if ~isempty(handles.acq.results{iStage})
            savedFilePath = fullfile(handles.acq.outfileDir,['MMControl_track' num2str(iStage) '.txt']);
            T = mat2dataset(handles.acq.results{iStage},'VarNames',handles.trackHeader);
            export(T,'File',savedFilePath,'Delimiter','\t');
            updatestatus(handles.main_figure,savedFilePath);
        end
    end
end
updatestatus(handles.main_figure,'Track results have been saved.');


% --- Executes on button press in isLog_checkbox.
function isLog_checkbox_Callback(hObject, eventdata, handles)
% hObject    handle to isLog_checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of isLog_checkbox
state = get(hObject,'Value');
handles.isLog = state;
updatestatus(handles.main_figure,['isLog has been set to: ' num2str(state)]);
guidata(hObject, handles);


function moveStageRelative(handles,dx,dy)
% Move the stage relative to current position
% dx and dy are displacements in x and y in units of um

% x-axis is flipped in controller
% handles.mmc.setRelativeXYPosition(handles.stage,dx,dy);
handles.mmc.setRelativeXYPosition(handles.stage,-dx,dy);
% handles.mmc.waitForDevice(handles.stage);


function pix2um_edit_Callback(hObject, eventdata, handles)
% hObject    handle to pix2um_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of pix2um_edit as text
%        str2double(get(hObject,'String')) returns contents of pix2um_edit as a double
edit_number(hObject, handles, 'pix2um','double')
updatestatus(handles.main_figure,['Calibration is set to: 1 pixel = ' num2str(handles.pix2um) 'um']);


% --- Executes during object creation, after setting all properties.
function pix2um_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pix2um_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function uncageDuration_edit_Callback(hObject, eventdata, handles)
% hObject    handle to uncageDuration_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of uncageDuration_edit as text
%        str2double(get(hObject,'String')) returns contents of uncageDuration_edit as a double
str = get(hObject,'String');
handles.uncageDuration = str2double(str);
updatestatus(handles.main_figure,['uncageDuration has been set to: ' str]);
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function uncageDuration_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to uncageDuration_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in uncage_pushbutton.
function uncage_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to uncage_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
switch handles.uncageType
  case 'laser'
    uncage_laser(handles);
  case 'lamp'
    uncage_lamp(handles);
  case 'injector'
    numTrains = floor(handles.uncageDuration/handles.injectUnitTime);
%     uncage_injector(handles,[],numTrains,0,[]);
    uncage_injector(handles,[],numTrains,1,[]);
    otherwise
        updatestatus(handles.main_figure,['Cannot find uncaging type ' handles.uncageType '.']);
end


% Uncage by pico injector
function uncage_injector(handles,posInject,numTrains,isSaveFiles,outDir)
[xStage,yStage] = getStagePos(handles);
currentPos = [xStage,yStage];
if isempty(posInject)
    posInject = currentPos;
end
    
updatestatus(handles.main_figure,['Move stage to uncaging position: [' num2str(posInject(1:2)) '].']);
moveStage(handles,posInject(1:2));

if isSaveFiles
    frameInterval = 0.2; % (s)
    numFrames = ceil(handles.uncageDuration/frameInterval);
    numFrames = min(numFrames,25)+10;
    
%     handles.mmc.setConfig('Channel','Transmission');
%     handles.mmc.waitForConfig('Channel','Transmission');
    handles.mmc.setConfig('Channel','RFP');
    handles.mmc.waitForConfig('Channel','RFP');
%     handles.mmc.setExposure(100);
%     handles.mmc.setExposure(handles.exposure);
    
    isAutoShutter = handles.mmc.getAutoShutter();
    handles.mmc.setAutoShutter(0);
    handles.mmc.setShutterOpen(1);

    handles.mma.setFrames(numFrames,frameInterval);
    handles.mma.setSaveFiles(1);
    
    if isempty(outDir)
        outDir = handles.filedir;
    end
    handles.mma.setRootName(outDir);
    dirNamePrefix = 'inject';
    handles.mma.setDirName(dirNamePrefix);

    handles.mma.acquire();
    pause(0.1);
end

for i=1:numTrains
    ttl1_pushbutton_Callback([], [], handles);
    pause(handles.injectUnitTime);
end
updatestatus(handles.main_figure,['Uncage with ' num2str(numTrains) ' trains of injection pulses.']);

if isSaveFiles
    while handles.mma.isAcquisitionRunning()
        pause(0.1);
    end

    handles.mmc.setShutterOpen(0);
    if isAutoShutter
        handles.mmc.setAutoShutter(1);
    end

    lastdir = findLastInDir([outDir dirNamePrefix '*'],1);
    lastfile = findLastInDir([outDir lastdir '/*.tif'],0);
    lastimg = imread([outDir lastdir '/' lastfile]);

    updatestatus(handles.main_figure,['Uncaging images were saved in folder: ' fullfile(outDir,lastdir)]);
    dispImage(lastimg,handles);
end


% uncage with arc lamp
function uncage_lamp(handles)
handles.mmc.setConfig(handles.configGroup,handles.configUncage);
handles.mmc.waitForConfig(handles.configGroup,handles.configUncage);
handles.mmc.setExposure(handles.uncageDuration*1000);

img = snapSingleImage(handles);
dispImage(img,handles);
outfileName =  ['LampUncage_' getTime_filename() '.tif'];
imwrite(img,fullfile(handles.filedir,outfileName));


% uncage with UV laser
function uncage_laser(handles)
if handles.isExposeCam
    % Set config to uncaging for lamp to have consistent emission filter
    handles.mmc.setConfig(handles.configGroup,handles.configUncage);
    handles.mmc.waitForConfig(handles.configGroup,handles.configUncage);
    
    handles = storeShutterState(handles);
    handles.mmc.setShutterDevice(handles.shutterUncage);
    handles.mmc.setExposure(handles.uncageDuration*1000);
    img = snapSingleImage(handles);
    resetShutterState(handles);

    dispImage(img,handles);
    outfileName =  ['LaserUncage_' getTime_filename() '.tif'];
    imwrite(img,fullfile(handles.filedir,outfileName));
else
    handles.mmc.setConfig(handles.shutterUncage,'Open');
    pause(handles.uncageDuration);
    handles.mmc.setConfig(handles.shutterUncage,'Close');
end    


function exposure_edit_Callback(hObject, eventdata, handles)
% hObject    handle to exposure_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of exposure_edit as text
%        str2double(get(hObject,'String')) returns contents of exposure_edit as a double
edit_number(hObject, handles, 'exposure','double')


% --- Executes during object creation, after setting all properties.
function exposure_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to exposure_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function img = snapSingleImage(handles)
% snap one image and rotate to correct orientation
handles.mmc.snapImage();
tmpimg = handles.mmc.getImage();

if handles.bitDepth == 16
    % take care of the 16th bit denoting negative in Matlab
%     offset = (tmpimg<0)*32768;
%     tmpimg = uint16(abs(tmpimg))+uint16(offset);
    tmpimg = double(tmpimg);
    offset = (tmpimg<0)*2^16;
    tmpimg = uint16(tmpimg+offset);
else
    tmpimg = uint8(tmpimg);
end
tmpimg = reshape(tmpimg,[handles.imHeight,handles.imWidth]);
%img = rot90(tmpimg,3);
img = tmpimg.';


% --- Executes on button press in saveImage_pushbutton.
function saveImage_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to saveImage_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
outfileName =  [handles.prefix '_' getTime_filename() '.tif'];
savedImgPath =  fullfile(handles.filedir,outfileName);

% imwrite(handles.imgLeft,savedImgPath);
export_fig(savedImgPath,handles.left_axes);
updatestatus(handles.main_figure,['Left image has been saved to file: ' outfileName]);


% --- Executes on selection change in configs_popupmenu.
function configs_popupmenu_Callback(hObject, eventdata, handles)
% hObject    handle to configs_popupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns configs_popupmenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from configs_popupmenu
iConfig = get(hObject,'Value');
contents = cellstr(get(hObject,'String'));

try
    handles.mmc.setConfig(handles.configGroup,contents{iConfig});
    handles.mmc.waitForConfig(handles.configGroup,contents{iConfig});
catch
    updatestatus(handles.main_figure,['Error setting config: ' contents{iConfig}]);
    return;
end

updatestatus(handles.main_figure,['Config has been set to: ' contents{iConfig}]);

% --- Executes during object creation, after setting all properties.
function configs_popupmenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to configs_popupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes on button press in isUpdateImages_checkbox.
function isUpdateImages_checkbox_Callback(hObject, eventdata, handles)
% hObject    handle to isUpdateImages_checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of isUpdateImages_checkbox
state = get(hObject,'Value');
handles.isUpdateImages = state;
updatestatus(handles.main_figure,['isUpdateImages has been set to: ' num2str(state)]);
guidata(hObject, handles);


% --- Executes on button press in isPinCell_checkbox.
function isPinCell_checkbox_Callback(hObject, eventdata, handles)
% hObject    handle to isPinCell_checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of isPinCell_checkbox
state = get(hObject,'Value');
handles.isPinCell = state;
updatestatus(handles.main_figure,['isPinCell has been set to: ' num2str(state)]);

if handles.isPinCell && ~isfield(handles,'pinPos')
    updatestatus(handles.main_figure,'Pin position is not specified. Set to default.');
    handles.pinPos = [0 0 256 256];
end

guidata(hObject, handles);


% --- Executes on button press in settings_pushbutton.
function settings_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to settings_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
settings('main', handles.main_figure);


% --- Executes on selection change in acqProfiles_popupmenu.
function handles = acqProfiles_popupmenu_Callback(hObject, eventdata, handles)
% hObject    handle to acqProfiles_popupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns acqProfiles_popupmenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from acqProfiles_popupmenu
handles.iAcqProfile = get(hObject,'Value');
handles.acqConfigs = handles.acqProfileConfigs{handles.iAcqProfile};
handles.acqExpRatios = handles.acqProfileExpRatios{handles.iAcqProfile};

for iConfig=1:length(handles.acqConfigs)
	if ~ismember(handles.acqConfigs{iConfig},handles.configs)
		updatestatus(handles.main_figure,[handles.acqConfigs{iConfig} ' is not a valid config.']);
		return;
	end
end

guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function acqProfiles_popupmenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to acqProfiles_popupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function handles = storeShutterState(handles)
handles.currentShutterDevice = handles.mmc.getShutterDevice();
handles.currentShutterOpen = handles.mmc.getShutterOpen();


function resetShutterState(handles)
handles.mmc.setShutterDevice(handles.currentShutterDevice);
handles.mmc.setShutterOpen(handles.currentShutterOpen);


function setShutterUncage(handles,state)
% set the state of the UV shutter
% handles.mmc.setShutterDevice(handles.shutterUncage);
% handles.mmc.setShutterOpen(state);
if state
    handles.mmc.setConfig(handles.shutterUncage,'Open');
else
    handles.mmc.setConfig(handles.shutterUncage,'Close');
end


% --- Executes on button press in isAutoUncage_checkbox.
function isAutoUncage_checkbox_Callback(hObject, eventdata, handles)
% hObject    handle to isAutoUncage_checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of isAutoUncage_checkbox
handles.isAutoUncage = get(hObject,'Value');
updatestatus(handles.main_figure,['Auto Uncage is set to: ' num2str(handles.isAutoUncage)]);

% if handles.isAutoUncage
%     if ~handles.isAcqRunning
%         iImage = 1;
%     else
%         iImage = handles.acq.iImage;
%     end
%     handles.refFrame = iImage+handles.uncagePeriod;
%     updatestatus(handles.main_figure,['Next frame to uncage: ' num2str(handles.refFrame)]);
% end

guidata(hObject, handles);



% --- Executes on button press in saveRightImg_pushbutton.
function saveRightImg_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to saveRightImg_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if isempty(eventdata)
    prefix = handles.prefix;
else
    prefix = ['acq' num2str(handles.iBatch)];
end

outfileName =  [prefix '_' getTime_filename() '.tif'];
savedImgPath =  fullfile(handles.filedir,outfileName);

export_fig(savedImgPath,handles.right_axes);
updatestatus(handles.main_figure,['Right image has been saved to file: ' outfileName]);


% --- Executes on button press in invert_pushbutton.
function invert_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to invert_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.imgLeft = handles.maxPixelValue-handles.imgLeft;
imshow(handles.imgLeft,'Parent',handles.left_axes);
guidata(hObject, handles);


function uncagePeriod_edit_Callback(hObject, eventdata, handles)
% hObject    handle to uncagePeriod_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of uncagePeriod_edit as text
%        str2double(get(hObject,'String')) returns contents of uncagePeriod_edit as a double
str = get(hObject,'String');
if ~isempty(str)
    handles.uncagePeriod = str2double(str);
else
    set(hObject,'String',num2str(handles.uncagePeriod));
end

if ~isfield(handles,'acq')
    iImage = 1;
else
    iImage = handles.acq.iImage;
end
handles.refFrame = iImage+handles.uncagePeriod;

updatestatus(handles.main_figure,['Period has been set to: ' num2str(handles.uncagePeriod)]);
updatestatus(handles.main_figure,['Next frame to uncage: ' num2str(handles.refFrame)]);

guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function uncagePeriod_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to uncagePeriod_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in connectMM_pushbutton.
function connectMM_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to connectMM_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%%%%%% Get MM gui variable from workspace
handles.gui = evalin('base', 'handles.gui');
handles.mmc = evalin('base', 'handles.mmc');
handles.mma = evalin('base', 'handles.mma');

% Go to settings window if hardware initialization fails
handles = initHardware(handles);
if ~isempty(handles.error)
    updatestatus(handles.main_figure,'Hardware initialization failed with the following error:');
    updatestatus(handles.main_figure,handles.error.message);
    handles.closeFigure = true;
    guidata(hObject, handles);
    return;
end

handles = acqProfiles_popupmenu_Callback(handles.acqProfiles_popupmenu, [], handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
handles.timer = timer;
set(handles.timer,'ExecutionMode','fixedRate','BusyMode','drop','Period',1);
handles.timer.TimerFcn = {@runAcquisition,hObject};

handles.isConnectedMM = 1;
set(handles.connectMM_pushbutton,'String','Connected to MM','ForegroundColor',[0,0.5,0]);
set(handles.configs_popupmenu,'String',handles.configs);

guidata(hObject, handles);


% --- Executes on button press in ttl1_pushbutton.
function ttl1_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to ttl1_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.mmc.setConfig('TTL1','1');
handles.mmc.setConfig('TTL1','0');
updatestatus(handles.main_figure,'TTL1 has been triggered.');


% --- Executes on button press in addPos_pushbutton.
function stagePosArray = addPos_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to addPos_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Positions are in acquired image's orientation that has x-coord reversed
% from that of the stage

% x position read from micro-manager has opposite sign of that from the
% display
[xStage, yStage] = getStagePos(handles);

% if position is passed from another function via event data, use it
if strcmp(class(eventdata),'double') && isequal(size(eventdata),[1,2])
    newPos = eventdata;
else
    if ~isfield(handles,'selectedPos')
        newPos = [256,256];
    else
        newPos = handles.selectedPos;
    end
end

stagePosArray = [handles.stagePosArray;[xStage,yStage,newPos]];

contents = cellstr(get(handles.stagePos_popupmenu,'String'));
nContents = length(contents);
contents(end+1) = {['Pos ' num2str(nContents)]};

set(handles.stagePos_popupmenu,'Value',nContents+1);
set(handles.stagePos_popupmenu,'String',contents);

updatestatus(handles.main_figure,['Current stage at (' num2str(xStage) ',' num2str(yStage) ') and cell at (' num2str(round(newPos(1))) ',' num2str(round(newPos(2))) ') has been added.']);

% Update values
handles.stagePosArray = stagePosArray;
guidata(hObject, handles);


% --- Executes on button press in clearPos_pushbutton.
function clearPos_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to clearPos_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
contents = cellstr(get(handles.stagePos_popupmenu,'String'));
contents = contents(1);

set(handles.stagePos_popupmenu,'Value',1);
set(handles.stagePos_popupmenu,'String',contents);

handles.stagePosArray = [];

updatestatus(handles.main_figure, 'Stage position array has been cleared.');
guidata(hObject, handles);


% --- Executes on button press in pinUncagePos_pushbutton.
function pinUncagePos_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to pinUncagePos_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
updatePos(handles,'pinUncagePos');


% --- Executes on button press in isPinUncage_checkbox.
function isPinUncage_checkbox_Callback(hObject, eventdata, handles)
% hObject    handle to isPinUncage_checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of isPinUncage_checkbox
state = get(hObject,'Value');
handles.isPinUncage = state;
updatestatus(handles.main_figure,['isPinUncage has been set to: ' num2str(state)]);

if handles.isPinUncage && ~isfield(handles,'pinUncagePos')
    updatestatus(handles.main_figure,'Pin uncage position is not specified. Set to default.');
    handles.pinUncagePos = handles.pinPos;
end

guidata(hObject, handles);


% --- Executes on button press in moveToUncage_pushbutton.
function moveToUncage_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to moveToUncage_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
moveStage(handles,handles.uncagingPos(1:2));
updatestatus(handles.main_figure,['Current position: (x,y) = (' num2str(handles.uncagingPos(3:4)) ')']);

function moveStage(handles,pos)
handles.mmc.setXYPosition(handles.stage,-pos(1),pos(2));
handles.mmc.waitForDevice(handles.stage);
% pause(0.5);

function [xStage,yStage] = getStagePos(handles)
xStage = -handles.mmc.getXPosition(handles.stage);
yStage = handles.mmc.getYPosition(handles.stage);


function pinUncage
if ~isfield(handles,'pinUncagePos')
    updatestatus(handles.main_figure,'Pinned position has not been marked.');
    return;
end
if ~isfield(handles,'cellPos')
    updatestatus(handles.main_figure,'Cell position for uncaging has not been determined.');
    return;
end

% Move cell near uncaging spot
dx = (handles.cellPos(3) - handles.pinUncagePos(3))*handles.pix2um;
dy = (handles.cellPos(4) - handles.pinUncagePos(4))*handles.pix2um;
moveStageRelative(handles,dx,dy);
% handles.cellPos = handles.pinUncagePos;
% guidata(hObject, handles);
updatestatus(handles.main_figure,'Cell has been moved to uncaging pin for imaging.');

tmpimg = snapSingleImage(handles);
dispImage(tmpimg,handles);
saveImage_pushbutton_Callback(hObject, eventdata, handles);
% updatestatus(handles.main_figure,'Exposing cell to uncaging ...');
pause(handles.uncageDuration);

% Move cell back for imaging
moveStageRelative(handles,-dx,-dy);
updatestatus(handles.main_figure,'Cell has been moved out of uncaging for imaging.');


% --- Executes on button press in moveToPin_pushbutton.
function moveToPin_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to moveToPin_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if ~isfield(handles,'pinPos')
    updatestatus(handles.main_figure,'Pinned position has not been marked.');
    return;
end
if ~isfield(handles,'cellPos')
    updatestatus(handles.main_figure,'Cell position has not been determined.');
    return;
end

dx = (handles.cellPos(3) - handles.pinPos(3))*handles.pix2um;
dy = (handles.cellPos(4) - handles.pinPos(4))*handles.pix2um;
moveStageRelative(handles,dx,dy);
handles.cellPos = handles.pinPos;
guidata(hObject, handles);


% --- Executes on button press in removePos_pushbutton.
function removePos_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to removePos_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% First position is for label
iPos = get(handles.stagePos_popupmenu,'Value')-1;
contents = cellstr(get(handles.stagePos_popupmenu,'String'));

if iPos<1
    updatestatus(handles.main_figure,'Nothing to remove.');
    return;
end

if isempty(handles.stagePosArray) || size(handles.stagePosArray,1)<iPos
    updatestatus(handles.main_figure,'Position array is smaller than specified in the popup menu.');
    return;
end

posCurrent = handles.stagePosArray(iPos,:);

handles.stagePosArray(iPos,:) = [];
if size(handles.stagePosArray,1)<iPos
    iPos = size(handles.stagePosArray,1);
end
contents(end) = [];

set(handles.stagePos_popupmenu,'Value',iPos+1);
set(handles.stagePos_popupmenu,'String',contents);

updatestatus(handles.main_figure,['Position #' num2str(iPos) ' at (' num2str(posCurrent(1)) ',' num2str(posCurrent(2)) ') has been removed.']);
guidata(hObject, handles);


% --- Executes on selection change in stagePos_popupmenu.
function stagePos_popupmenu_Callback(hObject, eventdata, handles)
% hObject    handle to stagePos_popupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns stagePos_popupmenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from stagePos_popupmenu
% First position is the label
iPos = get(handles.stagePos_popupmenu,'Value')-1;
if iPos<1
    return;
end

posCurrent = handles.stagePosArray(iPos,:);
updatestatus(handles.main_figure,['Current position: (x,y) = (' num2str(posCurrent(1)) ',' num2str(posCurrent(2)) ')']);

guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function stagePos_popupmenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to stagePos_popupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in test_pushbutton.
function test_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to test_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Load scalar variables
% Load vector variables
% delete(gcf);

% --- Executes on selection change in yLabel_popupmenu.
function yLabel_popupmenu_Callback(hObject, eventdata, handles)
% hObject    handle to yLabel_popupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns yLabel_popupmenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from yLabel_popupmenu
handles.yLabels = cellstr(get(hObject,'String'));
handles.iYLabel = get(hObject,'Value');
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function yLabel_popupmenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to yLabel_popupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function plotOptions_edit_Callback(hObject, eventdata, handles)
% hObject    handle to plotOptions_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of plotOptions_edit as text
%        str2double(get(hObject,'String')) returns contents of plotOptions_edit as a double
handles.plotOptions = get(hObject,'String');
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function plotOptions_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to plotOptions_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in plotTracks_pushbutton.
function plotTracks_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to plotTracks_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

colFrame = 1;
numColors = length(handles.acq.colors);

cla(handles.right_axes,'reset');
hold(handles.right_axes,'on');
for iStage=1:handles.acq.numStagePos
    if isempty(handles.acq.results{iStage})
        xData = [];
        yData = [];
    else
        xData = handles.acq.results{iStage}(:,colFrame)*handles.acq.interval/60; % time in minute
        yData = handles.acq.results{iStage}(:,handles.iYLabel);
    end
    color = handles.acq.colors(mod(iStage-1,numColors)+1,:);
    plot(handles.right_axes,xData,yData,handles.plotOptions,'Color',color,'LineWidth',0.7,'MarkerSize',2);
end
hold(handles.right_axes,'off');


% --- Executes on button press in moveToPos_pushbutton.
function moveToPos_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to moveToPos_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if isempty(handles.stagePosArray)
    updatestatus(handles.main_figure,'Position array is empty.');
    return;
end
% First position is the label
iPos = get(handles.stagePos_popupmenu,'Value')-1;
if iPos<1
    return;
end

posCurrent = handles.stagePosArray(iPos,:);
moveStage(handles,posCurrent(1:2));

updatestatus(handles.main_figure,['Current position: (x,y) = (' num2str(posCurrent(1)) ',' num2str(posCurrent(2)) ')']);


% --- Executes on button press in showPos_togglebutton.
function showPos_togglebutton_Callback(hObject, eventdata, handles)
% hObject    handle to showPos_togglebutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of showPos_togglebutton
state = get(hObject,'Value');
if state
    set(hObject,'String','Show');
else
    set(hObject,'String','Mark');
end


% --- Executes on button press in isPreRelease_checkbox.
function isPreRelease_checkbox_Callback(hObject, eventdata, handles)
% hObject    handle to isPreRelease_checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of isPreRelease_checkbox
state = get(hObject,'Value');
handles.isPreRelease = state;
updatestatus(handles.main_figure,['Pre-release has been set to: ' num2str(state)]);
guidata(hObject, handles);


% --- Executes on button press in isMultiPos_checkbox.
function isMultiPos_checkbox_Callback(hObject, eventdata, handles)
% hObject    handle to isMultiPos_checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of isMultiPos_checkbox
state = get(hObject,'Value');
handles.isMultiPos = state;
updatestatus(handles.main_figure,['Multi Position has been set to: ' num2str(state)]);
guidata(hObject, handles);


function imgOrder_edit_Callback(hObject, eventdata, handles)
% hObject    handle to imgOrder_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of imgOrder_edit as text
%        str2double(get(hObject,'String')) returns contents of imgOrder_edit as a double
str = get(hObject,'String');
handles.imgOrder = str;
updatestatus(handles.main_figure,['imgOrder is set to: ' str]);
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function imgOrder_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to imgOrder_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in isImgAll_checkbox.
function isImgAll_checkbox_Callback(hObject, eventdata, handles)
% hObject    handle to isImgAll_checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of isImgAll_checkbox
state = get(hObject,'Value');
handles.isImgAll = state;
updatestatus(handles.main_figure,['isImgAll has been set to: ' num2str(state)]);
guidata(hObject, handles);


function refFrame_edit_Callback(hObject, eventdata, handles)
% hObject    handle to refFrame_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of refFrame_edit as text
%        str2double(get(hObject,'String')) returns contents of refFrame_edit as a double
str = get(hObject,'String');
if isempty(str)
    set(hObject,'String',num2str(handles.refFrame));
    return;
else
    handles.refFrame = str2double(str);
end

updatestatus(handles.main_figure,['refFrame has been set to: ' str]);
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function refFrame_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to refFrame_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in createGrid_pushbutton.
function createGrid_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to createGrid_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if ~isfield(handles,'stagePosTopLeft')||~isfield(handles,'stagePosTopLeft')
    updatestatus(handles.main_figure,'Top-left and bottom-right positions need to be specified.');
    return;
end
handles.stagePosTopLeft

% get the coordinates of the first 2 positions
x1 = handles.stagePosTopLeft(1);
y1 = handles.stagePosTopLeft(2);
x2 = handles.stagePosBottomRight(1);
y2 = handles.stagePosBottomRight(2);
dx = handles.imWidth*handles.pix2um;
dy = handles.imHeight*handles.pix2um;
defaultPos = [256,256];

numGridX = ceil((x2-x1)/dx)+1;
numGridY = ceil((y2-y1)/dy)+1;

% create array of positions and save to handles
contents = cellstr(get(handles.stagePos_popupmenu,'String'));
contents = contents(1);

handles.stagePosArray = [];
for iY=1:numGridY
    for iX = 1:numGridX
        posNew = [x1+(iX-1)*dx, y1+(iY-1)*dy, defaultPos];
        handles.stagePosArray = [handles.stagePosArray;posNew];
        contents(end+1) = {['Pos ' num2str(iY) '-' num2str(iX)]};
    end
end

nContents = length(contents);
set(handles.stagePos_popupmenu,'Value',nContents);
set(handles.stagePos_popupmenu,'String',contents);

updatestatus(handles.main_figure,['Grid of size ' num2str(numGridX) ' x ' num2str(numGridY) ' with step size ' num2str(dx) ' x ' num2str(dy) ' has been created at position (' num2str(x1) ',' num2str(y1) ').']);

% Update values
guidata(hObject, handles);


function uncageIntervalBetweenPos_edit_Callback(hObject, eventdata, handles)
% hObject    handle to uncageIntervalBetweenPos_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of uncageIntervalBetweenPos_edit as text
%        str2double(get(hObject,'String')) returns contents of uncageIntervalBetweenPos_edit as a double
str = get(hObject,'String');
if isempty(str)
    set(hObject,'String',num2str(handles.uncageIntervalBetweenPos));
    return;
else
    handles.uncageIntervalBetweenPos = str2double(str);
end

updatestatus(handles.main_figure,['uncageIntervalBetweenPos has been set to: ' str]);
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function uncageIntervalBetweenPos_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to uncageIntervalBetweenPos_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function imgIntervalBetweenPos_edit_Callback(hObject, eventdata, handles)
% hObject    handle to imgIntervalBetweenPos_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of imgIntervalBetweenPos_edit as text
%        str2double(get(hObject,'String')) returns contents of imgIntervalBetweenPos_edit as a double
str = get(hObject,'String');
if isempty(str)
    set(hObject,'String',num2str(handles.imgIntervalBetweenPos));
    return;
else
    handles.imgIntervalBetweenPos = str2double(str);
end

updatestatus(handles.main_figure,['imgIntervalBetweenPos has been set to: ' str]);
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function imgIntervalBetweenPos_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to imgIntervalBetweenPos_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in updatePos_pushbutton.
function updatePos_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to updatePos_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if ~isfield(handles,'acq') || ~isfield(handles.acq,'stagePosArray') || isempty(handles.acq.stagePosArray)
    updatestatus(handles.main_figure,'No acquisition stage positions is found.');
    return;
end

handles.stagePosArray = handles.acq.stagePosArray;
contents = arrayfun(@(x) ['Pos' num2str(x)],1:size(handles.stagePosArray,1),'UniformOutput',false)
contents = [{'Position'} contents];
set(handles.stagePos_popupmenu,'Value',1);
set(handles.stagePos_popupmenu,'String',contents);
updatestatus(handles.main_figure,['stagePosArray has been updated.']);
guidata(hObject, handles);


% --- Executes on button press in isMonitorUncage_checkbox.
function isMonitorUncage_checkbox_Callback(hObject, eventdata, handles)
% hObject    handle to isMonitorUncage_checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of isMonitorUncage_checkbox
state = get(hObject,'Value');
handles.isMonitorUncage = state;
updatestatus(handles.main_figure,['isMonitorUncage has been set to: ' num2str(state)]);
guidata(hObject, handles);



function numFramesUncage_edit_Callback(hObject, eventdata, handles)
% hObject    handle to numFramesUncage_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of numFramesUncage_edit as text
%        str2double(get(hObject,'String')) returns contents of numFramesUncage_edit as a double
str = get(hObject,'String');
if isempty(str)
    set(hObject,'String',num2str(handles.numFramesUncage));
    return;
else
    handles.numFramesUncage= str2double(str);
end

updatestatus(handles.main_figure,['numFramesUncage has been set to: ' str]);
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function numFramesUncage_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to numFramesUncage_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function iConfigToDisplay_edit_Callback(hObject, eventdata, handles)
% hObject    handle to iConfigToDisplay_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of iConfigToDisplay_edit as text
%        str2double(get(hObject,'String')) returns contents of iConfigToDisplay_edit as a double
num = str2double(get(hObject,'String'));
if ~mod(num,1)==0 || num > length(handles.acqConfigs) || num <1
    set(hObject,'String',num2str(handles.iConfigToDisplay));
    return;
else
    handles.iConfigToDisplay = num;
end

updatestatus(handles.main_figure,['iConfigToDisplay has been set to: ' num2str(num)]);
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function iConfigToDisplay_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to iConfigToDisplay_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function gridRows_edit_Callback(hObject, eventdata, handles)
% hObject    handle to gridRows_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of gridRows_edit as text
%        str2double(get(hObject,'String')) returns contents of gridRows_edit as a double


% --- Executes during object creation, after setting all properties.
function gridRows_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to gridRows_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function gridCols_edit_Callback(hObject, eventdata, handles)
% hObject    handle to gridCols_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of gridCols_edit as text
%        str2double(get(hObject,'String')) returns contents of gridCols_edit as a double


% --- Executes during object creation, after setting all properties.
function gridCols_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to gridCols_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in markTopLeft_pushbutton.
function markTopLeft_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to markTopLeft_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[x,y] = getStagePos(handles);
handles.stagePosTopLeft = [x,y];
updatestatus(handles.main_figure,[num2str(x) ' ' num2str(y)]);
guidata(hObject, handles);

% --- Executes on button press in markBottomRight_pushbutton.
function markBottomRight_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to markBottomRight_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[x,y] = getStagePos(handles);
handles.stagePosBottomRight = [x,y];
updatestatus(handles.main_figure,[num2str(x) ' ' num2str(y)]);
guidata(hObject, handles);


% --- Executes on button press in laserCut_pushbutton.
function laserCut_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to laserCut_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Expose sample to UV laser while moving the sample through positions
% specified by stagePosArray. The transit time between positions is
% specified by uncageDuration
if ~isfield(handles,'uncagingPos')
    updatestatus(handles.main_figure,'Uncaging position has not been marked.');
    return;
end
disp(handles.stagePosArray)
disp(length(handles.stagePosArray))

posInit = handles.stagePosArray(1,:);
dx = (posInit(3) - handles.uncagingPos(3))*handles.pix2um;
dy = (posInit(4) - handles.uncagingPos(4))*handles.pix2um;
moveStageRelative(handles,dx,dy);
pause(0.5)

handles.mmc.setConfig(handles.configGroup,'Blocked');
handles.mmc.waitForConfig(handles.configGroup,'Blocked');
handles.mmc.setConfig(handles.shutterUncage,'Open');

% stagePosArray has empty row as the last item
for iPos=1:length(handles.stagePosArray)-2
    pos1 = handles.stagePosArray(iPos,:);
    pos2 = handles.stagePosArray(iPos+1,:);
    dx = (pos2(3) - pos1(3))*handles.pix2um;
    dy = (pos2(4) - pos1(4))*handles.pix2um;
    moveStageRelative(handles,dx,dy);

    hold(handles.left_axes,'on');
    plot(handles.left_axes,[pos1(3),pos2(3)],[pos1(4),pos2(4)],'r');
    hold(handles.left_axes,'off');
    pause(1)
end
handles.mmc.setConfig(handles.shutterUncage,'Close');
moveStage(handles,posInit(1:2));

updatestatus(handles.main_figure,'Laser cutting is finished.');


function periodExtraStimuli_edit_Callback(hObject, eventdata, handles)
% hObject    handle to periodExtraStimuli_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of periodExtraStimuli_edit as text
%        str2double(get(hObject,'String')) returns contents of periodExtraStimuli_edit as a double
edit_number(hObject, handles, 'periodExtraStimuli','double')


% --- Executes during object creation, after setting all properties.
function periodExtraStimuli_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to periodExtraStimuli_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function numExtraStimuli_edit_Callback(hObject, eventdata, handles)
% hObject    handle to numExtraStimuli_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of numExtraStimuli_edit as text
%        str2double(get(hObject,'String')) returns contents of numExtraStimuli_edit as a double
edit_number(hObject, handles, 'numExtraStimuli','int')


% --- Executes during object creation, after setting all properties.
function numExtraStimuli_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to numExtraStimuli_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function durationExtraStimuli_edit_Callback(hObject, eventdata, handles)
% hObject    handle to durationExtraStimuli_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of durationExtraStimuli_edit as text
%        str2double(get(hObject,'String')) returns contents of durationExtraStimuli_edit as a double
edit_number(hObject, handles, 'durationExtraStimuli','double')


% --- Executes during object creation, after setting all properties.
function durationExtraStimuli_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to durationExtraStimuli_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
