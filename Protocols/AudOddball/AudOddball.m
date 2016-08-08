function AudOddball

%Functions used in this protocol:
%"CuedReinforcers_Phase": specify the phase of the training
%"WeightedRandomTrials" : generate random trials sequence
%"SoundGenerator"       : generate sound wave
%"getValveTime"         : get Valve time for reward delivery
%"ScaledRewardStates"   : scale the reward according to time of lick

%"Online_LickPlot"      : initialize and update online lick and outcome plot
%"Online_LickEvents"   : extract the data for the online lick plot
%"Online_NidaqPlot"     : initialize and update online nidaq plot
%"Online_NidaqEvents"   : extract the data for the online nidaq plot

global BpodSystem NidaqData_thisTrial

%% Define parameters

S = BpodSystem.ProtocolSettings; % Load settings chosen in launch manager into current workspace as a struct called S

if isempty(fieldnames(S))  % If settings file was an empty struct, populate struct with default settings
    
    S.Order = 1; % if 0, low to high first. if 1, high to low first (counterbalance across animals)
    S.NumBlocks = 10;
    S.TrialPerBlock = 100;
    S.MinTonesBetweenOddballs = 6;
    S.SoundDuration = 0.2;
    S.ISI = 0.8;
    S.OddballProb = 0.1;
    S.BlockBreak = 5;
    
    S.LowFreq = 4000;   %Hz
    S.HighFreq = 20000;  %Hz

end
% Initialize parameter GUI plugin
%BpodParameterGUI('init', S);

%% Define stimuli and send to sound server

SamplingRate = 192000; % Sound card sampling rate
time=0:1/SamplingRate:S.SoundDuration;

SweepA=chirp(time,S.LowFreq,S.SoundDuration,S.HighFreq);
SweepB=chirp(time,S.HighFreq,S.SoundDuration,S.LowFreq);

PsychToolboxSoundServer('init')
PsychToolboxSoundServer('Load', 1, SweepA);
PsychToolboxSoundServer('Load', 2, SweepB);


BpodSystem.SoftCodeHandlerFunction = 'SoftCodeHandler_PlaySound';

%% Define Block Order

BlockSeq = zeros(1,S.NumBlocks);

if S.Order
    for i = 1:S.NumBlocks
        if mod(i,2) 
            BlockSeq(i) = 1;
        end
    end
else
    for i = 1:S.NumBlocks
        if ~mod(i,2) 
            BlockSeq(i) = 1;
        end
    end
end

%% Define trial types parameters, trial sequence for each block and Initialize plots

TrialsSequences = zeros(S.NumBlocks,S.TrialPerBlock);

for i = 1:S.NumBlocks
    thistrialsequence = zeros(1,S.TrialPerBlock);
    if BlockSeq(i)
        DevSound = 1;
        NonDevSound = 2;
    else
        DevSound = 2;
        NonDevSound = 1;
    end
    
    thistrialsequence(1:round(S.TrialPerBlock*S.OddballProb)) = DevSound;
    thistrialsequence(round(S.TrialPerBlock*S.OddballProb)+1:end) = NonDevSound;
    spacingcheck = 0;
        
    while ~spacingcheck
        thistrialsequence = thistrialsequence(randperm(length(thistrialsequence)));
        count = 0;
        counts = [];
        numbad = 0;
        for j = 1:length(thistrialsequence)
            if thistrialsequence(j) == DevSound
                counts(size(counts)+1) = count;
                if count < 6
                    numbad = numbad + 1;
                end
                count = 0;             
            else
                count = count +1;
            end
        end
    
        if numbad == 0
            spacingcheck = 1;
        end
    
    end

    TrialSequences(i,:) = thistrialsequence
end

   
FigLick=Online_LickPlot('ini',TrialSequence,S.TrialsMatrix,S.TrialsNames,S.Phase);
% FigNidaq=Online_NidaqPlot('ini',S.TrialsNames,S.Phase);

BpodSystem.Data.TrialTypes = []; % The trial type of each trial completed will be added here.

% NIDAQ Initialization
%     nidaq=Nidaq_photometryA('ini');
%         function processNidaqData(src,event)
%             NidaqData_thisTrial = [NidaqData_thisTrial;event.Data];
%         end
%     lh{1} = nidaq.session.addlistener('DataAvailable',@processNidaqData);
%     lh{2} = nidaq.session.addlistener('DataRequired', @(src,event) src.queueOutputData(nidaq.ao_data));

%% Main trial loop

for currentBlock = 1:S.NumBlocks
    for currentTrial = 1:S.TrialPerBlock

        %Initialize current trial parameters
        S.Sound = TrialSequences(currentBlock,currentTrial);
        %% Assemble State matrix
        sma = NewStateMatrix;
        %Stimulus delivery
        sma=AddState(sma,'Name', 'SoundDelivery',...
            'Timer',S.SoundDuration,...
            'StateChangeConditions',{'Tup', 'ISI'},...
            'OutputActions', {'SoftCode',S.Sound});
     
      sma = AddState(sma,'Name', 'ISI',...
            'Timer',S.ISI,...
            'StateChangeConditions', {'Tup', 'exit'},...
            'OutputActions',{});
        SendStateMatrix(sma);

    %% NIDAQ Get nidaq ready to start
    %      nidaq=Nidaq_photometryA('WaitToStart',nidaq);

         RawEvents = RunStateMatrix;

    %% NIDAQ Stop acquisition and save data in bpod structure
    %     nidaq=Nidaq_photometryA('Stop',nidaq);
    %     BpodSystem.Data.NidaqData{currentTrial} = NidaqData_thisTrial;

        %% Save
        %if ~isempty(fieldnames(RawEvents))                                          % If trial data was returned
         %   BpodSystem.Data = AddTrialEvents(BpodSystem.Data,RawEvents);            % Computes trial events from raw data
          %  BpodSystem.Data.TrialSettings(currentTrial) = S;                        % Adds the settings used for the current trial to the Data struct (to be saved after the trial ends)
           % BpodSystem.Data.TrialTypes(currentTrial) = TrialSequence(currentTrial); % Adds the trial type of the current trial to data
            %SaveBpodSessionData;                                                    % Saves the field BpodSystem.Data to the current data file
        %end

        %% PLOT - extract events from BpodSystem.data and update figures
      %  [currentOutcome, currentLickEvents]=Online_LickEvents(S.TrialsMatrix,currentTrial,TrialSequence(currentTrial),'PostReward');
       % FigLick=Online_LickPlot('update',[],[],[],[],FigLick,currentTrial,currentOutcome,TrialSequence(currentTrial),currentLickEvents);
    %     currentNidaq=Online_NidaqEvents(currentTrial,'PostReward',7);
    %     FigNidaq=Online_NidaqPlot('update',[],[],FigNidaq,currentNidaq,TrialSequence(currentTrial));

        HandlePauseCondition; % Checks to see if the protocol is paused. If so, waits until user resumes.
        if BpodSystem.BeingUsed == 0
            return
        end

end
end
