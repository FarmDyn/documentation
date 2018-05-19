# Dynamic Character of FARMDYN

## The Fully Dynamic Version

As described in earlier sections, the model template optimizes the farm
production process over time in a fully dynamic setting. Connecting
different modules over time (t~1~-t~n~) allows for a reproduction of
biologic and economic path dependencies.

As can be seen from Figure 6, the temporal resolution varies across
different parts of the template module. Cropping decisions are annually
implemented, whereas the intra-year resolution of the herd size module
can be flexibly chosen by the user.

Concerning fodder composition, decision points in each year are every
three month. This provides the decision maker a more flexible adjustment
to feed requirements of the herd (conditional on lactation phase), his
resources and prices respectively availability of pasture, silage and
concentrates. Furthermore, as stated in the manure module, the
application of manure or synthetic fertilizers, as well as the stored
manure amounts on farm are implemented on monthly level.

The optimal production plan over time is not simulated in a recursive
fashion from year to year, but all variables of the planning horizon are
optimised at once. Consequently, decisions at some point in time also
influence decisions before and not only after that point. For instance,
an increase in the herd at some point might require increased raising
processes before.

## Short Run and Comparative Static Version

The short run version considers only one year and does not comprise a
liquidation of the enterprise. The comparative-static version replaces
the herd dynamics by a steady state model where, for example, the cows
replaced in the current year are equal to the heifers in the current
year, which in turn are equal to the calves raised in the current year.
In the comparative static mode, the vintage model for investments in
buildings and machinery is replaced by a setting in which the investment
costs are related to one year. Nevertheless, the binary character can be
maintained.
