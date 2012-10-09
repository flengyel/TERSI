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
  #   True iff mechanism bit is on in society-1
  return(bitAnd(society-1,mechanism) == mechanism);
}



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
          
  print("I")
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
  print("E")
  surplus <- 0 
  v <- this[[crop]][soc, ]
  if (.HasMechanism(soc, kE)) {
    # compute value to be distributed over the limit to each
    surplus <- sum(v[v > limit] - limit) / this$.num.agents
  }
  v[v > limit] <- limit   # truncate to maximum individually liftable
  this[[crop]][soc, ] <- v + surplus
})

setMethodS3("RiskPooling", "MECHANISM", function(this, soc, crop, seed, ...) {
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
  
  print("R")
  if (.HasMechanism(soc, kR)) {
    v <- this[[crop]][soc, ]
    shortfall <- sum(seed - v[v < seed])  # difference the needy agents need to make up
    if (shortfall > 0) {  # proceed only if some starve      
      surplus <- sum(v[v > seed] - seed)  # what the others can spare
	   if (surplus > shortfall) {   # help only if no systemic failure
	     # bring the imperiled agent crop to subsistence by normalizing the shortfall over
       # the healthy agents and subtracting this from the healthy agents
       v[v > seed] <- v[v > seed] - ((v[v > seed] - seed) * (shortfall / surplus))
       v[v < seed] <- seed  # bring the needy agents up to subsistence level
	     this[[crop]][soc, ] <- v
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

  print("S")
  v <- this[[crop]][soc, ]
  num.defectors <- sum(v > sust)  # count the number of defectors
  
  if (.HasMechanism(soc, kS)) {
    v[v > sust] <- sust   # truncate crop to sustainable level
  }	  
  else { # there may be a tragedy of the commons
    if ( num.defectors > 0 ) { # proceed only if some crops are unsustainable
      externality <-  sum(v[v > sust] - sust)   # the amount imposed on others
      sustainable <-  sum(v[v <= sust])         # the total sustainable crop value
      
      # there are several cases. Use trichotomy to be safe
      if (externality < sustainable) { # the externality is nonzero and can be absorbed
        # distribute the externality over the honest farmers
        v[v <= sust] <- v[v <= sust] * (1 - externality / sustainable)
      }
      if (externality == sustainable) { # wipe out the honest ones
        v[v <= sust] <- 0
      }
      if (sustainable < externality) { # there are two subcases
        # case 1, there is some sustainable value
        if (sustainable > 0) { # now distribute 
          v[v > sust]  <- (v[v > sust] - sust) * (sustainable / externality) + sust
          v[v <= sust] <- 0   # wipe out the honest ones
        }
        else { # the honest farmers are bankrupt if they exist
          # This is the interesting case. The defectors could prey on each other.
          # we use the relative wealth of the defectors to assert ownership
          # the rich get richer. .
          # We add some log-normally distributed (hence, nonzero) luck to their
          # wealth. The agents need this at the beginning.
          wealth <-  this$.profit[soc, v > sust] + rlnorm(num.defectors)
          v[v > sust] <- wealth / sum(wealth) * sust * num.defectors
          print(v)
        }
      }      
    }
  } # tragedy of the commons  
  this[[crop]][soc, ] <- v    # update the result 
})



setMethodS3("ComputeProfit", "MECHANISM", function(this, soc, crop.seed, ...) {
# update the profit matrix for each agent of the society
# this subtracts the seed crop and rewards equal quantites of a and b.
  
  gross.profit <- this$.a[soc, ] + this$.b[soc, ]   # may be zero in some coordinates
  delta   <- abs(this$.a[soc, ] - this$.b[soc, ])   # vector of deviates

  # the net profit subtracts the seed values from a and b.
  net.profit <- gross.profit - 2 * crop.seed
  net.profit[net.profit < 0] <- 0   # adjust for values below 0 (beats using apply())

  # The multiplier rewards more nearly equal crops and penalizes division by 0
  multiplier <- mapply(function(x, y) { ifelse(y <= 0, 0, 2 - x / y) }, delta, gross.profit)
  this$.profit[soc, ] <- this$.profit[soc, ] + net.profit * multiplier
})



setMethodS3("GainFromTrade", "MECHANISM", function(this, soc, seed, trade.ratio,  ...) {
# Trade if mechanism enabled
# Attempts to equalize crops. Profits are computed as a function of how equal they are.

  print("T")
  if (.HasMechanism(soc, kT)) {
    delta <- this$.a[soc, ] - this$.b[soc, ]     # compute inter-crop differentials 
    trade.limit <- sum(abs(delta)) * trade.ratio  # maximum tradable value
    traded <- 0                                  # traded so far
    for (i in 1:(this$.num.agents-1)) {
      if (traded >= trade.limit) break;
      for (j in (i+1):this$.num.agents) {
        if (traded >= trade.limit) break;
        if (sign(delta[[i]]) * sign(delta[[j]]) == -1) { # trade if mutual benefit, meaning:
	        # either i has more of a (b) than b (a) and j has more of b (a) than a (b).
          max.exchange = min(abs(delta[[i]]), abs(delta[[j]]))  # max exchanged
	        dx <- sign(delta[[i]]) * max.exchange / 2    # equalize the min difference
	        a.i <- this$.a[[soc, i]]
	        a.j <- this$.a[[soc, j]]
	        b.i <- this$.b[[soc, i]]
	        b.j <- this$.b[[soc, j]]
          go <- a.i - dx >= seed & b.i + dx >= seed & a.j + dx >= seed & b.j - dx >= seed
	        if (go) {  # trade only if all trades stay at or above seed 
            this$.a[[soc, i]] <- a.i - dx
	          this$.b[[soc, i]] <- b.i + dx
	          this$.a[[soc, j]] <- a.j + dx
	          this$.b[[soc, j]] <- b.j - dx
	          delta <- this$.a[soc, ] - this$.b[soc, ]
	          traded <- traded + abs(dx)  # |dx| was traded between i and j
	        }
        } 
      }
    }
  }  # if kT mechanism
})  # GainFromTrade

# End of TERSI methods
