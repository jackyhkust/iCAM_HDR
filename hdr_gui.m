%% Ke Ma, Christopher Bodden
% CS 766 - Project 1 (HDR)

function varargout = hdr_gui(varargin)
% HDR_GUI MATLAB code for hdr_gui.fig
%      HDR_GUI, by itself, creates a new HDR_GUI or raises the existing
%      singleton*.
%
%      H = HDR_GUI returns the handle to a new HDR_GUI or the handle to
%      the existing singleton*.
%
%      HDR_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in HDR_GUI.M with the given input arguments.
%
%      HDR_GUI('Property','Value',...) creates a new HDR_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before hdr_gui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to hdr_gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help hdr_gui

% Last Modified by GUIDE v2.5 15-May-2017 12:12:21

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @hdr_gui_OpeningFcn, ...
    'gui_OutputFcn',  @hdr_gui_OutputFcn, ...
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


% --- Executes just before hdr_gui is made visible.
function hdr_gui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to hdr_gui (see VARARGIN)

% Choose default command line output for hdr_gui
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% initialize tonemap default settings
setappdata(handles.figure1,'GAMMA_gammaVal', 0.15);
setappdata(handles.figure1,'DURAND_contrastVal', 6);
setappdata(handles.figure1,'REINHARD_aVal', 0.36);
setappdata(handles.figure1,'DRAGO_betaVal', 0.85);

% UIWAIT makes hdr_gui wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = hdr_gui_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



