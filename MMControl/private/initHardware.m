function handles = initHardware(handles)
% Get config groups and configs from MM core

handles.stage = char(handles.mmc.getXYStageDevice());
handles.camera = char(handles.mmc.getCameraDevice());
handles.shutter = char(handles.mmc.getShutterDevice());

try
	handles.mmc.assignImageSynchro(handles.stage);
	handles.mmc.assignImageSynchro(handles.shutter);
catch
    handles.error = struct;
    handles.error.identifier = 'MMImageSyncAssignError';
	handles.message = 'Error assigning image synchronization in the Micro-Manager core.';
	return;
end

configGroupsJava = handles.mmc.getAvailableConfigGroups();
handles.configGroups = cell(configGroupsJava.toArray());

if ~ismember(handles.configGroup,handles.configGroups)
    handles.error = struct;
    handles.error.identifier = 'MMConfigGroupInvalidError';
	handles.message = [handles.configGroup ' is not a valid config group. Are you using the correct Micro-Manager configuration file?'];
	return;
end

configsJava = handles.mmc.getAvailableConfigs(handles.configGroup);
handles.configs = cell(configsJava.toArray());

handles.imHeight = handles.mmc.getImageHeight;
handles.imWidth = handles.mmc.getImageWidth;
handles.bitDepth = handles.mmc.getImageBitDepth;
