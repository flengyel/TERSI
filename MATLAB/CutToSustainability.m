function Wout=CutToSustainability(Win, Sustlevel,contractinplace);
%If some crops are above the sustainable level, cut from the others
%If multiple farmers are above, none of their crops are cut
%For simplicity, deal out losses to all others evenly
%If one of the farmers goes below zero, just set his crop to zero
%Other option would be to divide his extra among the others
%But this behavior is enough to show the key effect: loss to neighbors
%Not a zero-sum game: a random percentage is depleted!

Wout=Win;


if contractinplace;
    Wout=min(Sustlevel,Win);
else;
    abovelevel=find(Win>Sustlevel);
    losers=find(Win<=Sustlevel);
    if length(abovelevel)>0; %Don't go thru loop unnecessarily
        delta=sum(Win((abovelevel)));
        payout=zeros(length(Win),1);
        payout(losers)=(Win(losers)/sum(Win(losers)))*delta*rand(); %Divide by ratio
        Win(losers)=max(0,Win(losers)-payout(losers));
    end;
    Wout=Win; % moved from after the end to here - FL
end;


