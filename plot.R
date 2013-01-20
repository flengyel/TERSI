# Plot routines for tersi simulations.
# (c) 2012 F. Lengyel

library(ggplot2)
library(methods)
library(bitops)
library(reshape)

options(error=utils::recover)

profit <- function(sim, mech) {
  total.profit <-  sim@stats$current.profit[ , mech] 
   + sim@stats$dead.profit[ , mech]

  plot(total.profit, type="o", col="red")
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

.sim.title <- function(ob) {
return(paste("TERSI Simulation\n",
  "agents:",ob@agents, 
  " crop target:", ob@crop.target.start,
  " sustainability ratio:", ob@max.sust.ratio,
  " harvest ratio:", ob@max.harvest.ratio,sep=''))
}

hobbes <- function(ob, mech) {
  return((ob@stats$current.profit[ , mech] 
          + ob@stats$dead.profit[ , mech]) / (ob@stats$deaths[ , mech] + ob@stats$a.famines[ , mech] + ob@stats$b.famines[ ,mech] + 1))
}

setGeneric("plot")
setGeneric("plot",function(ob,f,...){standardGeneric("plot")})

setMethod("plot", 
          c("TERSI","numeric"), 
          function(ob, f) {
  
  if (f == 1) {
    df <- data.frame(Run=1:ob@runs, 
                     ERSI=hobbes(ob,1+kE+kR+kS+kI),
                     TERSI=hobbes(ob,1+kT+kE+kR+kS+kI),
                     TRSI=hobbes(ob,1+kT+kR+kS+kI),
                     TES=hobbes(ob,1+kT+kE+kS),
                     TERS=hobbes(ob,1+kE+kR+kS),
                     R=hobbes(ob,1+kR),
                     S=hobbes(ob,1+kS))
    ggplot(df,aes(x=Run))  + ylab("Hobbes Index") +
    theme(legend.background=element_rect()) +
    geom_line(aes(y=ERSI, colour="ERSI")) +
    geom_line(aes(y=TERSI, colour="TERSI")) +
    geom_line(aes(y=TRSI, colour="TRSI")) +
    geom_line(aes(y=TES, colour="TES")) +
    geom_line(aes(y=R, colour="R")) +
    geom_line(aes(y=TERS, colour="TERS")) +
    geom_line(aes(y=S, colour="S")) +
    labs(title=.sim.title(ob)) +
    scale_color_manual("Legend", values=ob@palette)
  } else if (f == 2) {
    df <- data.frame(Run=1:ob@runs, 
                     O=hobbes(ob,1),
                     T=hobbes(ob,1+kT),
                     E=hobbes(ob,1+kE),
                     I=hobbes(ob,1+kI))
    ggplot(df,aes(x=Run))  + ylab("Hobbes Index") +
      theme(legend.background=element_rect()) +
      geom_line(aes(y=O, colour="O")) +
      geom_line(aes(y=T, colour="T")) +
      geom_line(aes(y=E, colour="E")) +
      geom_line(aes(y=I, colour="I")) +
      labs(title=.sim.title(ob)) +
      scale_color_manual("Legend", values=ob@palette)
  } else    if (f == 3) {
    df <- data.frame(Run=1:ob@runs, 
                     ERSI=hobbes(ob,1+kE+kR+kS+kI),
                     TRSI=hobbes(ob,1+kT+kR+kS+kI),
                     TERI=hobbes(ob,1+kT+kE+kR+kI),
                     TERS=hobbes(ob,1+kE+kR+kS),
                     TERSI=hobbes(ob,1+kT+kE+kR+kS+kI))
    ggplot(df,aes(x=Run))  + ylab("Hobbes Index") +
      theme(legend.background=element_rect()) +
      geom_line(aes(y=ERSI, colour="ERSI")) +
      geom_line(aes(y=TRSI, colour="TRSI")) +
      geom_line(aes(y=TERI, colour="TERI")) +
      geom_line(aes(y=TERS, colour="TERS")) +
      geom_line(aes(y=TERSI, colour="TERSI")) +
      labs(title=.sim.title(ob)) +
      scale_color_manual("Legend", values=ob@palette)
  } else {
    
    df <- data.frame(Run=1:ob@runs, 
                           R=hobbes(ob,1+kR),
                          S=hobbes(ob,1+kS))
    ggplot(df,aes(x=Run))  + ylab("Hobbes Index") +
      theme(legend.background=element_rect()) +
      geom_line(aes(y=R, colour="R")) +
      geom_line(aes(y=S, colour="S")) +
      labs(title=.sim.title(ob)) +
      scale_color_manual("Legend", values=ob@palette)
  }
    
})


# dangerous! setGeneric("density")
# Lowercase density() wants its first argument to be numeric.

setGeneric("Density", function(ob,...) standardGeneric("Density") )

setMethod("Density", signature=signature(ob="TERSI"), definition=function(ob) {
  df <- data.frame(R=hobbes(ob,1+kR), 
		   TES=hobbes(ob,1+kT+kE+kS),
		   TERSI=hobbes(ob,1+kT+kE+kR+kS+kI))

  mdf <- melt(df, variable="Mechanism", value=value, value.name="Hobbes Index");
  cdf <- ddply(mdf, .(Mechanism), summarise, hobbes.mean=mean(value));

  ggplot(data=mdf, aes(x=value, fill=Mechanism)) +
    geom_vline(data=cdf, 
	       aes(xintercept=hobbes.mean, color=Mechanism), 
               linetype="dashed",size=1) +
    xlab("Hobbes Index") +
    labs(title=.sim.title(ob))+
    geom_density(alpha=.3); 
}) 

