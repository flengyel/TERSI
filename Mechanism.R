# Mechanisms of cooperative benefit. 
# Adapted from Jakke Makela's TERSI simulation by Florian Lengyel. R.oo classes are used 
# to enable passing the state of the simulation by reference to avoid copying large data 
# structures, and to facilitate modification of them. (S4 objects are immutable unless 
# replacement methods are defined, which introduces lexical ceremony and computational overhead.)

library(R.oo)
library(bitops)

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

TersiLegend <- function(f) {
  if (f==1) return("O")
  mechs <- c("T","E","R","S","I")
  bits <- c(1,2,4,8,16)
  flag <- f-1
  s <- ""
  i <- 0
  for (bit in bits) {
    i <- i + 1
    if (bitAnd(flag,bit) == bit)
      s <- paste(s, mechs[[i]],sep='')
  }
  return(s)  
}

kAgents    <-  9;  # number of agents per society
kSocieties <- 32;  # number of societies




# The MECHANISM class contains the state of a SIMULATION,
# as well as member functions corresponding to cooperative
# benefits. R.oo classes contain mutable state, unlike
# S4 classes, so they are used here.

setConstructorS3("MECHANISM", function (sim = new("SIMULATION")) {  # set simulation state
# Methods of the MECHANISM class define the five mechanisms of
# cooperative benefit.
#  
# Args:
#   sim:     SIMULATION object. Contains simulation parameters.
# Returns: 
#   Nothing. The side effect is to define the MECHANISM class.
#   Agent state mechanisms are defined by this class. The society
#   state is defined elsewhere.
#   An agent state matrix has dimensions kSocieties x kAgents. 
#   The agent state matrices are profit, wisdom, a and b.
  extend(Object(), "MECHANISM", 
    .sim = sim,  # set simulation parameters (no need for if missing statements)
    # define agent state variables and matrices, using simulation parameters
    .max.profit = matrix(sim@profit.start, 1, sim@societies),  # max of all agent profits
    .min.profit = matrix(sim@profit.start, 1, sim@societies),  # min of all agent profits
    .profit = matrix(sim@profit.start, sim@societies, sim@agents),
    .wisdom = matrix(sim@wisdom.start, sim@societies, sim@agents),
    .a      = matrix(sim@crop.target.start, sim@societies, sim@agents),
    .b      = matrix(sim@crop.target.start, sim@societies, sim@agents),
    .a.seed.exists = matrix(TRUE, sim@societies, sim@agents),  
    .b.seed.exists = matrix(TRUE, sim@societies, sim@agents),
    # society state variables hold for all societies
    .a.rainfall  =  runif(sim@agents) * sim@max.rain.ratio, 
    .b.rainfall  =  runif(sim@agents) * sim@max.rain.ratio)
})

setMethodS3("Rainfall", "MECHANISM", function(this, ...) {
  this$.a.rainfall  <- runif(this$.sim@agents) * this$.sim@max.rain.ratio 
  this$.b.rainfall  <- runif(this$.sim@agents) * this$.sim@max.rain.ratio
})


setMethodS3("GrowCrops", "MECHANISM", function(this, soc, crop.target, ...) {
  this$.a[soc, ] <- this$.a.rainfall * this$.wisdom[soc, ]  * 
                      this$.a.seed.exists[soc, ] * crop.target
  this$.b[soc, ] <- this$.b.rainfall * this$.wisdom[soc, ]  * 
                      this$.b.seed.exists[soc, ] * crop.target
})

					              
setMethodS3("Famines", "MECHANISM", function(this, soc,  seed.exists, ...) {
  return (sum(this[[seed.exists]][soc, ] == 0))
})


setMethodS3("AgentProfit", "MECHANISM", function(this, soc, agent, ...) {
# Return the profit matrix
# Args:
#   this: this S3 object
#   soc:  number of society
# Returns:
#   vector of agent profits for soc	    
  return (this$.profit[[soc, agent]])})



setMethodS3("Crucifixus", "MECHANISM", function(this, soc, crop.seed, ...) {
# List indices of bankrupted agents
# Args:
#   this: this S3 object
#   soc:  number of society
#   crop.seed: subsistence amount needed to grow next year's crops
# Returns:
#   vector of indices of dead agents
  this$.a.seed.exists[soc, ]  <- this$.a[soc, ] >= crop.seed  # boolean vector
  this$.b.seed.exists[soc, ]  <- this$.b[soc, ] >= crop.seed  # boolean vector
  # index the dead
  return(which( ! (this$.a.seed.exists[soc, ] | this$.b.seed.exists[soc, ]))) 
})

