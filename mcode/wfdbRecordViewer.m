function varargout = wfdbRecordViewer(varargin)
% WFDBRECORDVIEWER MATLAB code for wfdbRecordViewer.fig
%      WFDBRECORDVIEWER, by itself, creates a new WFDBRECORDVIEWER or raises the existing
%      singleton*.
%
%      H = WFDBRECORDVIEWER returns the handle to a new WFDBRECORDVIEWER or the handle to
%      the existing singleton*.
%
%      WFDBRECORDVIEWER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in WFDBRECORDVIEWER.M with the given input arguments.
%
%      WFDBRECORDVIEWER('Property','Value',...) creates a new WFDBRECORDVIEWER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before wfdbRecordViewer_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to wfdbRecordViewer_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help wfdbRecordViewer

% Last Modified by GUIDE v2.5 05-Feb-2015 15:38:57

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @wfdbRecordViewer_OpeningFcn, ...
    'gui_OutputFcn',  @wfdbRecordViewer_OutputFcn, ...
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

% --- Executes just before wfdbRecordViewer is made visible.
function wfdbRecordViewer_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to wfdbRecordViewer (see VARARGIN)

global current_record records tm tm_step signalDescription

% Choose default command line output for wfdbRecordViewer
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);
[filename,directoryname] = uigetfile('*.hea','Select signal header file:');
cd(directoryname)
tmp=dir('*.hea');

N=length(tmp);
records=cell(N,1);
current_record=1;
for n=1:N
    fname=tmp(n).name;
    records(n)={fname(1:end-4)};
    if(strcmp(fname,filename))
        current_record=n;
    end
end
set(handles.RecorListMenu,'String',records)
set(handles.RecorListMenu,'Value',current_record)
loadRecord(records{current_record})
set(handles.signalList,'String',signalDescription)
loadAnnotationList(records{current_record},handles);
set(handles.slider1,'Max',tm(end))
set(handles.slider1,'Min',tm(1))
set(handles.slider1,'SliderStep',[1 1]);
sliderStep=get(handles.slider1,'SliderStep');
tm_step=(tm(end)-tm(1)).*sliderStep(1);

wfdbplot(handles)



