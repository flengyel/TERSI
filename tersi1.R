# Translation of Jakke Makela's TERSI simulation to R. 
#
# Translation by Florian Lengyel. 

# The simulation is motivated by Joseph Heath's  typology of mechanisms of 
# cooperative benefit (Heath, Joseph. The Benefits of Cooperation. 
# Philosophy & Public Affairs.  Vol. 34, number 4. Blackwell Publishing Inc. 
# 2006. pp 313-351).
#
# The code attempts to follow Google's R Style Guide
# URL: http://google-styleguide.googlecode.com/svn/trunk/google-r-style.html
# The first rule we attempt to follow is the 80 character maximum line length. 
#
#2345678901234567890123456789012345678901234567890123456789012345678901234567890
#        1         2         3         4         5         6         7         8
#
# During development, we follow Cory Doctorow's advice to insert TK in 
# comments for facts we should look up and replace in the future. (TK is a 
# combination that rarely comes up in text searches, so journlists use it.)
#
# The Google Style Guide recommends using S3 classes instead of S4 classes 
# unless there is a justification. My justification for using them is 
# that I know more about S4 classes than S3 classes. They are used to store
# simulation parmeters and completed simulations. However, S4 class objects
# are immutable and R does not currently provide intrinsic support for 
# purely functional data structures (Chris Okasaki. Purely Functional
# Data Structures. Cambridge University Press, Jun 13, 1999). S4 objects
# require replacement methods to update a new copy of the original object
# for each slot that is updated. Creating new immutable objects by copying 
# old ones whenever an agent changes state is less efficient than appending 
# to an existing data structure (useful for maintaining the history of 
# state changes of an agent). Appending to an existing data structure such 
# as data frame is less space and time  efficient than destructive assignment, 
# which S4 objects do not support.  Exploring purely functional data 
# structures in R is left as an exercise for the future. R does support 
# appending a new row to a data frame through the rbind() call. Our use of 
# rbind() will probably land us in the Second Circle of the R Inferno, unless
# we can allocate the entire data structure from the beginning.
#
# Addition: Class names are all UPPERCASE.
#
# DATA STRUCTURES
# This translation uses data structures appropriate to R.
# Only one society at a time is simulated -- this should facilitate
# parallel processing, since the 32 societies are independent.
#
# The data structures include:
#
# 1. An S4 class called TERSI that contains the parameters that define the 
# simulation, the R data structures that maintain the history of the 
# simulation, and strings and constants useful for the analysis and display
# of a simulation. The simulation is run when the TERSI object is created,
# within the initialization method of the class.
#
# 2. Simulation matrices. 
# 2a. Society matrix. A matrix of data frames of the state of each agent. 
#     Matrices of data frames were chosen for ease of implementation:
#        m <- matrix(data.frame(), society.rows, society.cols)
#     Individual cells can be updated (all values must be assembled at once)
#        m[[2,1]] <- rbind(m[[2,1]], c(1.2, 4, -1, 2.2, 0)
#     Cells can be assigned names
#        names(m[[2,1]]) <- c("profit", "wisdom", "a", "b", "a.famines")
# 2b. Dead profit matrix. A matrix of lists of "dead profits" accumulated 
#     by agents that go bankrupt during the simulation. The sum of the 
#     lengths of the lists is the number of deaths. 

# The society matrix keeps the history of the simulation for each time step.
# The dead profits matrix maintains only changes. Dead profits can be 
# maintained in the society matrix with the addition of a cumulative dead
# profits field.  Since I cannot decide, I will do both.

library(methods) # use version S4 R classes
library(bitops)  # for bitAnd

# The TERSI constants (constants are camelCase beginning with k)
kT <- 1;   # gain from trade mechanism bit
kE <- 2;   # economies of scale mechanism bit
kR <- 4;   # risk pool mechanism bit
kS <- 8;   # self-binding mechanism bit
kI <- 16;  # information transmission mechanism bit

