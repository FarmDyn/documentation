# Database

The database is located in the *\dat* folder and contains all the relevant information used in FarmDyn. It contains country or region specific agronomic, policy or emission data, which are denominated with the suffix of the corresponding country. In the example below, you can see files denominated with a suffix *\_de* for Germany (Deutschland) and *\_no* for Norway. Further, most data files are written in the *.gms* files, however, some of the data is coming from pre-processing steps and are given by .gdx files.

In addition to the data used in the agronomic, policy and emission domain of FarmDyn, the farm population can be generated in the file *farmData_de.gms* or any copy of it to generate a *gdx* file with the farm population.

![](../../media/Data/Folder_Structure.png){: style="width:100%"}
Figure 2: File structure with exemplary snippet
Source: Own illustration


# KTBL Database

The KTBL database reports detailed data for 145 crops, including for example main and catch crops under conventional and organic production and different tillage systems (till,mintill,notill). The data includes information on machine applications and related resource requirements, revenues and direct costs as well as agronomic information required in FarmDyn.
A list of all crops and available combinations of crops, tillage and farming system (org,conv) are provided in the file *c_s_t_i.gms*. The KTBL database reports different implementations of a crop, which are associated with different machine requirements, revenues and costs (e.g. irrigated vs. non-irrigated cultivation, different processing and marketing options). In the file, a standard implementation is selected for each available combination of crop, tillage and farming system which can be adapted to specific needs.

## Revenues and direct costs

For each available combination of crops, tillage and farming system, detailed information on yields, prices as well as expenses for agricultural contractors and direct costs (e.g. planting materials, fertilizers and pesticides) are included in *Revenue_directcosts/crops.gdx*. The file *revenues_directcosts.gms* loads and processes the data to prepare its use in FarmDyn. The processed data is stored in *gams/ktbl/revenues_directCosts.gdx* and later accessed by the *build-data* processing (described in the section *Data processing*).

## Machine applications and related resource requirements

The KTBL database reports for each crop required field operations (e.g. tillage, sowing) and related machine applications.  Data covers resource requirements and costs of machine applications, including, for instance, labor requirements, machinery depreciation and costs for maintenance, lubricants and fuel. All data are provided for each available combination of crops, farming and tillage system and are differentiated by mechanization levels, which reflect substitution possibilities between labor and capital and costs in crop production. Labor requirements and costs of machine applications are highly dependent on plot sizes and farm-plot distances. A regression model is implemented, expressing labor and resource requirements of machine applications as a function of plot sizes and farm-plot distances (Heinrichs et al 2021). Thereby, plot sizes of up to 40ha and farm-plot distances of up to 30km are considered.
The data is stored in *KTBL_to_FarmDyn\KTBL_Data* and processed by *variable_machineCosts.gms*. An overview of the structure of the machinery data is given in the file *Summary_structure_KTBL_Data.xlsx*.

## Agronomic data  

The data for each crop is supplemented by detailed agronomic information, including for example maximum rotational shares, feeding attributes and N fixation of legumes. The data is stored in multiple *.gms* files (e.g. *biogas_data.gms*, *crop_dat_farmDyn.gms*, *feedContent_data.gms*). The agronomic data is imported from online databases, books and scientific literature. The exact data sources are mentioned and documented in the GAMS code.
All crops are further subdivided into multiple subsets (*crops_subsets_FarmDyn.gms*) to ease data processing in FarmDyn.

## Data aggregation

Both, the agronomic data as well as the data related to machine applications is processed and summarized in the file *ktbl_to_farmdyn.gms*. The file generates a large *.gdx* file *gams/ktbl/ktbl.gdx*, containing relevant data for all crops. The file is later accessed by the *build-data* processing.

## Implementation of new crops  

The KTBL data can be adapted to individual requirements and new crops can be introduced using the file "implement_new_crops.gms". An example is presented. Thereby, it is important to introduce all relevant data for the new crop. The file is called by *revenues_directCosts.gms* and by *ktbl_to_farmdyn.gms*.
