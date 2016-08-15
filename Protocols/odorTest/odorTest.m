%{
----------------------------------------------------------------------------

This file is part of the Bpod Project
Copyright (C) 2014 Joshua I. Sanders, Cold Spring Harbor Laboratory, NY, USA

----------------------------------------------------------------------------

This program is free software: you can redistribute it and/or modify
it under the terms neral Public License as published by
the Free Software Foundation, version 3.

This program is distributed  WITHOUT ANY WARRANTY and without even the
implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
%}
function odorTest
    % Cued outcome task
    % Written by Fitz Sturgill 3/2016.

    % Photometry with LED light sources, 2Channels
   
    
    global BpodSystem nidaq

%     TotalRewardDisplay('init')
    %% Define parameters
    S = BpodSystem.ProtocolSettings; % Load settings chosen in launch manager into current workspace as a struct called S

    if isempty(fieldnames(S))  % If settings file was an empty struct, populate struct with default settings
        S.GUI.LED1_amp = 0;
        S.GUI.LED2_amp = 0;
        S.GUI.mu_iti = 1; % 6; % approximate mean iti duration
        S.GUI.saveOn = 0;


        S.NoLick = 0; % forget the nolick
        S.ITI = []; %ITI duration is set to be exponentially distributed later
%         S.SoundDuration = []; % to be set later
%         S.RewardValveCode = 1;
%         S.OmitValveCode = 2;
%         S.OdorValveCode = []; % now this denotes the output pin on the slave arduino switching a particular odor valve
        S.Valve = [];
        
%         S.SmallReward = 2;
%         S.BigReward = 8;
%         S.SmallRewardTime =  GetValveTimes(S.SmallReward, S.RewardValveCode);
%         S.BigRewardTime =  GetValveTimes(S.BigReward, S.RewardValveCode);        
        
        % state durations in behavioral protocol
        S.PreCsRecording  = 3; % After ITI        
        S.OdorTime = 1; % 0.5s tone, 1s delay        
        S.Delay = 2; %  time after odor and before US delivery (or omission)        
%         S.PostUsRecording = 2; % After trial before exit
    end
    
    %% Initialize NIDAQ
    S.nidaq.duration = S.PreCsRecording + S.OdorTime + S.Delay;
    S = initPhotometry(S);
    
    %%
    portname = 'COM9';
    valveSlave = initValveSlave(portname);

    if isempty(valveSlave)
        BpodSystem.BeingUsed = 0;
        return
    end    
    
    %% Initialize parameter GUI plugin
    BpodParameterGUI('init', S);
    
    %% pause and reintialize photometry if parameters have been changed???
    %% also save settings??
    %% Populate Settings field with initial ProtocolSettings (these can change, see also TrialSettings field)
    BpodSystem.Data.Settings = S;

    %% Init Plots
    scrsz = get(groot,'ScreenSize'); 
    
    BpodSystem.ProtocolFigures.NIDAQFig       = figure(...
        'Position', [25 scrsz(4)*2/3-100 scrsz(3)/2-50  scrsz(4)/3],'Name','NIDAQ plot','numbertitle','off');
    BpodSystem.ProtocolFigures.NIDAQPanel1     = subplot(2,1,1);
    BpodSystem.ProtocolFigures.NIDAQPanel2     = subplot(2,1,2);
    
    
    %% Define trials
    
    typeMatrix = [...
        % odor
        5, 1/3;... % odor 1
        6, 1/3;... % odor 2
        7, 1/3;...  % odor 3
        ];

    
    MaxTrials = 1000;    
    TrialTypes = defineRandomizedTrials(typeMatrix, MaxTrials);
    TrialTypes = rem(0:999, 3) + 5; % kludge, don't randomize
    %% define outcomes, sound durations, and valve times
    UsOutcomes = TrialTypes;

    
%     Us = cell(size(TrialTypes));
%     Us(ismember(TrialTypes, [1 2 4 5])) = {'Reward'}; % for reward
%     Us(ismember(TrialTypes, [3 6])) = {'Omission'}; % for omission    
    
%     Cs = zeros(size(TrialTypes)); % zeros for omission
%     Cs(ismember(TrialTypes, [1 2 3])) = S.OdorValveCode; % for reward
%     Cs(ismember(TrialTypes, [4 5 6])) = 6; % omission (dummy valve)
    
    
%     RewardValveTimes = zeros(size(TrialTypes)); % 
%     RewardValveTimes(ismember(TrialTypes, [1 4])) = S.SmallRewardTime;
%     RewardValveTimes(ismember(TrialTypes, [2 5 3 6])) = S.BigRewardTime; % use big reward valve time for omission dummy valve activation
%     
%     RewardAmounts = zeros(size(TrialTypes)); % for omissions valveTime = 0
%     RewardAmounts(ismember(TrialTypes, [1 4])) = S.SmallReward;
%     RewardAmounts(ismember(TrialTypes, [2 5])) = S.BigReward;
    
    %% for saving later:
    BpodSystem.Data.TrialTypes = TrialTypes; % The trial type of each trial 
    BpodSystem.Data.TrialOutcomes = UsOutcomes; % the outcomes

    %% init outcome plot




    %% Main trial loop
    for currentTrial = 1:MaxTrials
        
        % update outcome plot to reflect currently executed trial

        
        slaveResponse = updateValveSlave(valveSlave, TrialTypes(currentTrial));
        S.Valve = slaveResponse;
        if isempty(slaveResponse);
            disp(['*** Valve Code not succesfully updated, trial #' num2str(currentTrial) ' skipped ***']);
            continue
        else
            disp(['*** Valve #' num2str(slaveResponse) ' Trial #' num2str(currentTrial) ' ***']);
        end
