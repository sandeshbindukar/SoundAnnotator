function varargout = SoundAnnotatorGUI(varargin)
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @SoundAnnotatorGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @SoundAnnotatorGUI_OutputFcn, ...
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

% --- The code is executed before GUI is made visible.
function SoundAnnotatorGUI_OpeningFcn(hObject, eventdata, handles, varargin)
handles.output = hObject;
guidata(hObject, handles);

%GLOBAL DECLARATIONS OF THE VARIABLE-------------------------------------------------------
global playing_var_track1 % keep track whether var_track 1 is currently playing.
global loaded_var_track1 % keep track whether var_track 1 is loaded.
global pause_var_track1; %keep track whether var_track 1 is paused or not.
global storedata_var_track1; %keep track of the data for var_track 1.
playing_var_track1 = false; 
loaded_var_track1 = false;
pause_var_track1 = false;
storedata_var_track1 = 0;

global playing_var_track2 % keep track whether var_track 2 is currently playing.
global loaded_var_track2 % keep track whether var_track 2 is loaded.
global pause_var_track2; %keep track whether var_track 2 is paused.
global storedata_var_track2; %keep track of the data for var_track 2.
playing_var_track2 = false;
loaded_var_track2 = false;
pause_var_track2 = false;
storedata_var_track2 = 0;

global var_track_sample_rate; %Stores the sample rate to apply to the var_tracks.
var_track_sample_rate = 48000; %default value
global var_track_change_speed;
var_track_change_speed = false;
%END-----------------------------------------------------------------------

%Function which plays the selected sound file
function fn_play_track(var_track) 
if var_track == 1
    global track1;
    global playing_var_track1;
    global loaded_var_track1;
    global pause_var_track1;
    if ~playing_var_track1 && loaded_var_track1
        resume(track1);
        playing_var_track1 = true;
        pause_var_track1 = false;
    end
elseif var_track == 2
    global track2;
    global playing_var_track2;
    global loaded_var_track2;
    global pause_var_track2;
    if ~playing_var_track2 && loaded_var_track2
        resume(track2);
        playing_var_track2 = true;
        pause_var_track2 = false;
    end
end

%Function to pause currenly playing track
function fn_pause_track(var_track) 
if var_track == 1
    global track1;
    global playing_var_track1;
    global pause_var_track1;  
    playing_var_track1 = false;
    pause_var_track1 = true;
    pause(track1);
elseif var_track == 2
    global track2;
    global playing_var_track2;
    global pause_var_track2;
    playing_var_track2 = false;
    pause_var_track2 = true;
    pause(track2);
end

function fn_stop_track(handles, var_track) 
%Function to stop the current track and reset it to the start
if var_track == 1
    global loaded_var_track1;
    global track1;
    global playing_var_track1;
    global pause_var_track1;  
    if loaded_var_track1 %if track 1 is loaded
        playing_var_track1 = false;
        pause_var_track1 = false;
        stop(track1);
        set(handles.track1slider, 'VALUE', get(handles.track1slider, 'MIN')); %resets the track 1 slider.
        set(handles.sliderText1, 'String', round(handles.track1slider.Value, 1)); %resets the track1 slider label.
    end
elseif var_track == 2 
    global loaded_var_track2;
    global track2;
    global playing_var_track2;
    global pause_var_track2;
    if loaded_var_track2 %if track 2 is loaded
        playing_var_track2 = false;
        pause_var_track2 = false;
        stop(track2);
        set(handles.track2slider, 'VALUE', get(handles.track2slider, 'MIN')); %resets the var_track 2 slider.
        set(handles.sliderText2, 'String', round(handles.track2slider.Value, 1)); %resets the var_track 2 slider label.
    end
end

%Function to load the file in the system
function fn_load_file(handles, var_track) 
global var_track_sample_rate;
global var_track_change_speed;
[file_name,path_name] = uigetfile( ...
{'*.wav;*.mp3',...
'Audio Files (*.wav,*.mp3)'; ...
'*wav', 'WAV Files(*.wav)';...
'*mp3', 'MP3 Files(*.mp3)';},...
'Select an audio file'); %different file types like .wav, .mp3

