# FarmDyn - A highly detailed template model for dynamic optimization of farms

![](/media/FarmDyn.png)

Universität Bonn<br/>
Institute for Food and Resource Economics<br/>
[Economic Modeling of Agricultural Systems Group](http://www.ilr.uni-bonn.de/em/em_e.htm)

The dynamic single farm model FARMDYN is the outcome of several,
partially on-going research activities. It provides a modular and
extendable template model to simulate economically optimal production
and investment decisions in detail at single farm scale. FARMDYN depicts
various farm branches (arable cropping, pig fattening, piglet
production, dairy, beef fattening, biogas plants). Its default layout
maximizes the deterministic net present value over a longer simulation
horizon; alternatively, short-run, comparative-static or stochastic
layouts are available. In the latter case, all variables are state
contingent and different types of risk behaviour can be modelled.
Integer variables depict indivisibilities in labour use and investment
decisions. Constraints reflect in rich detail (1) the inventory of and
requirements for machines, stables and other structures, (2) demographic
relations between different herds, (3) labour and feed requirements and
nutrient flows as well as (4) the financial sphere of the farm, with a
temporal resolution between two weeks and a year. The constraints can
depict various environmental standards linked to detailed environmental
accounting for nitrogen, phosphate and gases relevant for global
warming. A state-of-the-art software implementation based on GAMS in
combination with MIP industry solvers and a graphical user interface
allows for efficient analysis. FARMDYN consists of several interacting
modules (Figure 1).

![](media/figure2.png)
:   Figure 1.  Overview of template model.

The **herd module** captures the intra-temporal demographic relations
between different herds (number of animals born, replacement rates,
raising periods etc.), at a maximal intra-yearly resolution of single
months. The temporal resolution can be increased by aggregation on
demand to reduce model size. In a specific cattle module, cow herds can
be distinguished by genetic potential, including endogenous breeding
towards higher milk yield. Furthermore, herds can be differentiated by
animal types - such as cow, heifer, calf -, breeds, intensity levels
(milk yield, daily weight gain) and feeding regimes. The pig module
distinguishes between fattening- and piglet production systems.
Fattening pigs are subdivided into different phases to account for
different feeding requirements and excretion values. The piglet
production system differentiates between sows, young piglets and
piglets, which are separated from their mother after two weeks.

The **feed module** distinguishes between pig and cattle feeding
requirements. For a dairy herd, it captures a cost minimal feed mix from
own produced fodder and different types of concentrates at given
requirements per head and intra-year feeding periods (energy, protein,
dry matter) for each cattle herd. For pigs it determines a cost minimal
feed mix from own produced and purchased fodder and concentrates such as
soybean meal and soy oil. For both branches, different feeding phases
for reduced nitrogen and phosphorus output can be used.

The **cropping module** optimizes the cropping pattern subject to land
availability, reflecting yields, prices, machinery and fertilizing needs
and other variable costs for a selectable longer list of arable crops.
The crops can be differentiated by production system (plough, minimal
tillage, no tillage, organic) and intensity level (normal and reduced
fertilization in 20% steps). Machinery use is linked to field working
days requirements depicted with a bi-weekly resolution during the
relevant months. Crop rotational constraints can be either depicted by
introducing crop rotations or by simple maximal shares. The model can
capture plots which are differentiated by soil, size and land type
(gras, arable).

The **labourmodule** (not shown in Figure 1) optimizes work use on- and
off farm with a monthly resolution, depicting in detail labour needs for
different farm operations, herds and stables as well as management
requirements for each farm branch and the farm as a whole. Off farm work
distinguishes between half and full time work (binaries) and working
flexibly for a low wage rate.

The **investment module** depicts investment decisions in machinery,
stables and structures (silos, biogas plants, storage) as binary
variables with a yearly resolution. Physical depreciation can be based
on lifetime or use. Machinery use can be alternatively depicted as
continuous re-investment rendering investment costs variable, based on a
Euro per ha threshold. Investment can be financed out of (accumulated)
cash flow or by credits of different length and related interest rates.
For stables and biogas plants, maintenance investment is reflected as
well.

Manure excretion from animals is calculated in the **manure module**
based on fixed factors, differentiated by animal type, yield level and
feeding practice. For biogas production, the composition of different
feed stock is taken into account. Manure can be stored subfloor in
stables and in different types of silos. Application of manure has to
follow legal obligations and interacts with plant nutrient need from the
cropping module. Different N losses are accounted for in stable, storage
and during application.

The **environmental accounting module** allows quantifying gas emissions
of Ammonia (NH<sub>3</sub>), nitrous oxide (N<sub>2</sub>O), nitrogen oxides (NO<sub>x</sub>) and
elemental nitrogen (N<sub>2</sub>). For nitrogen (N) and phosphate (P), soil
surface balances are calculated indicating potential nitrate leaching
and phosphate losses. Environmental impacts are related to relevant
farming operation.

The **biogas module** defines the economic and technological relations
between components of a biogas plant with a monthly resolution, as well
as links to the farm. Thereby, it includes the statutory payment
structure and their respective restrictions according to the German
Renewable Energy Acts (EEGs) from 2004 up to 2014. The biogas module
differentiates between three different sizes of biogas plants and
accounts for three different lifespans of investments connected to the
biogas plant. Data for the technological and economic parameters used in
the model are derived from KTBL (2014) and FNR (2013). The equations
within the template model related to the biogas module are presented in
the following section.
