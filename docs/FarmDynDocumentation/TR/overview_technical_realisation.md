# Overview of Technical Realisation

!!!abstract
    The model uses GAMS for data transformations and model generation and applies the industry LP and MIP solver CPLEX for solution. The code adheres to strict coding guidelines, for instance with regard to naming conventions, code structuring and documentation, including a modular approach. A set of carefully chosen compilation and exploitation tests is used to check the code. The code is steered by a GUI based on GGIG (ref., Java code) which also support result exploitation.


The model template and the coefficient generator are realised in GAMS
(General Algebraic Modeling System), a widely used modeling language
for economic simulation models. GAMS is declarative, i.e. the structure of the model's equation is declared once, and from there different model instances can be
generated. GAMS supports scripting for data transformation, extensively
used by the coefficient generator and by the post-model reporting.

![](../../media/TechnicalRealisation/Bild_1.png){: style="width:100%"}
:   Figure 11: Overview of technical realisation.
    Source: Own illustration

Additionally, as an extension of the experiment exploiter, *machine
learning* (for detailed description see Britz, 2011) can
be used to derive correlations and dependencies between model results
and available model variables.