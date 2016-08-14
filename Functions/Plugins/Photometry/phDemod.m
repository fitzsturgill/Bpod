function demod = phDemod(rawData, refData, sampleRate, modRate, lowCutoff)
% DEMODULATE AM-MODULATED INPUT IN QUADRATURE GIVEN A REFERENCE
% tBaseline-  baseline period, in seconds
% lowCutoff corner frequency for 5-pole butterworth filter (lowpass),
% default = [], i.e. no filtering is performed


    if nargin < 5
        lowCutoff = []; 
    end
    
    if size(rawData, 2) ~= 1 ||size(refData, 2) ~= 1
        disp('*** Error in phDemod, refData and rawData must be column vectors ***');
        demod = [];
        return
    end

    
    nSamples = length(rawData);
    refData = refData(1:nSamples,1); % shorten refData to same size as rawData
    refData = refData - mean(refData); % *** get rid of DC offset!!!
    

    % generate 90degree shfited copy of refData
    samplesPerPeriod = 1/modRate / (1/sampleRate);
    % I should do this explicitly- add pi/2 :
    quarterPeriod = round(samplesPerPeriod / 4); % ideally you shouldn't have to round, i.e. mod frequencies should be close to factors of sample freq
    refData90 = circshift(refData, [1 quarterPeriod]);

    processedData_0 = rawData .* refData;
    processedData_90 = rawData .* refData90;

    demodData = (processedData_0 .^2 + processedData_90 .^2) .^(1/2); % quadrature decoding

     % Create butterworth filter
    lowCutoff = lowCutoff/sampleRate * 2; % multiply by 2 to convert to rad/sample- see butter documentation:
    % for a cutoff freq of 300Hz and sample rate of 1000Hz, cutoff
    % corresponds to 0.6pi rad/sample    300/1000 * 2 = 0.6    

    % note-   5 pole Butterworth filter in Matlab used in Frohlich and McCormick  
    [b, a] = butter(5, lowCutoff, 'low');   
    pad = 1;
    if pad
        paddedData = demodData(randperm(sampleRate), 1); % pad with 1s of randomized data (should still contain DC trend)
%% For online analysis don't use filtfilt for speed        
        demodDataFilt = filter(b,a,[paddedData; demodData]);        
        demod = demodDataFilt(sampleRate + 1: end, 1);
    else
        demod = filter(b, a, demodData);
    end
    %% I should just normalize by basleine period (say from 0.5 - 1.5s)
    
    % correct for amplitude of reference 
    
    % Vsig = Vsig*Vref/2 + Vsig*Vref/2 * Cos(2*Fmod * time)
    % you filter out the second term
    % multiply by two and divide by Vref to get Vsig
    
%     modAmp = calcSinusoidAmp(refData);
%     demod = demod * 2 / modAmp;
%     fig = ensureFigure('test', 1);
%     plot(demodDataFilt);

