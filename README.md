# TERSI: agent-base simulation of cooperative behavior based on Heath's typology of mechanisms of cooperative benefit #
## AuthorsA ##
Florian Lengyel 
CUNY Environmental CrossRoads Initiative
Department of Civil Engineering
The City College of New York
160 Convent Avenue, NY 10023

Jakke Makela

## Abstract ##
In "The Benefits of Cooperation," Joseph Heath proposed a typology
of five sui generis mechanisms of cooperative behavior: gain from 
Trade in competitive markets, Economies of scale, Risk pools, Self binding and 
Information transmission.  TERSI is an approach 
to agent-based simulation of simple societies which takes Heath's typology of mechanisms of 
cooperative benefit as the basis for the explicit specification  of cooperative behavior of 
simulated agents, and in which mechanisms can be selectively enabled and disabled to gauge 
their effect on the welfare of simulated societies.  Our simulations  show that welfare 
measures of societies in which all mechanisms of cooperative benefit are enabled are higher 
than those in which fewer mechanisms operate.  They also show that each of the five mechanisms 
exhibit diminishing returns and trade off against each other. Trade-offs among
cooperative benefits are highly interrelated and exhibit non-linearity. 

### Keywords ###

agent-based simulation; cooperative benefit; gain from trade; economies of scale; risk pools; self binding; information transmission.


## Overview ##

The code provided can simulate a simple society of nine zero-knowledge agents, in which 
five kinds of cooperarive benefit are specified algorithmically, and in which each of 
the five mechanisms of cooperative benefit could be enabled or disabled, and individually 
parametrized.  The simulation runs through each of the 32 possible societies corresponding to the 
mechanisms of cooperative benefit, designated by T, E, R, S and I, respectively.
Comparisons of welfare measures computed for these societies show that
societies in which all mechanisms of cooperative benefit are enabled are higher than 
those in which fewer mechanisms operate.
They also show that each of the five mechanisms exhibit diminishing returns and
trade off against each other.

A society for us consists of a configuration of agents, together with a collection of
mechanisms of cooperative benefit. Given that there are five mechanisms of cooperative benefit, there are 32 societies for a each fixed parametrization of mechanisms and of the environment. 
The environment of the simulated agents is simulated during each run in advance of the 
activities of the agents, which are controlled by the mechanisms enabled for each of
the 32 societies. In the current model there are environmental forcings on agent behavior
but agent behaviors does not affect the environment.


We take cooperation for granted in these simulations.  In evolutionary game-theoretic simulation, 
cooperation emerges as an evolutionarily stable strategy in a repeated non-cooperative game. 
Cooperative behavior is interpreted in this approach as the choice of a mutually beneficial strategy 
profile in a non-cooperative game such as prisoners' dilemma, for which non-cooperation is the 
dominant strategy according to some solution concept such as Nash-equilibrium . 

Our specification of mechanisms of cooperative benefit is plausible, but ad hoc. Game-theory 
based simulations define cooperation in terms of payoff functions, but leave the mechanism of
cooperation open or concentrate on one or two explicit mechanisms, such as gain from trade.
This raises the question of the formal definability of mechanisms of cooperative benefit, and
the question whether Heath's fivefold typology is provably exhaustive.


   
