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
function SO_RewardPunish_odor
    % Cued outcome task
    % Written by Fitz Sturgill 3/2016.

    % Photometry with LED light sources, 2Channels
   
    
    global BpodSystem nidaq

    TotalRewardDisplay('init')
    %% Define parameters
    S = BpodSystem.ProtocolSettings; % Load settings chosen in launch manager into current workspace as a struct called S

    
    if isempty(fieldnames(S))  % If settings file was an empty struct, populate struct with default settings
        S.GUI.LED1_amp = 1.5;
        S.GUI.LED2_amp = 0;
        S.GUI.mu_iti = 6; % 6; % approximate mean iti duration
        S.GUI.RewardOdorValveCode = 5; % now this denotes the output pin on the slave arduino switching a particular odor valve
        S.GUI.PunishOdorValveCode = 6;
        S.GUI.Delay = 1;
        S.GUI.Epoch = 1;

        
        S.NoLick = 0; % forget the nolick
        S.ITI = []; %ITI duration is set to be exponentially distributed later
%         S.SoundDuration = []; % to be set later
        S.RewardValveCode = 1;
        S.PunishValveCode = 2;
        S.GUI.PunishValveTime = 0.2; %s        
%         S.OmitValveCode = 4; % bit 3 is on
        S.OmitValveCode = 0; % forget about omit valve for VIP animal
        S.currentValve = []; % holds odor valve # for current trial
        
        S.GUI.Reward = 8;
        S.RewardValveTime =  GetValveTimes(S.GUI.Reward, S.RewardValveCode);
        
        % state durations in behavioral protocol
        S.PreCsRecording  = 3; % After ITI        was 3
        S.GUI.OdorTime = 1; % 0.5s tone, 1s delay        
        S.GUI.Delay = 1; %  time after odor and before US delivery (or omission)
        S.GUI.PunishOn = 1;
        S.PostUsRecording = 4; % After trial before exit    was 5
    end
    
    %% Pause and wait for user to edit parameter GUI - this probably won't work initially
    
    BpodParameterGUI('init', S);    
    BpodSystem.Pause = 1;
    HandlePauseCondition; % Checks to see if the protocol is paused. If so, waits until user resumes.
    S = BpodParameterGUI('sync', S); % Sync parameters with BpodParameterGUI plugin
    BpodSystem.ProtocolSettings = S; % copy settings back prior to saving
    try
        SaveBpodProtocolSettings;
    catch
        disp('fix this, see line 71 in SO_RewardPUnish_Odor');
    end
        
    
    %% Initialize NIDAQ
    S.nidaq.duration = S.PreCsRecording + S.GUI.OdorTime + S.GUI.Delay + S.PostUsRecording;
    S = initPhotometry(S);
    
    %% Initialize olfactometer and point grey camera
    % retrieve machine specific olfactometer settings
    addpath(genpath(fullfile(BpodSystem.BpodPath, 'Settings Files'))); % Settings path is assumed to be shielded by gitignore file
    olfSettings = machineSpecific_Olfactometer;
    rmpath(genpath(fullfile(BpodSystem.BpodPath, 'Settings Files'))); % remove it just in case there would somehow be a name conflict
    
    % retrieve machine specific point grey camera settings
    addpath(genpath(fullfile(BpodSystem.BpodPath, 'Settings Files'))); % Settings path is assumed to be shielded by gitignore file
    pgSettings = machineSpecific_pointGrey;
    rmpath(genpath(fullfile(BpodSystem.BpodPath, 'Settings Files'))); % remove it just in case there would somehow be a name conflict    
    
    % initialize olfactometer slave arduino
    valveSlave = initValveSlave(olfSettings.portName);
    if isempty(valveSlave)
        BpodSystem.BeingUsed = 0;
        return
    end    
    
    % determine nidaq/point grey and olfactometer triggering arguments
    npgWireArg = 0;
    npgBNCArg = 1; % BNC 1 source to trigger Nidaq is hard coded
    switch pgSettings.triggerType
        case 'WireState'
            npgWireArg = bitset(npgWireArg, pgSettings.triggerNumber); % its a wire trigger
        case 'BNCState'
            npgBNCArg = bitset(npgBNCArg, pgSettings.triggerNumber); % its a BNC trigger
    end
    olfWireArg = 0;
    olfBNCArg = 0;
    switch olfSettings.triggerType
        case 'WireState'
            olfWireArg = bitset(olfWireArg, olfSettings.triggerNumber);
        case 'BNCState'
            olfBNCArg = bitset(olfBNCArg, olfSettings.triggerNumber);
    end
    

    
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
    % I should move valves outside
    if S.GUI.PunishOn
        typeMatrix = [...
            % rewarded odor
            1, 1/3 * 0.8;... %  reward
            2, 1/3 * 0.2;...  % omit (with dummy valve), 
            % punished odor
            3, 1/3 * 0.8;... %  punish
            4, 1/3 * 0.2;...  % omit (with dummy valve), 
            % uncued
            5, 1/3 * 0.45;...  % reward
            6, 1/3 * 0.45;...  % punish
            7, 1/3 * 0.1;...   % omit (with dummy valve),
            ];
    else
        typeMatrix = [...
            % rewarded odor
            1, 1/2 * 0.8;... %  reward
            2, 1/2 * 0.2;...  % omit (with dummy valve), 
            % punished odor
            3, 0 * 0.8;... %  punish
            4, 0 * 0.2;...  % omit (with dummy valve), 
            % uncued
            5, 1/2 * 0.8;...  % reward
            6, 0 * 0.45;...  % punish
            7, 1/2 * 0.2;...   % omit (with dummy valve),
            ];
    end

    
    MaxTrials = 1000;    
    TrialTypes = defineRandomizedTrials(typeMatrix, MaxTrials);
    
    %% define outcomes, sound durations, and valve times
    UsOutcomes = ones(size(TrialTypes));  % remember! these can't be left as zeros because they are used as indexes by processAnalysis_Photometry
    UsOutcomes(ismember(TrialTypes, [1 5])) = 1; % reward
    UsOutcomes(ismember(TrialTypes, [3 6])) = 2; % punish    
    UsOutcomes(ismember(TrialTypes, [2 4 7])) = 3; % omission, 1/2 way in between reward and punishment valve times (simplification)
    
    Us = cell(size(TrialTypes));
    Us(ismember(TrialTypes, [1 5])) = {'Reward'}; % for reward
    Us(ismember(TrialTypes, [3 6])) = {'Punish'}; % for reward    
    Us(ismember(TrialTypes, [2 4 7])) = {'Omit'}; % for omission    
    
    Cs = zeros(size(TrialTypes)); % zeros for uncued
    Cs(ismember(TrialTypes, [1 2])) = S.GUI.RewardOdorValveCode; % reward
    Cs(ismember(TrialTypes, [3 4])) = S.GUI.PunishOdorValveCode; % punish
    
    
   
    
    %% for saving later:
