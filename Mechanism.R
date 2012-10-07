# Mechanisms of cooperative benefit. 
# Adapted from Jakke Makela's TERSI simulation by Florian Lengyel. R.oo classes are used 
# to enable passing the state of the simulation by reference to avoid copying large data 
# structures, and to facilitate modification of them. (S4 objects are immutable unless 
# replacement methods are defined, which introduces lexical ceremony and computational overhead.)

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
            function(this, soc, annual.wisdom.gain, ...) {
# Information information mechanism. Distributes wisdom among agents
# If the information transmission flag is TRUE, all agents
# receive annual.wisdom.gain; otherwise they receive
# a uniformly distributed random number in [0, 1] times
# annual.wisdom.gain
#
# Args:
#   this: MECHANISM state
#   soc:  society index
#   annual.wisdom.gain:  the maximum level of information transmission / year
#
# Returns:
#   nothing
#
# Side effects:
#   Updates wisdom
              
  random.growth <- runif(this$.num.agents)  # matrix of uniform random numbers for each agent
  # normalize to the interior of the simplex of dimenstion num.agents - 1
  normalizer    <- sum(random.growth)  # nonzero since runif() returns nonzero numbers
  
  if (.HasMechanism(soc, kI)) { # everyone shares the max information
    wisdom.increase <- matrix(max(random.growth) / normalizer, 1, this$.num.agents)
  }
  else { # No information transmission. Pick up what you can.
    wisdom.increase <- random.growth / normalizer  # normalize
  }
  this$.wisdom[soc, ] <- this$.wisdom[soc, ] + wisdom.increase * annual.wisdom.gain               
})


setMethodS3("EconomiesOfScale", "MECHANISM", function(this, soc, crop, limit, ...) {
# Economies of Scale mechanism. Distributes wisdom among agents
#
# Args:
#   this: MECHANISM state
#   soc:  society index
#   crop: string argument equal to ".a" or ".b"
#   limit:  the maximum harvest level in the absence of this mechanism
#
# Returns:
#   nothing
#
# Side effects:
#   Updates a and b crops depending whether kE is set in soc

# You might use the exception mechanism to check for ".a" or ".b"
  
  surplus <- 0
  if (.HasMechanism(soc, kE)) {
     # compute vector of excess over limit of crop for each agent
     excess <- sapply(this[[crop]][soc, ], function(x){return (max(0, x - limit))})  
     surplus <- sum(excess) / this$.num.agents  # surplus sums the excesses and distributes
  }
  # truncate the crops to the maximum limit and add any surplus
  this[[crop]][soc, ] <- sapply(this[[crop]][soc, ], function(x) {return(min(x, limit))}) + surplus

})

setMethodS3("RiskPooling", "MECHANISM", function(this, soc, seed, ...) {
# If farmers go below seed level, the othefs help out unless they go bankrupt.
#
# Args:
#   this: simulation state
#   soc:  the current society
#   crop: ".a" or ".b"
#   seed: minimum level required to plant a viable crop
#
# Returns:
#   state modified to reflect aid to indigent farmers
  if (.HasMechanism(soc, kR)) {
     starving.flags <- this[[crop]][soc, ] < seed
     if (sum(starving.flags) > 0) {  # proceed only if some starve
	agent.subsistence <- starving.flags * seed
	starving.agents <-   starving.flags * this[[crop]][soc, ]
        shortfall <- sum(agent.subsistence - starving.agents)  # shortfalls for each agent
	wellfed.flags <- ! starving.flags  # negate these. 
	wellfed.agents <- wellfed.flags * this[[crop]][soc, ]
        agent.surplus <- wellfed.agents - wellfed.flags * seed  # what the others can spare
	surplus <- sum(agent.surplus)  # total agent surplus
	if (surplus > shortfall) {   # help only if no systemic failure
	   payout <- agent.surplus/surplus * shortfall   # normalize by total surplus
	   this[[crop]][soc, ] <- wellfed.agents - payout + agent.subsistence
	}
     }	 
  }
})


setMethodS3("SelfBinding", "MECHANISM", function(this, soc, crop, sust, ...) {
# if the self-binding mechanism holds, a tragedy of the commons is averted,
# and no one produces above the sustainability limit. If the self-binding mechanism 
# does not hold, the defectors, defined as those agents over the sustainability limit, 
# impose a negative externality on the cooperators, based on the ability of the 
# cooperators to pay. If the cooperators can pay, they pay based on what they earn.
# If they cannot pay, the defectors weight their claim to the entire earnings of
# the cooperators based on their expectation, as if they were in the previous case.
  

  cooperator.flags <- this[[crop]][soc, ] <= sust
  num.cooperators = length(cooperator.flags)
  if (num.cooperators == 0 | .HasMechanism(soc, kS)) {
    this[[crop]][soc, ] <- sapply(this[[crop]][soc, ], function(x) {return(min(x, sust))})	  
  }	  
  else { # there are cooperators, zero or more defectors but no self-binding mechanism
    defector.flags <- ! cooperator.flags 
    defectors <- defector.flags * this[[crop]][soc, ]
    externality <- sum(defectors  - defector.flags * sust)
    cooperators <- cooperator.flags * this[[crop]][soc, ]
    earned <- sum (cooperators)
    # Now it's a contest between what the cooperators earned and the externality 
    # that the defectors would like to impose on the cooperators.
    if ( externality <= earned ) {
      # From each cooperator in according to his actual earnings, to each defector according 
      # to his unsustainable expectation. (Defectors mark to model.) The cooperator's externality
      # is the defector's subsidy.
      if (earned > 0) {
        payout <- cooperators / earned * externality;
        this[[crop]][soc, ] <- this[[crop]][soc, ] - payout;    
      } # no payout if cooperators have no earnings
    # note that sum(this[[crop]][soc, ] - payout) = sum(defector.flags * sust + cooperators)
    } 
    else { # earned < externality
      # From each cooperator everything, to each defector according to his expected earnings,
      # sustainable or not.  The cooperators haven't earned enough to pay the defectors. The 
      # defectors now have to negotiate or fight over the proceeds. If the defectors had
      # decided to cooperate with each other, they might have split the earnings on the basis 
      # of their excess claims over sustainable production. That would follow Aumann's 
      # interpretation of a text from the Talmud. But these defectors don't recognize 
      # sustainable production.  Each weights his entitlement based on his total expectation.  
      # We call this weighting the "Pareto greed distribution." Any cooperators are wiped out.
      pareto <- defectors / sum (defectors);
      this[[crop]][soc, ] <- (defector.flags * sust) + (pareto * earned);
    }
  } # unsustainable
})

# End of TERSI methods


setMethodS3("ComputeProfit", "MECHANISM", function(this, soc, crop.seed, ...) {
# update the profit matrix for each agent of the society
# this subtracts the seed crop and rewards equal quantites of a and b.
  
  gross.profit <- this$.a[soc, ] + this$.b[soc, ]   # may be zero in some coordinates
  delta   <- abs(this$.a[soc, ] - this$.b[soc, ])   # vector of deviates

  # the net profit subtracts the seed values from a and b.
  net.profit <- sapply(gross.profit - 2 * crop.seed, function(x){max(0, x)})

  # The multiplier rewards more nearly equal crops and penalizes division by 0
  multiplier <- mapply(function(x, y) { ifelse(y <= 0, 0, 2 - x / y) }, delta, gross.profit)

  this$.profit[soc, ] <- this$.profit[soc, ] + net.profit * multiplier
})



setMethodS3("GainFromTrade", "MECHANISM", function(this, soc,  ...) {

})

