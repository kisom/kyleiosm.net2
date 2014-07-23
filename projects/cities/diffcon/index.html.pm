#lang pollen

◊h2{Diffusion-contact model}

◊p{Diffusion-contact is the first actual model used to simulate urban
development. In this model, a cellular automata model represents
physical space, with each cell being either empty or containing an
agent. When an agent has at least ◊entity['phi] Moore neighbours, it
stops moving; otherwise, they walk randomly throughout the grid. A
Moore neighbourhood considers a 3x3 grid, with the cell at the centre
being the cell whose neighbours are being counted. Each cell with an
agent (including the agent's cell) is counted as 1.}

◊p{Formally, given an initial number of agents ◊emph{M} and ◊emph{j},
a regular tesslation (in this case, a 2D grid without wrapping), and
◊entity['phi], the number of neighbours in the Moore space an agent
has, the system observes the following rules:}

◊ol{

  ◊li{Initial conditions: ◊emph{A◊sub{j}◊sup{m} = random(j)}}

  ◊li{if
  ◊entity['Sigma]◊sub{k=◊entity['Omega]◊sub{i}}A◊sub{k}◊sup{m}(t) >
  ◊entity['phi], thene D◊sub{i}(t) = 1} ◊li{Otherwise, both
  D◊sub{i}(t) = 0 and move(A◊sub{i}◊sup{m}(t-1), random(◊entity['Phi],
  random(d))), where ◊entity['Phi] is the agent's heading and d is the
  maximum distance for a step.}

}

◊p{In this simulation, agents walk randomly with a maximum distance of
10 cells in the x plane and 10 cells in the y plane according to a
Monte-Carlo squared distribution; that is, given p = random(10) and d
= random(10), if d◊sup{2} < p, then d is the distance chosen and the
direction is a coin flip over the uniform distribution.}

◊h3{Experiment 1}

◊p{An initial experiment on a 150x150 grid with 7500 agents and
◊em{◊entity['phi]=5} was run through. After 153 steps, all agents had
stopped moving.}

◊p{t=0}
◊img['src: "initial.png"]{}

◊p{t=153}
◊img['src: "clusters.png"]{}

◊p{Animation:}
◊img['src: "diffcon7500-5.gif"]{}


◊h3{Experiment 2}

◊p{With 2500 agents, it took 3071 steps:}

◊p{t=0}
◊img['src: "initial2500-5.png"]{}

◊p{t=3071}
◊img['src: "clusters2500-5.png"]{}

◊p{Animation:}
◊img['src: "diffcon2500-5.gif"]{}

◊p{Code is ◊link["https://dev.metacircular.net/projects/CC/repos/diffcon"]{available}.}