setMethodS3("EtResurrexit", "MECHANISM", function(this, soc, agent, crop.target, ...) {
# An agent has gone bankrupt. Create a new agent in his place.
# Args:
#   this: this S3 object
#   soc:  number of society
#   agent: agent to resurrect
#   crop.seed: subsistence amount needed to grow next year's crops
# Returns:
#   Nothing. Agent resurrected.
  this$.profit[[soc, agent]] <- 0   # the dead go fast
  # reset the crops to the crop.target for the next farmer
  this$.a[[soc, agent]] <- crop.target;
  this$.b[[soc, agent]] <- crop.target;
  # leave the wisdom intact. JM says this is for simplicity
  this$.a.seed.exists[[soc, agent]] <- TRUE;  # Et Resurrexit!
  this$.b.seed.exists[[soc, agent]] <- TRUE;
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
          
 
  random.growth <- runif(this$.sim@agents)  # matrix of uniform random numbers for each agent
  # normalize to the interior of the simplex of dimenstion num.agents - 1
  normalizer    <- sum(random.growth)  # nonzero since runif() returns nonzero numbers
  
  if (.HasMechanism(soc, kI)) { # everyone shares the max information
    wisdom.increase <- matrix(max(random.growth) / normalizer, 1, this$.sim@agents)
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

  surplus <- 0 
  v <- this[[crop]][soc, ]
  if (.HasMechanism(soc, kE)) {
    # compute value to be distributed over the limit to each
    surplus <- sum(v[v > limit] - limit) / this$.sim@agents
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
  # play an n-player prisoner's dilemma in which defectors each receive a fraction
  # of the sustainable amount and the total proceeds of the cooperators. The fraction
  # is the reciprocal of the number of defectors. It pays to be the sole defector.
  # If all are defectors, they undermine each other.
  
  v <- this[[crop]][soc, ]
  if (.HasMechanism(soc, kS)) {
    v[v > sust] <- sust   # truncate crop to sustainable level
  }    
  else { # potential tragedy of the commons
    num.defectors <- sum(v > sust)  # count the number of defectors
    if ( num.defectors > 0 ) { # play an n-player prisoner's dilemma
      v[v > sust] <- (sust + sum(v[v <= sust])) / num.defectors
      v[v <= sust] <- 0  # wipe out the cooperators
      }
  }# tragedy of the commons  
  this[[crop]][soc, ] <- v    # update the result 
})

setMethodS3("SelfBindingJM", "MECHANISM", function(this, soc, crop, sust, ...) {
  # if the self-binding mechanism holds, a tragedy of the commons is averted,
  # and no one produces above the sustainability limit. If the self-binding mechanism 
  # does not hold, the defectors, defined as those agents over the sustainability limit, 
  # impose a an average cost on the cooperators equal to 1/2 their unsustainable yield.
  
  v <- this[[crop]][soc, ]
  if (.HasMechanism(soc, kS)) {
    v[v > sust] <- sust   # truncate crop to sustainable level
  }    
  else { # defectors keep their profits and subject cooperators to a shock
    sum.cooperators <- sum(v <= sust)  # compute cooperator yield
    if ( sum.cooperators > 0 ) { # subject solvent cooperators to random shock
      shock <-  (v[v <= sust] / sum.cooperators) * sum(v[v > sust]) * runif(1)
      v[v <= sust] <- v[v <= sust] - shock
      v[v < 0] <- 0   # correct negative terms
      this[[crop]][soc, ] <- v    # update the result
    }
  }# The rich get richer
 
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
  this$.max.profit[[soc]] <- max(this$.max.profit[[soc]], this$.profit[soc, ])
  this$.min.profit[[soc]] <- min(this$.min.profit[[soc]], this$.profit[soc, ])
})



setMethodS3("GainFromTrade", "MECHANISM", function(this, soc, seed, trade.ratio,  ...) {
# Trade if mechanism enabled
# Attempts to equalize crops. Profits are computed as a function of how equal they are.
  if (.HasMechanism(soc, kT)) {
    delta <- this$.a[soc, ] - this$.b[soc, ]     # compute inter-crop differentials 
    trade.limit <- sum(abs(delta)) * trade.ratio  # maximum tradable value
    traded <- 0                                  # traded so far
    for (i in 1:(this$.sim@agents-1)) {
      if (traded >= trade.limit) break;
      for (j in (i+1):this$.sim@agents) {
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
