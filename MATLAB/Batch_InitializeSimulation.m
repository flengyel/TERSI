%Define all variables that are needed to tweak the models
%This is the only file users must touch

gridvals=[ 10,1, 1.5;   10, 1.1, 1.2;  10, 1.1, 1.3;  10, 1.1, 1.5;
    10, 1.2, 1.3;   10, 1.2, 1.4;  10, 1.2, 1.5;
    10, 1.3, 1.4;   10, 1.3, 1.5;  10, 1.3, 1.6;
    10, 1.4, 1.5;   10, 1.4, 1.6;  10, 1.4, 1.8;
    10, 1.5, 1.6;   10, 1.5, 1.8; 10, 1.7, 2]; 


for index=1:length(gridvals);



    Parameter.Crop_target_start=gridvals(index,1)/5;
    %This means on average 5% of time there will be famine


    Parameter.SustainabilityMaximumRatio=gridvals(index,2);
    %Ratio to basic target where suatainability limit sets in

    Parameter.HarvestMaximumRatio=gridvals(index,3);
    %Ratio to basic target which can be lifted alone.



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

Parameter.TradeRatio=0.5;
%Maximum amount of crops that can be traded


%%%%%%%%%%%%%%
%Wisdom Parameters. Do not change by default
Parameter.GlobalWisdomParameter_start=1; 
%Calibrates the wisdom. Keep at one


%%%%%%%%%%%%%%%%%%%%%
%%%DO NOT CHANGE
%%%%%%%%%%%%%%%%%%%%
Parameter.WorldSize=9; %World is assumed NxN matrix, but stored as vector
Parameter.NumberOfSocieties=32; %Total number of societies, 32 for TERSI model




    Simulate;
    CompareSocieties;
    print -dtiff
    ttl=sprintf('Simu2_%i_%i_%i',gridvals(index,1),floor(gridvals(index,2)*10),floor(gridvals(index,3)*10));
    save(ttl,'Parameter','Output')

end;
