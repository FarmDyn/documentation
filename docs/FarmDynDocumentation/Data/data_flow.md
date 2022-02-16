# Data flow

> **_Abstract_**  
This section provides an overview over the general data flow within the model. It
addresses all relevant information related to data sourcing/collection, data
processing pre- and during the simulation and the structure of the database.

Data in Farmdyn is primarily collected from books, literature and online databases.
The collected data populates directly the exogenous parameters or is processed
in order to be harmonized with data from other sources (figure 1).
The parameters are stored in *.gms* or *.gdx* files, where each file deals
with a specific domain of the farm. This includes, for example, *cattle.gms*,
which stores data on all kind of information for dairy, beef and mothercow
farms, or *crops_de.gms* which stores and processes information for crops and
cropping activities. The database is not only domain specific but also country
specific. The suffix *_de* in the name of *crops_de.gms*, for instance, indicate that
the parameterization with this file would provide crop information for German
conditions. For some domains, FarmDyn also contains information for the
Netherlands, Norway, and Swizz. In line with the idea of modularity in FarmDyn,
each data file in the database corresponds to a certain module. This allows to call
only those data files which are necessary to run a simulation which was set-up in
the GUI configurator. Parameters from the called database are then processed further
in order to fit to the defined model configuration and can then be used in the
simulation run.

![](../../media/Data/Data_Flow.png){: style="width:100%"}
Figure 1: General data flow  in FarmDyn
Source: Own illustration
