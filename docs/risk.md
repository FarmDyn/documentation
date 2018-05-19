# Dealing with risk and risk behavior: deterministic versus stochastic model versions

!!! danger "Prototype feature"
    This feature has'nt been thoroughly tested and should be used with caution.

!!!abstract
    The default layout of the model maximizes the net present value over the simulation horizon in a deterministic setting. The stochastic programming extensions introduces decision trees based on mean reverting processes for the output and input price levels and renders all variable state contingents, calculating the option value of full flexibility in management and investment decision over the simulation horizon. A tree reduction algorithm allows exploiting the outcome of large-scale Monte-Carlo simulations while avoiding the curse of dimensionality. Besides risk neutral maximization of the expected net present value, different types of risk behavior such as MOTAD, Target MOTAD or value at risk can be used in conjunction with the stochastic programming extension.

## Overview


The FarmDyn model comprises since the first versions optionally
stochastic components. In the current version, three set-ups are
possible:

1.  A deterministic version

2.  A partial stochastic programming version where only some variables
    (crop acreages, feed mix, manure handing and fertilization) are
    state contingent. In that version, in each year, several price
    levels for input and outputs can be considered and the state
    contingent variables adjusted accordingly, but conceptually, each
    year starts again with a given mean expected price level as all
    other variables are not state contingent.

3.  A fully stochastic programming version where all variables are state
    contingent and unbalanced stochastic trees are used.

In the deterministic version, no parameter is stochastic and hence no
variable state contingent. The equations, variables and certain
parameter carry nevertheless indices for nodes in the decision tree and
States-of-Natures, but these refer in any year to a deterministic
singleton. In the partly stochastic simulation version of the FarmDyn
model, farm management and investment characters with a longer term
character are not state contingent and hence must allow managing all
states-of-natures in any year. For example, in case of machine
depreciation based on use, the investment decisions must ensure the
maximum use in any year and state-of-nature.

The fully Stochastic Programming (SP) version of the model introduces
scenario trees and renders all variables in the model stage contingent
to yield a fully dynamic stochastic approach. That is only feasible in
conjunction with a tree reduction approach: even if we would only allow
for two different states in each year (= decision nodes), we would end
up after twenty years with 2\^10 \~ 1 Million leaves in the trees. Given
the number of variables and equations in any year, the resulting model
would be impossible to generate and solve. In the following, we briefly
discuss the changes to model structure and how the decision tree and the
related random variable(s) are constructed.

The SP version of the model can be combined with a number of risk
behavioral models to maximize the expected utility. Given the complex
character of the remaining modules in the model, only those extensions
were chosen which can be implemented in a MIP framework, hence, a
non-linear approach such as an E-V approach are not considered. The
available risk models (value at risk (var), conditional value at risk,
MOTAD and target MOTAD) are discussed in Risk behavior section below.

Partly stochastic version where long term variables are not state contingent

### States of Nature (SON) in the partly stochastic version

In the partly stochastic version, only some variables are assumed to be
state contingent and there is no complex tree structure. Specifically,
we assume that SONs relate to the farm's market environment,
specifically to the input and output prices, wages and interest rates
faced by the firm. Crop yield variability is not considered. Each SON
defines price levels for all input and output prices simultaneously,
i.e. one vector of input and output prices. The cropping pattern,
feeding, off-farm labour on an hourly basis and further farm activities
are state contingent with regard to these SONs. However, decisions with
a long-term character (full or half time work off farm, investment
decisions, herd size, renting out of land) are not state contingent. The
differentiation between SON specific decisions (cropping, feeding) and
annual decisions in the otherwise deterministic version of the model is
depicted in the following Figure:

7. Figure 6: Systematic view on the model
    approach

Source: Own illustration

The first two blocks of variables shown above labelled investments and
herds are identical for all state of nature as indicated with the blue
brackets below, whereas cropping and feeding and some other farm
management decisions are state contingent and are adjusted to the
State-of-the-nature. That implies that for instance the unique, i.e. not
state contingent, investment decisions in machinery must ensure that the
maximum occurring depreciation under any state of nature can be
realized.

### Objective Function in the deterministic and partly stochastic version

In the deterministic version of the model, we consider a maximization of
net present value of profit under a discount rate. The partly stochastic
version assumes always a risk neutral profit maximizing farmer, and
hence maximizes the expected net present values of profits from SONs.
The farm is assumed to be liquidated at the end of the planning horizon,
i.e. the cow herd, machinery, land are sold and loans are paid back. Any
remaining equity is discounted to its net present value; therefore, a
definition close to the flow-to-equity approach is used:

