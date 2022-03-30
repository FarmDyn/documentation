# Calibration

## General concept

In order to generate a reasonable baseline for policy analysis, FarmDyn provides the option to calibrate the model to observed farms. The calibration is implemented as a bi-level optimization approach. The bi-level optimization approach is segmented in an upper and lower problem. The upper problem represents the minimization of the deviation between observed values and previously fixed values. These fixed values against which the model is calibrated against, can be set on the one hand by the user and on the other hand are taken from key parameters in FarmDyn. The user can define crop rotations and the number of animals. Data on  prices for both input and output, yields, labour coefficients, feeding coefficients are used and adapted to steer the FarmDyn model to reproduce the observed crop rotations and animal numbers. The lower problem of the bi-level optimization process is the FarmDyn model itself.

For a general introduction of the calibration method in FarmDyn you can refer to:

Britz, W. (2021): Automated Calibration of Farm-Sale Mixed Linear Programming Models using Bi-Level Programming, *German Journal of Agricultural Economics*, 70(3): 165-181.

## Small user guide

In the figure below you see the set-up of the calibration process. In the "File with calibration bounds" you can select your file in which the calibration targets for crop rotations and animal numbers are set. Further, you can set the calibration bounds for yields, output prices, costs, input prices, feed coefficients and labour coefficients. The values which can be steered by the user give a +/- percentage deviation of given FarmDyn parameters. Eventually, one can set the lower bound on the objective function. This is realized by using the overall farm profit from a "normal" solve, which then can be enables to define a lower bound on the objective function.

![](../../media/Calibration/Calibration.PNG){: style="width:100%"}
Figure 1: GUI calibration options
Source: Own illustration.

The calibration results are stored in a *.gdx* container which can be called in the GUI to simulate the given farm.

![](../../media/Calibration/CalibrationResults.PNG){: style="width:100%"}
Figure 1: GUI calibration options
Source: Own illustration.
