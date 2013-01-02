
function Wout=DivideWisdom(Win,wisdomadded,contractinplace);
%Version 1.0.7
%If no contract, everyone gets at rand()*wisdomadded
%If in contract, everyone gets wisdomadded



randomgrowth=rand(length(Win),1);
distributedwisdom=randomgrowth./sum(randomgrowth)*wisdomadded;
maxwisdom=max(randomgrowth)/sum(randomgrowth)*wisdomadded; %Largest wisdom added

if contractinplace;  %Everyone gets the maximum wisdom
    increases=ones(length(Win),1)* maxwisdom; %Maximum wisdom for everyone
else;  %Divide the wisdom randomly
    increases=distributedwisdom;
    %Wisdom might not increase at all
end;
Wout=Win+increases;