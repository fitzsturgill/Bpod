function [trialsNames, trialsMatrix]=CuedReward_Phase(S)

switch S.Phase
    case 'Training'  % training
        trialsNames={'Cue A Small Reward ',' Cue A Omission',...
            'Cue A Large Reward','Cue B Omission',...
            'Uncued Reward','blank'};
        trialsMatrix=[...
        %  type, proba,  sound,     delay,       valve,      Pav/Inst 0/1    Marker
            1,   0.6,      1,    S.Delay,   S.Valve,    0,              double('o'), S.SmallRew   ;...   %
            2,   0.1,      1,    S.Delay,   S.noValve,  0,              double('s'), S.SmallRew   ;...   %
            3,   0.1,      1,    S.Delay,   S.Valve,    0,              double('o'), S.LargeRew   ;...   %
            4,   0.1,  	   2,    S.Delay,   S.noValve,  0,              double('s'), S.LargeRew   ;...   %
            5,   0.1,      3,    S.Delay,   S.Valve,    0,              double('o'), S.UncuedRew;...     %
            6,   0.0,      3,    S.Delay,   S.Valve,    0,              double('s'), S.UncuedRew];       %
        
	case 'Pavlovian1Cue'  % training
        trialsNames={'Cue A Small Reward ',' Cue A Omission',...
            'Cue A Large Reward','Cue B Omission',...
            'Uncued Reward','blank'};
        trialsMatrix=[...
        %  type, proba,  sound,     delay,       valve,      Pav/Inst 0/1    Marker
            1,   0.4,     1,    S.Delay,   S.Valve,    0,              double('o'), S.SmallRew   ;...   % 
            2,   0.1,     1,    S.Delay,   S.noValve,  0,              double('s'), S.SmallRew   ;...   % 
            3,   0.1,     1,    S.Delay,   S.Valve,    0,              double('o'), S.LargeRew   ;...   % 
            4,   0.3,     2,    S.Delay,   S.noValve,  0,              double('s'), S.LargeRew   ;...   % 
            5,   0.1,     3,    S.Delay,   S.Valve,    0,              double('o'), S.UncuedRew  ;...   % 
            6,   0.0,     3,    S.Delay,   S.Valve,    0,              double('s'), S.UncuedRew];       % 
        
    case 'Pavlovian2Cues'
        trialsNames={'Cue A Small Reward ',' Cue A Omission',...
            'Cue A Large Reward','Cue B Large Reward',...
            'Cue B Omission','Uncued Small Reward'};
       trialsMatrix=[...
        %  type, proba,  sound,     delay,       valve,      Pav/Inst 0/1    Marker
            1,   0.3,      1,    S.Delay,   S.Valve,    0,              double('o'), S.SmallRew   ;...   %
            2,   0.1,      1,    S.Delay,   S.noValve,  0,              double('s'), S.SmallRew   ;...   %
            3,   0.1,      1,    S.Delay,   S.Valve,    0,              double('v'), S.LargeRew   ;...   %
            4,   0.3,  	   2,    S.Delay,   S.Valve,    0,              double('s'), S.LargeRew   ;...   %
            5,   0.1,      2,    S.Delay,   S.noValve,  0,              double('o'), S.LargeRew   ;...   % 
            6,   0.1,      3,    S.Delay,   S.Valve,    0,              double('s'), S.UncuedRew];       % 
    
    case 'Inversion'
        trialsNames={'Cue A Large Reward ',' Cue A Omission',...
            'Cue B Small Reward','Cue B Omission',...
            'Uncued Small Reward','blank'};
       trialsMatrix=[...
        %  type, proba,  sound,     delay,       valve,      Pav/Inst 0/1    Marker
            1,   0.35,      1,    S.Delay,   S.Valve,    0,              double('o'), S.LargeRew   ;...   %
            2,   0.1,       1,    S.Delay,   S.noValve,  0,              double('s'), S.LargeRew   ;...   %
            3,   0.35,      2,    S.Delay,   S.Valve,    0,              double('v'), S.SmallRew   ;...   %
            4,   0.1,  	    2,    S.Delay,   S.noValve,  0,              double('s'), S.SmallRew   ;...   %
            5,   0.1,       3,    S.Delay,   S.Valve,    0,              double('o'), S.UncuedRew  ;...   % 
            6,   0,         3,    S.Delay,   S.Valve,    0,              double('s'), S.UncuedRew];       %    
    
end
        
end