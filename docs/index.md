# FarmDyn

## A dynamic mixed integer bio-economic farm scale model

FARMDYN provides a **flexible, modular template** to simulate
**different farming systems (dairy, mother cows, beef fattening, pig fattening, piglet
production, arable farming, biogas plants)** at single farm scale.

![](media/farmdyn.PNG){: style="width:100%"}


Universität Bonn<br/>
Institute for Food and Resource Economics<br/>
[Economic Modeling of Agricultural Systems Group](http://www.ilr.uni-bonn.de/em/em_e.htm)

## Main characteristics

-   **Fully dynamic**, simulations typically cover several decades,
    alternatively comparative-static or short run version
-   Integer variables capture **indivisibilities in investments**
    (machinery, buildings) and **labour use**
-   Selected farm management decisions (e.g. feeding, manure management,
    labour use) depicted with a **sub-annual temporal resolution**,
    partially bi-weekly
-   **Deterministic or stochastic** programming version. The latter
    treats all variables as state dependent, allows for sceneario tree
    reduction and covers different risk measures (value at risk, MOTAD
    ...)
-   Farm labour, machinery and stable use are modelled in rich detail
-   Arable cropping can be differentiated by tillage type and intensity
    Different intensities are also available for grassland management
-   For dairy farming, the model distinguishes several herds by milk
    yield potential and lactation phase
-   The machinery park is available in different mechanization levels
-   Highly differentiated modules for nitrogen fate, while covering
    German legislation on fertilizer use

![Overview](media/Figure1.PNG){: style="width:100%"}

The model is currently **parameterized for German conditions** using
highly detailed farm planning data provided by
[KTBL](https://www.ktbl.de/) in combination with farm structural
statistics. It offers a complementary approach to other farm scale
models used in the institute such as the farm group models integrated in
[CAPRI](http://www.capri-model.org) or [FADN based farm-scale progamming
models](http://www.ilr.uni-bonn.de/agpo/rsrch/fadntool/fadntool_e.htm)
which both are comparative-static, calibrated against observed farm
programs with Positive Mathematical Programming while being far less
detailed with regard to technology, and not comprising explicit
investement decisions.

The model is realized in [GAMS](https://www.gams.com), solved with the industry
MIP solver
[CPLEX](http://www-01.ibm.com/software/commerce/optimization/cplex-optimizer/),
linked to a Graphical User Interface realized in
[GGIG](/em/staff/britz/ggig_e.htm) and hosted on a [Software Versioning
System](http://subversion.tigris.org/). Design of experiments, building
on [R](http://www.r-project.org) routines [directly called from
GAMS](http://support.gams.com/doku.php?id=gdxrrw:interfacing_gams_and_r),
can be used in combination with farm structural statistics to
systematically simulate different farm realizations (assets, farm
branches) and boundary conditions such as input and output prices or
emisisons ceilings using a **computing server to solve several instances
in parallel**. That approach has e.g. been used to estimate a
statistical meta model for Marginal Abatement Costs of Green House Gases
from dairy farms. Code development and testing follows agreed upon
[guidelines](https://www.ilr.uni-bonn.de/em/rsrch/farmdyn/codingConventions.pdf).