function varargout = wfdbRecordViewer_OutputFcn(~,~, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Get default command line output from handles structure
varargout{1} = handles.output;

function PreviousButton_Callback(hObject, eventdata, handles)
global current_record records

current_record=current_record - 1;
set(handles.RecorListMenu,'Value',current_record);
Refresh(hObject, eventdata, handles)


function NextButton_Callback(hObject, eventdata, handles)
global current_record records
current_record=current_record + 1;
set(handles.RecorListMenu,'Value',current_record);
Refresh(hObject, eventdata, handles)


% --------------------------------------------------------------------
function FileMenu_Callback(hObject, eventdata, handles)
% hObject    handle to FileMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function OpenMenuItem_Callback(hObject, eventdata, handles)
file = uigetfile('*.fig');
if ~isequal(file, 0)
    open(file);
end

% --------------------------------------------------------------------
function PrintMenuItem_Callback(hObject, eventdata, handles)
printdlg(handles.figure1)

% --------------------------------------------------------------------
function CloseMenuItem_Callback(hObject, eventdata, handles)
selection = questdlg(['Close ' get(handles.figure1,'Name') '?'],...
    ['Close ' get(handles.figure1,'Name') '...'],...
    'Yes','No','Yes');
if strcmp(selection,'No')
    return;
end

delete(handles.figure1)


% --- Executes on selection change in RecorListMenu.
function RecorListMenu_Callback(hObject, eventdata, handles)

global current_record records
current_record=get(handles.RecorListMenu,'Value');
Refresh(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function RecorListMenu_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on slider movement.
function slider1_Callback(hObject, eventdata, handles)
wfdbplot(handles)


% --- Executes during object creation, after setting all properties.
function slider1_CreateFcn(hObject, eventdata, handles)
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

function loadRecord(fname)
global tm signal info tm_step signalDescription analysisSignal analysisTime
h = waitbar(0,'Loading Data. Please wait...');
try
    [tm,signal]=rdmat(fname);
catch
    [tm,signal]=rdsamp(fname);
end
info=wfdbdesc(fname);
R=length(info);
analysisSignal=[];
analysisTime=[];
signalDescription=cell(R,1);
for r=1:R
    signalDescription(r)={info(r).Description};
end
close(h)

function loadAnn1(fname,annName)
global ann1
h = waitbar(0,'Loading Annotations. Please wait...');
if(strcmp(fname,'none'))
    ann1=[];
else
    [ann1,type,subtype,chan,num,comments]=rdann(fname,annName);
end
close(h)

function loadAnn2(fname,annName)
global ann2
h = waitbar(0,'Loading Annotations. Please wait...');
if(strcmp(fname,'none'))
    ann1=[];
else
    [ann2,type,subtype,chan,num,comments]=rdann(fname,annName);
end
close(h)

function loadAnnotationList(fname,handles)
global ann1 ann2 annDiff
ann1=[];
ann2=[];
annDiff=[];
tmp=dir([fname '*']);
annotations={'none'};
exclude={'dat','hea','edf','mat'};
for i=1:length(tmp)
    name=tmp(i).name;
    st=strfind(name,'.');
    if(~isempty(st))
        tmp_ann=name(st+1:end);
        enter=1;
        for k=1:length(exclude)
            if(strcmp(tmp_ann,exclude{k}))
                enter=0;
            end
        end
        if(enter)
            annotations(end+1)={tmp_ann};
        end
    end
end

set(handles.Ann1Menu,'String',annotations)
set(handles.Ann2Menu,'String',annotations)


function wfdbplot(handles)
global tm signal info tm_step ann1 ann2 annDiff ann1RR analysisSignal analysisTime analysisUnits analysisYAxis
axes(handles.axes1);
cla;

%Normalize each signal and plot them with an offset
[N,CH]=size(signal);
offset=0.5;

%Get time info
center=get(handles.slider1,'Value');
maxSlide=get(handles.slider1,'Max');
minSlide=get(handles.slider1,'Min');
if(tm_step == ( tm(end)-tm(1) ))
    tm_start=tm(1);
    tm_end=tm(end);
elseif(center==maxSlide)
    tm_end=tm(end);
    tm_start=tm_end - tm_step;
elseif(center==minSlide)
    tm_start=tm(1);
    tm_end=tm_start + tm_step;
else
    tm_start=center - tm_step/2;
    tm_end=center + tm_step/2;
end
[~,ind_start]=min(abs(tm-tm_start));
[~,ind_end]=min(abs(tm-tm_end));

DC=min(signal(ind_start:ind_end,:),[],1);
sig=signal - repmat(DC,[N 1]);
SCALE=max(sig(ind_start:ind_end,:),[],1);
SCALE(SCALE==0)=1;
sig=offset.*sig./repmat(SCALE,[N 1]);
OFFSET=offset.*[1:CH];
sig=sig + repmat(OFFSET,[N 1]);

for ch=1:CH;
    plot(tm(ind_start:ind_end),sig(ind_start:ind_end,ch))
    hold on ; grid on
    if(~isempty(ann1))
        tmp_ann1=ann1((ann1>ind_start) & (ann1<ind_end));
        if(~isempty(tmp_ann1))
            if(length(tmp_ann1)<30)
                msize=8;
            else
                msize=5;
            end
            plot(tm(tmp_ann1),OFFSET(ch),'go','MarkerSize',msize,'MarkerFaceColor','g')
        end
    end
    if(~isempty(ann2))
        tmp_ann2=ann2((ann2>ind_start) & (ann2<ind_end));
        if(~isempty(tmp_ann2))
            if(length(tmp_ann2)<30)
                msize=8;
            else
                msize=5;
            end
            plot(tm(tmp_ann2),OFFSET(ch),'r*','MarkerSize',msize,'MarkerFaceColor','r')
        end
    end
    if(~isempty(info(ch).Description))
        text(tm(ind_start),ch*offset+0.85*offset,info(ch).Description,'FontWeight','bold','FontSize',12)
    end
    
end
set(gca,'YTick',[])
set(gca,'YTickLabel',[])
set(gca,'FontSize',10)
set(gca,'FontWeight','bold')
xlabel('Time (seconds)')
xlim([tm(ind_start) tm(ind_end)])

%Plot annotations in analysis window
if(~isempty(annDiff) & (get(handles.AnnotationMenu,'Value')==2))
    axes(handles.AnalysisAxes);
    df=annDiff((ann1>ind_start) & (ann1<ind_end));
    plot(tm(tmp_ann1),df,'k*-')
    text(tm(tmp_ann1(1)),max(df),'Ann Diff','FontWeight','bold','FontSize',12)
    grid on
    ylabel('Diff (seconds)')
    xlim([tm(ind_start) tm(ind_end)])
end

%Plot custom signal in the analysis window
if(~isempty(analysisSignal))
    axes(handles.AnalysisAxes);
    if(isempty(analysisYAxis))
        %Standard 2D Plot
        plot(analysisTime,analysisSignal,'k')
        grid on;
    else
        if(isfield(analysisYAxis,'isImage') && analysisYAxis.isImage)
            %Plot scaled image
            imagesc(analysisSignal)
        else
            %3D Plot with colormap
            surf(analysisTime,analysisYAxis.values,analysisSignal,'EdgeColor','none');
            axis xy; axis tight; colormap(analysisYAxis.map); view(0,90);
        end
        ylim([analysisYAxis.minY analysisYAxis.maxY])
    end
    xlim([tm(ind_start) tm(ind_end)])
    if(~isempty(analysisUnits))
        ylabel(analysisUnits)
    end
else
    %Plot RR series in analysis window
    if(~isempty(ann1RR) & (get(handles.AnnotationMenu,'Value')==3))
        Nann=length(ann1);
        axes(handles.AnalysisAxes);
        ind=(ann1(1:end)>ind_start) & (ann1(1:end)<ind_end);
        ind=find(ind==1)+1;
        if(~isempty(ind) && ind(end)> Nann)
            ind(end)=[];
        end
        tm_ind=ann1(ind);
        del_ind=find(tm_ind>N);
        if(~isempty(del_ind))
            ind(ann1(ind)==tm_ind(del_ind))=[];
            tm_ind(del_ind)=[];
        end
        if(~isempty(ind) && ind(end)>length(ann1RR))
            del_ind=find(ind>length(ann1RR));
            ind(del_ind)=[];
            tm_ind(del_ind)=[];
        end
        plot(tm(tm_ind),ann1RR(ind),'k*-')
        text(tm(tm_ind(1)),max(df),'RR Series','FontWeight','bold','FontSize',12)
        grid on
        ylabel('Interval (seconds)')
        if(~isnan(ind_start) && ~isnan(ind_end) && ~(ind_start==ind_end))
            xlim([tm(ind_start) tm(ind_end)])
        end
        
    end
end


% --- Executes on selection change in TimeScaleSelection.
function TimeScaleSelection_Callback(hObject, eventdata, handles)
global tm_step tm

TM_SC=[tm(end)-tm(1) 120 60 30 15 10 5 1];
index = get(handles.TimeScaleSelection, 'Value');
%Normalize step to time range
if(TM_SC(index)>TM_SC(1))
    index=1;
end
stp=TM_SC(index)/TM_SC(1);
set(handles.slider1,'SliderStep',[stp stp*10]);
tm_step=TM_SC(1).*stp(1);

axes(handles.axes1);
cla;
wfdbplot(handles)

% --- Executes during object creation, after setting all properties.
function TimeScaleSelection_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in AmplitudeScale.
function AmplitudeScale_Callback(hObject, eventdata, handles)
wfdbplot(handles)


% --- Executes during object creation, after setting all properties.
function AmplitudeScale_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in Ann1Menu.
function Ann1Menu_Callback(hObject, eventdata, handles)
global ann1 records current_record

ind = get(handles.Ann1Menu, 'Value');
annStr=get(handles.Ann1Menu, 'String');
loadAnn1(records{current_record},annStr{ind})
wfdbplot(handles)


% --- Executes during object creation, after setting all properties.
function Ann1Menu_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in Ann2Menu.
function Ann2Menu_Callback(hObject, eventdata, handles)
global ann2 records current_record

ind = get(handles.Ann2Menu, 'Value');
annStr=get(handles.Ann2Menu, 'String');
loadAnn2(records{current_record},annStr{ind})
wfdbplot(handles)


% --- Executes during object creation, after setting all properties.
function Ann2Menu_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function AnnotationMenu_Callback(hObject, eventdata, handles)

global ann1 ann1RR info tm ann2

tips=0;
Fs=double(info(1).SamplingFrequency);
annStr=get(handles.AnnotationMenu,'String');
index=get(handles.AnnotationMenu,'Value');
switch(annStr{index})
    case 'Plot Annotation Differences'
        h = waitbar(0,'Comparing Annotations. Please wait...');
        annDiff=[];
        %Compare annotation with ann1menu being the reference
        N=length(ann1);
        if(~isempty(ann2))
            [A1,A2]=meshgrid(ann1,ann2);
            annDiff=min(abs(A1-A2))./Fs;
        end
        close(h)
        wfdbplot(handles)
        
    case 'Plot RR Series Ann1'
        h = waitbar(0,'Generating RR Series. Please wait...');
        %Compare annotation with ann1menu being the reference
        ann1RR=diff(ann1)./double(info(1).SamplingFrequency);
        close(h)
        wfdbplot(handles)
        
    case 'Add annotations to Ann1'
        %Get closest sample using ginput
        if(tips)
            helpdlg('Left click to add multiple annotations. Hit Enter when done.','Adding Annotations');
        end
        axes(handles.axes1);
        [x,~]= ginput;
        
        %Convert to samples ann to ann1
        x=round(x*Fs);
        ann1=sort([ann1;x]);
        %Refresh annotation plot
        wfdbplot(handles)
        
    case 'Delete annotations from Ann1'
        
        %Get closest sample using ginput
        if(tips)
            helpdlg('Left click on annotations to remove multiple. Hit Enter when done.','Removing Annotations');
        end
        axes(handles.axes1);
        [x,~]= ginput;
        rmN=length(x);
        rm_ind=zeros(rmN,1);
        for n=1:rmN
            [~,tmp_ind]=min(abs(x(n)-tm(ann1)));
            rm_ind(n)=tmp_ind;
        end
        if~(isempty(rm_ind))
            ann1(rm_ind)=[];
        end
        %Refresh annotation plot
        wfdbplot(handles)
        
    case 'Delete annotations in a range from Ann1'
        
        %Get closest sample using ginput
        if(tips)
            helpdlg('Left click on start and end regions. Hit Enter when done.','Removing Annotations');
        end
        axes(handles.axes1);
        [x,~]= ginput;
        [~,start_ind]=min(abs(x(end-1)-tm(ann1)));
        [~,end_ind]=min(abs(x(end)-tm(ann1)));
        ann1(start_ind:end_ind)=[];
        %Refresh annotation plot
        wfdbplot(handles)
        
    case 'Edit annotations in Ann1'
        %Modify closest sample using ginput
        if(tips)
            helpdlg('Left click on waveform will shift closest annotation to the clicked point. Hit Enter when done.','Adding Annotations');
        end
        axes(handles.axes1);
        [x,~]= ginput;
        editN=length(x);
        edit_ind=zeros(editN,1);
        for n=1:editN
            [~,tmp_ind]=min(abs(x(n)-tm(ann1)));
            edit_ind(n)=tmp_ind;
        end
        if~(isempty(edit_ind))
            ann1(edit_ind)=round(x*Fs);
        end
        %Refresh annotation plot
        wfdbplot(handles)
        
    case 'Add annotations in a range from Ann2 to Ann2'
        global ann2
        if(tips)
            helpdlg('Left click on waveform to select start and end of region to add from Ann2 to Ann1. Hit Enter when done.','Adding Annotations');
        end
        axes(handles.axes1);
        [x,~]= ginput;
        [~,start_ind]=min(abs(x(1)-tm(ann2)));
        [~,end_ind]=min(abs(x(2)-tm(ann2)));
        ann1=sort([ann1;ann2(start_ind:end_ind)]);
        %Refresh annotation plot
        wfdbplot(handles)
        
    case 'Save modified annotations of Ann1'
        global records current_record
        defaultAnn=get(handles.Ann1Menu,'String');
        defaultInd=get(handles.Ann1Menu,'Value');
        defName={[defaultAnn{defaultInd} '_x']};
        newAnn=inputdlg('Enter new annotation name:','Save Annotation',1,defName);
        h=waitbar(0,['Saving annotation file: ' records{current_record} '.' newAnn{1}]);
        wrann(records{current_record},newAnn{1},ann1);
        close(h)
        
end


function AnnotationMenu_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function Refresh(hObject, eventdata, handles)
global records current_record

loadRecord(records{current_record})
loadAnnotationList(records{current_record},handles)
Ann1Menu_Callback(hObject, eventdata, handles)
Ann2Menu_Callback(hObject, eventdata, handles)
%AnalysisMenu_Callback(hObject, eventdata, handles)

% --- Executes on selection change in SignalMenu.
function SignalMenu_Callback(hObject, eventdata, handles)
% hObject    handle to SignalMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns SignalMenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from SignalMenu

global tm signal info analysisSignal analysisTime analysisUnits analysisYAxis
contents = cellstr(get(hObject,'String'));
ind=get(handles.signalList,'Value');
str= contents{get(hObject,'Value')};

%Get Raw Signal
analysisTime=tm;
analysisSignal=signal(:,ind);
analysisUnits=strsplit(info(ind).Gain,'/');
if(length(analysisUnits)>1)
    analysisUnits=analysisUnits{2};
else
    analysisUnits=[];
end
Fs=double(info(ind).SamplingFrequency);
analysisYAxis=[];
switch str
    case 'Plot Raw Signal'
        %default to plot after switch
    case 'Apply General Filter'
        [analysisSignal]=wfdbFilter(analysisSignal);
    case '60/50 Hz Notch Filter'
        [analysisSignal]=wfdbNotch(analysisSignal,Fs);
    case 'Resonator Filter'
        [analysisSignal]=wfdbResonator(analysisSignal,Fs);
    case 'Custom Function'
        [analysisSignal,analysisTime]=wfdbFunction(analysisSignal,analysisTime,Fs);
    case 'Spectogram Analysis'
        [analysisSignal,analysisTime,analysisYAxis,analysisUnits]=wfdbSpect(analysisSignal,Fs);
    case 'Wavelets Analysis'
        [analysisSignal,analysisYAxis,analysisUnits]=wfdbWavelets(analysisSignal,Fs);
    case 'Spatial PCA'
        [analysisSignal,analysisUnits]=wfdbPCA(signal);
    case 'Karhunen-Loeve Expansion'
        [analysisSignal,analysisUnits]=wfdbKL(analysisSignal);
    case 'Track Fundamental'
        [analysisSignal,analysisUnits]=wfdbF1Track(analysisSignal,Fs);
end
if(~isempty(analysisSignal))
    %If analysisSignal is empty, command has been cancelled, else go ahead
    %and plot
    wfdbplot(handles);
end

% --- Executes during object creation, after setting all properties.
function SignalMenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SignalMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in signalList.
function signalList_Callback(hObject, eventdata, handles)
% hObject    handle to signalList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns signalList contents as cell array
%        contents{get(hObject,'Value')} returns selected item from signalList


% --- Executes during object creation, after setting all properties.
function signalList_CreateFcn(hObject, eventdata, handles)
% hObject    handle to signalList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function [analysisSignal]=wfdbFilter(analysisSignal)

%Set Low-pass default values
persistent dlgParam

if(isempty(dlgParam)) 
dlgParam.prompt={'Filter Design Function (should return "a" and "b", for use by FILTFILT ):'};
dlgParam.answer='b=fir1(48,[0.1 0.5]);a=1;';
dlgParam.name='Filter Design Command';
dlgParam.numlines=1;
end

answer=inputdlg(dlgParam.prompt,dlgParam.name,dlgParam.numlines,{dlgParam.answer});

if(isempty(answer))
    analysisSignal=[];
    return;
end
h = waitbar(0,'Filtering Data. Please wait...');
dlgParam.answer=answer{1};
try
    eval([dlgParam.answer ';']);
    analysisSignal=filtfilt(b,a,analysisSignal);
catch
    errordlg(['Unable to filter data! Error: ' lasterr])
end
close(h)


function [analysisSignal]=wfdbNotch(analysisSignal,Fs)
% References:
% *Rangayyan (2002), "Biomedical Signal Analysis", IEEE Press Series in BME
%
% *Hayes (1999), "Digital Signal Processing", Schaum's Outline
%Set Low-pass default values

persistent dlgParam

if(isempty(dlgParam)) 
dlgParam.prompt={'Control Paramter (0 < r < 1 ):','Notch Frequency (Hz):'};
dlgParam.r='0.995';
dlgParam.fn='60';
dlgParam.name='Notch Filter Design';
dlgParam.numlines=1;
end

answer=inputdlg(dlgParam.prompt,dlgParam.name,dlgParam.numlines,...
    {dlgParam.r, dlgParam.fn});
if(isempty(answer))
    analysisSignal=[];
    return;
end

h = waitbar(0,'Filtering Data. Please wait...');
dlgParam.r = answer{1};   % Control parameter. 0 < r < 1.
dlgParam.fn= answer{2};

r = str2num(dlgParam.r);   % Control parameter. 0 < r < 1.
fn= str2num(dlgParam.fn);

cW = cos(2*pi*fn/Fs);
b=[1 -2*cW 1];
a=[1 -2*r*cW r^2];
try
    eval([answer{1} ';']);
    analysisSignal=filtfilt(b,a,analysisSignal);
catch
    errordlg(['Unable to filter data! Error: ' lasterr])
end
close(h)


function [analysisSignal]=wfdbResonator(analysisSignal,Fs)
% References:
% *Rangayyan (2002), "Biomedical Signal Analysis", IEEE Press Series in BME
%
% *Hayes (1999), "Digital Signal Processing", Schaum's Outline
%Set Low-pass default values

persistent dlgParam

if(isempty(dlgParam))
dlgParam.prompt={'Resonating Frequency (Hz):','Q factor:'};
dlgParam.fn=num2str(Fs/5);
dlgParam.K='50';
dlgParam.name='Resonator Filter Design';
dlgParam.numlines=1;
end

answer=inputdlg(dlgParam.prompt,dlgParam.name,dlgParam.numlines,...
    {dlgParam.fn,dlgParam.fn});
if(isempty(answer))
    analysisSignal=[];
    return;
end


h = waitbar(0,'Filtering Data. Please wait...');
dlgParam.fn= answer{1};
dlgParam.K= answer{2};

%Similar  to 'Q1' but more accurate
%For details see IEEE SP 2008 (5), pg 113
K=str2num(dlgParam.K);
fn=str2num(dlgParam.fn);
beta=1+K;
f=pi*fn/Fs;
numA=tan(pi/4 - f);
denA=sin(2*f)+cos(2*f)*numA;
A=numA/denA;
b=[1 -2*A A.^2];
a=[ (beta + K*(A^2)) -2*A*(beta+K) ((A^2)*beta + K)];

try
    eval([answer{1} ';']);
    analysisSignal=filtfilt(b,a,analysisSignal);
catch
    errordlg(['Unable to filter data! Error: ' lasterr])
end
close(h)


function [analysisSignal,analysisTime]=wfdbFunction(analysisSignal,analysisTime,Fs)

persistent dlgParam

if(isempty(dlgParam))
dlgParam.prompt={'Custom Function must output variables ''analysisSignal'' and ''analysisTime'''};
dlgParam.answer={'[analysisSignal,analysisTime]=foo(analysisSignal,analysisTime,Fs)'};
dlgParam.name='Evaluate Command:';
end

answer=inputdlg(dlgParam.prompt,dlgParam.name,dlgParam.numlines,dlgParam.answer);
if(isempty(answer))
    analysisSignal=[];
    analysisTime=[];
    return;
end

dlgParam.answer=answer{1};
h = waitbar(0,'Executing code on signal. Please wait...');
try
    eval([dlgParam.answer ';']);
catch
    errordlg(['Unable to execute code!! Error: ' lasterr])
end
close(h)


function [analysisSignal,analysisTime,analysisYAxis,analysisUnits]=wfdbSpect(analysisSignal,Fs)

persistent dlgParam
if(isempty(dlgParam))
    dlgParam.prompt={'window size','overlap size','Min Frequency (Hz)','Max Frequency (Hz)','colormap'};
    dlgParam.window=2^10;
    dlgParam.minY= 0;
    dlgParam.maxY= floor(Fs/2);
    dlgParam.noverlap=round(dlgParam.window/2);
    dlgParam.map='jet';
    dlgParam.name='Spectogram Parameters';
    dlgParam.numlines=1;
end

dlgParam.defaultanswer={num2str(dlgParam.window),num2str(dlgParam.noverlap),...
    num2str(dlgParam.minY),num2str(dlgParam.maxY),dlgParam.map};

answer=inputdlg(dlgParam.prompt,dlgParam.name,dlgParam.numlines,dlgParam.defaultanswer);
if(isempty(answer))
    analysisSignal=[];
    analysisUnits=[];
    analysisYAxis=[];
    analysisTime=[];
    return;
end

h = waitbar(0,'Calculating spectogram. Please wait...');
dlgParam.window= str2num(answer{1});
dlgParam.noverlap= str2num(answer{2});
analysisYAxis.minY= str2num(answer{3});
analysisYAxis.maxY= str2num(answer{4});
analysisYAxis.map=answer{5};

dlgParam.minY=analysisYAxis.minY;
dlgParam.maxY=analysisYAxis.maxY;
dlgParam.map=analysisYAxis.map;

[~,F,analysisTime,analysisSignal] = spectrogram(analysisSignal,dlgParam.window,...
    dlgParam.noverlap,dlgParam.window,Fs,'yaxis');

analysisSignal=10*log10(abs(analysisSignal));
analysisYAxis.values=F;
analysisUnits='Frequency (Hz)';
close(h)


function [analysisSignal,analysisYAxis,analysisUnits]=wfdbWavelets(analysisSignal,Fs)

persistent dlgParam
if(isempty(dlgParam))
    dlgParam.prompt={'wavelet','scales','colormap','logScale'};
    dlgParam.wavelet='coif2';
    dlgParam.scales='1:28';
    dlgParam.map='jet';
    dlgParam.log='false';
    dlgParam.name='Wavelet Parameters';
    dlgParam.numlines=1;
end

dlgParam.defaultanswer={num2str(dlgParam.wavelet),num2str(dlgParam.scales),dlgParam.map,dlgParam.log};

answer=inputdlg(dlgParam.prompt,dlgParam.name,dlgParam.numlines,dlgParam.defaultanswer);
if(isempty(answer))
    analysisSignal=[];
    analysisUnits=[];
    analysisYAxis=[];
    return;
end

h = waitbar(0,'Calculating wavelets. Please wait...');
dlgParam.wavelet= answer{1};
dlgParam.scales = str2num(answer{2});
dlgParam.map= answer{3};
dlgParam.log= answer{4};
analysisYAxis.minY= dlgParam.scales(1);
analysisYAxis.maxY= dlgParam.scales(end);
analysisYAxis.map=dlgParam.map;
analysisYAxis.isImage=1;

coefs = cwt(analysisSignal,dlgParam.scales,dlgParam.wavelet);
analysisSignal = wscalogram('',coefs);
if(strcmp(dlgParam.log,'true'))
    analysisSignal=log(analysisSignal);
end
analysisYAxis.values=dlgParam.scales;
analysisUnits='Scale';
close(h)

function [analysisSignal,analysisUnits]=wfdbPCA(signal)

persistent dlgParam

if(isempty(dlgParam))
dlgParam.M=['1:' num2str(size(signal,2))];
dlgParam.P='1';
dlgParam.prompt={'Indices of signals to include in PCA:',...
    'Selecta a Principal Component (equal or less than the number of indices above):'};
dlgParam.name='Parameters for ploting principal component';
dlgParam.numlines=1;
end

answer=inputdlg(dlgParam.prompt,dlgParam.name,dlgParam.numlines, {dlgParam.M, ...
    dlgParam.P});
if(isempty(answer))
    analysisSignal=[];
    analysisUnits=[];
    return;
end

dlgParam.M=answer{1};
dlgParam.P=answer{2};   
h = waitbar(0,'Estimating K-L Basis. Please wait...');
analysisUnits='Amplitude';

signal=signal(:,str2num(dlgParam.M));
[u,~,~]=svd(signal,0);
ind=str2num(dlgParam.P);
analysisSignal=u(:,ind);
close(h)


function [analysisSignal,analysisUnits]=wfdbKL(signal)

persistent dlgParam
maxM=11;
if(isempty(dlgParam))
dlgParam.P='1';
dlgParam.prompt={['Select index of desired Principal Component (<= ' num2str(maxM) ') :']};
dlgParam.numlines=1;
dlgParam.name='Parameters for K-L Expansion';
end

answer=inputdlg(dlgParam.prompt,dlgParam.name,dlgParam.numlines, {dlgParam.P});
if(isempty(answer))
    analysisSignal=[];
    analysisUnits=[];
    return;
end

dlgParam.P=answer{1};   
h = waitbar(0,'Estimating fundamental frequency. Please wait...');
analysisUnits='Amplitude';

signal=signal-mean(signal);
ind=num2str(dlgParam.P);
R=corrmtx(signal,maxM);
[u,s,v]=svd(R,0);
N=length(signal);
ind=str2num(dlgParam.P);
analysisSignal=u(1:N,ind);
close(h)




function [analysisSignal,analysisUnits]=wfdbF1Track(analysisSignal,Fs)

persistent dlgParam

if(isempty(dlgParam))
dlgParam.prompt={'Order of how many harmonics to track:',...
    'Initial guess of the fundamental frequency (Hz)', 'Step size of the LMS algorithm',...
    'Magnitude of the pole for the harmonic comb filter'};
dlgParam.P='3';
dlgParam.theta='[]';
dlgParam.mu='10^-3';
dlgParam.r='0.85';
dlgParam.answer={'[analysisSigal,analysisTime]=foo(analysisSignal,analysisTime,Fs)'};
dlgParam.name='Parameters for tracking fundamental frequency';
dlgParam.numlines=1;
end

answer=inputdlg(dlgParam.prompt,dlgParam.name,dlgParam.numlines, {dlgParam.P, ...
    dlgParam.theta,dlgParam.mu,dlgParam.r});

if(isempty(answer))
    analysisSignal=[];
    analysisUnits=[];
    return;
end

dlgParam.P=answer{1};
dlgParam.theta=answer{2};
dlgParam.mu=answer{3};
dlgParam.r=answer{4};

if(strcmp(dlgParam.theta,'[]'))
    %use peak on low range of FFT as an estimate
    [Pxx,F] = pwelch(analysisSignal,[],[],[],Fs);
    FUP=100;
    [~,maxInd]=min(abs(F-FUP));
    [~,maxP]=max(Pxx(1:maxInd));
    dlgParam.theta=num2str(F(maxP));
end
    
h = waitbar(0,'Estimating fundamental frequency. Please wait...');
analysisSignal=harmonic_est(analysisSignal,str2num(dlgParam.P),Fs,...
    str2num(dlgParam.theta),str2num(dlgParam.mu),str2num(dlgParam.r));
analysisUnits='Hz';
close(h)


function theta_curve=harmonic_est(x,varargin)
%
%[theta_curve]=harmonic_est(x,P,Fs,theta,mu,r)
% Implements harmonic frequency tracking algorithm as described in
% IEEE Signal Processing Magazine (189) 11/09 by Tan and Jiang.
% Parameters are:
%
% Input:
%     x     - (Nx1, required) Signal to be tracked
%     P     - (1x1, required) Order of how many harmonics (including fundamental)
%              to be estimated.
%     Fs    - (1x1, optional) Sampling frequency (Hz). If present output is returned
%             in Hertz, if absent output is returned in radians.
%     theta - (1x1, optional) Initial guess of the fundamental frequency capture range.
%     mu    - (1x1, optional) Step size of the LMS algorithm.
%     r     - (1x1, optinoal) Magnitude of the pole for the harmonic comb filter
%             (0<r<1).
%
% Output:
%     theta -       (1x1,required) Final estimate of the fundamental frequency.
%     theta_curve - (Nx1,optional) Tracking curve of the instantenous fundamental
%                                  frequency.
%     b-            (1xP,optional) b coefficients of the comb filter.
%     a-            (1xP,optional) a coefficients fo the comb filter.
%
%
% %Example
% clear all;close all;clc
% N=1200;
% Fs=8000;
% tm=[0:1/Fs:(N-1)/Fs]';
% t=[0:400:N]+1;
% snr=10^(-18/20);
% F=[1000 1075 975];
% x=[];
% true=[];
% for i=1:3
%     T=2*pi*F(i).*tm(t(i):t(i+1)-1);
%     sig=sin(T)+0.5*cos(T*2)+0.25*cos(T*3)+randn(N/3,1).*snr;
%     x=[x;sig];
%     true=[true;ones(N/3,1)*F(i)];
% end
%
% [theta,theta_curve,b,a]=harmonic_est(x,3,Fs);
% subplot(211)
% plot(tm,theta_curve)
% hold on
% plot(tm,true,'r--','LineWidth',3)
% grid on
% xlabel('Time')
% ylabel('Fundamental Frequency Estimate')
% legend('Tracking','True')
% subplot(212)
% [H,F]=freqz(b,a,N,Fs);
% plot(F,log10(abs(H)))
% title('Final Comb Filter')
% xlabel('Frequency')
% ylabel('Magnitude')
%%%  Written by Ikaro Silva, 2010


[N,M]=size(x);
step=500;
r= 0.85;
Fs=[];
theta=[];
mu=10^-3;


P=varargin{1}; %required
if(nargin>2 && ~isempty(varargin{2}) )
    Fs=varargin{2};
end
if(nargin>3 && ~isempty(varargin{3}) )
    theta=varargin{3};
end
if(nargin>4 && ~isempty(varargin{4}) )
    mu=varargin{4};
end
if(nargin>5 && ~isempty(varargin{5}) )
    r=varargin{5};
end

THETA=linspace(0,pi/P,step);
F=THETA;
Ntheta=length(THETA);
MSE=zeros(Ntheta,1);
MSE1=zeros(Ntheta,1);

if(isempty(theta))
    %Default guess to a frequency on the low range
   theta=60; 
end

%Step 1- Convert theta to radians
theta=theta*2*pi/Fs;

%Step 2 - Apply LMS to optimize Theta
beta=zeros(P+1,1);
ym=zeros(P+1,1);
theta_curve=zeros(N,1)+NaN;
ym_old=zeros(P+1,2);
beta_old=zeros(P+1,2);
ym_const=zeros(P+1,2);
ym_old(1,:)=[0 0];

for n=1:N
    
    ym=rec_step(ym_old,ym_const,x(n),theta,P+1,r);
    beta=rec_step(beta_old,ym_old(:,1),0,theta,P+1,r);
    
    ym_old=[ym ym_old(:,1)];
    beta_old=[beta beta_old(:,1)];
    
    theta_curve(n)=theta;
    theta= theta - 2*mu*ym(end)*beta(end);
end

theta_curve=theta_curve*Fs/(2*pi);



function out = rec_step(out_old,const,init,theta,P,r)

out=zeros(P,1);
out(1)=init;

for p=2:P
    
    w=(p-1)*theta;
    out(p)= out(p-1) - 2*cos(w)*out_old(p-1,1) + ...
        2*(p-1)*sin(w)*const(p-1) + out_old(p-1,2) + ...
        2*r*cos(w)*out_old(p,1) - (r^2)*out_old(p,2) - ...
        2*r*(p-1)*sin(w)*const(p);
end
