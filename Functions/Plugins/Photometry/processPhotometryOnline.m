function processPhotometryOnline(currentTrial)
    
    % calculate baseline F and dF/F, this function is seperate from
    % phDemodOnline because you need a baseline period which is specific to
    % a given behavioral protocol

    phDemodOnline(currentTrial);

    
    global BpodSystem nidaq    
    baselinePeriod = BpodSystem.Photomtery.baselinePeriod;
    blStartP = bpX2pnt(baselinePeriod(1), nidaq.sample_rate);
    blEndP = bpX2pnt(baselinePeriod(2), nidaq.sample_rate);
    
    trialBaselines = zeros(1,2);
    for ch = 1:2 % 2 channels are hard coded
        chData = nidaq.online.trialDemodData{currentTrial, ch};
        bl = mean(chData(blStartP:blEndP));
        dFF = (chData - bl) ./ bl;
        BpodSystem.PluginObjects.Photometry.trialDFF{ch}(currentTrial, :) = dFF;
        trialBaselines(ch) = bl;
    end
    BpodSystem.PluginObjects.Photometry.blF(currentTrial, :) = trialBaselines;
    