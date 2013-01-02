 

for ii=1:100;

Win.A=round(rand(10,1)*9); Win.B=round(rand(10,1)*9); 
Wout=TContract(Win,1,1); 

(Wout.A-Wout.B)./(Win.A-Win.B)
%(sum(Win.A<seed)+sum(Win.B<seed))
%(sum(Wout.A<seed)+sum(Wout.B<seed))

input('Press Enter')

end;