if file_name %Run when user selects the file
    [sData,sRate]=audioread(fullfile(path_name, file_name)); 
    %sData = Sample data, sRate = Sample rate.
    
    if var_track == 1
        global storedata_var_track1;
        global track1;
        global playing_var_track1;
        playing_var_track1 = false;
        global pause_var_track1;
        pause_var_track1 = false;
        global loaded_var_track1;
        loaded_var_track1 = true;
        
         if sRate ~= var_track_sample_rate %if the sample rate of the var_track does not match the global var_track_sample_rate.
             [P,Q] = rat(var_track_sample_rate/sRate); %rational approximation of the global sample rate divided by the var_track's sample rate.
             storedata_var_track1 = resample(sData,P,Q); %resampling to use the new sample rate.
         else
             storedata_var_track1 = sData;
         end
        
        track1 = audioplayer(storedata_var_track1,var_track_sample_rate); %track1 audioplayer object replaced using the resampled data and the global sample rate.
        set(track1,'TimerFcn',{@fn_update_timer,var_track, handles}, 'TimerPeriod', 0.1, 'StopFcn',{@fn_track_end, var_track, handles}); %set the timer function and the stop function.    
        fn_updateUI(storedata_var_track1, var_track_sample_rate, handles, var_track); %updates the UI with the loaded var_track.
    elseif var_track == 2
        global storedata_var_track2;
        global track2;
        global playing_var_track2;
        playing_var_track2 = false;
        global pause_var_track2;
        pause_var_track2 = false;
        global loaded_var_track2;
        loaded_var_track2 = true;
        
        if sRate ~= var_track_sample_rate %if the sample rate of the var_track does not match the global var_track_sample_rate.
            [P,Q] = rat(var_track_sample_rate/sRate); %rational approximation of the global sample rate divided by the var_track's sample rate.
            storedata_var_track2 = resample(sData,P,Q); %resampling to use the new sample rate.
        else
             storedata_var_track2 = sData;
         end
        
        track2 = audioplayer(storedata_var_track2,var_track_sample_rate); %track2 audioplayer object replaced using the resampled data and the global sample rate.
        set(track2,'TimerFcn',{@fn_update_timer,var_track, handles}, 'TimerPeriod', 0.1, 'StopFcn',{@fn_track_end, var_track, handles});%set the timer function and the stop function.       
        fn_updateUI(storedata_var_track2, var_track_sample_rate, handles, var_track); %updates the UI with the loaded var_track.
    end
    if(var_track_change_speed) %if the play speed has been changed it is reset back to default.
        fn_reset_speed(handles);
    end
end

%function to be called when a track is finished
function fn_track_end(~,~,var_track, handles) 
global playing_var_track1;
global playing_var_track2;
if var_track == 1
    if playing_var_track1 == true %passes if the track ended
        playing_var_track1 = false;
        set(handles.track1slider, 'VALUE', get(handles.track1slider, 'MIN')); %set slider for track1 to 0.
        if get(handles.loop1, 'Value') == true %if the loop 1 checkbox is checked, track 1is played again.
            fn_play_track(1);
        end
    end
elseif var_track == 2
    if playing_var_track2 == true %passes if the track ended
        playing_var_track2 = false;
        set(handles.track2slider, 'VALUE', get(handles.track2slider, 'MIN')); %set slider for track2 to 0;
        if get(handles.loop2, 'value') == true %if the loop 2 checkbox is checked,track2 is played again.
            fn_play_track(2);
        end
    end
end

%Function to update the axis when needed
function fn_updateUI(sData, sRate, handles, var_track)
var_time=round((1/sRate)*length(sData),1); %time duration of the tracks in seconds. 
if var_track == 1 % for track 1
    var_axes = handles.mainAxes1;
    var_slider = handles.track1slider;
    set(handles.insertSlider, 'MAX', var_time); %sets the values for the slider.
    set(handles.insertSlider, 'VALUE', 0);
    set(handles.insertSlider, 'MIN', 0);
