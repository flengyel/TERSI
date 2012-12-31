# TERSI #
Simulation of artificial societies  based on Heath's typology of mechanisms of cooperative benefit

## Authors ##
* Florian Lengyel  [CUNY Environmental CrossRoads Initiative](http://asrc.cuny.edu/crossroads), 
[Advanced Science Research Center](http://asrc.cuny.edu)

* Jakke Makela

### Keywords ###

agent-based simulation; cooperative benefit; gain from trade; economies of scale; risk pools; self binding; information transmission.


## Overview ##

In "The Benefits of Cooperation," Joseph Heath proposed a typology of five 
sui generis mechanisms of cooperative behavior: gain from Trade in competitive 
markets, Economies of scale, Risk pools, Self binding and Information 
transmission.  TERSI is an approach to agent-based simulation of simple 
societies which takes Heath's typology of mechanisms of cooperative benefit 
as the basis for the explicit specification  of cooperative behavior of 
simulated agents, in which mechanisms can be selectively enabled and disabled 
to gauge their effect on the welfare of simulated societies.  

Our simulations  show that welfare measures of societies in which all 
mechanisms of cooperative benefit are enabled are higher than those in 
which fewer mechanisms operate.  They also show that each of the five 
mechanisms exhibit diminishing returns and trade off against each other. 
Trade-offs among cooperative benefits are highly interrelated and exhibit 
non-linearity. 


The code provided simulates a simple society of nine zero-knowledge agents, 
in which five kinds of cooperarive benefit are specified algorithmically. 
The  mechanisms of cooperative benefit are  designated here by T (gain from 
trade), E (economies of scale), R (risk pools), S (self binding) and I 
(information transmission), respectively.  A society for us consists of a 
configuration of agents, together with a collection of mechanisms of 
cooperative benefit. Given five mechanisms of cooperative benefit, 
there are 32 societies for  each fixed parametrization of mechanisms and 
of the environment.  The environment of the simulated agents is simulated 
during each run in advance of the activities of the agents, which are 
controlled by the mechanisms enabled for each of the 32 societies. 
In the current model there are environmental forcings on agent behavior;
agent behavior does not affect the environment.  


Fixed simulation parameters are defined in an R S4 object of class TERSI. 
(One such user-specifiable parameter is the number of agents.) The simulation 
itself is stored as an  object of type TERSI for subsequent analysis.  
Mutable simulation state is maintained in an R S3 object of class 
SIMULATION as the simulation runs. 



We take cooperation for granted in these simulations.  In evolutionary 
game-theoretic simulation, cooperation often emerges as an evolutionarily 
stable strategy in a repeated non-cooperative game.  Cooperative behavior 
is interpreted in this approach as the choice of a mutually beneficial 
strategy profile in a non-cooperative game such as prisoners' dilemma, 
for which non-cooperation is the dominant strategy according to some 
solution concept such as Nash-equilibrium. 

Our specification of mechanisms of cooperative benefit is plausible, but 
ad hoc. Game-theory based simulations define cooperation in terms of 
payoff functions, but leave the mechanism of cooperation open or 
concentrate on one or two explicit mechanisms, such as gain from trade.
This raises the question of the formal definability of mechanisms of 
cooperative benefit, and the question whether Heath's fivefold typology 
is provably exhaustive.

## Sample output ##
The following plot shows measures of welfare computed for seven combinations
of mechanisms. The measure computed is the Hobbes Index: the total profit
accumulated by all agents, dead or alive, during each run of the simulation,
divided by the number of deaths during each run. Each run lasts 100 years.
The plot shows that enabling risk pools alone (R) is consistently more stable
than enabling gain from trade, economies of scale and self binding (TES). 
TERSI dominates all other combinations of mechanisms.
[<img src="https://github.com/flengyel/TERSI/blob/master/Runs/2012Oct12/Rplot1.png?raw=true">](https://github.com/flengyel/TERSI/blob/master/Runs/2012Oct12/Rplot1.png?raw=true)

## License ##

(c) 2012, Florian Lengyel (florian dot lengyel at gmail dot com) and 
Jakke Makela (jakke dot makela at gmail dot com).  The text is licensed 
under a [Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported (CC BY-NC-SA-3.0) license](http://creativecommons.org/licenses/by-nc-sa/3.0/).  The code is licensed under the GNU General Public License, version 2.