![](/media/image173.png)

Further on, fully dynamic optimization assumes that the decision maker
is fully informed about the future states of nature such that the
economically optimal farm plan over the chosen planning horizon is
simulated, potentially under different future SON (best-practice
simulations).

## The Stochastic Programming version with full stage contingency


As opposed to the deterministic or partly stochastic version, in the
stochastic programming version all variables are state contingent. The
stochastic version considers different future developments over time,
currently implemented for selected output and input prices, i.e. price
paths. These paths do not need to have equal probability. The stochastic
programming (SP) approach includes a decision tree that reflects
decision nodes where each node has leaves with probability of
occurrence. All decisions are contingent on the state of nature in the
current year, and decisions in subsequent years depend on decisions made
on previous nodes (=stages) on the path to a final leave. In the SP, all
production and investment decisions in any year are hence depicted as
state-contingent, i.e. they reflect at that time point the different
futures which lay ahead, including future management flexibility. Also
the timing of investments is hence state contingent.

All variables and equations carry the index *nCur*, which indicates the
current node in the decision tree. Equally, the node needs to be linked
to the correct year, which is achieved by a dollar operator and the
*t\_n* set, for instance as in the following equation which was already
shown above. Whereas in the deterministic and partly stochastic version,
there is just one dummy node for each year, in the stochastic version,
potentially different states and thus nodes are found for decision
variables and equations in any one year.

The revised objective function maximizes the probability weighted
average of the final liquidity for each final leave in the decision
tree:

![](/media/image174.png)

The number of uncompressed scenarios to start with and the desired
number of leaves in the final reduced tree are defined via the interface
if the SP module is switched on:

![](/media/image175.png)

![](/media/image176.png)

That information enters the declarations in *model\\templ\_decl.gms.* If
the stochastic programming extension is switched off, there is only one
node (which is indicated by a blank space, " ") and the model collapses
to a deterministic one:

![](/media/image177.png)

The changes in the listing are minimal compared to the previous version
without the SP extension, only one point more in each variable or
equation name is included, which indicates the blank common node
(between the dots), for example as following:

![](/media/image178.png)

With the SP extension, information is needed about ancestor nodes and
nodes before the current one:

![](/media/image179.png)

### Generating Random Variable(s) and the decision tree

The generation of decision tree and related random variable(s) consists
of three major steps:

1.  **Generation of a predefined number of scenarios** which describe
    equally probable future developments for the random variables
    considered, i.e. in that uncondensed tree, the probabilities of the
    scenarios are identical.

2.  **Generating a reduced decision tree** from all possible scenarios
    most of the nodes are dropped and the remaining nodes receive
    different probabilities.

3.  **Defining the symbols in GAMS** according to step 1 and 2.

As GAMS can become quite slow with complex loops, the first step is
implemented in Java. Currently, two random variables (one for output and
one for input price changes) are generated based on two independent
logarithmic mean-reverting processes (MRPs), the log is introduced to
avoid negative outcomes. The variance and speed of reversion are defined
on the graphical user interface as shown above, under an expected mean
of unity. The starting price multiplier is also set to unity. Each path
of input and output prices are simulated once in the SP.

The Java program is called from GAMS to pass the information on the
number of decision nodes (= simulated time points) and the desired
number of scenarios to the program:

![](/media/image180.png)

The Java process stores the generated random developments along with the
ancestor matrix in a GDX file. The following Figure shows an example of
a decision tree as generated by the Java program for five years and four
scenarios, illustrated as a fan. The common root node *1*, the node in
the first year, is on the left side of the Figure. The nodes 2, 5, 8,
11, 14 are in the second year. Each second year node has its own set of
followers, and all nodes besides *1* have the same probability of 20%.

8. Example of an input decision tree
    organized as a fan

Source: Own illustration

