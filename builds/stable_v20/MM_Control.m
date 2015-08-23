% Author: Duong "Zoom" Nguyen
% Email: duongnh "at" gmail "dot" com
% version 2.0
% date: Feb 18, 2014

function varargout = MM_Control(varargin)
% MM_CONTROL MATLAB code for MM_Control.fig
%      MM_CONTROL, by itself, creates a new MM_CONTROL or raises the existing
%      singleton*.
%
%      H = MM_CONTROL returns the handle to a new MM_CONTROL or the handle to
%      the existing singleton*.
%
%      MM_CONTROL('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MM_CONTROL.M with the given input arguments.
%
%      MM_CONTROL('Property','Value',...) creates a new MM_CONTROL or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before MM_Control_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to MM_Control_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help MM_Control

% Last Modified by GUIDE v2.5 14-Feb-2014 14:51:18

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @MM_Control_OpeningFcn, ...
                   'gui_OutputFcn',  @MM_Control_OutputFcn, ...
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


% --- Executes just before MM_Control is made visible.
function MM_Control_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to MM_Control (see VARARGIN)

libdir = fullfile(pwd,'lib');
if exist(libdir,'dir')
    addpath(genpath(libdir));
end

% Choose default command line output for MM_Control
handles.output = hObject;

%%%%% Initialize variables
handles = setDefaultValues(handles);
%Only to bootstrap guiVars
%guiVars = struct;

if exist(handles.varsFileName ,'file')
    load(handles.varsFileName ,'guiVars');
end
for i=1:length(handles.savedVars)
    var = handles.savedVars{i};
    if isfield(guiVars,var)
        handles.(var) = guiVars.(var);
        guiName = handles.guiName{i};
        if ~isempty(guiName)
            set(handles.(guiName),handles.guiType{i},handles.(var));
        end
    end
end

posStr = ['(' num2str(round(handles.uncagingPos(1))) ',' num2str(round(handles.uncagingPos(2))) ')'];
set(handles.uncagingPos_text,'String',posStr);

% Initialize log
setappdata(handles.main_figure,'log',cell(0));

defaultBackground = get(0,'defaultUicontrolBackgroundColor');
set(handles.main_figure,'Color',defaultBackground);

% Update handles structure
updatestatus(handles.main_figure,'Welcome!');
guidata(hObject, handles);

% UIWAIT makes MM_Control wait for user response (see UIRESUME)
% uiwait(handles.main_figure);


function handles = setDefaultValues(handles)
handles.varsFileName = 'gui_vars.mat';

handles.configGroup = 'Channel';
handles.filedir = '';
handles.prefix = 'image';

handles.numImages = 1;
handles.interval = 1;
handles.pix2um = 1;

handles.isTrackCell = false;
handles.isAutoContrast = false;
handles.isLog = false;
handles.isAcqMultiPos = false;
handles.isUpdateImages = true;
handles.isAutoUncage = false;
handles.isAcqRunning = false;

handles.limitMargin = 100;
handles.limitTop = 14900;
handles.limitBottom = -14900;
handles.limitLeft = -9900;
handles.limitRight = 8900;

handles.stagePosArray = [];
handles.maxPixelValue = 65535;
handles.shutterUncage = 'ShutterUV';
% handles.shutterUncage = 'ShutterFL';

handles.acqProfiles = {'GFP','Transmission','TransWithOpenedFL','2-channel FRET','3-channel FRET','3-channel FRET + TR','2-channel FRET2 + RFP + TR','2-channel FRET2 + TR','2-channel FRET2','3-channel FRET2','3-channel FRET2 + TR'};
set(handles.acqProfiles_popupmenu,'String',handles.acqProfiles);
handles.iAcqProfile = 1;

handles.acqProfileConfigs = {...
    {'GFP'},...
    {'Transmission'},...
    {'TransWithOpenedFL'},...
    {'CFP-YFP','CFP-CFP'},...
    {'CFP-YFP','CFP-CFP','YFP-YFP'},...
    {'CFP-YFP','CFP-CFP','YFP-YFP','Transmission'},...
    {'CFP2-YFP','CFP2-CFP','RFP','Transmission'},...
    {'CFP2-YFP','CFP2-CFP','Transmission'},...
    {'CFP2-YFP','CFP2-CFP'},...
    {'CFP2-YFP','CFP2-CFP','YFP-YFP'},...
    {'CFP2-YFP','CFP2-CFP','YFP-YFP','Transmission'}
    }

handles.uncagingPos = [0 0];
handles.configUncage = 'Uncaging';

% Variables to save to a file so that they are loaded at the next startup
handles.savedVars = {'filedir' 'prefix' 'numImages' 'interval' 'pix2um' ...
    'exposure' 'uncagingExposure' 'autoUncageNumTotal' 'autoUncageNumOpened' ...
    'isTrackCell' 'isAutoContrast' 'isLog' 'isAutoSaveTrack' 'isAutoShutter' ...
    'isUpdateImages' 'isPinCell' 'iAcqProfile' 'isAutoUncage' 'isExposeCam' ...
    'isLaserUncage' 'isAcqMultiPos' 'isPinUncage' ...
    'limitMargin' 'limitTop' 'limitBottom' 'limitLeft' 'limitRight' ...
    'uncagingPos' 'configGroup' 'pinUncagePos' ...
    };
handles.guiName = {'filedir_edit' 'prefix_edit' 'numImages_edit' 'interval_edit' 'pix2um_edit' ...
    'exposure_edit' 'uncagingExposure_edit' 'autoUncageNumTotal_edit' 'autoUncageNumOpened_edit' ...
    'isTrackCell_checkbox' 'isAutoContrast_checkbox' 'isLog_checkbox' 'isAutoSaveTrack_checkbox' 'isAutoShutter_checkbox' ...
    'isUpdateImages_checkbox' 'isPinCell_checkbox' 'acqProfiles_popupmenu' 'isAutoUncage_checkbox' 'isExposeCam_checkbox' ...
    'isLaserUncage_checkbox' 'isAcqMultiPos_checkbox' 'isPinUncage_checkbox' ...
    '' '' '' '' '' ...
    '' '' '' ...
    };
handles.guiType = {'String' 'String' 'String' 'String' 'String' ...
    'String' 'String' 'String' 'String' ...
    'Value' 'Value' 'Value' 'Value' 'Value' ...
    'Value' 'Value' 'Value' 'Value' 'Value' ...
    'Value' 'Value' 'Value' ...
    '' '' '' '' '' ...
    '' '' '' ...
    };


% --- Outputs from this function are returned to the command line.
function varargout = MM_Control_OutputFcn(hObject, eventdata, handles) 
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

disp(handles.configGroup)

% save gui variables
guiVars = struct;
for i=1:length(handles.savedVars)
    var = handles.savedVars{i};
    if isfield(handles,var)
        guiVars.(var) = handles.(var);
    end
end
save(handles.varsFileName,'guiVars');

% delete timer
if isfield(handles,'acq') && isfield(handles.acq,'timer')
    if strcmp(get(handles.acq.timer, 'Running'), 'on')
        stopTimer(handles);
    end
    delete(handles.acq.timer);
end

updatestatus(handles.main_figure,'Goodbye!');

% save log
if handles.isLog
    if ~exist(handles.filedir,'dir')
        filedir = '';
        updatestatus(handles.main_figure,'Directory does not exist. Log is saved to the program directory.');
    else
        filedir = handles.filedir;
    end

    log = getappdata(handles.main_figure,'log');
    logFilePath = fullfile(filedir,'MMControl.log');

    updatestatus(handles.main_figure,['Current log is being saved to: ' logFilePath]);
    fid = fopen(logFilePath,'wt');
    fprintf(fid, '%s\n', log{:});
    fclose(fid);
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


% --- Executes during object creation, after setting all properties.
function pattern_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pattern_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function current_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to current_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function prefix_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to prefix_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


%%%%%%%%%%%%%%%%%%%%%%% Begin user-defined functions
%%%%%%%%%%%%%%%%%%%%%%% End user-defined functions


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
handles.acq.iBatch = 0;

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


function handles = loadCurrentImage(currentFilePath,handles)
% Read and display image from currentFilePath\

handles.status = '';

try
   imgTemp = imread(currentFilePath);
catch exception
    handles.status = ['Error reading image from file' currentFilePath];
    return;
end

if handles.isAutoContrast
    handles.imgLeft = autocontrast(imgTemp,handles.fileInfo.BitsPerSample);
else
    handles.imgLeft = imgTemp;
end
    
%axes(handles.left_axes);
dispImage(handles.imgLeft,handles);


function prefix_edit_Callback(hObject, eventdata, handles)
% hObject    handle to prefix_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of prefix_edit as text
%        str2double(get(hObject,'String')) returns contents of prefix_edit as a double
handles.prefix = get(hObject,'String');
guidata(hObject, handles);


% --- Executes on button press in isAutoContrast_checkbox.
function isAutoContrast_checkbox_Callback(hObject, eventdata, handles)
% hObject    handle to isAutoContrast_checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of isAutoContrast_checkbox
handles.isAutoContrast = get(hObject,'Value');
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
      distanceum = sqrt((xpos-handles.uncagingPos(1))^2+(ypos-handles.uncagingPos(2))^2)*handles.pix2um;
      updatestatus(handles.main_figure,['Selected position: (x,y) = (' num2str(xpos) ',' num2str(ypos) '), ' num2str(round(distanceum)) ' um from uncaging spot.']);
  case 'extend' % Shift - click left mouse button or click both left and right mouse buttons.
      % find nearest cell near mouse click and toggle the selection
  case 'open'   % Double-click any mouse button.
end
guidata(hObject, handles);


% --- Executes on button press in markUncaging_pushbutton.
function markUncaging_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to markUncaging_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if ~isfield(handles,'selectedPos')
    updatestatus(handles.main_figure,'No position has been selected.');
    return;
end

handles.uncagingPos = handles.selectedPos;
xpos = round(handles.uncagingPos(1));
ypos = round(handles.uncagingPos(2));

posStr = ['(' num2str(xpos) ',' num2str(ypos) ')'];
set(handles.uncagingPos_text,'String',posStr);

showUncaging_pushbutton_Callback(hObject, eventdata, handles);

updatestatus(handles.main_figure,['Uncaging position: (x,y) = ' posStr '.']);
guidata(hObject, handles);


function selectedSpot = findNearbySpot(handles)
if ~isfield(handles,'imgLeft')
    updatestatus(handles.main_figure,'No image has been loaded to the left axes.');
    return;
end

input.image = handles.imgLeft;
output = findSpots(input);

spots = output.tracks;
masks = output.masks;

numSpots = length(spots);
if (numSpots ==0) || (numSpots ==1 && isempty(spots(1).x))
    updatestatus(handles.main_figure,'No spot has been detected.');
    return;
end

allPos = [spots(:).x;spots(:).y]';
index = nearest(allPos,handles.selectedPos);

selectedSpot = spots(index);
selectedPos = allPos(index,:);
posStr = ['(' num2str(round(selectedPos(1))) ',' num2str(round(selectedPos(2))) ')'];

if handles.isUpdateImages
    handles.imgRight = handles.imgLeft;
    allMasks = zeros(size(handles.imgRight));
    for i=1:length(masks)
        allMasks = allMasks|masks{i};
    end
    handles.imgRight(allMasks) = 65535;

    imshow(handles.imgRight,'Parent',handles.right_axes);
    hold(handles.right_axes,'on');
    plot(handles.right_axes,allPos(:,1),allPos(:,2),'r+');
    plot(handles.right_axes,selectedPos(1),selectedPos(2),'g+');
    hold(handles.right_axes,'off');
end

updatestatus(handles.main_figure,['Spot number ' num2str(index) ' at position ' posStr ' has been selected.']);


% --- Executes on button press in findspot_pushbutton.
function handles = findspot_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to findspot_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
selectedSpot = findNearbySpot(handles);
handles.selectedPos = [selectedSpot.x,selectedSpot.y];
guidata(hObject, handles);


function acqImages = snapImagesAllConfigs(handles)
% Snap images for each config
acqImages = cell(1,handles.acq.numConfigs);
for i=1:handles.acq.numConfigs
    handles.mmc.setConfig(handles.configGroup,handles.acqConfigs{i});
    handles.mmc.waitForConfig(handles.configGroup,handles.acqConfigs{i});
%     pause(.5);
    handles.mmc.setExposure(handles.acqExposure(i));
    acqImages{i} = snapSingleImage(handles);
    updatestatus(handles.main_figure,['Taking image with config: ' handles.acqConfigs{i}]);
end
handles.mmc.setConfig(handles.configGroup,handles.acqConfigs{1});


function saveImagesAllConfigs(handles,images,outfileDir)
% Save images into folder and pattern given by prefix with config names specified in filenames
for i=1:handles.acq.numConfigs
    outfilePath = fullfile(outfileDir,['img_' num2str(handles.acq.iImage,'%09d') '_' handles.acqConfigs{i} '_000.tif']);
    imwrite(images{i},outfilePath);
end


function runAcquisition(hObject,eventdata,hfigure)
% Run one acquisition when timer fires
handles = guidata(hfigure);

if handles.acq.iImage>handles.numImages
    stopTimer(handles);
    updatestatus(handles.main_figure,'Acquisition has finished');
    return;
end

% Check if acq process will auto uncage in the last frame or this frame
isAutoUncageLastFrame = handles.isAutoUncage && mod(handles.acq.iImage-2,handles.autoUncageNumTotal)<handles.autoUncageNumOpened;
isAutoUncageThisFrame = handles.isAutoUncage && mod(handles.acq.iImage-1,handles.autoUncageNumTotal)<handles.autoUncageNumOpened;

if isAutoUncageLastFrame
    handles.mmc.setConfig(handles.shutterUncage,'Close');
end

if handles.acq.isAcqMultiPos
    tmpimgs = {};
    for i=1:handles.acq.numStagePos
        posCurrent = handles.stagePosArray(i,:);
        handles.mmc.setXYPosition(handles.stage,-posCurrent(1),posCurrent(2));
        snappedImages = snapImagesAllConfigs(handles);
        dispImage(snappedImages{handles.acq.iConfigToDisplay},handles);
        tmpimgs = [tmpimgs;snappedImages];
        pause(0.5);
    end
else
    tmpimgs = snapImagesAllConfigs(handles);
    dispImage(tmpimgs{1,handles.acq.iConfigToDisplay},handles);
end
handles.imgLeft = tmpimgs{1,handles.acq.iConfigToDisplay};
% dispImage(handles.imgLeft,handles);

if isAutoUncageThisFrame
    ttl1_pushbutton_Callback(hObject, eventdata, handles);
end

if handles.acq.numConfigs==4
    % Display transmission image on the right
    handles.imgRight = tmpimgs{1,handles.acq.numConfigs};
    dispImageRight(handles.imgRight,handles);
end

if handles.acq.isAcqMultiPos
    for i=1:handles.acq.numStagePos
        saveImagesAllConfigs(handles,{tmpimgs{i,:}},handles.acq.outfileDirArray{i});
    end
else
    saveImagesAllConfigs(handles,tmpimgs,handles.acq.outfileDir);
end

if handles.acq.isTrackCell
    inVars = struct;
    inVars.isPassImages = true;
    
    if length(handles.acq.acqConfigs)==1
        inVars.imYFP = tmpimgs{1};
        inVars.imCFP = tmpimgs{1};
        inVars.imYYFP = tmpimgs{1};
    elseif length(handles.acq.acqConfigs)==2
        inVars.imYFP = tmpimgs{1};
        inVars.imCFP = tmpimgs{2};
        inVars.imYYFP = tmpimgs{1};
    else
        inVars.imYFP = tmpimgs{1};
        inVars.imCFP = tmpimgs{2};
        inVars.imYYFP = tmpimgs{3};
    end
    
%     outVars = getFRET(inVars);
    outVars = getFRETZ(inVars);
    spots = outVars.tracks;

    allPos = [spots(:).x;spots(:).y]';
    index = nearest(allPos,handles.cellPos);

    handles.selectedPos = allPos(index,:);
    spot = spots(index);

    % Stage's y-axis convention is opposite that in Matlab image
    % Image is flipped horizonally, so x-axis is also opposite to that of
    % real space
    
    newLine = [];
    if handles.isPinCell
        dx = (handles.selectedPos(1) - handles.pinnedPos(1))*handles.acq.pix2um;
        dy = (handles.selectedPos(2) - handles.pinnedPos(2))*handles.acq.pix2um;
        moveStageRelative(handles,dx,dy);
        handles.cellPos = handles.pinnedPos;
    else
        handles.cellPos = handles.selectedPos;
    end
    
    newLine = [handles.acq.iImage handles.acq.interval]; % col 1
    newLine = [newLine handles.selectedPos(1)*handles.acq.pix2um handles.selectedPos(2)*handles.acq.pix2um]; % col 3
    newLine = [newLine spot.yfp spot.cfp spot.ratio spot.rawy spot.rawc spot.rawr]; % col 5
    newLine = [newLine spot.area spot.round]; %col 11
    newLine = [newLine handles.selectedPos(1) handles.selectedPos(2)]; % col 13
    newLine = [newLine handles.acq.pix2um]; % col 15
    if handles.isPinCell
        newLine = [newLine handles.pinnedPos(1) handles.pinnedPos(2)]; % col 16
        newLine = [newLine dx dy]; % col 18
    else
        newLine = [newLine -1 -1]; % col 16
        newLine = [newLine 0 0]; % col 18
    end
    
    handles.acq.track = [handles.acq.track;newLine];
    % plot FRET ratio
    plot(handles.right_axes,handles.acq.track(:,7));
end

updatestatus(handles.main_figure,['Frame ' num2str(handles.acq.iImage) '/' num2str(handles.numImages) ' has been acquired.']);
handles.acq.iImage = handles.acq.iImage+1;

guidata(hfigure, handles);


% --- Executes on button press in acquire_pushbutton.
function acquire_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to acquire_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Check if acquisition status
if strcmp(get(handles.acq.timer, 'Running'), 'on')
    stopTimer(handles);
    updatestatus(handles.main_figure,'Acquisition is stopped by user');
    handles.isAcqRunning = false;
    guidata(hObject, handles);
    return;
end

if handles.isAcqRunning
    updatestatus(handles.main_figure,'Acquisition has been stopped unexpectedly');

    saveRightImg_pushbutton_Callback(NaN, NaN, handles);
    if handles.isAutoSaveTrack && handles.isTrackCell
        savetrack_pushbutton_Callback(NaN, NaN, handles);
    end
end
    
handles.isAcqRunning = true;

% Run acquisition session
handles.acq.iBatch = handles.acq.iBatch+1;

% Stop if status contains error
updatestatus(handles.main_figure,handles.status);
if ~isempty(handles.status)
    return;
end

% Parameters that cannot be changed by user during acquisition
handles.acq.iImage = 1;
handles.acq.interval = handles.interval;
handles.acq.pix2um = handles.pix2um;
handles.acq.acqConfigs = handles.acqConfigs;
handles.acq.numConfigs = length(handles.acq.acqConfigs);
handles.acqExposure = ones(1,handles.acq.numConfigs)*handles.exposure;
% handles.acqExposure(3) = 10;

handles.acq.outfileDir = [handles.filedir strtrim(handles.prefix) '_' num2str(handles.acq.iBatch) '/'];
if ~exist(handles.acq.outfileDir,'dir')
    mkdir(handles.acq.outfileDir);
end
updatestatus(handles.main_figure,['Acquired images are to be saved in folder: ' handles.acq.outfileDir]);

if handles.isAcqMultiPos && size(handles.stagePosArray,1)<1
    handles.isAcqMultiPos = false;
    set(handles.isAcqMultiPos_checkbox,'Value',false);
end
handles.acq.isAcqMultiPos = handles.isAcqMultiPos;

if handles.acq.isAcqMultiPos
    handles.acq.stagePosArray = handles.stagePosArray;
    handles.acq.numStagePos = size(handles.acq.stagePosArray,1);
    handles.acq.outfileDirArray = {};
    for i = 1:handles.acq.numStagePos
        outfileDir = [handles.acq.outfileDir 'Pos_' num2str(i)];
        if ~exist(outfileDir,'dir')
            mkdir(outfileDir);
        end
        handles.acq.outfileDirArray{i} = outfileDir;
        updatestatus(handles.main_figure,['Multi-position images are to be saved in folder: ' outfileDir]);
    end
end

% disable some acquisition options the beginning
if handles.isAutoUncage 
    handles.isAutoUncage = 0;
    set(handles.isAutoUncage_checkbox,'Value',0);
end

if handles.isTrackCell && ~isfield(handles,'cellPos')
    updatestatus(handles.main_figure,'Initial cell position is not specified. Track cell option is disabled.');
    handles.isTrackCell = 0;
    set(handles.isTrackCell_checkbox,'Value',0);
end

if handles.isPinCell && ~isfield(handles,'pinnedPos')
    updatestatus(handles.main_figure,'Pin position is not specified. Set to default.');
    handles.pinnedPos = [256 256];
end

if handles.isPinUncage && ~isfield(handles,'pinUncagePos')
    updatestatus(handles.main_figure,'Pin uncage position is not specified. Set to default.');
    handles.pinUncagePos = [256 256];
end

% track cell during acquisition
handles.acq.isTrackCell = handles.isTrackCell;
if handles.acq.isTrackCell
    % initialize track
    handles.acq.track = [];
    
    handles.trackHeader = sprintf('frame\tinterval');
    handles.trackHeader = [handles.trackHeader sprintf('\tcellposxum\tcellposyum')]; 
    handles.trackHeader = [handles.trackHeader sprintf('\tyfp\tcfp\tratio\trawy\trawc\trawr')]; 
    handles.trackHeader = [handles.trackHeader sprintf('\tarea\tround')]; 
    handles.trackHeader = [handles.trackHeader sprintf('\tcellposx\tcellposy')]; 
    handles.trackHeader = [handles.trackHeader sprintf('\tpix2um')]; 
    handles.trackHeader = [handles.trackHeader sprintf('\tpinnedposx\tpinnedposy')]; 
    handles.trackHeader = [handles.trackHeader sprintf('\tdxum\tdyum')]; 
end

set(handles.acquire_pushbutton,'String','Click to stop...','ForegroundColor',[0,0.5,0]);

set(handles.acq.timer,'Period',handles.acq.interval);
set(handles.acq.timer,'StartDelay',0.05);

guidata(hObject, handles);

% Start timer after guidata so that new values in handles are updated
start(handles.acq.timer);


function stopTimer(handles)
% Clean up when timer is stopped

stop(handles.acq.timer);

if handles.isAutoUncage
    handles.mmc.setConfig(handles.shutterUncage,'Close');
end

saveRightImg_pushbutton_Callback(NaN, NaN, handles);

if handles.isAutoSaveTrack && handles.isTrackCell
    savetrack_pushbutton_Callback(NaN, NaN, handles);
end

set(handles.acquire_pushbutton,'String','Acquire','ForegroundColor',[0,0,0]);


function dispImage(img,handles)
% display image on the axes
if handles.isAutoContrast
    img = autocontrast(img,handles.bitDepth);
end

if handles.isUpdateImages
    imshow(img,'Parent',handles.left_axes);
end

function dispImageRight(img,handles)
% display image on the axes
if handles.isAutoContrast
    img = autocontrast(img,handles.bitDepth);
end

if handles.isUpdateImages
    imshow(img,'Parent',handles.right_axes);
end


function numImages_edit_Callback(hObject, eventdata, handles)
% hObject    handle to numImages_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of numImages_edit as text
%        str2double(get(hObject,'String')) returns contents of numImages_edit as a double
num = round(str2double(get(hObject,'String')));
handles.numImages = num;

guidata(hObject, handles);


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
num = str2double(get(hObject,'String'));
handles.interval = num;

guidata(hObject, handles);


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


% --- Executes on button press in markcell_pushbutton.
function markcell_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to markcell_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if ~isfield(handles,'selectedPos')
    updatestatus(handles.main_figure,'No position has been selected.');
    return;
end

% handles = findspot_pushbutton_Callback(handles.findspot_pushbutton, eventdata, handles);
% first position in the track
handles.cellPos = handles.selectedPos;

posStr = ['(' num2str(round(handles.selectedPos(1))) ',' num2str(round(handles.selectedPos(2))) ')'];
set(handles.cellPos_text,'String',posStr);

updatestatus(handles.main_figure,['Cell at position: (x,y) = ' posStr ' has been marked.']);
guidata(hObject, handles);


% --- Executes on button press in isTrackCell_checkbox.
function isTrackCell_checkbox_Callback(hObject, eventdata, handles)
% hObject    handle to isTrackCell_checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of isTrackCell_checkbox
handles.isTrackCell = get(hObject,'Value');
guidata(hObject, handles);


% --- Executes on button press in markpin_pushbutton.
function markpin_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to markpin_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if ~isfield(handles,'selectedPos')
    updatestatus(handles.main_figure,'No position has been selected.');
    return;
end

handles.pinnedPos = handles.selectedPos;
xpos = round(handles.selectedPos(1));
ypos = round(handles.selectedPos(2));

posStr = ['(' num2str(xpos) ',' num2str(ypos) ')'];
set(handles.pinnedPos_text,'String',posStr);

showPin_pushbutton_Callback(hObject, eventdata, handles);

updatestatus(handles.main_figure,['Pinned position: (x,y) = ' posStr '.']);
guidata(hObject, handles);


% --- Executes on button press in savetrack_pushbutton.
function savetrack_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to savetrack_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if ~isfield(handles.acq,'track')
    updatestatus(handles.main_figure,'No track data found.');
    return;
end

savedFilePath = fullfile(handles.acq.outfileDir,'MMControl_track.txt');
dlmwrite(savedFilePath,handles.trackHeader,'delimiter','');
dlmwrite(savedFilePath,handles.acq.track,'delimiter', '\t','-append');


% --- Executes on button press in isLog_checkbox.
function isLog_checkbox_Callback(hObject, eventdata, handles)
% hObject    handle to isLog_checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of isLog_checkbox
handles.isLog = get(hObject,'Value');
guidata(hObject, handles);


function moveStageRelative(handles,dx,dy)
% Move the stage relative to current position
% dx and dy are displacements in x and y in units of um

% x-axis is flipped in controller
x = -handles.mmc.getXPosition(handles.stage);
y = handles.mmc.getYPosition(handles.stage);

if x+dx>handles.limitRight
    updatestatus(handles.main_figure,'New position will exceed the right limit.');
    return;
end
if x+dx<handles.limitLeft
    updatestatus(handles.main_figure,'New position will exceed the left limit.');
    return;
end

if y+dy>handles.limitTop
    updatestatus(handles.main_figure,'New position will exceed the top limit.');
    return;
end
if y+dy<handles.limitBottom
    updatestatus(handles.main_figure,'New position will exceed the bottom limit.');
    return;
end

% x-axis is flipped in controller
handles.mmc.setRelativeXYPosition(handles.stage,-dx,dy);
% handles.mmc.waitForDevice(handles.stage);


function pix2um_edit_Callback(hObject, eventdata, handles)
% hObject    handle to pix2um_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of pix2um_edit as text
%        str2double(get(hObject,'String')) returns contents of pix2um_edit as a double
handles.pix2um = str2double(get(hObject,'String'));
updatestatus(handles.main_figure,['Calibration is set to: 1 pixel = ' num2str(handles.pix2um) 'um']);
guidata(hObject, handles);


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


% --- Executes on button press in isAutoSaveTrack_checkbox.
function isAutoSaveTrack_checkbox_Callback(hObject, eventdata, handles)
% hObject    handle to isAutoSaveTrack_checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of isAutoSaveTrack_checkbox

handles.isAutoSaveTrack = get(hObject,'Value');
guidata(hObject, handles);


function uncagingExposure_edit_Callback(hObject, eventdata, handles)
% hObject    handle to uncagingExposure_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of uncagingExposure_edit as text
%        str2double(get(hObject,'String')) returns contents of uncagingExposure_edit as a double
handles.uncagingExposure = str2double(get(hObject,'String'));
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function uncagingExposure_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to uncagingExposure_edit (see GCBO)
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
if handles.isLaserUncage
    uncage_laser(handles);
else
    uncage_lamp(handles);
end

updatestatus(handles.main_figure,['Shutter for uncaging was opened for ' num2str(handles.uncagingExposure) ' ms.']);
% guidata(hObject, handles);


function uncage_lamp(handles)
% uncage with arc lamp

handles.mmc.setConfig(handles.configGroup,handles.configUncage);
handles.mmc.waitForConfig(handles.configGroup,handles.configUncage);
handles.mmc.setExposure(handles.uncagingExposure);

img = snapSingleImage(handles);
dispImage(img,handles);
outfileName =  ['LampUncage_' getTime_filename() '.tif'];
imwrite(img,fullfile(handles.filedir,outfileName));


function uncage_laser(handles)
% uncage with UV laser
if handles.isExposeCam
    % Set config to uncaging for lamp to have consistent emission filter
    handles.mmc.setConfig(handles.configGroup,handles.configUncage);
    handles.mmc.waitForConfig(handles.configGroup,handles.configUncage);
    
    handles = storeShutterState(handles);
    handles.mmc.setShutterDevice(handles.shutterUncage);
    handles.mmc.setExposure(handles.uncagingExposure);
    img = snapSingleImage(handles);
    resetShutterState(handles);

    dispImage(img,handles);
    outfileName =  ['LaserUncage_' getTime_filename() '.tif'];
    imwrite(img,fullfile(handles.filedir,outfileName));
else
    handles.mmc.setConfig(handles.shutterUncage,'Open');
    pause(handles.uncagingExposure/1000);
    handles.mmc.setConfig(handles.shutterUncage,'Close');
end    


function exposure_edit_Callback(hObject, eventdata, handles)
% hObject    handle to exposure_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of exposure_edit as text
%        str2double(get(hObject,'String')) returns contents of exposure_edit as a double
handles.exposure = str2double(get(hObject,'String'));
guidata(hObject, handles);


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



% --- Executes on button press in isAutoShutter_checkbox.
function isAutoShutter_checkbox_Callback(hObject, eventdata, handles)
% hObject    handle to isAutoShutter_checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of isAutoShutter_checkbox
handles.isAutoShutter = get(hObject,'Value');
handles.mmc.setAutoShutter(handles.isAutoShutter);
guidata(hObject, handles);

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
i = get(hObject,'Value');
contents = cellstr(get(hObject,'String'));

try
    handles.mmc.setConfig(handles.configGroup,contents{i});
    handles.mmc.waitForConfig(handles.configGroup,contents{i});
catch
    updatestatus(handles.main_figure,['Error setting config: ' contents{i}]);
    return;
end

updatestatus(handles.main_figure,['Config has been set to: ' contents{i}]);

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


% --- Executes on button press in showUncaging_pushbutton.
function showUncaging_pushbutton_Callback(~, ~, handles)
% hObject    handle to showUncaging_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if ~isfield(handles,'uncagingPos')
    updatestatus(handles.main_figure,'Uncaging position has not been marked.');
    return;
end

hold(handles.left_axes,'on');
plot(handles.left_axes,handles.uncagingPos(1),handles.uncagingPos(2),'b+');
hold(handles.left_axes,'off');


% --- Executes during object creation, after setting all properties.
function showUncaging_pushbutton_CreateFcn(hObject, eventdata, handles)
% hObject    handle to showUncaging_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes on button press in showPin_pushbutton.
function showPin_pushbutton_Callback(~, ~, handles)
% hObject    handle to showPin_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if ~isfield(handles,'pinnedPos')
    updatestatus(handles.main_figure,'Pinned position has not been marked.');
    return;
end

hold(handles.left_axes,'on');
plot(handles.left_axes,handles.pinnedPos(1),handles.pinnedPos(2),'y+');
hold(handles.left_axes,'off');


% --- Executes on button press in isUpdateImages_checkbox.
function isUpdateImages_checkbox_Callback(hObject, eventdata, handles)
% hObject    handle to isUpdateImages_checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of isUpdateImages_checkbox
handles.isUpdateImages = get(hObject,'Value');
guidata(hObject, handles);


% --- Executes on button press in isPinCell_checkbox.
function isPinCell_checkbox_Callback(hObject, eventdata, handles)
% hObject    handle to isPinCell_checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of isPinCell_checkbox
handles.isPinCell = get(hObject,'Value');
guidata(hObject, handles);


% --- Executes on button press in settings_pushbutton.
function settings_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to settings_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
settings('main', handles.main_figure);


% --- Executes on selection change in acqProfiles_popupmenu.
function acqProfiles_popupmenu_Callback(hObject, eventdata, handles)
% hObject    handle to acqProfiles_popupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns acqProfiles_popupmenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from acqProfiles_popupmenu
handles.iAcqProfile = get(hObject,'Value');
handles.acqConfigs = handles.acqProfileConfigs{handles.iAcqProfile};
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
guidata(hObject, handles);


% --- Executes on button press in showCell_pushbutton.
function showCell_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to showCell_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if ~isfield(handles,'cellPos')
    updatestatus(handles.main_figure,'Cell position has not been marked.');
    return;
end

hold(handles.left_axes,'on');
plot(handles.left_axes,handles.cellPos(1),handles.cellPos(2),'g+');
hold(handles.left_axes,'off');


% --- Executes on button press in isExposeCam_checkbox.
function isExposeCam_checkbox_Callback(hObject, eventdata, handles)
% hObject    handle to isExposeCam_checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of isExposeCam_checkbox
handles.isExposeCam = get(hObject,'Value');
guidata(hObject, handles);


% --- Executes on button press in isLaserUncage_checkbox.
function isLaserUncage_checkbox_Callback(hObject, eventdata, handles)
% hObject    handle to isLaserUncage_checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of isLaserUncage_checkbox
handles.isLaserUncage = get(hObject,'Value');
if handles.isLaserUncage
    handles.shutterUncage = 'ShutterUV';
else
    handles.shutterUncage = 'ShutterFL';
end    
guidata(hObject, handles);


% --- Executes on button press in saveRightImg_pushbutton.
function saveRightImg_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to saveRightImg_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
outfileName =  [handles.prefix '_' getTime_filename() '.tif'];
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



function autoUncageNumOpened_edit_Callback(hObject, eventdata, handles)
% hObject    handle to autoUncageNumOpened_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of autoUncageNumOpened_edit as text
%        str2double(get(hObject,'String')) returns contents of autoUncageNumOpened_edit as a double
handles.autoUncageNumOpened = str2double(get(hObject,'String'));
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function autoUncageNumOpened_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to autoUncageNumOpened_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function autoUncageNumTotal_edit_Callback(hObject, eventdata, handles)
% hObject    handle to autoUncageNumTotal_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of autoUncageNumTotal_edit as text
%        str2double(get(hObject,'String')) returns contents of autoUncageNumTotal_edit as a double
handles.autoUncageNumTotal = str2double(get(hObject,'String'));
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function autoUncageNumTotal_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to autoUncageNumTotal_edit (see GCBO)
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
handles.configGroup = 'Channel';

% Go to settings window if hardware initialization fails
handles = initHardware(handles);
if ~isempty(handles.status)
    disp('Hardware initialization failed with the following error:');
    disp(handles.status);
    handles.closeFigure = true;
    guidata(hObject, handles);
    settings('main', handles.main_figure);
    return;
end

set(handles.connectMM_pushbutton,'String','Connected to MM','ForegroundColor',[0,0.5,0]);
set(handles.configs_popupmenu,'String',handles.configs);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
handles.acq = struct;
handles.acq.iBatch = 0;
% config to show images on the gui, default is the last config
handles.acq.iConfigToDisplay = 1; 

handles.acq.timer = timer;
set(handles.acq.timer,'ExecutionMode','fixedRate','BusyMode','drop','Period',1);
handles.acq.timer.TimerFcn = {@runAcquisition,hObject};

handles.acqConfigs = handles.acqProfileConfigs{handles.iAcqProfile};
for i=1:length(handles.acqConfigs)
	isConfig = ismember(handles.acqConfigs{i},handles.configs);
	if ~isConfig
		handles.status = [handles.acqConfigs{i} ' is not a valid config group.'];
		return;
	end
end

guidata(hObject, handles);


% --- Executes on button press in fl_togglebutton.
function fl_togglebutton_Callback(hObject, eventdata, handles)
% hObject    handle to fl_togglebutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of fl_togglebutton
state = get(hObject,'Value');
if state
    handles.mmc.setConfig('ShutterFL','Open');
else
    handles.mmc.setConfig('ShutterFL','Close');
end


% --- Executes on button press in tr_togglebutton.
function tr_togglebutton_Callback(hObject, eventdata, handles)
% hObject    handle to tr_togglebutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of tr_togglebutton
state = get(hObject,'Value');
if state
    handles.mmc.setConfig('ShutterTR','Open');
else
    handles.mmc.setConfig('ShutterTR','Close');
end


% --- Executes on button press in laser_togglebutton.
function laser_togglebutton_Callback(hObject, eventdata, handles)
% hObject    handle to laser_togglebutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of laser_togglebutton
state = get(hObject,'Value');
if state
    handles.mmc.setConfig('ShutterUV','Open');
else
    handles.mmc.setConfig('ShutterUV','Close');
end


% --- Executes on button press in ttl1_pushbutton.
function ttl1_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to ttl1_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.mmc.setConfig('TTL1','1');
handles.mmc.setConfig('TTL1','0');
updatestatus(handles.main_figure,'TTL1 has been triggered.');

% Move cell near uncaging spot
if handles.isPinUncage && isfield(handles,'pinUncagePos')
%     pause(3);
    moveToUncage_pushbutton_Callback(hObject, eventdata, handles);
end


% --- Executes on button press in addPos_pushbutton.
function addPos_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to addPos_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Positions are in acquired image's orientation that has x-coord reversed
% from that of the stage

% x position read from micro-manager has opposite sign of that from the
% display
xpos = -handles.mmc.getXPosition(handles.stage);
ypos = handles.mmc.getYPosition(handles.stage);
handles.stagePosArray = [handles.stagePosArray;[xpos,ypos]];
updatestatus(handles.main_figure,['Current position: (x,y) = (' num2str(xpos) ',' num2str(ypos) ') has been added to the stage position array.']);
guidata(hObject, handles);


% --- Executes on button press in clearPos_pushbutton.
function clearPos_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to clearPos_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.stagePosArray = [];
updatestatus(handles.main_figure, 'Stage position array has been cleared.');
guidata(hObject, handles);


% --- Executes on button press in isAcqMultiPos_checkbox.
function isAcqMultiPos_checkbox_Callback(hObject, eventdata, handles)
% hObject    handle to isAcqMultiPos_checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of isAcqMultiPos_checkbox
handles.isAcqMultiPos = get(hObject,'Value');
guidata(hObject, handles);


% --- Executes on button press in pinUncage_pushbutton.
function pinUncage_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to pinUncage_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if ~isfield(handles,'selectedPos')
    updatestatus(handles.main_figure,'No position has been selected.');
    return;
end

handles.pinUncagePos = handles.selectedPos;

xpos = round(handles.selectedPos(1));
ypos = round(handles.selectedPos(2));
posStr = ['(' num2str(xpos) ',' num2str(ypos) ')'];
set(handles.pinnedPos_text,'String',posStr);

showPinUncage_pushbutton_Callback(hObject, eventdata, handles);

updatestatus(handles.main_figure,['Pinned position for uncaging: (x,y) = ' posStr '.']);
guidata(hObject, handles);


% --- Executes on button press in showPinUncage_pushbutton.
function showPinUncage_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to showPinUncage_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if ~isfield(handles,'pinUncagePos')
    updatestatus(handles.main_figure,'Pinned position for uncaging has not been marked.');
    return;
end

hold(handles.left_axes,'on');
plot(handles.left_axes,handles.pinUncagePos(1),handles.pinUncagePos(2),'b+');
hold(handles.left_axes,'off');


% --- Executes on button press in isPinUncage_checkbox.
function isPinUncage_checkbox_Callback(hObject, eventdata, handles)
% hObject    handle to isPinUncage_checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of isPinUncage_checkbox
handles.isPinUncage = get(hObject,'Value');
guidata(hObject, handles);


% --- Executes on button press in moveToUncage_pushbutton.
function moveToUncage_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to moveToUncage_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if ~isfield(handles,'pinUncagePos')
    updatestatus(handles.main_figure,'Pinned position has not been marked.');
    return;
end
if ~isfield(handles,'cellPos')
    updatestatus(handles.main_figure,'Cell position for uncaging has not been determined.');
    return;
end

% Move cell near uncaging spot
dx = (handles.cellPos(1) - handles.pinUncagePos(1))*handles.pix2um;
dy = (handles.cellPos(2) - handles.pinUncagePos(2))*handles.pix2um;
moveStageRelative(handles,dx,dy);
% handles.cellPos = handles.pinUncagePos;
% guidata(hObject, handles);
updatestatus(handles.main_figure,'Cell has been moved to uncaging pin for imaging.');

tmpimg = snapSingleImage(handles);
dispImage(tmpimg,handles);
saveImage_pushbutton_Callback(hObject, eventdata, handles);
% updatestatus(handles.main_figure,'Exposing cell to uncaging ...');
pause(handles.uncagingExposure/1000);

% Move cell back for imaging
moveStageRelative(handles,-dx,-dy);
updatestatus(handles.main_figure,'Cell has been moved out of uncaging for imaging.');


% --- Executes on button press in moveToPin_pushbutton.
function moveToPin_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to moveToPin_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if ~isfield(handles,'pinnedPos')
    updatestatus(handles.main_figure,'Pinned position has not been marked.');
    return;
end
if ~isfield(handles,'cellPos')
    updatestatus(handles.main_figure,'Cell position has not been determined.');
    return;
end

dx = (handles.cellPos(1) - handles.pinnedPos(1))*handles.pix2um;
dy = (handles.cellPos(2) - handles.pinnedPos(2))*handles.pix2um;
moveStageRelative(handles,dx,dy);
handles.cellPos = handles.pinnedPos;
guidata(hObject, handles);


% --- Executes on button press in recallPos_pushbutton.
function recallPos_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to recallPos_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if isempty(handles.stagePosArray)
    updatestatus(handles.main_figure,'Position array is empty.');
    return;
end

posCurrent = handles.stagePosArray(end,:);
handles.mmc.setXYPosition(handles.stage,-posCurrent(1),posCurrent(2));

% handles.stagePosArray(end,:) = [];
updatestatus(handles.main_figure,['Current position: (x,y) = (' num2str(posCurrent(1)) ',' num2str(posCurrent(2)) ')']);
guidata(hObject, handles);
