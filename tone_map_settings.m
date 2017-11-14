%% Ke Ma, Christopher Bodden
% CS 766 - Project 1 (HDR)

%% Settings GUI for tone mapping
function varargout = tone_map_settings(varargin)
% TONE_MAP_SETTINGS MATLAB code for tone_map_settings.fig
%      TONE_MAP_SETTINGS, by itself, creates a new TONE_MAP_SETTINGS or raises the existing
%      singleton*.
%
%      H = TONE_MAP_SETTINGS returns the handle to a new TONE_MAP_SETTINGS or the handle to
%      the existing singleton*.
%
%      TONE_MAP_SETTINGS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in TONE_MAP_SETTINGS.M with the given input arguments.
%
%      TONE_MAP_SETTINGS('Property','Value',...) creates a new TONE_MAP_SETTINGS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before tone_map_settings_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to tone_map_settings_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help tone_map_settings

% Last Modified by GUIDE v2.5 16-Feb-2015 06:42:40

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @tone_map_settings_OpeningFcn, ...
    'gui_OutputFcn',  @tone_map_settings_OutputFcn, ...
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


% --- Executes just before tone_map_settings is made visible.
function tone_map_settings_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to tone_map_settings (see VARARGIN)

% Choose default command line output for tone_map_settings
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes tone_map_settings wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = tone_map_settings_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on slider movement.
function gamma_slider_Callback(hObject, eventdata, handles)
% hObject    handle to gamma_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

sliderPos = roundn(get(hObject,'Value'), -2);
set(hObject,'Value', sliderPos);
set(handles.gamma_text,'String', num2str(sliderPos), 'Value', sliderPos);


% --- Executes during object creation, after setting all properties.
function gamma_slider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to gamma_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%closes the figure
delete(hObject);


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% get handles
mainHandles = getappdata(handles.figure1,'mainHandles');

% update gamma
GAMMA_gammaVal = get(handles.gamma_slider, 'Value');
setappdata(mainHandles.figure1,'GAMMA_gammaVal',GAMMA_gammaVal);

% update durand
DURAND_contrastVal = get(handles.durand_slider, 'Value');
setappdata(mainHandles.figure1,'DURAND_contrastVal',DURAND_contrastVal);

% update drago
DRAGO_betaVal = get(handles.drago_slider, 'Value');
setappdata(mainHandles.figure1,'DRAGO_betaVal',DRAGO_betaVal);

% update reinhard
REINHARD_aVal = get(handles.reinhard_slider, 'Value');
setappdata(mainHandles.figure1,'REINHARD_aVal',REINHARD_aVal);

figure1_CloseRequestFcn(handles.figure1, eventdata, handles);


% --- Executes on slider movement.
function durand_slider_Callback(hObject, eventdata, handles)
% hObject    handle to durand_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
sliderPos = roundn(get(hObject,'Value'), 0);
set(hObject,'Value', sliderPos);
set(handles.durand_text,'String', num2str(sliderPos), 'Value', sliderPos);


% --- Executes during object creation, after setting all properties.
function durand_slider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to durand_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function drago_slider_Callback(hObject, eventdata, handles)
% hObject    handle to drago_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
sliderPos = roundn(get(hObject,'Value'), -2);
set(hObject,'Value', sliderPos);
set(handles.drago_text,'String', num2str(sliderPos), 'Value', sliderPos);


% --- Executes during object creation, after setting all properties.
function drago_slider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to drago_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

figure1_CloseRequestFcn(handles.figure1, eventdata, handles);


% --- Executes on slider movement.
function reinhard_slider_Callback(hObject, eventdata, handles)
% hObject    handle to reinhard_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
sliderPos = roundn(get(hObject,'Value'), -2);
set(hObject,'Value', sliderPos);
set(handles.reinhard_text,'String', num2str(sliderPos), 'Value', sliderPos);


% --- Executes during object creation, after setting all properties.
function reinhard_slider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to reinhard_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
