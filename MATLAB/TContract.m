
function WorldOut=TContract(WorldIn,seed,Ratio);
%Make trades, try to balance A and B.
%Only a maximum number of crops can be changed, 
%should be done in order of profit so that richest has a benefit. Right now
%is not
%The algorithm makes sure no one makes an unfavorable trade.
%Note that all possible pairwise trades are effectively never made, so
%ratio is notional.
%Seed needed to avoid bankruptcies in trade

WorldOut=WorldIn;

A=WorldIn.A;
B=WorldIn.B;
Profit=WorldIn.Profit;  %Trades to be made in order of cumulative profit?

%debug: sum 90

croplen=length(A);
Delta=A-B;
MaximumTrades=sum(abs(Delta))*Ratio;
TradesDone=0;



for ind1=1:(croplen-1);
    for ind2=(ind1+1):(croplen);
        %ind1, ind2
        if sign(Delta(ind1)*sign(Delta(ind2)))==-1; %Only switch if sign different
            chmax=min([abs(Delta(ind1)),abs(Delta(ind2))]);   %Ain(ind1)-seed, Ain(ind2)-seed,Bin(ind1)-seed,Bin(ind2)-seed]);
            dx=sign(Delta(ind1))*chmax/2;  %Amount of change
            %dx
            %A(ind1), B(ind1),          A(ind2),             B(ind2)
            %Determine if trade Ok for everyone
	    % last two conjuncts changed to match assignments in goahead
            goahead=( (A(ind1)-dx>=seed)&&(B(ind1)+dx>=seed)
	              &&(A(ind2)+dx>=seed)&&(B(ind2)-dx>=seed) );
            if goahead;
                %Never go bankrupt
                A(ind1)=A(ind1)-dx;
                B(ind1)=B(ind1)+dx;
                A(ind2)=A(ind2)+dx;
                B(ind2)=B(ind2)-dx;
                Delta=A-B;
                TradesDone=TradesDone+abs(dx);
                %A',B',TradesDone, input('Press Return'); %debug
                if TradesDone>=MaximumTrades; break;end; %If trades still possible
            end;
        end;
    end;
    if TradesDone>=MaximumTrades; break;end; %If trades still possible

end;



%MaximumTrades, TradesDone

WorldOut.A=A;
WorldOut.B=B;
