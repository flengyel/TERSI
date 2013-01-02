function wout=RContract(win,seed);
%If farmer(s) go below see level, others chip in
%Each one gives as a fraction of his existing crop

H=win;

starving=find(H<seed);
if length(starving)>0; %Don't go thru loop unnecessarily
    delta=length(starving)*seed-sum(H(starving));
    wellfed=find(H>seed);
    surplus=zeros(length(H),1);
    surplus(wellfed)=H(wellfed)-seed;
    if sum(surplus)>delta;%If all would go bankrupt, don't do it
        payout=(surplus/sum(surplus))*delta; %Divide by ratio
        if length(starving)>0;
            H(wellfed)=H(wellfed)-payout(wellfed);
            H(starving)=seed;
        end;
    end;
end;
wout=H;