elseif var_track == 2 % for track 2
    var_axes = handles.mainAxes2;
    var_slider = handles.track2slider;
end
var_ls=linspace(0,var_time,length(sData)); %linspace creates a vector of a number of values equal to the number of samples in the var_track.
plot(var_axes,var_ls,sData); %plots the data onto the axes in UI.
fn_axes_labels(var_axes); %adds labels to the axes in UI.
set(var_slider, 'MAX', var_time); % sets max value from calculating the time duration above
set(var_slider, 'VALUE', 0); %sets default value 0
set(var_slider, 'MIN', 0); %sets minimum value 0

%Function to update the timer in the GUI while playing the track
function fn_update_timer(~,~,var_track, handles)
global var_track_sample_rate;
if var_track == 1
    global track1;
    global storedata_var_track1
    var_slider = handles.track1slider;
    var_text = handles.sliderText1;
    var_time = round(track1.CurrentSample / var_track_sample_rate,1); %time based on the current sample of the track 1.
    sData = storedata_var_track1;   
elseif var_track == 2
    global track2;
    global storedata_var_track2;  
    var_slider = handles.track2slider;
    var_text = handles.sliderText2;
    var_time = round(track2.CurrentSample / var_track_sample_rate,1); %time based on the current sample of the track 2.
    sData = storedata_var_track2;
end
var_end_time = get(var_slider, 'MAX'); %gets the duration of the track from it's associated slider.
if var_time < var_end_time %if the track is not finished.
    set(var_slider, 'VALUE', var_time); %set the slider and label to the current time in the track.
    set(var_text, 'String', var_time);
else %if the track is finished
   set(var_slider, 'VALUE', var_end_time); %set the slider and label of the current time to the end time.
   set(var_text, 'String', var_end_time);
   fn_updateUI(sData,var_track_sample_rate,handles,var_track); %update the UI to indicate the var_track has finished and reset everything.
end

%Function to add the labels to the axes.
function fn_axes_labels(hObject)
axes = hObject;
axes.YLabel.String = 'Signal Strength';
axes.XLabel.String = 'Time(Sec)';

%function to change the speed of the playing track
function fn_change_rate(handles, sampleMultiplier)
global storedata_var_track1;
global storedata_var_track2;
global var_track_sample_rate;
global track1;
global track2;
global playing_var_track1;
global playing_var_track2;
global loaded_var_track1;
global loaded_var_track2;
global var_track_change_speed;
var_track_change_speed = true;

resume1 = playing_var_track1; %check whether either var_track is playing.
resume2 = playing_var_track2;

newRate = var_track_sample_rate * sampleMultiplier; %create the new var_track_sample_rate using the old rate * the multiplier.

if(loaded_var_track1) %if track 1 is loaded.
    track1 = audioplayer(storedata_var_track1, newRate); %create an audioplayer object using the new sample rate and replace the existing audioplayer object with it.
    set(track1,'TimerFcn',{@fn_update_timer,1, handles}, 'TimerPeriod', 0.1, 'StopFcn',{@fn_track_end, 1, handles});
    fn_stop_track(handles,1); %run fn_stop_track function to prepare system to play new var_track.
    if(resume1) %if var_track one was playing when this function was called play the new var_track.
        fn_play_track(1);
    end
end

if(loaded_var_track2)%if track 2 is loaded.
    track2 = audioplayer(storedata_var_track2, newRate); %create an audioplayer object using the new sample rate and replace the existing audioplayer object with it.
    set(track2,'TimerFcn',{@fn_update_timer,2, handles}, 'TimerPeriod', 0.1, 'StopFcn',{@fn_track_end, 2, handles});
    fn_stop_track(handles,2); %run fn_stop_track function to prepare system to play new var_track.
    if(resume2) %if var_track two was playing when this function was called play the new var_track.
        fn_play_track(2);
    end