%     BpodSystem.Data.TrialTypes = TrialTypes; % The trial type of each trial 
%     BpodSystem.Data.TrialOutcomes = UsOutcomes; % the outcomes

    %% init outcome plot

    scrsz = get(groot,'ScreenSize');
    % i need to mimic bpod integrated figures (see other protocols) so it
    % is closed properly on bpod protocol stop
    outcomeFig = ensureFigure('Outcome_plot', 1);
    set(outcomeFig, 'Position', [25 scrsz(4)/2-150 scrsz(3)-50  scrsz(4)/6],'numbertitle','off', 'MenuBar', 'none'); %, 'Resize', 'off');    
    outcomeAxes = axes('Parent', outcomeFig);
    placeHolder = line([1 1], [min(unique(TrialTypes)) max(unique(TrialTypes))], 'Color', [0.8 0.8 0.8], 'LineWidth', 4, 'Parent', outcomeAxes);    
    hold on;
    outcomesHandle = scatter(1:MaxTrials, TrialTypes);
    outcomeSpan = 20;
    set(outcomeAxes, 'XLim', [0 outcomeSpan]);
 
%% init lick raster plot
    lickPlot = struct(...
        'lickRasterFig', [],...
        'Ax', [],...
        'Types', [],...
        'Outcomes', []...
        );
    lickPlot.lickRasterFig = ensureFigure('Reward_Licks', 1);
    lickPlot.Ax(1) = subplot(2,1,1); title('Reward Cued');
    lickPlot.Ax(2) = subplot(2,1,2); title('Reward Uncued');
    lickPlot.Types{1} = [1];
    lickPlot.Types{2} = [5];
    lickPlot.Outcomes{1} =  [1];
    lickPlot.Outcomes{2} = [1];




    %% Main trial loop
    for currentTrial = 1:MaxTrials
        S = BpodParameterGUI('sync', S); % Sync parameters with BpodParameterGUI plugin        
        % update outcome plot to reflect currently executed trial
        set(outcomeAxes, 'XLim', [max(0, currentTrial - round(outcomeSpan/2)) min(MaxTrials, currentTrial + round(outcomeSpan/2))]);
        set(placeHolder, 'XData', [currentTrial currentTrial]);   
        % kludge-  for reversal, so that I can change reward and punish
        % odors on the fly
        currentType = TrialTypes(currentTrial);
        if ismember(currentType, [1 2])
            odorValve = S.GUI.RewardOdorValveCode; % reward
        elseif ismember(currentType, [3 4])
            odorValve = S.GUI.PunishOdorValveCode; % reward            
        else
            odorValve = 0;
        end
        
        slaveResponse = updateValveSlave(valveSlave, odorValve);
        S.currentValve = slaveResponse;
        if isempty(slaveResponse);
            disp(['*** Valve Code not succesfully updated, trial #' num2str(currentTrial) ' skipped ***']);
            continue
        else
            disp(['*** Valve #' num2str(slaveResponse) ' Trial #' num2str(currentTrial) ' ***']);
        end
       
        S.ITI = inf;
        while S.ITI > 3 * S.GUI.mu_iti   % cap exponential distribution at 3 * expected mean value (1/rate constant (lambda))
            S.ITI = 1 + exprnd(S.GUI.mu_iti); % % kludge, added time to see if it fixes bonsai dropped frames
        end


        sma = NewStateMatrix(); % Assemble state matrix
        sma = AddState(sma, 'Name', 'Start', ...
            'Timer', 0.025,...
            'StateChangeConditions', {'Tup', 'NoLick'},...
            'OutputActions', {}); % Trigger Point Grey Camera and Bonsai
        sma = AddState(sma,'Name', 'NoLick', ...
            'Timer', S.NoLick,...
            'StateChangeConditions', {'Tup', 'ITI','Port1In','RestartNoLick'},... %port 1 is hard coded now, change?
            'OutputActions', {'PWM1', 255}); %Light On
        sma = AddState(sma,'Name', 'RestartNoLick', ...
            'Timer', 0,...
            'StateChangeConditions', {'Tup', 'NoLick',},...
            'OutputActions', {'PWM1', 255}); %Light On
        sma = AddState(sma, 'Name', 'ITI', ...
            'Timer',S.ITI,...
            'StateChangeConditions', {'Tup', 'StartRecording'},...
            'OutputActions',{});
