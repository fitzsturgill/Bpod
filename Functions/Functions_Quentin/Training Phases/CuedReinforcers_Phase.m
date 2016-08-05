function [trialsNames, trialsMatrix]=CuedReinforcers_Phase(S)

switch S.Phase
    case 'Phase1'
trialsNames={'NC','SoundA - Pavlovian',...
             'NC','SoundB - Pavlovian',...
             'Uncued type A','Uncued type B'};
trialsMatrix=[... 
%  type, proba,  sound,     delay,    valve,      Pav/Inst 0/1  Marker
    1,  0.0,    1,    S.GUI.DelayA, S.Valve,    1,            double('o');...   %SoundA
    2,  0.4,    1,    S.GUI.DelayA, S.Valve,	0,            double('s');...   %SoundA
    3,  0.0,	2,    S.GUI.DelayB, S.Valve,	1,            double('o');...   %SoundB
    4,  0.4,	2,    S.GUI.DelayB, S.Valve,	0,            double('s');...   %SoundB
	5,  0.1,	3,    S.GUI.DelayA, S.Valve,    0,            double('o');...   %uncued
    6,  0.1,	3,    S.GUI.DelayB, S.Valve,    0,            double('o')];     %uncued

    case 'Phase2'
trialsNames={'SoundA ommission','SoundA - Pavlovian',...
             'SoundB ommission','SoundB - Pavlovian',...
             'Uncued type A','Uncued type B'};
trialsMatrix=[... 
%  type, proba,  sound,     delay,    valve,      Pav/Inst 0/1  Marker
    1,  0.1,    1,    S.GUI.DelayA, S.noValve,  0,            double('o');...   %SoundA
    2,  0.3,    1,    S.GUI.DelayA, S.Valve,	0,            double('s');...   %SoundA
    3,  0.1,	2,    S.GUI.DelayB, S.noValve,	0,            double('o');...   %SoundB
    4,  0.3,	2,    S.GUI.DelayB, S.Valve,	0,            double('s');...   %SoundB
	5,  0.1,	3,    S.GUI.DelayA, S.Valve,    0,            double('o');...   %uncued
    6,  0.1,	3,    S.GUI.DelayB, S.Valve,    0,            double('o')];     %uncued

    case 'Phase3'
trialsNames={'SoundA - Instru','SoundA - Pavlovian',...
             'SoundB - Instru','SoundB - Pavlovian',...
             'Uncued, 1sec reward','Uncued, 2sec reward'};
trialsMatrix=[... 
%  type, proba,  sound,     delay,    valve,      Pav/Inst 0/1  Marker
    1,  0.3,      1,    S.GUI.DelayA, S.Valve,    1,            double('o');...   %SoundA with a delayed reward
    2,  0.1,      1,    S.GUI.DelayA, S.Valve,  0,            double('s');...   %SoundA with an omitted reward
    3,  0.3,      2,    S.GUI.DelayB, S.Valve,    1,            double('o');...   %SoundB with a delayed reward
    4,  0.1,      2,    S.GUI.DelayB, S.Valve,  0,            double('s');...   %SoundB with an omitted reward
	5,  0.1,      3,    S.GUI.DelayA, S.Valve,    0,            double('o');...   %uncued reward with a soundA-like delay
    6,  0.1,      3,    S.GUI.DelayB, S.Valve,    0,            double('o')];     %uncued reward with a soundB-like delay

    case 'Phase4'
trialsNames={'SoundA with reward','NC',...
             'SoundB with reward','NC',...
             'Uncued, 1sec reward','Uncued, 2sec reward'};
trialsMatrix=[... 
%  type, proba,  sound,     delay,    valve,      Pav/Inst 0/1  Marker
    1,  0.4,      1,    S.GUI.DelayA, S.Valve,    1,            double('o');...   %SoundA with a delayed reward
    2,  0.0,      1,    S.GUI.DelayA, S.noValve,  1,            double('s');...   %SoundA with an omitted reward
    3,  0.4,      2,    S.GUI.DelayB, S.Valve,    1,            double('o');...   %SoundB with a delayed reward
    4,  0.0,      2,    S.GUI.DelayB, S.noValve,  1,            double('s');...   %SoundB with an omitted reward
	5,  0.1,      3,    S.GUI.DelayA, S.Valve,    0,            double('o');...   %uncued reward with a soundA-like delay
    6,  0.1,      3,    S.GUI.DelayB, S.Valve,    0,            double('o')];     %uncued reward with a soundB-like delay

    case 'Phase5'
trialsNames={'SoundA with reward','SoundA with omission',...
             'SoundB with reward','SoundB with omission',...
             'Uncued, 1sec reward','Uncued, 2sec reward'};
trialsMatrix=[... 
%  type, proba,  sound,     delay,    valve,      Pav/Inst 0/1  Marker
    1,  0.2,      1,    S.GUI.DelayA, S.Valve,    1,            double('o');...   %SoundA with a delayed reward
    2,  0.2,      1,    S.GUI.DelayA, S.noValve,  1,            double('s');...   %SoundA with an omitted reward
    3,  0.2,      2,    S.GUI.DelayB, S.Valve,    1,            double('o');...   %SoundB with a delayed reward
    4,  0.2,      2,    S.GUI.DelayB, S.noValve,  1,            double('s');...   %SoundB with an omitted reward
	5,  0.1,      3,    S.GUI.DelayA, S.Valve,    0,            double('o');...   %uncued reward with a soundA-like delay
    6,  0.1,      3,    S.GUI.DelayB, S.Valve,    0,            double('o')];     %uncued reward with a soundB-like delay
end