has.mech <- function(society, mechanism) {
# Check if society has mechanism enabled
#
# Args:
#   society: number of society 1:32
#   mechanism: one of kT, kE, kR, kS, kI.
#
# Returns:
#   True iff mechanism bit equals 1 in society-1
    bitAnd(society-1,mechanism)==1;}

# A society is a 3x3 matrix consisting of data frames, called a cell. 
# Each cell represents the state of an agent, one state per row.   
# The bitmask of mechanisms of cooperative benefits enabled  for the
# society to which the agent belongs is contained in the TERSI object
# for the simulation.

# Vector of column names of each cell 
agent.colnames <- c("profit",   # agent profit 
    "wisdom",                   # unit of information  
    "a",                        # a crop value in cell
    "b",                        # b crop value in cell
    "deaths",                   # deaths in cell
    "a.famines",                # no times a = 0
    "b.famines",                # no times b = 0
    "dead.profits")             # cumulative dead profits

CreateAgent <- function(crop.target.start, profit=0, wisdom=1,
			a = crop.target.start, b = crop.target.start,
			deaths=0, a.famines=0, b.famines=0, 
			dead.profits=0) {
# Set the initial state of a TERSI agent.

# Args:
#   crop.target.start: initial value of a and b crops.
#
# Returns: 
#   Data frame of initilized agent object, with default
#   values and column names set.
#   
    df <- data.frame(profit, wisdom, a, b, deaths,
		      a.famines, b.famines, dead.profits);
    names(df) <- agent.colnames;
    df
}

CreateSociety <- function(rows, cols, crop.target.start) {
# create rows x cols matrix of agents
#
# Args:
#   crop.target.start: initial value of a and b crops
#   rows: self explanatory
#   cols: ditto
#
# Returns:
#   rows x cols matrix of data frames of agent states.
    soc <- matrix(data.frame(), rows, cols);
    for (i in 1:rows) {
        for (j in 1:cols) {
	    soc[[i, j]] <- rbind(soc[[i, j]], CreateAgent(crop.target.start));    
        }
    }
    soc
}

PushList <- function(lst, obj) {
# push an object onto an immutable list
#
# Args:
#   lst: an R list
#   obj: an object
#
# Returns:
#   A new immutable list.     
#
    lst[[length(lst)+1]] <- obj
    return(lst)
}

# I might want to define a SIMULATION object and subclass the final
# TERSI object from this, to save copying variables. The TERSI initialization
# can then call the superclass initialization method to set the initial 
# variables the superclass Run method to define the simulation.
# That means running an experiment.

setClass("SIMULATION", representation = representation( 
    crop.target.start = "numeric",  # Mean raised crop at beginning
    # On average there will be famine * rainfall (verify TK)
    max.sust.ratio = "numeric",     # maximum sustainabiilty ratio
    # Ratio to basic target where sustainability limit sets in
    max.harvest.ratio = "numeric",
    # Ratio to basic target that can be harvested in the absence of
    # economies of scale (without the cooperation of others).
    # Limit is 4, since rainfall*wisdom can equal 4 at end of simulation 
    # TK explain all parameter choices.
    #
    # The following parameters are set for all class instances.
    # They are inaccessible to the initialize method.
    runs = "numeric",  # number of simulation runs
    years.per.run = "numeric",   
    annual.wisdom.gain = "numeric",  # wisdom increase per year
    max.rain.ratio = "numeric",      # Maximum annual rainfall 
    max.coop.ratio = "numeric",      # TK
    trade.ratio = "numeric",         # Maximum that can be traded
    crop.seed.start = "numeric",     # Minimum seed crop for next year
    wisdom.start = "numeric",        # global wisdom parameter
    society.rows = "numeric",
    society.cols = "numeric",
    society.size = "numeric",
    world.list="list"))


