# Introduction

The dynamic single farm model FarmDyn is the outcome of
several, partially on-going research activities. Its first version
(named DAIRYDYN) was developed in the context of a research project
financed by the German Science Foundation (DFG, Nr. HO3780/2-1) focusing
on marginal abatement costs of dairy farms in comparison across
different indicators for Green House Gases. Relating material and
information on the project are available on the project related
web-page:
<http://www.ilr.uni-bonn.de/agpo/rsrch/dfg-ghgabat/dfgabat_e.htm>. That
project contributed the overall concept and the highly detailed
description of dairy farming and GHG accounting, while it comprises only
a rudimentary module for arable cropping. It was -- while improvements
were going on -- used for several peer reviewed papers
(Lengers and Britz 2012,
Lengers et al. 2013a, 2013b, Lengers et al.
2014) and conference contributions (Lengers and
Britz 2011, Lengers et al. 2013c).

That version of the model was used by Garbert (2013) in
her PhD thesis as the starting point to develop a first module for pig
farming, however with less detail with regard to feeding options
compared to cattle. Garbert also developed a first
phosphate accounting module. Activities in spring 2013 for a scientific
paper (Remble et al. 2013) contributed a first version
with arable crops differentiated by intensity level and tillage type.
Along with that came a more detailed machinery module which also
considered plot size and mechanisation level effect on costs and labour
needs. Based on nitrogen response functions, nitrogen loss factors were
differentiated for the different intensity and related yield levels.
Activities in summer 2013 then contributed a soil pool approach for
nutrient accounts, differentiated by month and soil depth layer while
also introducing different soil types and three states of weather. In
parallel, further information from farm planning books was integrated
(e.g. available field working days depending on soil type and climate
zone) and more crops and thus machinery was added. The Graphical User
Interface (GUI) and reporting parts were also enhanced. As the model now
incorporated beside dairy production also other agricultural production
activities, the model was renamed to FARMDYN (farm dynamic).

David Schäfer, then a master student, developed in 2014 a bio-gas module
for the model which reflects the German renewable energy legislation.
Since 2014, sensitivity analysis with regard to farm endowment and
prices was used to generate observations sets to estimate dual profit
function which were then used in the Agent Based Model ABMSIM
(http://www.ilr.uni-bonn.de/agpo/rsrch/abmsim/abmsim\_e.htm). Around the
same time, Till Kuhn improved substantially the nutrient flow and
fertilizer management handling in the model. A project financed by the
DFG
(http://www.ilr.uni-bonn.de/agpo/rsrch/dfg-dairystruct/dfgdairystruct\_e.htm)
with a focus on Agent Based Modeling supports since 2015 that line of
work. Since summer 2016, a project financed by the State of
Nordrhine-Westfalia sponsors the combined application of crop-growth
models, FARMDYN and ABMSIM, focusing on nutrient flows on-farm and
between farms. In 2016, a stochastic programming extension with decision
tress where all variables are stage contingent was developed. That
extension can capture different type of risk behaviours and uses Mean
Reverting Processes for the logs of prices in conjunction with a tree
reduction algorithm.

That documentation is organized as follows. Following the introduction,
we will discuss the core methodology with regard to the overall concept
of the tool and the layout of the template model, with detail on the
different modules, such as the herd, cropping, fertilization or
investment module. The third section discusses the dynamic examination
of the modeling approach, followed in section four by a discussion of
the stochastic version and how different types of risk behaviour can be
integrated. Section five describes the different GHG indicators and the
calculation of Marginal Abatement Curves (MAC). The following sections
present the coefficient generator, the technical implementation and the
graphical user interface (GUI) which help the user to define experiments
and visualize or analyze the results. For more information or access to
unpublished technical papers of Britz and Lengers please feel free to
contact:

**Wolfgang Britz**, Dr., Institute of Food and Resource Economics,
University of Bonn, wolfgang.britz\@ilr.uni-bonn.de

## Basic methodology and tool concept


The core of the simulation framework consists of a detailed fully
dynamic mixed integer optimization (MIP) model for one farm which can be
extended to stochastic programming framework. The linear program
maximizes utility -- Net Present Value (NPV) of future farm profits,
expected NPV or depicting different types of risk behaviour -- under
constraints which describe (1) the production feasibility set of the
farm with detailed bio-physical interactions, (2) maximal willingness to
work of the family members for working on and off farms, (3) liquidity
constraints, and (4) environmental restrictions.

Using MIP allows depicting the non-divisibility of investment and labour
use decisions. An overview on mixed integer programming models and their
theoretical concepts provide for instance Nemhauser and
Wolsey (1999) or Pochet and
Wolsey (2006). Non-linear relations such as yield-nutrient
responses of crops are depicted by piece-wise linearization. The fully
dynamic character optimizes farm management and investment decisions
over a planning horizon. However, the model can also be simplified to a
comparative-static one by assuming continuous re-investments, see
section 3.1, or extended to a stochastic fully-dynamic one, in
combination with different type of risk behaviour, see section 4.

FARMDYN presents a modular and extendable framework which allows
simulating in detail changes of farm management and investment decisions
under different boundary conditions such as prices or policy instruments
e.g. relating to GHG abatement such as tradable permits or an emission
tax, for a wide range of different farm systems found in Germany and
beyond. It depicts the complex interplay of farm management and
investment decisions - such as e.g. adjustments of herd sizes, milk
yields, feeding practise, crop shares and intensity of crop production,
manure treatment -- in a highly detailed fully dynamic bio-economic
simulation model, building on Mixed-Integer Programming.

In its default version, the model assumes a fully rational and fully
informed farmer optimizing the net present value of the farm operation
plus earnings from working off farm. A rich set of constraints describe
the relations between the farmer's decision variables in financial and
physical terms and his production possibility set arising e.g. from the
firm's initial endowment of primary factors. These constraints also
cover different relevant environmental externalities. Its dynamic
approach over several years has clearly advantages in policy analysis as
the adjustment path including (re-)investments can be depicted as it
reflects sunk costs and other path dependencies.

The application of a mixed integer programming approach allows
considering non-divisibility of labour use and investment decisions.
Neglecting that aspect has at least two serious dis-advantages. Firstly,
economies of scale are typically not correctly depicted as e.g.
fractions of large-scale machinery or stables will be bought in a
standard LP. That will tend to underestimate production costs and
overestimate the flexibility in changing capital stock. Secondly, using
fractions increases the production feasibility set which again will tend
to increase profits and decrease costs.

Sensitivity analysis using Design of Experiments can be used to derive
the simulation response under, for instance, changes in farm endowment
or input and output prices.