% trigger nidaq and point grey- my 2 bpods have different issues, for one
% bnc2 doesn't work for the other the wire outputs don't work, 
        sma = AddState(sma, 'Name', 'StartRecording', ...
            'Timer',0.025,...
            'StateChangeConditions', {'Tup', 'PreCsRecording'},...
            'OutputActions', {'BNCState', npgBNCArg, 'WireState', npgWireArg});         
        sma = AddState(sma, 'Name','PreCsRecording',...
            'Timer',S.PreCsRecording,...
            'StateChangeConditions',{'Tup','DeliverStimulus'},...
            'OutputActions',{});
% invariant state name to feed into analysis routines preceding odor cue (or Uncued)        
        sma = AddState(sma, 'Name', 'DeliverStimulus', ... 
            'Timer', 0,... 
            'StateChangeConditions', {'Tup', 'Cue'},... % either Cued or Uncued
            'OutputActions', {});
% even though 'DeliverStimulus' is really a delay state I'm retaining name for consistency with previous code
        sma = AddState(sma, 'Name', 'Cue', ... 
            'Timer', S.GUI.OdorTime,...
            'StateChangeConditions', {'Tup','Delay'},...
            'OutputActions', {'WireState', olfWireArg, 'BNCState', olfBNCArg});
        sma = AddState(sma, 'Name', 'Delay', ... 
            'Timer', S.GUI.Delay,...
            'StateChangeConditions', {'Tup',Us{currentTrial}},...
            'OutputActions', {});         
        sma = AddState(sma,'Name', 'Reward', ...
            'Timer',S.RewardValveTime,... % time will be 0 for omission
            'StateChangeConditions', {'Tup', 'PostUsRecording'},...
            'OutputActions', {'ValveState', S.RewardValveCode});
        sma = AddState(sma,'Name', 'Punish', ...
            'Timer',S.GUI.PunishValveTime,... 
            'StateChangeConditions', {'Tup', 'PostUsRecording'},...
            'OutputActions', {'ValveState', S.PunishValveCode});          
        sma = AddState(sma,'Name', 'Omit', ...
            'Timer',mean([S.RewardValveTime S.GUI.PunishValveTime]),...  % split the difference
            'StateChangeConditions', {'Tup', 'PostUsRecording'},...
            'OutputActions', {'ValveState', S.OmitValveCode});     
        sma = AddState(sma, 'Name','PostUsRecording',...
            'Timer',S.PostUsRecording,...  
            'StateChangeConditions',{'Tup','exit'},...
            'OutputActions',{});

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
        pause(0.05); 
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
        if ~isempty(fieldnames(RawEvents)) % If trial data was returned
            BpodSystem.Data = AddTrialEvents(BpodSystem.Data,RawEvents); % Computes trial events from raw data
            BpodSystem.Data.TrialSettings(currentTrial) = S; % Adds the settings used for the current trial to the Data struct (to be saved after the trial ends)
            BpodSystem.Data.TrialTypes(currentTrial) = TrialTypes(currentTrial); % Adds the trial type of the current trial to data
            BpodSystem.Data.TrialOutcome(currentTrial) = UsOutcomes(currentTrial);
            BpodSystem.Data.OdorValve(currentTrial) =  odorValve;
            BpodSystem.Data.Epoch(currentTrial) = S.GUI.Epoch;
            try
                BpodSystem.Data.Us(currentTrial) = Us{currentTrial}; % fluff, nice to have the strings for 'reward', 'punish', 'omit'
            catch
                BpodSystem.Data.Us = Us{currentTrial}; % I'm in a hurry...
            end
           
            if UsOutcomes(currentTrial) == 1
                TotalRewardDisplay('add', S.GUI.Reward); % fix this, it's wrong
            end
            bpLickRaster(BpodSystem.Data, lickPlot.Types{1}, lickPlot.Outcomes{1}, 'DeliverStimulus', [], lickPlot.Ax(1));
            set(gca, 'XLim', [-3, 6]);
            bpLickRaster(BpodSystem.Data, lickPlot.Types{2}, lickPlot.Outcomes{2}, 'DeliverStimulus', [], lickPlot.Ax(2));            
            set(gca, 'XLim', [-3, 6]);            
            %save data
            SaveBpodSessionData; % Saves the field BpodSystem.Data to the current data file
        else
            disp('WTF');
        end
        HandlePauseCondition; % Checks to see if the protocol is paused. If so, waits until user resumes.
        if BpodSystem.BeingUsed == 0
            fclose(valveSlave);
            delete(valveSlave);
            return
        end 
    end
end


   