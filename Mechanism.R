# Mechanisms of cooperative benefit. Adapted from Jakke Makela's TERSI simulation
# by Florian Lengyel. R.oo classes are used to enable passing the state of the simulation
# by reference to avoid copying large data structures, and to facilitate modification
# of them. (S4 objects are immutable unless replacement methods are defined, which
# introduces lexical ceremony and computational overhead.)

library(R.oo)

# The TERSI constants (constants are camelCase beginning with k)
kT <- 1;   # gain from trade mechanism bit
kE <- 2;   # economies of scale mechanism bit
kR <- 4;   # risk pool mechanism bit
kS <- 8;   # self-binding mechanism bit
kI <- 16;  # information transmission mechanism bit

# hide this function
.HasMechanism <- function(society, mechanism) {
  # Check if society has one of the five mechanisms of cooperative benefit enabled
  #
  # Args:
  #   society: number of society 1:32
  #   mechanism: one of kT, kE, kR, kS, kI.
  #
  # Returns:
  #   True iff mechanism bit equals 1 in society-1
  bitAnd(society-1,mechanism)==1;}



kAgents    <-  9;  # number of agents per society
kSocieties <- 32;  # number of societies


# The MECHANISM class contains the state of a SIMULATION,
# as well as member functions corresponding to cooperative
# benefits. R.oo classes contain mutable state, unlike
# S4 classes, so they are used here.

setConstructorS3("MECHANISM", function (
# Set the initial society state for one run of the simulation.
# Methods of the MECHANISM class define the five mechanisms of
# cooperative benefit.
#  
# Args:
#   crop.target.start: initial value of a and b crops.
#   profit:  default profit value of all agents
#   wisdom:  starting information transmission parameter
#   a:       initial crop a value for each agent
#   b:       initial crop b value for each agent
#   deaths:  initial number of deaths in each society  
#  
# Returns: 
#   Nothing. The side effect is to define the MECHANISM class.
#   For efficiency, the society state is a list of preallocatted
#   matrices of two types: agent state matrices and society state vectors.
#   An agent state matrix has dimensions kSocieties x kAgents. 
#   The agent state matrices are profit, wisdom, a and b.
#   The society state vectors have length kSocieties.
#   The society state is reset at the beginning of each run
  
  crop.target.start = 1.6, 
  profit=0, 
  wisdom=1,
  a = crop.target.start, 
  b = crop.target.start,
  deaths=0, 
  a.famines=0, 
  b.famines=0, 
  dead.profit=0,
  num.societies = kSocieties, 
  num.agents = kAgents) {

#  We set parameters in the function definition instead of using
#  if (missing) statements.
  
  extend(Object(), "MECHANISM", 
    .num.societies = num.societies,
    .num.agents    = num.agents,
    .crop.target.start = crop.target.start,
    # define agent state matrices  
    .profit = matrix(profit, num.societies, num.agents),
    .wisdom = matrix(wisdom, num.societies, num.agents),
    .a      = matrix(crop.target.start, num.societies, num.agents),
    .b      = matrix(crop.target.start, num.societies, num.agents),
    # define society state matrices (vectors)
    .deaths      = matrix(deaths, 1, num.societies),
    .a.famines   = matrix(a.famines, 1, num.societies),
    .b.famines   = matrix(b.famines, 1, num.societies),
    .dead.profit = matrix(dead.profit, 1, num.societies)) # extend Object()
})

setMethodS3("InfoTransmission", "MECHANISM", 
            function(this, annual.wisdom.gain, society, ...) {
# Distribute information transmission among agents
# If the information transmission flag is TRUE, all agents
# receive annual.wisdom.gain; otherwise they receive
# a uniformly distributed random number in [0, 1] times
# annual.wisdom.gain
#
# Args:
#   wisdom: 1 x kAgents matrix assignment of current wisdom
#   annual.wisdom.gain:  the maximum level of information transmission
#   i.flag: TRUE iff Information Transmission mechanism enabled
#
# Returns:
#   nothing
#
# Side effects:
#   Updates wisdom
              
  # do nothing just to test
})

setMethodS3("EconomiesOfScale", "MECHANISM", function(this, ...)
  {})

setMethodS3("GainFromTrade", "MECHANISM", function(this, ...)
  {})

setMethodS3("RiskPooling", "MECHANISM", function(this, ...)
  {})

setMethodS3("SelfBinding", "MECHANISM", function(this, ...)
  {})

# End of TERSI methods


setMethodS3("ComputeProfit", "MECHANISM", function(this, soc, crop.seed, ...) {
# update the profit matrix for each agent of the society
# this subtracts the seed crop    
  
  c <- this$.a[soc, ] + this$.b[soc, ]  #  This assumes that the agent has crops or the sum is zero
  profit <- (c - 2 * crop.seed) * (2 - abs(this$.a[soc, ] - this$.b[soc, ]) / c) 
  this$.profit[soc, ] <- this$.profit[soc, ] + sapply(profit, function(x) { max(0, x) })  
})



