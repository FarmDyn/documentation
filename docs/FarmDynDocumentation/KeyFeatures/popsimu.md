# Farm population

## Introduction to the simulation of farm populations

FarmDyn is a single-farm level model. This provides an ideal option to assess certain policies or technologies given a few suitable case study farms. However, often the research question at hand wants to answer questions related to certain populations or want to examines the effect on many heterogenous farms. In research questions such as that, case study farms are not capable to capture all relevant aspects. In order to address exactly this heterogenous effect of different farms within a population or the population as a whole, FarmDyn offers to simulate farm populations. Farm populations are introduced as single farms with each one distinct from another. The relevant characteristics which distinguish each of the farms are the:

* Farm type
* Output levels (crop yields and animal outputs)
* Number of labor units on farms
* Arable- and grasland endowments
* Number of animals
* Initial inventory of stables

## Implementation in the model

The file to generate a farm population can be found under */dat* with an farm population example in the file *farmData\_de.gms*. In that file you can adjust the number of farms your populations has and assign values to the parameters from the list above. After filling in all relevant information in the file you can run the file to generate a *.gdx* container which can be used as the farm population in FarmDyn.

In a second step you can call upon the generated farm population in the GUI as seen in the figure below. You can choose here your relevant *Farm sample file* which opens up the option to choose certain farms to simulate or to automatically run all farms sequentially. Note, that you have to set the FarmDyn task from *Single farm run* to *Farm sample run* on the left hand side of the GUI.   

![](../../media/PopSimu/PopSimuGUI.PNG){: style="width:100%"}
Figure 1: GUI Farm sample options
Source: Own illustration.