%         S.RewardValveTime = RewardValveTimes(currentTrial); % ommision, small or big reward
       
        S.ITI = inf;
        while S.ITI > 3 * S.GUI.mu_iti   % cap exponential distribution at 3 * expected mean value (1/rate constant (lambda))
            S.ITI = exprnd(S.GUI.mu_iti); %
        end
        S = BpodParameterGUI('sync', S); % Sync parameters with BpodParameterGUI plugin

        sma = NewStateMatrix(); % Assemble state matrix
        sma = AddState(sma, 'Name', 'ITI', ...
            'Timer',S.ITI,...
            'StateChangeConditions', {'Tup', 'StartRecording'},...
            'OutputActions',{});
        sma = AddState(sma, 'Name', 'StartRecording', ...
            'Timer',0.025,...
            'StateChangeConditions', {'Tup', 'PreCsRecording'},...
            'OutputActions',{'BNCState', 1});         % trigger nidaq
        sma = AddState(sma, 'Name','PreCsRecording',...
            'Timer',S.PreCsRecording,...
            'StateChangeConditions',{'Tup','Odor'},...
            'OutputActions',{});
% invariant state name to feed into analysis routines preceding odor cue (or Uncued)        
% even though 'DeliverStimulus' is really a delay state I'm retaining name for consistency with previous code
        sma = AddState(sma, 'Name', 'Odor', ... 
            'Timer', S.OdorTime,...
            'StateChangeConditions', {'Tup','Delay'},...
            'OutputActions', {'WireState', 1, 'BNCState', 2});
        sma = AddState(sma, 'Name', 'Delay', ... 
            'Timer', S.Delay,...
            'StateChangeConditions', {'Tup', 'exit'},...
            'OutputActions', {});         

        %%
        BpodSystem.Data.TrialSettings(currentTrial) = S; % Adds the settings used for the current trial to the Data struct (to be saved after the trial ends)
        SendStateMatrix(sma);

        % NIDAQ :: Initialize data matrix and start nidaq in background - this takes ~150ms
       
        updateLEDData(S); % FS MOD
        
        %% make this a function
        nidaq.ai_data = [];
        % Dropping from 10hz to 5hz seems to fix the short-nidaq-recording bug?
%         nidaq.session.NotifyWhenDataAvailableExceeds = nidaq.session.Rate/5; % Must be done after queueing data.
        nidaq.session.prepare(); %Saves 50ms on startup time, perhaps more for repeats.
        nidaq.session.startBackground(); % takes ~0.1 second to start and release control.
        %%

        % Run state matrix
        RawEvents = RunStateMatrix();  % Blocking!

        %% this too a function
        % NIDAQ :: Stop nidaq.session and cleanup
        nidaq.session.stop() % Kills ~0.002 seconds after state matrix is done.
        wait(nidaq.session) % Tring to wait until session is done - did we record the full session?
        % demodulate and plot trial data
        try
            updatePhotometryPlot;
        catch
        end
        
        nidaq.session.outputSingleScan(zeros(1,length(nidaq.aoChannels)));
        % ..... :: Ensure we drop our outputs back to zero if at all possible - takes ~0.01 seconds.
%         nidaq.session.outputSingleScan(zeros(1,length(nidaq.do_channels))); 
        % ..... :: Save data in BpodSystem format.
        BpodSystem.Data.NidaqData{currentTrial, 1} = nidaq.ai_data; %input data
        BpodSystem.Data.NidaqData{currentTrial, 2} = nidaq.ao_data; % output data
        % /NIDAQ
        if S.GUI.saveOn && ~isempty(fieldnames(RawEvents)) % If trial data was returned
            BpodSystem.Data = AddTrialEvents(BpodSystem.Data,RawEvents); % Computes trial events from raw data
            BpodSystem.Data.TrialSettings(currentTrial) = S; % Adds the settings used for the current trial to the Data struct (to be saved after the trial ends)
            BpodSystem.Data.TrialTypes(currentTrial) = TrialTypes(currentTrial); % Adds the trial type of the current trial to data
            BpodSystem.Data.TrialOutcome(currentTrial) = TrialTypes(currentTrial);
           
            
%             TotalRewardDisplay('add', RewardAmounts(currentTrial));
%             bpLickRaster(BpodSystem.Data, lickPlot.Types{1}, lickPlot.Outcomes{1}, 'DeliverStimulus', [], lickPlot.Ax(1));
%             set(gca, 'XLim', [-3, 6]);
%             bpLickRaster(BpodSystem.Data, lickPlot.Types{2}, lickPlot.Outcomes{2}, 'DeliverStimulus', [], lickPlot.Ax(2));            
%             set(gca, 'XLim', [-3, 6]);            
            %save data
            SaveBpodSessionData; % Saves the field BpodSystem.Data to the current data file
        else
            disp('data not saved');
        end
        HandlePauseCondition; % Checks to see if the protocol is paused. If so, waits until user resumes.
        if BpodSystem.BeingUsed == 0
            fclose(valveSlave);
            delete(valveSlave);
            return
        end 
    end
end


   