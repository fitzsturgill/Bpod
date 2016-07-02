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
function testCameraTrigger
    % Cued outcome task
    % Written by Fitz Sturgill 3/2016.

    % Photometry with LED light sources, 2Channels
   
    
    global BpodSystem nidaq

%     TotalRewardDisplay('init')

%         S.SoundDuration = []; % to be set later
%         S.RewardValveCode = 1;
%         S.OmitValveCode = 2;
%         S.OdorValveCode = []; % now this denotes the output pin on the slave arduino switching a particular odor valve

        
%         S.SmallReward = 2;
%         S.BigReward = 8;
%         S.SmallRewardTime =  GetValveTimes(S.SmallReward, S.RewardValveCode);
%         S.BigRewardTime =  GetValveTimes(S.BigReward, S.RewardValveCode);        
        
        % state durations in behavioral protocol
    
%         S.PostUsRecording = 2; % After trial before exit

    

    




    
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
%     BpodSystem.Data.TrialTypes = TrialTypes; % The trial type of each trial 
%     BpodSystem.Data.TrialOutcomes = UsOutcomes; % the outcomes

    %% init outcome plot




    %% Main trial loop
    for currentTrial = 1:1000
        
        % update outcome plot to reflect currently executed trial

        


        sma = NewStateMatrix(); % Assemble state matrix
        sma = AddState(sma, 'Name', 'trigger', ...
            'Timer', 0.05,...
            'StateChangeConditions', {'Tup', 'ITI'},...
            'OutputActions',{'BNCState', 2});
        sma = AddState(sma, 'Name', 'ITI', ...
            'Timer',10,...
            'StateChangeConditions', {'Tup', 'exit'},...
            'OutputActions',{});         % trigger nidaq

% invariant state name to feed into analysis routines preceding odor cue (or Uncued)        
% even though 'DeliverStimulus' is really a delay state I'm retaining name for consistency with previous code
   

        %%
%         BpodSystem.Data.TrialSettings(currentTrial) = S; % Adds the settings used for the current trial to the Data struct (to be saved after the trial ends)
        SendStateMatrix(sma);

        % NIDAQ :: Initialize data matrix and start nidaq in background - this takes ~150ms
       
%         updateLEDData(S); % FS MOD
        
        %% make this a function
%         nidaq.ai_data = [];
        % Dropping from 10hz to 5hz seems to fix the short-nidaq-recording bug?
%         nidaq.session.NotifyWhenDataAvailableExceeds = nidaq.session.Rate/5; % Must be done after queueing data.
%         nidaq.session.prepare(); %Saves 50ms on startup time, perhaps more for repeats.
%         nidaq.session.startBackground(); % takes ~0.1 second to start and release control.
        %%

        % Run state matrix
        RawEvents = RunStateMatrix();  % Blocking!
        disp('hello');

        %% this too a function
        % NIDAQ :: Stop nidaq.session and cleanup
%         nidaq.session.stop() % Kills ~0.002 seconds after state matrix is done.
%         wait(nidaq.session) % Tring to wait until session is done - did we record the full session?
        % demodulate and plot trial data
%         try
%             updatePhotometryPlot;
%         catch
%         end
        
      
end


   