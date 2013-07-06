function varargout = PLCSim(varargin)
% PLCSIM MATLAB code for PLCSim.fig
%      PLCSIM, by itself, creates a new PLCSIM or raises the existing
%      singleton*.
%
%      H = PLCSIM returns the handle to a new PLCSIM or the handle to
%      the existing singleton*.
%
%      PLCSIM('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in PLCSIM.M with the given input arguments.
%
%      PLCSIM('Property','Value',...) creates a new PLCSIM or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before PLCSim_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to PLCSim_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help PLCSim

% Last Modified by GUIDE v2.5 01-Jul-2013 22:47:12

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @PLCSim_OpeningFcn, ...
                   'gui_OutputFcn',  @PLCSim_OutputFcn, ...
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

NET.addAssembly ('C:\Users\slombard.KINGDOM\Documents\Visual Studio 2010\Projects\PLCSimConnector\PLCSimConnector\bin\Debug\PLCSimConnector.dll');


% --- Executes just before PLCSim is made visible.
function PLCSim_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to PLCSim (see VARARGIN)

% Choose default command line output for PLCSim
handles.output = hObject;
sys = get_param(gcs, 'Handle');
connect = find_system(sys, 'MaskType','PLCSimConnect');
projPath = get_param(connect, 'projectFile');
proj = PLCSimConnector.PCS7Project(projPath);
handles.project = proj;
% Update handles structure
guidata(hObject, handles);

set (handles.popupmenu1, 'String', transpose(cell(proj.GetOutputImageSymbols())));
% UIWAIT makes PLCSim wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = PLCSim_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in popupmenu1.
function popupmenu1_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu1

proj = handles.project;
contents = cellstr(get(hObject,'String'));
v = contents{get(hObject,'Value')};
entry = proj.PCS7SymbolTable.GetEntryFromSymbol(v);
v = char(entry.OperandIEC);
set(handles.addressText, 'String', char(entry.OperandIEC));
set(handles.dataTypeText, 'String', char(entry.DataType));
set(handles.descriptionText, 'String', char(entry.Comment));

% --- Executes during object creation, after setting all properties.
function popupmenu1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
