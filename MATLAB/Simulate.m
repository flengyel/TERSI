%v1.06


%clear; %clear everything
%InitializeSimulation; %Define all global simulation settings here


%Simplify variables
Crop_seed_start=Parameter.Crop_seed_start;
Crop_target_start=Parameter.Crop_target_start;
SustainabilityMaximumRatio=Parameter.SustainabilityMaximumRatio;
HarvestMaximumRatio=Parameter.HarvestMaximumRatio;
CooperationMaximumRatio=Parameter.CooperationMaximumRatio;
MaximumRainRatio=Parameter.MaximumRainRatio;
WorldSize=Parameter.WorldSize; %World is assumed NxN matrix, but stored as vector
NumberOfSocieties=Parameter.NumberOfSocieties; %Total number of societies, 32 for TERSI model
GlobalWisdomParameter_start=Parameter.GlobalWisdomParameter_start;
WisdomIncreasePerYear=Parameter.WisdomIncreasePerYear;
NumberOfSimulationRuns=Parameter.NumberOfSimulationRuns;
NumberOfYearsPerRun=Parameter.NumberOfYearsPerRun;

TradeRatio=Parameter.TradeRatio; %New parameter from v1.0.4

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%  SIMULATE %%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


SocietiesToCheck=1:32; %1:32; %Can zoom in on individual societies,
%Default 1:32;
%To simulate just T,E,R,S,I: [17,9,5,3,2]


