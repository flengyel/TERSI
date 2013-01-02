function profit=CalculateProfit(Win,seed)

A=Win.A;
B=Win.B;



profit=max(0,(A+B-2*seed).*(2-(abs(A-B)./(A+B))));

%Old 
%profit=max(0,A+B-2*seed);

