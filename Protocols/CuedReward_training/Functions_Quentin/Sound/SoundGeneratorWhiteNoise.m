function sound = SoundGeneratorWhiteNoise(samprate, reps, pulselength, restlength,ramp)
    noisedur = (pulselength+restlength)*reps;
    n = round(noisedur * samprate);
    noise = randn(1,n);
    noise = noise / max(abs(noise));
    MaxAmpl=2;
    MinAmpl=MaxAmpl/5;
    
	for i = 1:reps;
        beginrest = i*(round(samprate*(pulselength+restlength)))-round(samprate*restlength);
        endrest = i*(round(samprate*(pulselength+restlength)));
        noise(beginrest:endrest) = 0;
    end
        
    switch ramp
        case 0
            ampl = MaxAmpl*ones(1,length(noise));
        case 1
            ampl = linspace(MinAmpl,MaxAmpl,length(noise));
        case -1
            ampl = linspace(MaxAmpl,MinAmpl,length(noise));
        otherwise
            display ('Ramp should be 0, 1 or -1');
            return
    end
    
    size(ampl)
    size(noise)
    
    sound = ampl.*noise;
        
end