for numofrun=1:NumberOfSimulationRuns;
    NumberOfSimulationRuns-numofrun


    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%  Initialize %%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    for kk=SocietiesToCheck;
        World(kk).TERSI=dec2bin(kk-1,5); %Create the binary representation
        World(kk).Profit=zeros(WorldSize,1);
        World(kk).Wisdom=ones(WorldSize,1);
        World(kk).A=ones(WorldSize,1)*Crop_target_start;  %Take care don't starve!
        World(kk).B=ones(WorldSize,1)*Crop_target_start;
        World(kk).Deaths=0; %Number of deaths that have occurred
        World(kk).AFamines=0; %List how many times there are zeros
        World(kk).BFamines=0; %List how many times there are zeros
        World(kk).DeadProfits=[]; %List profits of all who died
        World(kk).sumA=0; World(kk).sumB=0; %debug. Should be same
    end;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%  End Initialize %%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%% START SIMULATION WITH A RESETTED UNIVERSE
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    Crop_sust_start=Crop_target_start*SustainabilityMaximumRatio;
    Crop_coop_start=Crop_target_start*CooperationMaximumRatio;
    %Fixed starting parameters


    %Growing parameters initialized
    Crop_seed=Crop_seed_start;
    Crop_target=Crop_target_start;
    Crop_sust=Crop_sust_start;

    GlobalWisdomParameter=GlobalWisdomParameter_start;
    ASeedExists=1; %Doesnät get cut off in first run
    BSeedExists=1; %Doesnät get cut off in first run



    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%% SIMULATE EACH WORLD FOR A LIFETIME
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    for numofyear=1:NumberOfYearsPerRun;


        %%%%%%%%%%%%%%%%%%%%%%%
        %%% START DISTRIBUTE GROWTH%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%
        GlobalWisdomParameter=GlobalWisdomParameter+WisdomIncreasePerYear;
        %As wisdom grows, sustainable crops must also grow
        Crop_target=Crop_target_start*GlobalWisdomParameter;
        Crop_sust=Crop_sust_start*GlobalWisdomParameter;
        Crop_coop=Crop_coop_start*GlobalWisdomParameter;
        Crop_seed=Crop_seed_start*GlobalWisdomParameter; %QUESTION on this
        %%%%%%%%%%%%%%%%%%%%%%%
        %%% END DISTRIBUTE GROWTH%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%



        %%%%%%%%%%%%%%%%%%%%%%%
        %%% SET SAME RAINFALL FOR ALL SOCIETIES%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%
        Arainfall=rand(WorldSize,1)*MaximumRainRatio;  %Same for all societies
        Brainfall=rand(WorldSize,1)*MaximumRainRatio;  %Same for all societies



        %%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%% START CONTRACT DEALS%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        for numofsociety=SocietiesToCheck; %Enforce the contracts


            
            %Wisdom grown before new crop grown
            %I contract. The total amount of Wisdom added is WisdomIncreasePerYear
            %This is divided in different ways depending on contract
            Icontractinplace=(World(numofsociety).TERSI(5)=='1');
            World(numofsociety).Wisdom=DivideWisdom(World(numofsociety).Wisdom,WisdomIncreasePerYear,Icontractinplace);
            
            %%%Grow Crops
            World(numofsociety).A=(Arainfall.*World(numofsociety).Wisdom.*ASeedExists)*Crop_target;
            World(numofsociety).B=(Brainfall.*World(numofsociety).Wisdom.*BSeedExists)*Crop_target;

            %%Calculate famines
            World(numofsociety).AFamines=World(numofsociety).AFamines+sum(ASeedExists==0);
            World(numofsociety).BFamines=World(numofsociety).BFamines+sum(BSeedExists==0);


            %E: Economy of scale. Can only lift Crop_target alone, all if
            %together
            Econtractinplace=(World(numofsociety).TERSI(2)=='1');
            World(numofsociety).A=EContract(World(numofsociety).A,Crop_target*HarvestMaximumRatio,Econtractinplace);
            World(numofsociety).B=EContract(World(numofsociety).B,Crop_target*HarvestMaximumRatio,Econtractinplace);
            
            %S: If some fields have unsustainable yield, decrease others
            Scontractinplace=(World(numofsociety).TERSI(4)=='1');            
            World(numofsociety).A=CutToSustainability(World(numofsociety).A, Crop_sust,Scontractinplace);
            World(numofsociety).B=CutToSustainability(World(numofsociety).B, Crop_sust,Scontractinplace);
            %if min(min(World(numofsociety).A),min(World(numofsociety).B))<0; 'SHITTT!!!', return, end; %debug
            

            %R: Risk pooling. If not used, do nothing.
            if World(numofsociety).TERSI(3)=='1';
                World(numofsociety).A=RContract(World(numofsociety).A,Crop_seed);
                World(numofsociety).B=RContract(World(numofsociety).B,Crop_seed);
            end;
            %if min(min(World(numofsociety).A),min(World(numofsociety).B))<0; 'FUCKKKK!!!', return, end; %debug
            
            
            %T: Make trades. If not used, do nothing
            %%debug: CHANGE!!!
            if World(numofsociety).TERSI(1)=='1';
                World(numofsociety)=TContract(World(numofsociety),Crop_seed,TradeRatio);
            end;
            if min(min(World(numofsociety).A),min(World(numofsociety).B))<0; 'ERROR', return, end; %debug
            
            


            %PROFIT
            %Subtract the seed crop, make sure doesn't go negative
            %debug:CHANGE TO REFLECT T CHANGE
             World(numofsociety).Profit=World(numofsociety).Profit+CalculateProfit(World(numofsociety),Crop_seed);



            %%%%DEAL WITH DEATHS. DELETE OLD, SET UP NEW FARMER
            %New farmer currently set up as an average current farmer.
            %Avoid biasing simulation unfairly against deaths
            %If no seed has been left from previous round, cannot grow any now
            ASeedExists=(World(numofsociety).A>=Crop_seed);
            BSeedExists=(World(numofsociety).B>=Crop_seed);
            DeadMen=[];DeadMen=find(ASeedExists+BSeedExists==0); %How many are dead
            if length(DeadMen)>0; %If there are any dead
                for dm=DeadMen; %Go thru all dead farmers
                    %Must use temp variable when just one matrix element changed
                    World(numofsociety).Deaths=World(numofsociety).Deaths+1;
                    %Add to statistics
                    temp=[]; temp=World(numofsociety).Profit;
                    World(numofsociety).DeadProfits=[World(numofsociety).DeadProfits;temp(dm)];
                    %Add dead man to list of profits of all who died
                    %Set profit of new farmer to zero
                    temp=[];temp=World(numofsociety).Profit;
                    temp(dm)=0;
                    World(numofsociety).Profit=temp;
                    %Retain Wisdom level of previous farmer, for simplicity
                    %Reset A
                    temp=[];temp=World(numofsociety).A;
                    temp(dm)=Crop_target;
                    World(numofsociety).A=temp;
                    %Reset B
                    temp=[];temp=World(numofsociety).B;
                    temp(dm)=Crop_target;
                    World(numofsociety).B=temp;
                end;
            end;
            %Reset Seeds accoring ro new values
            ASeedExists=(World(numofsociety).A>=Crop_seed);
            BSeedExists=(World(numofsociety).B>=Crop_seed);
            %%%%%%%%%END DEAL WITH DEATHS


            %%% GET DECSRIPTIVE PARAMETERS FOR EACH WORLD
            CurrentProfit(numofrun,numofsociety)=sum(World(numofsociety).Profit);
            Deaths(numofrun,numofsociety)=World(numofsociety).Deaths;
            DeadProfit(numofrun,numofsociety)=sum(World(numofsociety).DeadProfits);
            AFamines(numofrun,numofsociety)=sum(World(numofsociety).AFamines);
            BFamines(numofrun,numofsociety)=sum(World(numofsociety).BFamines);
            %%% END GET DECSRIPTIVE PARAMETERS FOR EACH WORLD


        end;
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%% END CONTRACT DEALS%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    end; %END SIMULATE WORLDS FOR A LIFETIME

end; %END START FRESH NEW UNIVERSE


%To help store stuff
Output.CurrentProfit=CurrentProfit;
Output.DeadProfit=DeadProfit;
Output.Deaths=Deaths;
Output.AFamines=AFamines;
Output.BFamines=BFamines;

CompareSocieties;


