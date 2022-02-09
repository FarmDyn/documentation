# Data Collection

FarmDyn sources it's data from online databases, books and scientific literature.
In the German version, it heavily relies on data for the agricultural sector
from the "Kuratorium für Technik und Bauwesen in der Landwirtschaft" (KTBL) for:

- **Farm planning data**: for example, work steps in crop production, feed ratios
in animals based on the development stage, variable costs for all production activities,
etc.

- **Investment data**: this includes prices and technical information on buildings
and machinery.

- **Prices**: both input and output prices from KTBL are used in the default setting
in FarmDyn, however, can be adjusted to each specific case study

In addition to the KTBL data, FarmDyn uses data from scientific literature and
other publicly available policy briefs for:

- **Policy**: relevant parameters for policy assessment such as, the CAP based
*greening*, *agri-environmental schemes*, and the *Fertilization Ordinance*

- **Emission factors**: information on disaggregated GHG emissions as well as data
on particulate matter, nitrate leaching, etc. for all farming activities.

- **Biodiversity indicators**: data from scientific literature to determine three
different biodiversity indicator.

The exact data sources are mentioned and documented in the GAMS code such as seen
below:


[embedmd]:# (N:/em/work1/Pahmeyer/FarmDyn/FarmDynDoku/FarmDyn_Docu/dat/emissions_de.gms GAMS /\*--- Cattle, partial emission factor for NH3-N from housing / /;/)
```GAMS
*--- Cattle, partial emission factor for NH3-N from housing (related to TAN) in kg kg-1
*     Haenel et al. (2018), p. 108

   $$iftheni.cattle "%cattle%"=="true"

      p_EFSta("NH3","LiquidCattle")       = 0.197;
```
As most data is freely available online, there are no limitations in most configurations of the model.
However, some of the data used in projects is under copyright protection and hence
prevents the use of certain parts of modules.