setMethod("initialize","SIMULATION", 
	  function(.Object, 
		   bitmask = 0, # TERSI bitmask
		   crop.target.start = 10, 
                   max.sust.ratio = 1.3, 
		   max.harvest.ratio = 1.5,
		   trade.ratio = 0.5,
		   runs = 100,
		   years.per.run = 100,
		   max.rain.ratio = 2,
		   crop.seed.start = 1,
		   wisdom.start = 1,
		   society.rows = 3,
		   society.cols = 3) {
    .Object@crop.target.start <- crop.target.start;
    .Object@max.sust.ratio <- max.sust.ratio;
    .Object@max.harvest.ratio <- max.harvest.ratio;
    .Object@trade.ratio <- trade.ratio;
    .Object@runs <- runs; 
    .Object@years.per.run <- years.per.run; 

    # Maximum Wisdom increase per year. Hundred years in total
    # At end of simulation, will be exactly at sustainability level!
    .Object@annual.wisdom.gain <- (max.sust.ratio - 1) / .Object@years.per.run;

    .Object@max.rain.ratio <- max.rain.ratio;
    .Object@max.coop.ratio <- .Object@max.rain.ratio * max.sust.ratio;
    # All can be lifted if cooperation is in place. This is full amount at end.
    .Object@crop.seed.start <- crop.seed.start;  
    # Minimum needed as seed crop for next year
    # Wisdom Parameters. Do not change by default
    .Object@wisdom.start <- wisdom.start; 
    .Object@society.rows <- society.rows;
    .Object@society.cols <- society.cols;
    .Object@society.size <- society.rows * society.cols;  # NxN matrix
    .Object@bitmask <- bitmask;  # This MUST be set. Non-optional.

    # (TODO) run the simulation

    .Object  # return the initialized object
})  # (initialize TERSI object)


# Without setGeneric, the corresponding setMethod generates an error
# Error in setMethod("DivideWisdom", signature = signature(ob = "TERSI"),  : 
#  no existing definition for function ‘DivideWisdom’
# The variable 'ob' in setGeneric MUST match
# the corresponding setMethod

#setGeneric("DivideWisdom", function(ob, ...) standardGeneric("DivideWisdom"))

#setMethod("DivideWisdom", signature=signature(ob="TERSI"), definition=function(ob, soc) {
#  society <- ob@world.list[[soc]]  # get society
#  society
#})


setGeneric("Simulate", function(ob, ...) standardGeneric("Simulate"))

setMethod("Simulate", signature=signature(ob="SIMULATION"), definition=function(ob) {
# Run the simulation. 
#
# Args:
#   ob: SIMULATION object
#
# Returns:
#   matrix of data.frames of AGENTS. Used to define the 
    for (i in 1:ob@runs) {
        crop.sust.start <- ob@crop.target.start * ob@max.sust.ratio;
        crop.coop.start <- ob@crop.target.start * ob@max.coop.ratio;

    	# Set growing parameters 
        crop.seed <- ob@crop.seed.start;

        crop.target     <- ob@crop.target.start;
        crop.sust       <- crop.sust.start;
        global.wisdom   <- ob@wisdom.start;

        a.seed.exists   <- 1;  # Doesn't get cut off in first run
        b.seed.exists   <- 1; 


        # Simulate each world for a lifetime 
        for (year in 1:ob@years.per.run) {
            global.wisdom <- global.wisdom + ob@annual.wisdom.gain;

            # As wisdom grows, sustainable crops must also grow
            crop.target <- ob@crop.target.start * global.wisdom;
            crop.sust   <- crop.sust.start * global.wisdom;
            crop.coop   <- crop.coop.start * global.wisdom;
            
	    # TK JaKke writes, "question on this."
	    # Probably because the initialized value above is overwritten here.
	    crop.seed   <- ob@crop.seed.start * global.wisdom;  


	    # Define rainfall matrices for all societies
            a.rainfall  <- runif(ob@world.rows, ob@world.cols) 
	                         * ob@max.rain.ratio;  
            b.rainfall  <- runif(ob@world.rows, ob@world.cols) 
	                         * ob@max.rain.ratio;  


            # I mechanism. Wisdom increases before new crop is grown.
            # This is divided in different ways depending on contract
            i.flag  <- hasMechanism(ob@bitmask, kI);
            
	}
    }
}) # (method {function})
