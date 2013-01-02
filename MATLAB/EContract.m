function Hout=EContract(Hin,limit,contractinplace);
%Everything above personal limit gets shared


if contractinplace; %Evrything lifted but excess shared
    htemp=zeros(length(Hin),1);
    above=(Hin>limit);
    below=(Hin<limit);
    htemp(above)=limit;
    htemp(below)=Hin(below);
    surplus=sum(Hin(above)-htemp(above));
    htemp=htemp+surplus/length(Hin);
    Hout=htemp;
else;
    %Each one lifts at most the limit
    Hout=min(limit,Hin);
end;