end

%Function to reset the track speed to default
function fn_reset_speed(handles)
global var_track_change_speed;
if(var_track_change_speed)
    fn_change_rate(handles, 1); %calls the fn_change_rate function to change the multiplier on the sample rate back to 1.
    set(handles.speedSlider, 'Value', 1);
end
var_track_change_speed = false;

%Function to merge the tracks
function fn_combine_tracks(handles)
global loaded_var_track1;
global loaded_var_track2;
global track1;
global track2;
global storedata_var_track1;
global storedata_var_track2;
if loaded_var_track1 && loaded_var_track2 %if both tracks are loaded
    if get(track2, 'NumberOfChannels') == 1 
        %if track 2 has single channel the channel is duplicated.
        storedata_var_track2temp = [storedata_var_track2 storedata_var_track2];
    else
        storedata_var_track2temp = storedata_var_track2;
    end
    if get(track1, 'NumberOfChannels') == 1
        %if track 1 has single channel the channel is duplicated.
        storedata_var_track1 = [storedata_var_track1 storedata_var_track1];
    end
    fn_stop_track(handles,1);
    fn_stop_track(handles,2);
    sData1=get(track1,'TotalSamples');
    sRate1=get(track1,'SampleRate');
    sData2=get(track2,'TotalSamples');
    var_insert_time=round(get(handles.insertSlider,'value')) * sRate1; %insert empty sound in the track based on the slider
    if (sData2+var_insert_time) > sData1
        var_added_time = sData2+var_insert_time-sData1; %empty track is added to make track equal
        var_silence = zeros(var_added_time,2); %create the empty track as a matrix of zeros with two channels.
        storedata_var_track1 = [storedata_var_track1 ; var_silence];
    end
    var_pre_added_time = var_insert_time; %holds the value
    var_pre_silence = zeros(var_pre_added_time,2); %create the empty track to be added before track 1 as a matrix of zeros with two channels. 
    if (sData2+var_insert_time) < sData1
        %In this case track 2 needs to extend
        var_post_added_time = sData1 - var_insert_time - sData2; %empty track is added to make track equal
        var_post_silence = zeros(var_post_added_time,2); %create the empty var_track as a matrix of zeros with two channels.
        storedata_var_track2Manip = [var_pre_silence ; storedata_var_track2temp ; var_post_silence]; %add the empty var_track sections before and after track 2.
    else %else if the two would be equal just add the empty track section prior to track 2.
        storedata_var_track2Manip = [var_pre_silence ; storedata_var_track2temp];
    end
    storedata_var_track1 = storedata_var_track1 + storedata_var_track2Manip; %two tracks are combined.
    track1 = audioplayer(storedata_var_track1,sRate1); %track 1 is updated with the new combined track.
    set(track1,'TimerFcn',{@fn_update_timer,1, handles}, 'TimerPeriod', 0.1, 'StopFcn',{@fn_track_end, 1, handles}); %update the new track with the timer and stop functions.
    fn_updateUI(storedata_var_track1,sRate1,handles,1); %update the ui to reflect the track changes.
end

