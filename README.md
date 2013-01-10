# TERSI #
Simulation of institutions via Heath's typology of mechanisms of cooperative benefit

## Authors ##
* Florian Lengyel  [CUNY Environmental CrossRoads Initiative](http://asrc.cuny.edu/crossroads), 
[Advanced Science Research Center](http://asrc.cuny.edu)

* Jakke Makela

### Keywords ###

agent-based simulation; cooperative benefit; gain from trade; economies of scale; risk pools; self binding; information transmission.


## Overview ##

In [The Benefits of Cooperation](http://homes.chass.utoronto.ca/~jheath/BoC.pdf), Joseph Heath proposed a typology of five *sui generis* mechanisms of cooperative behavior: gain from Trade in competitive markets, Economies of scale, Risk pools, Self binding and Information transmission.  TERSI is an approach to agent-based simulation of simple societies which takes Heath's typology of mechanisms of cooperative benefit as the basis for the explicit specification  of cooperative behavior of simulated agents, in which mechanisms can be selectively enabled and disabled to gauge their effect on the welfare of simulated societies.  

Our simulations  show that welfare measures of societies in which all mechanisms of cooperative benefit are enabled are higher than those in which fewer mechanisms operate.  They also show that each of the five mechanisms exhibit diminishing returns and trade off against each other.  Trade-offs among cooperative benefits are highly interrelated and exhibit non-linearity. 


The code provided simulates a simple society of nine zero-knowledge agents, in which five kinds of cooperarive benefit are specified algorithmically.  The  mechanisms of cooperative benefit are designated here by **T** (gain from trade), **E** (economies of scale), **R** (risk pools), **S** (self binding) and **I** (information transmission), respectively.  A society for us consists of a configuration of agents, together with a collection of mechanisms of cooperative benefit. Given five mechanisms of cooperative benefit, there are 32 societies for  each fixed parametrization of mechanisms and of the environment.  The environment of the simulated agents is simulated during each run in advance of the activities of the agents, which are controlled by the mechanisms enabled for each of the 32 societies.  In the current model there are environmental forcings on agent behavior; agent behavior does not affect the environment.  


Fixed simulation parameters are defined in an R S4 object of class `TERSI`.  (One such user-specifiable parameter is the number of agents.) The simulation itself is stored as an  object of type `TERSI` for subsequent analysis.  Mutable simulation state is maintained in an R S3 object of class `SIMULATION` as the simulation runs. 

We take cooperation for granted in these simulations. In evolutionary game-theoretic simulation, cooperation often emerges as an evolutionarily stable strategy in a repeated non-cooperative game.  Cooperative behavior is interpreted in this approach as the choice of a mutually beneficial strategy profile in a non-cooperative game such as prisoners' dilemma, for which non-cooperation is the dominant strategy according to some solution concept such as Nash-equilibrium. 

Our specification of mechanisms of cooperative benefit is plausible, but *ad hoc*. Game-theory based simulations define cooperation in terms of payoff functions, but leave the mechanism of cooperation open or concentrate on one or two explicit mechanisms, such as gain from trade.  This raises the question of the formal definability of mechanisms of cooperative benefit, and the question whether Heath's fivefold typology is provably exhaustive.

## Running the simulation ##
Source the file `tersi.R`. Creation of a new `TERSI` object will run a simulation. 
```R
> source("tersi.R")
> x <- new("TERSI", crop.target.start=7, max.sust.ratio=1.2, runs=50, agents=25)
[1] "Running simulation."
[1] "Run number:1"
[1] "run: 1 year: 1 soc: 1 O deaths: 7"
[1] "run: 1 year: 1 soc: 2 T deaths: 7"
[1] "run: 1 year: 1 soc: 3 E deaths: 4"
[1] "run: 1 year: 1 soc: 4 TE deaths: 4"
[1] "run: 1 year: 1 soc: 5 R deaths: 0"
[1] "run: 1 year: 1 soc: 6 TR deaths: 0"
[1] "run: 1 year: 1 soc: 7 ER deaths: 0"
[1] "run: 1 year: 1 soc: 8 TER deaths: 0"
[1] "run: 1 year: 1 soc: 9 S deaths: 0"
```
Simulations may be saved to disk with the generic method `save()`.
```R
save(x, "MyFilename")
```
The `save()` method calls saveRDS() and will print an error message if an error is caught.

### TERSI constructor arguments ###
The TERSI object constructor arguments have the following default parameters. These may
be overriden.

```R
new ("TERSI", filename="", 
     crop.target.start = 10, 
     max.sust.ratio = 1.3, 
     max.harvest.ratio = 1.5, 
     trade.ratio = 0.5, 
     runs = 100, 
     years.per.run = 100, 
     max.rain.ratio = 2, 
     crop.seed.start = 1, 
     wisdom.start = 1, 
     agents = 9)
```

If the `filename` argument is used, it should be set to the name of a serialzed `TERSI` filesystem 
object previously saved using the generic method `save()`. The `TERSI` constructor will attempt 
to read the named file and will print an error message if an error is caught.

### Plotting functions ###
Source the file `plot.R`. This section of the documentation is under development.

## Sample output ##
The following plot shows measures of welfare computed for seven combinations of mechanisms. The measure computed is the Hobbes Index: the total profit accumulated by all agents, dead or alive, during each run of the simulation, divided by the number of deaths during each run. Each run lasts 100 years. The plot shows that enabling risk pools **R** alone is consistently more stable than enabling gain from trade, economies of scale and self binding **TES**. **TERSI** dominates all other combinations of mechanisms.
[<img src="https://github.com/flengyel/TERSI/blob/master/Runs/2012Oct12/Rplot1.png?raw=true">](https://github.com/flengyel/TERSI/blob/master/Runs/2012Oct12/Rplot1.png?raw=true)

Individual mechanisms of cooperative benefit other than **R** exhibit high variance. In [The Benefits of Cooperation](http://homes.chass.utoronto.ca/~jheath/BoC.pdf), Heath writes, "in an economic environment characterized by high variability in returns, with a mean return only slightly above the subsistence level, the benefits to be achieved through risk-pooling tend to far outweigh those that are achievable through trade" (p.19-20). The preceding and following plots illustrate that **R** dominates **O** (no mechanisms of cooperative benefit), **T**, **E**, **S** and **I**.  

[<img src="https://github.com/flengyel/TERSI/blob/master/Runs/2012Oct12/Rplot2.png?raw=true">](https://github.com/flengyel/TERSI/blob/master/Runs/2012Oct12/Rplot2.png?raw=true)

## License ##

(c) 2012, Florian Lengyel (flengyel at ccny dot cuny dot edu) and Jakke Makela (jakke dot makela at gmail dot com).  The text is licensed under a [Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported (CC BY-NC-SA-3.0) license](http://creativecommons.org/licenses/by-nc-sa/3.0/).  The code is licensed under the GNU General Public License, version 2.

