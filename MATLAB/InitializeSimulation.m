%Define all variables that are needed to tweak the models
%This is the only file users must touch

%%%%%%%%%%%%%%%%%%
%%%ONLY CHANGE THESE
%%%%%%%%%%%%%%%%%%
%Crop parameters

Parameter.Crop_target_start=10; 
%Mean raised crop at beginning
%This means on average 10% of time there will be famine
%Multiplied by rainfall, maximum 2

Parameter.SustainabilityMaximumRatio=1.3;
%Ratio to basic target where suatainability limit sets in

Parameter.HarvestMaximumRatio=1.5;
%Ratio to basic target which can be lifted alone.
%Limit is 4, since Rainfall*Wisdom can equal 4 at end of simulation

Parameter.TradeRatio=0.5;
%Maximum amount of crops that can be traded

%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%Do not change below here
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Basic parameters for simulation
Parameter.NumberOfSimulationRuns=100; %How many times simulation is run
Parameter.NumberOfYearsPerRun=100; %How many years per run

Parameter.WisdomIncreasePerYear=(Parameter.SustainabilityMaximumRatio-1)/Parameter.NumberOfYearsPerRun;
%Maximum Wisdom increase per year. Hundred years in total
%At end of simulation, will be exactly at sustainability level!
%OR
%Parameter.WisdomIncreasePerYear=(Parameter.SustainabilityMaximum_start-Parameter.Crop_target_start)/Parameter.NumberOfYearsPerRun;

Parameter.MaximumRainRatio=2;
%Maximum amount of rain that can fall in one year

%Unneeded parameter
Parameter.CooperationMaximumRatio=Parameter.MaximumRainRatio*Parameter.SustainabilityMaximumRatio;
%All can be lifted if cooperation is in place. This is full amount at end.

Parameter.Crop_seed_start=1; %Minimum needed as seed crop for next year
%D not change
%This also rises as wisdom rises, so risk stays same


%%%%%%%%%%%%%%
%Wisdom Parameters. Do not change by default
Parameter.GlobalWisdomParameter_start=1; 
%Calibrates the wisdom. Keep at one


%%%%%%%%%%%%%%%%%%%%%
%%%DO NOT CHANGE
%%%%%%%%%%%%%%%%%%%%
Parameter.WorldSize=9; %World is assumed NxN matrix, but stored as vector
Parameter.NumberOfSocieties=32; %Total number of societies, 32 for TERSI model