%Function for saving tracks.
function fn_save_track()
global storedata_var_track1;
global loaded_var_track1;
global var_track_sample_rate;
if loaded_var_track1 %if track 1 is loaded
    folderName = uigetdir('','Select a folder to save into'); %open folder explorer for users to select a folder to save into.
    if folderName
        fileName = inputdlg('Enter a file name:',... %opens a dialog box asking users to enter a file name.
                     'Choose file name', [1 50]);
        if length(fileName) == 1 %Checks if a name was selected.
            path = strcat(folderName,'\',fileName,'.wav'); %formulates the filepath to save too from the selected folder and the filename.
            if exist(path{1}, 'file') == 2 %if the filename already exists create a dialog box asking if the user wants to overwrite existing file.
                confirmation = questdlg('That file already exists. Overwrite existing file?','File already exists','Yes','No','No');
                 if strcmp(confirmation,'Yes') %if the user selects yes save the file
                    audiowrite(path{1},storedata_var_track1,var_track_sample_rate);
                 end
            else
                audiowrite(path{1},storedata_var_track1,var_track_sample_rate); %save the data to the specified path.
            end
        end
    end
end


%There is no more core functionality code below here. ALL callbacks and creaefcn's are
%created automatically by MATLAB when designing through GUIDE
function varargout = SoundAnnotatorGUI_OutputFcn(hObject, eventdata, handles) 
varargout{1} = handles.output;

% --- Executes when insert sider is moved and add listener
function insertSlider_Callback(hObject, eventdata, handles)
addlistener(handles.insertSlider,'Value','PostSet',@(s,e) set(handles.insertTime, 'String', round(handles.insertSlider.Value, 1)));

% --- Executes when running the application
function track1slider_CreateFcn(hObject, eventdata, handles)
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

% --- Executes when pause button is pressed and call function to pause the
% track.
function pause_button_1_Callback(hObject, eventdata, handles)
fn_pause_track(1);
function pauseButton2_Callback(hObject, eventdata, handles)
fn_pause_track(2);

% --- Executes when play button is pressed and call function to play the
% track.
function play_button_1_Callback(hObject, eventdata, handles)
fn_play_track(1);
function playButton2_Callback(hObject, eventdata, handles)
fn_play_track(2);

% ---  Executes when stop button 1 is pressed and call function to stop the track. 
function stopButton1_Callback(hObject, eventdata, handles)
fn_stop_track(handles,1);

% --- Executes when stop button 2 is pressed and call function to stop the track. 
function stopButton2_Callback(hObject, eventdata, handles)
fn_stop_track(handles,2);

% --- Executes when select file 1 button is presssed and call function to load file.
function selectFile1_Callback(hObject, eventdata, handles)
fn_load_file(handles,1);

% --- Executes when select file 2 button is pressed and call function to
% load file.
function selectFile2_Callback(hObject, eventdata, handles)
fn_load_file(handles,2);

% --- Executes when combineButton is pressed and call function to combine/merge tracks.
function combineButton_Callback(hObject, eventdata, handles)
fn_combine_tracks(handles);

% --- Executes when runing the system and call function which display the
% axes.
function mainAxes1_CreateFcn(hObject, eventdata, handles)
fn_axes_labels(hObject);

% --- Executes when runing the system
function track2slider_CreateFcn(hObject, eventdata, handles)
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

% --- Executes when the save button 1 is pressed and call function to save
% the track
function saveButton1_Callback(hObject, eventdata, handles)
fn_save_track();


function insertSlider_CreateFcn(hObject, eventdata, handles)
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

% --- Executes when runing the system
function slider4_CreateFcn(hObject, eventdata, handles)
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

% ---Function to assign axes and is called during creation
function mainAxes2_CreateFcn(hObject, eventdata, handles)
fn_axes_labels(hObject);

%Loop function callback when the loop check box is marked
function loop1_Callback(hObject, eventdata, handles)
function loop2_Callback(hObject, eventdata, handles)

% --- Executes when the reset button is clicked
function reset_Callback(hObject, eventdata, handles)
%calls the fn_reset_speed function to reset the playing speed to it's default speed.
fn_reset_speed(handles);

% --- Runs when the slider is moved.
function speedSlider_Callback(hObject, eventdata, handles)
%add an event listener to the value property of the slider to change the
%label as it changes.
addlistener(handles.speedSlider,'Value','PostSet',@(s,e) set(handles.speedLbl, 'String', round(handles.speedSlider.Value, 1)));
fn_change_rate(handles, get(handles.speedSlider, 'Value')); %Call fn_change_rate function to change the var_track's speed.

% --- Executes while creating speed slider 
function speedSlider_CreateFcn(hObject, eventdata, handles)
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