Increasing the number of years leads to a proportional increase in the
number of nodes. For complex stochastic processes such as MRPs, many
paths are needed, each reflecting a Monte-Carlo experiment, to properly
capture the properties of the stochastic process. That leads to the
curse of dimensionality, as the number of variables and equations in the
model increases quadratic in the number of years and number of
Monte-Carlo experiments. As MIP models are NP-hard to solve, that
quickly leads to models which cannot be solved in any reasonable time.
Hence, in a next step, the tree must be reduced to avoid that curse of
dimensionality, achieved by using the [*SCENRED2*](https://www.gams.com/help/index.jsp?topic=%2Fgams.doc%2Ftools%2Fscenred2%2Findex.html) utility comprised
in GAMS (Heitsch & Römisch 2008, 2009). The algorithm deletes nodes from
the tree and adds the probability of dropped nodes to a neighboring
remaining one.

The example in the Figure below depicts a hypothetical tree from tree
reduction with four final leaves generated from the tree given in Figure
8. Each scenario starts with the same root node, *1*, for which the
information is assumed to be known for certain, i.e. the probability for
this root node N*1,* which falls in the first year, is equal to unity
and ends with one of the final leaves, 7, 10, 13 or 16. In the second
year two nodes are kept in the example, each depicting possible states
of nature with their specific followers while potentially differing in
their probabilities. Node number 8 has a probability of 60% as it
represents in the reduced tree three original nodes while node 11 has
one of 40%. The strategy chosen for each of these nodes depends
simultaneously on the possible future development beyond that node while
being conditioned on the decisions in the root node (which itself
depends on all follow up scenarios).

9. Example of a reduced tree

Source: Own illustration

The example can also help to understand better some core symbols used in
the code and relations in the SP extension. The nodes remaining in the
reduced tree are stored in the set *nCur*. The set *t\_n* would match
the first year with the first node, the second year with the nodes 8 and
11 etc. For the node 15, the ancestor set *anc* would be set to *anc*
(*n15*,*n11*) to indicate that node 11 is the node before 15 on the
scenario ending with leave 16. *Isbefore* (*n16*,*x*) would be true for
x=16,15,11 and 1 and comprises the complete scenario ending with the
final leave 16. The probabilities for node 8 and 11 must add up to unity
as they relate to the same time point. The same holds for the node set
(6, 9, 12, 15) for the third year. Hence, the decision at the root node
1 influences all subsequent scenarios, whereas the stage contingent
decisions at node 8 influence directly the scenarios ending with leaves
7 and 10. The root node reflects all scenarios simultaneously and
consequently an indirect influence between all nodes exists.

Furthermore, in a programming context no backward or forward recursion
solution tactic is possible to find the best strategy as the number of
strategies is normally not countable (the solution space is bounded, but
there exist typically an infinite number of possible solutions). Finding
a solution is further complicated by the fact that a larger number of
variables have an integer or binary character. MIP problems are NP-hard,
i.e. the solution time increases dramatically in the number of integers.
This makes it especially important to find an efficient way to reduce
the number of nodes considered to keep the solution time in an
acceptable range

In the current implementation, the tree size which also determines the
overall model size is steered by setting exogenously the number of final
nodes.

![](/media/image181.png)

Based on the information returned from the scenario reduction utility,
the set of active nodes, *nCur,* is determined:

![](/media/image182.png)

A little bit trickier is to efficiently find *all* nodes that are before
a given node in the same scenario (these are often nodes shared with
other scenarios such as the root node, see Figure 9 above). This is
achieved by an implicit backward recursion over a year loop:

![](/media/image183.png)

As indicated above, the set *anc (nCur, nCur1)* indicates that decision
node *nCur1* is the node before the node *nCur*, i.e. they belong to the
same scenario. That is used in lag and lead operators, e.g.:

![](/media/image184.png)

The *isNodeBefore(nCur,nCur1)* relation depicts all nodes, *nCur1,*
before node *nCur* in the same scenario, including the node *nCur*
itself. An example gives:

![](/media/image185.png)

+| > **Important Aspects to remember!**                                    |
|                                                                         |
| 1\. Even if the program scales the drawn price changes such that their  |
| mean is equal to unity, this does not guarantee that the model, even    |
| without stage contingency, would perfectly replicate the deterministic  |
| version as the timing of the changes is also relevant (discounting,     |
| dynamic effects on liquidity etc.).                                     |
|                                                                         |
| 2\. The normal case is that the objective value increases when          |
| considering stage contingency under risk neutrality. This is due to the |
| effect that profits increase over-proportionally in output prices under |
| profit maximization.                                                    |
|                                                                         |
| 3\. The solution time of the model can be expected to increase          |
| substantially with the SP extension switched on. MIP models are         |
| non-convex and NP-Complete problems. To our knowledge there is no       |
| existing sting polynomial-time algorithm, which means that the solution |
| time to optimality increases typically dramatically in the number of    |
| considered integers. Even small problems can take quite long to be      |
| solved even towards moderate optimality tolerances and not fully        |
| optimality. This holds especially if the *economic signal* to choose    |
| between one of the two branches of a binary variable is weak, i.e. if   |
| the underlying different strategy yield similar objective values. Which |
| is unfortunately exactly the case where the SP programming approach is  |
| most interesting (if there is one clearly dominating strategy rather    |
| independent e.g. of a reasonable range of output prices, considering    |
| different future inside that reasonable range is not necessary).        |
+
The interface allows to define the parameters of the logarithmic Mean
Reverting processes (MRP) with an expected mean and start value of
log(1):

![](/media/image186.png)

### Introduction of the Random Variable(s)

The notion *random variable* only implies that the variable has an
underlying probability distribution and not that it is a decision
variable in our problem. Consequently, random are a parameter in GAMS
and not declared as a variable. As mentioned in the section above, in
the SP version of the model the MRPs are simulated in Java that generate
deviations around unity, i.e. we can multiply a given mean price level
for an output and/or an input (e.g. defined by user on the interface)
with the node specific simulated random price multiplier. If two MRPs
are used, they are currently assumed to be uncorrelated. One path from
the root to a final leave thus depicts a time series of input and output
price deviations from the mean of the stochastic version.

The random variable can impact either revenue, *salRev\_*, by
introducing state specific output price(s) and/or cost for buying
inputs, *buyCost\_*, by state specific input price(s):

![](/media/image187.png)

![](/media/image188.png)

The decision in which prices are treated as random variables is steered
via the interface:

![](/media/image189.png)

![](/media/image190.png)

In the case neither input nor output prices are random a run time error
will occur.

The core branches are defined in *coeffgen\\stochprog.gms*:

![](/media/image191.png)

That means that dairy production takes precedence over other branches
and pigs over arable cropping, assuming that arable crops are typically
not the core farm branch in mixed enterprises.

## Risk Behavior


The model allows introducing four different risk behaviour options in
the stochastic programming version in addition to risk neutral behaviour
(None):

![](/media/image192.png)

All risk measures relate to the distribution of the NPV, i.e. changes in
expected returns aggregated over the full simulation horizon, and do not
take fluctuations of the cash flow for individual years into account.
This is reasonable as the farmer is assumed to have access to credits
which can be used to overcome short run cash constraints. The cost of
using credits as a risk management option is considered endogenously in
the model as farmers have to pay interest on these credits which reduces
the NPV. Still, considering that risk is accessed here with regard to
changes in accumulated final wealth over a long planning horizon is
crucial when comparing the approach and results to risk analysis based
e.g. on a comparative static analysis of yearly variance of gross
margins.

### MOTAD for Negative Deviations against NPV

The first and simplest risk model modifies the objective function: it
maximizes a linear combination of the expected NPV and the expected mean
negative deviation from the NPV.

![](/media/image193.png)

The formulation builds on MOTAD (Minimization of Total Absolute
Deviations) as a linear approximation of the quadratic E-V model
proposed by Hazell 1971. The approach was developed at a time where
quadratic programming was still not considered feasible for even medium
sized problems. Under normality, it can be shown that the absolute
deviations and the variance show approximately a linear relationship,
the factor between the two depends however in a non-linear way on the
number of observations. Mean absolute deviations can also be understood
as a robust estimate for the variance.

Our approach builds on an often used modification by only considering
down-side risk, i.e. only negative deviations from the simulated mean
are taken into account:

![](/media/image194.png)

This approach is especially relevant if the deviation above and below
the objective function are not by definition symmetric. However, as the
distribution itself is determined in our stage contingent approach
endogenously, symmetry makes limited sense. The expected mean deviation
is calculated as:

![](/media/image195.png)

And subtracted from the objective function (see equation *OBJE\_*),

![](/media/image196.png)

The reader should note that the standard MOTAD approach by Hazell and
described in text books is based on expected gross margins and deviation
thereof, whereas in this model an approach in the context of dynamic
stochastic programming approach is used. The expected mean returns for
each activity and related (co)variances are not known beforehand in our
model such that an E-V approach would be numerically demanding. This
holds especially for our large-scale MIP problem, such that avoiding
quadratic formulations, as required by an E-V approach, has its merits.
Finally, it should be noted that these equations are always active for
information purposes. The weight in the objective is set to a very small
number when other types of risk behaviour are simulated.

### MOTAD for Negative Deviations against Target

![](/media/image197.png)

The only difference to the *MOTAD against NPV* option described before
is that negative deviations are defined against a target set by the
user. That target is based on a relative threshold multiplied with the
simulated objective value in the case of no farming activity, therefore,
income is only drawn from off-farm work, decoupled payments and
interest. This income level is used as the absolute benchmark level
which can be modified by the user with the percentage multiplier entered
in the graphical user interface. This effects the following equation:

![](/media/image198.png)

Using this information the expected shortfall is defined:

![](/media/image199.png)

The expected shortfall enters then the objective function:

![](/media/image200.png)

### Target MOTAD

![](/media/image201.png)

The second option is what is called *Target MOTAD* in programming
modelling. It has some relation to *MOTAD* as it also takes negative
deviation from a pre-defined threshold into account, *p\_npvAtRiskLim*.

The difference to the approach above is that the expected shortfall
below the predefined threshold does not enter the objective function,
but acts as an upper bound. Hence, the shortfall of NPV cannot be lower
than certain level:

![](/media/image202.png)

### Value at Risk Approach

Contrary to the *MOTAD* approaches discussed before, the *Value at Risk*
*(VaR)* and *conditional value at risk (CVaR)* approaches (see next
section) require additional binary variables and thus are numerically
more demanding.

The value (NPV) at risk approach introduces a fixed lower quantile
(i.e., introduced as parameter and determined by the user) for the NPV
as shown in following illustration. It requires the following user
input:

![](/media/image203.png)

The second parameter defines the maximal allowed probability for
simulated objective values to fall below the resulting threshold. The
reader should be aware of the fact that only undercutting matters, not
by how much income drops below the given threshold. For the *conditional
value at risk* at approach see next section.

If the maximal probability is set to zero, the threshold acts as a
binding constraint in any state of nature, i.e. the NPV at any leaf
cannot fall below it. The NPV at risk approach does thus not change the
equation for the objective function, but introduces additional
constraints. The first one drives a binary indicator variable,
v\_*npvAtRisk,* which is equal to one if the objective value at a final
leaf falls below the threshold:

![](/media/image204.png)

If v\_*npvAtRisk* is zero, the objective value (LHS) fo r each final
leave must exceed the given threshold *p\_npvAtRiskLim*. The second
constraint, shown below, adds up the probabilities for those final nodes
which undercut the threshold (LHS) and ensures that their sum is below
the given maximal probability:

![](/media/image205.png)

As long as off-farm income is considered deterministic and the relative
threshold is below 100%, a solution where only off-farm income is
generated should always be a feasible.

### Conditional Value at Risk

The *Conditional Value at risk* approach is also referred to as the
expected or mean shortfall. It is the most complex and numerically
demanding of the options available and it can be seen as the combination
of the VaR approach and target MOTAD with an endogenously determined
limit. The decision taker defines hence a quantile, say 10% as in the
screen shot below, and the model calculates endogenously the expected
shortfall for the lowest 10% of the scenarios. The objective function in
the model maximizes a linear combination of the expected NPV and the
endogenous mean shortfall, subject to a predefined lower quantile:

![](/media/image206.png)

A first constraint, which is also used for the VaR option, ensures that
the sum of the considered cases does not fall below the now endogenously
defined limit (equation was already shown above in the section on the
Value at Risk Approach):

![](/media/image205.png)

Additionally, the expected shortfall for any of the final nodes which do
not contribute to active lower quantile must be zero, based on a
so-called BIGM formulation, i.e. the binary variable *v\_npvAtRisk* is
multiplied with a very large number, here with 1.E+7. If *v\_npvAtRisk*
for that final leave is zero (= it does not belong to the leaves with
the worst NPVs), the left hand size must be zero as well. On the other
hand, if *v\_npvAtRisk* is unity, i.e. the final leaves's NPV belongs to
the x% worst cases, where x is set by the user, the shortfall for that
leave can consider any number determined by the model as the RHS value
of 1.E+7 in the case of *v\_npvAtRisk* equal unity never becomes
binding.

![](/media/image207.png)

Besides this, any leaves which is not in worst cases set (*v\_npvAtRisk*
= 0) must at least generate a NPV which exceeds the best shortfall.

![](/media/image208.png)

For cases at or below the quantile which contributed towards the
expected mean shortfall, both the own expected NPV and the best NPV act
simultaneously as lower bounds:

![](/media/image209.png)

Accordingly, the *v\_bestShortFall* splits the expected NPVs in those
below and above the relevant quantile.

The cases below that bound define the expected shortfall:

![](/media/image199.png)

The expected shortfall adds to the objective (in opposite to target
MOTAD):

![](/media/image210.png)

The objective function is hence a trade-off between a higher expected
mean NPV and the expected shortfall of cases x% relative to that
endogenous mean.
