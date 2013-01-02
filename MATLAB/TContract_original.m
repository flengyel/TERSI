
function WorldOut=TContract(WorldIn);
%Make trades, try to balance A and B.
%Still has bugs!

WorldOut=WorldIn;
A=WorldIn.A;
B=WorldIn.B;

%Only grow the smaller of A and B

Delta=A-B; %Imbalances that need to be restored

above=find(Delta>0);
below=find(Delta<0);


sumabove=abs(sum(Delta(above)));
sumbelow=abs(sum(Delta(below)));

%A(below)-B(below)

if (sumbelow<sumabove); %More are negative
    %Set all negative to zero, distribute among the positive
    A(below)=B(below);  %Technically A(sumbelow)=A(sumbelow)-Delta;
    A(above)=A(above)-Delta(above)*sumbelow/(sumabove); %Divide evenly
else;
    B(below)=B(below)+Delta(below)*sumabove/(sumbelow);  
    B(above)=A(above); %Technically B(sumbelow)=B(sumbelow)+Delta;
end;


WorldOut.A=A;
WorldOut.B=B;
