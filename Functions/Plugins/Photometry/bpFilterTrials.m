function out = bpFilterTrials(SessionData, types, outcomes)
    

%     nTrials = length(SessionData.RawEvents.Trial);
    nTrials = SessionData.nTrials;
    
    out = ismember(SessionData.TrialTypes(1:SessionData.nTrials), types) & ismember(SessionData.TrialOutcome(1:SessionData.nTrials), outcomes);
    out = find(out);
    
    