% --------------------------------------------------------------------
function loadData_Callback(hObject, eventdata, handles)
% hObject    handle to loadData (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[fNames fPath] = uigetfile({'*.jpg;*.tif;*.png;*.gif','All Image Files'; ...
    '*.*','All Files' },'Select LDR Images','MultiSelect','on');

set(handles.slider1,'Value',1.0); % reset slider

%return if no values
if ~iscell(fNames)
    return
end

% load exposure times
[eFName eFPath] = uigetfile({'*.txt;','Text Files'; ...
    '*.*','All Files' },'Select Exposure File','MultiSelect','off');

%return if no values
if eFName == 0
    return
end

% setup exposure times
expTimes = 1 ./ load(fullfile(eFPath, eFName));

% get filenames
size = length(fNames);
files = cell([1 size]);
for i = 1:size
    files(i) = fullfile(fPath, fNames(i));
end

% init axes
hAxes = getappdata(handles.figure1,'hAxes');
if ~isempty(hAxes)
    f = find ( ishandle(hAxes) & hAxes);
    delete(hAxes(f));
end
hAxes = zeros(size,1);

axesProp = {'DataAspectRatio' ,'Parent','PlotBoxAspectRatio','XGrid','YGrid'};
axesVal = {[1.0 1.0 1.0], handles.uipanel1, [1.0 1.0 1.0], 'off', 'off'};
imageProp = {'ButtonDownFcn'};
imageVal = {'enlargeImage( guidata(gcf) )'};

% setup panel position for # of images
ht = 0.25 * size;
po = ht - 1.0;
pos = get(handles.uipanel1, 'Position');
pos(4) = ht;
pos(2) = -po;
set(handles.uipanel1, 'Position', pos);

% image position constants
x = 1 - (0.98 / 1); % x position (1 column)
rPitch = 0.98/size;
axWidth = 0.9/1;
axHight = 0.9/size;

% post images into LDR panel
h = waitbar(0, 'Loading images...'); % start progress bar
for i = 1:size
    % create axes
    y = 1 - (i) * rPitch; % y position
    hAxes(i) = axes('Position', [x y axWidth axHight], axesProp, axesVal);
    
    % draw image in axes
    im = imread(char(files(i)));
    imagesc(im,'Parent',hAxes(i),imageProp,imageVal);
    axis(hAxes(i),'image');
    axis(hAxes(i),'off');
    images(:,:,:,i) = im;
    
    waitbar(i / size); % progress bar update
end

close(h);
set(handles.solve,'Enable','on');
set(handles.align,'Enable','on');
setappdata(handles.figure1,'hAxes',hAxes);
setappdata(handles.figure1,'images',images);
setappdata(handles.figure1,'exposureTimes',expTimes);

% reset downstream data
if isappdata(handles.figure1,'radMap')
    ax = getappdata(handles.figure1,'radMapGraph');
    cla(ax);
    rmappdata(handles.figure1,'radMap')
end

if isappdata(handles.figure1,'radMapGraph')
    rmappdata(handles.figure1,'radMapGraph')
end

if isappdata(handles.figure1,'ldrDrawing')
    ax = getappdata(handles.figure1,'ldrDrawing');
    cla(ax);
    rmappdata(handles.figure1,'ldrDrawing');
end

if isappdata(handles.figure1,'finalImage')
    rmappdata(handles.figure1,'finalImage');
end

set(handles.red,'Visible','off');
set(handles.green,'Visible','off');
set(handles.blue,'Visible','off');
cla(handles.red);
cla(handles.green);
cla(handles.blue);

set(handles.saveFinal,'Enable','off');
set(handles.saveRadMap,'Enable','off');
set(handles.toneMap,'Enable','off');


% --- Executes on slider movement.
function slider1_Callback(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

pos = get(handles.uipanel1,'Position');
hight = pos(4);% get the height
if hight > 1
    val = get(hObject,'Value');
    yPos = -(hight-1) + (hight-1)*(1-val);
    pos(2) = yPos;
    set(handles.uipanel1,'Position',pos);
end


% --- Executes during object creation, after setting all properties.
function slider1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --------------------------------------------------------------------
function solve_Callback(hObject, eventdata, handles)
% hObject    handle to solve (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if isappdata(handles.figure1,'radMap')
    rmappdata(handles.figure1,'radMap');
end

if isappdata(handles.figure1,'radMapGraph')
    ax = getappdata(handles.figure1,'radMapGraph');
    cla(ax);
    rmappdata(handles.figure1,'radMapGraph');
end

images = getappdata(handles.figure1,'images');
B = getappdata(handles.figure1,'exposureTimes');

h = waitbar(0, 'Recovering Curves and Radiance Map...'); % start progress bar
[radMap, rG, gG, bG, rPxVals, gPxVals, bPxVals, rLgExps, gLgExps, bLgExps] = makeRadmap(images,B,20);
waitbar(1.0);
close(h);

cla(handles.red);
cla(handles.green);
cla(handles.blue);

graphProp = {'Visible'};
graphVal = {'on'};

%red
axes(handles.red)
set(handles.red,graphProp,graphVal);
hold on;
scatter(rLgExps,rPxVals,12,[0.6 0.6 1]);
plot(rG,1:256,'r');
xlim([-8 8]);
ylim([0 255]);
xlabel('log exposure X');
ylabel('pixel value Z');
title('Red Channel')

%blue
axes(handles.green)
set(handles.green,graphProp,graphVal);
hold on;
scatter(gLgExps,gPxVals,12,[0.6 0.6 1]);
plot(gG,1:256,'r');
xlim([-8 8]);
ylim([0 255]);
xlabel('log exposure X');
ylabel('pixel value Z');
title('Green Channel')

%blue
axes(handles.blue)
set(handles.blue,graphProp,graphVal);
hold on;
scatter(bLgExps,bPxVals,12,[0.6 0.6 1]);
plot(bG,1:256,'r');
xlim([-8 8]);
ylim([0 255]);
xlabel('log exposure X');
ylabel('pixel value Z');
title('Blue Channel')

imageProp = {'ButtonDownFcn'};
imageVal = {'enlargeImage( guidata(gcf), 1 )'};
L = rgb2gray(radMap); % convert to greyscale for false color
x = 1 - (0.98 / 1); % x position (1 column)
y = 1 - (0.98 / 1); % y position (1 row)
axWidth = 0.96;
axHight = 0.96;
axesProp = {'DataAspectRatio' ,'Parent','PlotBoxAspectRatio','XGrid','YGrid'};
axesVal = {[1.0 1.0 1.0], handles.uipanel4, [1.0 1.0 1.0], 'off', 'off'};
radDrawing = axes('Position', [x y axWidth axHight], axesProp, axesVal);
imagesc(L,imageProp,imageVal);
colormap(jet(256));
axis(radDrawing,'image');
axis(radDrawing,'off');

setappdata(handles.figure1,'radMap',radMap);
setappdata(handles.figure1,'radMapGraph',radDrawing);
set(handles.toneMap,'Enable','on');
set(handles.saveRadMap,'Enable','on');


% --------------------------------------------------------------------
function saveRadMap_Callback(hObject, eventdata, handles)
% hObject    handle to saveRadMap (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if isappdata(handles.figure1,'radMap')
    radMap = getappdata(handles.figure1,'radMap');
    [fileName, path] = uiputfile({'*.hdr;','HDR Files'},'Save HDR File');
    
    %return if no values
    if fileName == 0
        return
    end
    
    hdrwrite(radMap, fullfile(path, fileName));
end


% --------------------------------------------------------------------
function toneMap_Callback(hObject, eventdata, handles)
% hObject    handle to toneMap (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function openHDR_Callback(hObject, eventdata, handles)
% hObject    handle to openHDR (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% load exposure times
[hdrName hdrPath] = uigetfile({'*.hdr;','HDR Files'},'Select HDR File','MultiSelect','off');

%return if no values
if hdrName == 0
    return
end

% reset
set(handles.solve,'Enable','off');
set(handles.align,'Enable','off');
set(handles.saveFinal,'Enable','off');

set(handles.red,'Visible','off');
set(handles.green,'Visible','off');
set(handles.blue,'Visible','off');
cla(handles.red);
cla(handles.green);
cla(handles.blue);

if isappdata(handles.figure1,'radMap')
    rmappdata(handles.figure1,'radMap');
end

if isappdata(handles.figure1,'radMapGraph')
    ax = getappdata(handles.figure1,'radMapGraph');
    cla(ax);
    rmappdata(handles.figure1,'radMapGraph');
end

hAxes = getappdata(handles.figure1,'hAxes');
if ~isempty(hAxes)
    f = find ( ishandle(hAxes) & hAxes);
    delete(hAxes(f));
    rmappdata(handles.figure1,'hAxes');
end

if isappdata(handles.figure1,'ldrDrawing')
    ax = getappdata(handles.figure1,'ldrDrawing');
    cla(ax);
    rmappdata(handles.figure1,'ldrDrawing');
end

if isappdata(handles.figure1,'finalImage')
    rmappdata(handles.figure1,'finalImage');
end

% read rad map from file
radMap = hdrread(fullfile(hdrPath, hdrName));

imageProp = {'ButtonDownFcn'};
imageVal = {'enlargeImage( guidata(gcf), 1 )'};
L = rgb2gray(radMap); % convert to greyscale for false color
x = 1 - (0.98 / 1); % x position (1 column)
y = 1 - (0.98 / 1); % y position (1 row)
axWidth = 0.96;
axHight = 0.96;
axesProp = {'DataAspectRatio' ,'Parent','PlotBoxAspectRatio','XGrid','YGrid'};
axesVal = {[1.0 1.0 1.0], handles.uipanel4, [1.0 1.0 1.0], 'off', 'off'};
radDrawing = axes('Position', [x y axWidth axHight], axesProp, axesVal);
imagesc(L,imageProp,imageVal);
colormap(jet(256));
axis(radDrawing,'image');
axis(radDrawing,'off');

setappdata(handles.figure1,'radMap',radMap);
setappdata(handles.figure1,'radMapGraph',radDrawing);
set(handles.toneMap,'Enable','on');
set(handles.saveRadMap,'Enable','on');


% --------------------------------------------------------------------
function drago_Callback(hObject, eventdata, handles)
% hObject    handle to drago (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% reset
if isappdata(handles.figure1,'ldrDrawing')
    ax = getappdata(handles.figure1,'ldrDrawing');
    cla(ax);
    rmappdata(handles.figure1,'ldrDrawing');
end

if isappdata(handles.figure1,'finalImage')
    rmappdata(handles.figure1,'finalImage');
end

beta = getappdata(handles.figure1,'DRAGO_betaVal');
radMap = getappdata(handles.figure1,'radMap');
h = waitbar(0, 'Performing tone mapping...'); % start progress bar
DragoRGB = toneMapDrago(radMap, beta);
waitbar(1.0); % start progress bar
close(h);

x = 1 - (0.98 / 1); % x position (1 column)
y = 1 - (0.98 / 1); % y position (1 row)
axWidth = 0.96;
axHight = 0.96;
axesProp = {'DataAspectRatio' ,'Parent','PlotBoxAspectRatio','XGrid','YGrid'};
axesVal = {[1.0 1.0 1.0], handles.uipanel2, [1.0 1.0 1.0], 'off', 'off'};
ldrDrawing = axes('Position', [x y axWidth axHight], axesProp, axesVal);
imshow(DragoRGB,[]);

setappdata(handles.figure1,'finalImage',DragoRGB);
setappdata(handles.figure1,'ldrDrawing',ldrDrawing);
set(handles.saveFinal,'Enable','on');


% --------------------------------------------------------------------
function reinhard_Callback(hObject, eventdata, handles)
% hObject    handle to reinhard (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% reset
if isappdata(handles.figure1,'ldrDrawing')
    ax = getappdata(handles.figure1,'ldrDrawing');
    cla(ax);
    rmappdata(handles.figure1,'ldrDrawing');
end

if isappdata(handles.figure1,'finalImage')
    rmappdata(handles.figure1,'finalImage');
end

radMap = getappdata(handles.figure1,'radMap');
h = waitbar(0, 'Performing tone mapping...'); % start progress bar
a = getappdata(handles.figure1,'REINHARD_aVal');
ReinhardRGB = toneMapBasic(radMap, a);
waitbar(1.0); % start progress bar
close(h);

imageProp = {'ButtonDownFcn'};
imageVal = {'enlargeImage( guidata(gcf) )'};
x = 1 - (0.98 / 1); % x position (1 column)
y = 1 - (0.98 / 1); % y position (1 row)
axWidth = 0.96;
axHight = 0.96;
axesProp = {'DataAspectRatio' ,'Parent','PlotBoxAspectRatio','XGrid','YGrid'};
axesVal = {[1.0 1.0 1.0], handles.uipanel2, [1.0 1.0 1.0], 'off', 'off'};
ldrDrawing = axes('Position', [x y axWidth axHight], axesProp, axesVal);
imshow(ReinhardRGB,[]);

setappdata(handles.figure1,'finalImage',ReinhardRGB);
setappdata(handles.figure1,'ldrDrawing',ldrDrawing);
set(handles.saveFinal,'Enable','on');

% --------------------------------------------------------------------
function matlabToneMap_Callback(hObject, eventdata, handles)
% hObject    handle to matlabToneMap (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% reset
if isappdata(handles.figure1,'ldrDrawing')
    ax = getappdata(handles.figure1,'ldrDrawing');
    cla(ax);
    rmappdata(handles.figure1,'ldrDrawing');
end

if isappdata(handles.figure1,'finalImage')
    rmappdata(handles.figure1,'finalImage');
end

radMap = getappdata(handles.figure1,'radMap');
h = waitbar(0, 'Performing tone mapping...'); % start progress bar
builtInRGB = tonemap(radMap);
waitbar(1.0); % start progress bar
close(h);

imageProp = {'ButtonDownFcn'};
imageVal = {'enlargeImage( guidata(gcf) )'};
x = 1 - (0.98 / 1); % x position (1 column)
y = 1 - (0.98 / 1); % y position (1 row)
axWidth = 0.96;
axHight = 0.96;
axesProp = {'DataAspectRatio' ,'Parent','PlotBoxAspectRatio','XGrid','YGrid'};
axesVal = {[1.0 1.0 1.0], handles.uipanel2, [1.0 1.0 1.0], 'off', 'off'};
ldrDrawing = axes('Position', [x y axWidth axHight], axesProp, axesVal);
imshow(builtInRGB,[]);

setappdata(handles.figure1,'finalImage',builtInRGB);
setappdata(handles.figure1,'ldrDrawing',ldrDrawing);
set(handles.saveFinal,'Enable','on');


% --------------------------------------------------------------------
function align_Callback(hObject, eventdata, handles)
% hObject    handle to align (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if isappdata(handles.figure1,'hAxes') && isappdata(handles.figure1,'images')
    hAxes = getappdata(handles.figure1,'hAxes');
    images = getappdata(handles.figure1,'images');
    
    h = waitbar(0, 'Performing MTB alignment...'); % start progress bar
    newImages = alignMTB(images, 0.1);
    waitbar(1.0);
    close(h);
    
    for i = 1:size(newImages,4)
        cla(hAxes(i)); % clear
        imagesc(newImages(:,:,:,i),'Parent',hAxes(i))
        axis(hAxes(i),'image');
        axis(hAxes(i),'off');
        images(:,:,:,i) = newImages(:,:,:,i);
    end
    
    setappdata(handles.figure1,'hAxes',hAxes);
    setappdata(handles.figure1,'images',images);
end


% --------------------------------------------------------------------
function files_Callback(hObject, eventdata, handles)
% hObject    handle to files (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function tools_Callback(hObject, eventdata, handles)
% hObject    handle to tools (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function toneMapSettings_Callback(hObject, eventdata, handles)
% hObject    handle to toneMapSettings (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% toneMapSettings = tone_map_settings();
toneMapSettings = tone_map_settings();
toneMapSettingsHandles = guidata(toneMapSettings);
setappdata(toneMapSettingsHandles.figure1,'mainHandles',handles);

% gamma options
GAMMA_gamma = getappdata(handles.figure1,'GAMMA_gammaVal');
set(toneMapSettingsHandles.gamma_text,'String', num2str(GAMMA_gamma), 'Value', GAMMA_gamma);
set(toneMapSettingsHandles.gamma_slider, 'Value', GAMMA_gamma);

% durand options
DURAND_contrast = getappdata(handles.figure1,'DURAND_contrastVal');
set(toneMapSettingsHandles.durand_text,'String', num2str(DURAND_contrast), 'Value', DURAND_contrast);
set(toneMapSettingsHandles.durand_slider, 'Value', DURAND_contrast);

% drago options
DRAGO_beta = getappdata(handles.figure1,'DRAGO_betaVal');
set(toneMapSettingsHandles.drago_text,'String', num2str(DRAGO_beta), 'Value', DRAGO_beta);
set(toneMapSettingsHandles.drago_slider, 'Value', DRAGO_beta);

% reinhard options
REINHARD_a = getappdata(handles.figure1,'REINHARD_aVal');
set(toneMapSettingsHandles.reinhard_text,'String', num2str(REINHARD_a), 'Value', REINHARD_a);
set(toneMapSettingsHandles.reinhard_slider, 'Value', REINHARD_a);

% make visible
set(toneMapSettingsHandles.figure1,'Visible','on');


% --------------------------------------------------------------------
function durand_Callback(hObject, eventdata, handles)
% hObject    handle to durand (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% reset
if isappdata(handles.figure1,'ldrDrawing')
    ax = getappdata(handles.figure1,'ldrDrawing');
    cla(ax);
    rmappdata(handles.figure1,'ldrDrawing');
end

if isappdata(handles.figure1,'finalImage')
    rmappdata(handles.figure1,'finalImage');
end

contrast = getappdata(handles.figure1,'DURAND_contrastVal');
radMap = getappdata(handles.figure1,'radMap');
h = waitbar(0, 'Performing tone mapping...'); % start progress bar
DurandRGB = toneMapDurand(double(radMap), contrast);
waitbar(1.0); % start progress bar
close(h);

imageProp = {'ButtonDownFcn'};
imageVal = {'enlargeImage( guidata(gcf) )'};
x = 1 - (0.98 / 1); % x position (1 column)
y = 1 - (0.98 / 1); % y position (1 row)
axWidth = 0.96;
axHight = 0.96;
axesProp = {'DataAspectRatio' ,'Parent','PlotBoxAspectRatio','XGrid','YGrid'};
axesVal = {[1.0 1.0 1.0], handles.uipanel2, [1.0 1.0 1.0], 'off', 'off'};
ldrDrawing = axes('Position', [x y axWidth axHight], axesProp, axesVal);
imshow(DurandRGB,[]);

setappdata(handles.figure1,'finalImage',DurandRGB);
setappdata(handles.figure1,'ldrDrawing',ldrDrawing);
set(handles.saveFinal,'Enable','on');


% --------------------------------------------------------------------
function gammaC_Callback(hObject, eventdata, handles)
% hObject    handle to gammaC (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% reset
if isappdata(handles.figure1,'ldrDrawing')
    ax = getappdata(handles.figure1,'ldrDrawing');
    cla(ax);
    rmappdata(handles.figure1,'ldrDrawing');
end

if isappdata(handles.figure1,'finalImage')
    rmappdata(handles.figure1,'finalImage');
end

gamma = getappdata(handles.figure1,'GAMMA_gammaVal');
radMap = getappdata(handles.figure1,'radMap');
h = waitbar(0, 'Performing tone mapping...'); % start progress bar
GammaRGB = toneMapGamma(radMap, gamma);
waitbar(1.0); % start progress bar
close(h);

imageProp = {'ButtonDownFcn'};
imageVal = {'enlargeImage( guidata(gcf) )'};
x = 1 - (0.98 / 1); % x position (1 column)
y = 1 - (0.98 / 1); % y position (1 row)
axWidth = 0.96;
axHight = 0.96;
axesProp = {'DataAspectRatio' ,'Parent','PlotBoxAspectRatio','XGrid','YGrid'};
axesVal = {[1.0 1.0 1.0], handles.uipanel2, [1.0 1.0 1.0], 'off', 'off'};
ldrDrawing = axes('Position', [x y axWidth axHight], axesProp, axesVal);
imshow(GammaRGB,[]);

setappdata(handles.figure1,'finalImage',GammaRGB);
setappdata(handles.figure1,'ldrDrawing',ldrDrawing);
set(handles.saveFinal,'Enable','on');


% --------------------------------------------------------------------
function iCAM06_Callback(hObject, eventdata, handles)
% hObject    handle to iCAM06 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% reset
if isappdata(handles.figure1,'ldrDrawing')
    ax = getappdata(handles.figure1,'ldrDrawing');
    cla(ax);
    rmappdata(handles.figure1,'ldrDrawing');
end

if isappdata(handles.figure1,'finalImage')
    rmappdata(handles.figure1,'finalImage');
end
%gamma = getappdata(handles.figure1,'GAMMA_gammaVal');
radMap = getappdata(handles.figure1,'radMap');
h = waitbar(0, 'Performing tone mapping...'); % start progress bar
GammaRGB = iCAM06_HDR(radMap);
waitbar(1.0); % start progress bar
close(h);

imageProp = {'ButtonDownFcn'};
imageVal = {'enlargeImage( guidata(gcf) )'};
x = 1 - (0.98 / 1); % x position (1 column)
y = 1 - (0.98 / 1); % y position (1 row)
axWidth = 0.96;
axHight = 0.96;
axesProp = {'DataAspectRatio' ,'Parent','PlotBoxAspectRatio','XGrid','YGrid'};
axesVal = {[1.0 1.0 1.0], handles.uipanel2, [1.0 1.0 1.0], 'off', 'off'};
ldrDrawing = axes('Position', [x y axWidth axHight], axesProp, axesVal);
imshow(GammaRGB,[]);

setappdata(handles.figure1,'finalImage',GammaRGB);
setappdata(handles.figure1,'ldrDrawing',ldrDrawing);
set(handles.saveFinal,'Enable','on');


% --------------------------------------------------------------------
function iCAM02_Callback(hObject, eventdata, handles)
% hObject    handle to iCAM02 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% reset
if isappdata(handles.figure1,'ldrDrawing')
    ax = getappdata(handles.figure1,'ldrDrawing');
    cla(ax);
    rmappdata(handles.figure1,'ldrDrawing');
end

if isappdata(handles.figure1,'finalImage')
    rmappdata(handles.figure1,'finalImage');
end
%gamma = getappdata(handles.figure1,'GAMMA_gammaVal');
radMap = getappdata(handles.figure1,'radMap');
h = waitbar(0, 'Performing tone mapping...'); % start progress bar
GammaRGB = render_hdr(radMap);
waitbar(1.0); % start progress bar
close(h);

imageProp = {'ButtonDownFcn'};
imageVal = {'enlargeImage( guidata(gcf) )'};
x = 1 - (0.98 / 1); % x position (1 column)
y = 1 - (0.98 / 1); % y position (1 row)
axWidth = 0.96;
axHight = 0.96;
axesProp = {'DataAspectRatio' ,'Parent','PlotBoxAspectRatio','XGrid','YGrid'};
axesVal = {[1.0 1.0 1.0], handles.uipanel2, [1.0 1.0 1.0], 'off', 'off'};
ldrDrawing = axes('Position', [x y axWidth axHight], axesProp, axesVal);
imshow(GammaRGB,[]);

setappdata(handles.figure1,'finalImage',GammaRGB);
setappdata(handles.figure1,'ldrDrawing',ldrDrawing);
set(handles.saveFinal,'Enable','on');

% --------------------------------------------------------------------
function xlrcam_Callback(hObject, eventdata, handles)
% hObject    handle to xlrcam (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if isappdata(handles.figure1,'ldrDrawing')
    ax = getappdata(handles.figure1,'ldrDrawing');
    cla(ax);
    rmappdata(handles.figure1,'ldrDrawing');
end

if isappdata(handles.figure1,'finalImage')
    rmappdata(handles.figure1,'finalImage');
end
%gamma = getappdata(handles.figure1,'GAMMA_gammaVal');
radMap = getappdata(handles.figure1,'radMap');
h = waitbar(0, 'Performing tone mapping...'); % start progress bar
GammaRGB = xlrcam(radMap);
waitbar(1.0); % start progress bar
close(h);

imageProp = {'ButtonDownFcn'};
imageVal = {'enlargeImage( guidata(gcf) )'};
x = 1 - (0.98 / 1); % x position (1 column)
y = 1 - (0.98 / 1); % y position (1 row)
axWidth = 0.96;
axHight = 0.96;
axesProp = {'DataAspectRatio' ,'Parent','PlotBoxAspectRatio','XGrid','YGrid'};
axesVal = {[1.0 1.0 1.0], handles.uipanel2, [1.0 1.0 1.0], 'off', 'off'};
ldrDrawing = axes('Position', [x y axWidth axHight], axesProp, axesVal);
imshow(GammaRGB,[]);

setappdata(handles.figure1,'finalImage',GammaRGB);
setappdata(handles.figure1,'ldrDrawing',ldrDrawing);
set(handles.saveFinal,'Enable','on');



% --- Executes on mouse press over axes background.
function red_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to red (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

newFig = figure();
ax = copyobj(hObject,newFig);
set(ax,'ActivePositionProperty', 'outerposition', 'Box', 'on', 'OuterPosition', [0 0 1 1], 'Position', [0.13 0.11 0.775 0.815], 'Units', 'normalized');


% --- Executes on mouse press over axes background.
function green_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to green (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

newFig = figure();
ax = copyobj(hObject,newFig);
set(ax,'ActivePositionProperty', 'outerposition', 'Box', 'on', 'OuterPosition', [0 0 1 1], 'Position', [0.13 0.11 0.775 0.815], 'Units', 'normalized');


% --- Executes on mouse press over axes background.
function blue_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to blue (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

newFig = figure();
ax = copyobj(hObject,newFig);
set(ax,'ActivePositionProperty', 'outerposition', 'Box', 'on', 'OuterPosition', [0 0 1 1], 'Position', [0.13 0.11 0.775 0.815], 'Units', 'normalized');


% --------------------------------------------------------------------
function save_Callback(hObject, eventdata, handles)
% hObject    handle to save (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function saveFinal_Callback(hObject, eventdata, handles)
% hObject    handle to saveFinal (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if isappdata(handles.figure1,'finalImage')
    img = getappdata(handles.figure1,'finalImage');
    [fileName, path] = uiputfile({'*.png;','PNG Files'},'Save Final Image');
    
    %return if no values
    if fileName == 0
        return
    end
    
    imwrite(img, fullfile(path, fileName));
end


% --- Executes during object creation, after setting all properties.
function axes10_CreateFcn(hObject, eventdata, handles)
% hObject    handle to axes10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
axes(hObject)
imshow('cosi.png')

% Hint: place code in OpeningFcn to populate axes10


% --- Executes during object creation, after setting all properties.
function axes11_CreateFcn(hObject, eventdata, handles)
% hObject    handle to axes11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
axes(hObject)
imshow('ugr.png')

% Hint: place code in OpeningFcn to populate axes11
