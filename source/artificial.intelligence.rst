AI
==

.. contents::

Turing Test (1950)
------------------

The computer is interrogated by a human via a teletype, it passes the test if the human cannot tell if its a computer or a human at the other end.

Chinese Room Argument
---------------------
In the chinese argument model there is a operator sitting in a room and isolated from outside world. The operator has with him a translation book, which allows him to lookup any incoming chinese messages and responds with the corresponding reply message in the book which is also in chinsese. To the outisde world it looks as if the operator understands chinese.
But the operator does not understand the semantics of the language.

AI has

*     Automated Problem Solving
*     Machine Learning
*     Logic and Deduction
*     Computer Vision
*     Natural Language Processing (NLP)
*     Robotics


Godel's Incompleteness Theorem (1931)
-------------------------------------
In any language expressive enough to describe the properties of natural numbers, there are true statements that any undecidable, that is their truth cannot be established by any algorithm.

Church-Turing Thesis (1936)
---------------------------
The Turing machines is capable of computing any computable function. This is the accepted definition of computability.

How to prove NP
---------------
A problem is NP , if there are any NP problems which can be translated into the given problem, then if the given problem can be solved in polynomial time then the NP problem can also be solved in polynomial time.

Problem solving by search
-------------------------

------------------
State space search
------------------
Here a real world problem is converted into a state space, and then state space algorithms can search in this space.

2 state space alogrithms

*     Uninformed / Blind search - no domain knowledge
*     Informed / Heuristic search 


------------------------
Problem Reduction Search
------------------------
Given problem is divided into sub-problems which are then solved.

----------------
Game tree search
----------------
Used for searching in game-trees like chess.

State space search
------------------
The basic serach problem is defined as

*   given 4-tuple [S,s,O,G] where

        *   S is the set of state
        *   s is the start state
        *   O is the set of transition operators
        *   G is the set of goal state

*   Goal is to find a sequence of stat transistions leading from state start s to a goal state. 


----------------
8-puzzle problem
----------------
We have a figure like below

::

         _____ _____ _____
        |     |     |     |
        |  8  |  5  |  3  |
        |_____|_____|_____|
        |     |     |     |
        |  7  |  4  |  2  |
        |_____|_____|_____|
        |     |     |     |
        |  6  |     |  1  |
        |_____|_____|_____|


8 squares in the figure is filled with 8 numbers(1-8) in different order. The goal of the problem is to sort them into sequential order, by moving the numbers into the empty square. Only left,right,top and bottom transistions can be made. The final result should be

::

         _____ _____ _____
        |     |     |     |
        |  1  |  2  |  3  |
        |_____|_____|_____|
        |     |     |     |
        |  4  |  5  |  6  |
        |_____|_____|_____|
        |     |     |     |
        |  7  |  8  |     |
        |_____|_____|_____|


The state description for this problem

*    S = location of each of the eight numbered tiles and the blank tile

The start state is

*    The starting configuration given

Operators allowed are

*    Four operators, for moving blank left,right,up or down.

The goal state is

*    G = one or more goal configurations given


Similarly we can define for 15-puzzle, 24-puzzle ... x2-1 puzzle

----------------
8-queens problem
----------------
The problem is to place 8-queens on a chess board, so that none attacks the other.

========================
Problem Forumulation - I
========================
The state description is

*    A state is any arrangement of 0 to 8 queens on board.

Operators allowed are

*    Operators add a queen to any square


========================
Problem Formulation - II
========================
The state description is

*    A state is any arrangement of 0 to 8 queens on board.

Operators allowed are

*    Operators add a queen in the left-most empty column, in a way that the queens do not attack each other. 



=========================
Problem Formulation - III
=========================
The state description is

*    A state is any arrangement of 0 to 8 queens on board.

Operators allowed are

*    Operators move an attacked queen to another square in the same column. 


--------------------------
Missionaries and Cannibals
--------------------------
There are 3 missionaries and 3 cannibals on one side of a river, along with a boat that can hold one or two people. Find a way to get everyone to the other side, without ever leaving a group of missionaries outnumbered by cannibals.

The problem formulation for this problem is

*    A state is defined (#m, #c, 1/0)

  *     #m: number of missionaries in the first bank
  *     #c: number of cannibals in the first bank
  *     The last bit indicates whether the boat is in the first banka

*    The start state is defined as (3,3,0)
*    The goal state is defined as (0,0,0)
*    Operators allowed are

  *     Boat entries (1,0) or (0,1) or (1,1) or (2,0) or (0,2)

----------------------
Basic Search algorithm
----------------------

*    Iniitalise : Set OPEN = {s}
*    Fail: If OPEN ={}, terminate with failure
*    Select : Select a state, n, from OPEN
*    Teminate : If n belongs to G, terminate with success
*    Expand : Generate the successors of n using O and insert them in OPEN
*    Loop : Go to step 2


If OPEN is a stack then we have DFS (depth-first-search).
If OPEN is a queue then we have BFS (breadth-first-search).

If the size of state space is very large, then DFS might take more time than BFS.
If the size of state space is inifinite, then DFS might not even terminate.

==========
Complexity
==========

*    b: branching factor d: depth of the goal m: depth of the state space tree
*    Breadth-first search:

   *     Time: 1 + b + b2 + ... + bd = O(bd)
   *     Space : O(bd)a

*    Breadth-first search

   *     Time: O(bm)
   *     Space : O(bm)

===================
Iterative deepening
===================

*    Perform DFS repeatedly using increasing depth bounds. 

=====================
Bi-directional search
=====================
This is possible only if the operators are reversible. The search starts from the top and bottom, the result will be place where both places merge.

----------------------------------------------
Basic Search Algorithm with the explicit space
----------------------------------------------

*     Iniitalise : Set OPEN = {s}
*     Fail: If OPEN ={}, terminate with failure
*     Select : Select a state, n, from OPEN and save n in CLOSED
*     Teminate : If n belongs to G, terminate with success
*     Expand : Generate the successors of n using O and insert them in OPEN if the successor m does not belong to [OPEN U CLOSED]
*     Loop : Go to step 2

---------------------------------------------------------
Basic Search Alogrithm with explicit space and ost search
---------------------------------------------------------

*    Iniitalise : Set OPEN = {s},

CLOSED = {},
**C(s) = 0**

*    Fail: If OPEN ={}, Terminate with failure
*    Select : **Select the minimum cost state**, n, from OPEN and save n in CLOSED
*    Teminate : If n belongs to G, terminate with success
*    Expand : Generate the successors of n using O

    *   For each successor, m:

       *   if m does not belong to [OPEN U CLOSED]

          *   **Set C(m) = C(n) + C(n,m) and insert m in OPEN**

       *   if m belongs to [OPEN U CLOSED]

          *   **Set C(m) = min(C(m), C(n) + C(n,m))**
          *   **If C(m) has decreased and if m belongs to CLOSED, move it to OPEN**

    *  Loop : Go to step 2


This is similar to dijkstra's algorithm, but also works with -ve costs.
If all the costs are +ve, no state comes back to OPEN from CLOSED.
If the costs are all the same (say unit cost) then the alogrithm would reduce to BFS.

Branch and Bound can be applied to this, by removing any paths with higher cost when we find a path to the goal with a lower cost. This only works in case of +ve costs.

---------------------------------------------------------
Basic Search Alogrithm with explicit space and ost search
---------------------------------------------------------

*    Iniitalise : Set OPEN = {s},

CLOSED = {},
C(s) = 0, C* = infinity

*    Fail: If OPEN ={}, then return C*
*    Select : Select the minimum cost state, n, from OPEN and save n in CLOSED
*    Teminate : If n belongs to G and C(n) < C*, then 

**Set C* = C(n) and Go To Step 2 s**

#.   Expand : Generate the successors of n using O

    *   If (C(n) < C* generate the successors of n
    *   For each successor, m:

       *    if m does not belong to [OPEN U CLOSED]

           *    **Set C(m) = C(n) + C(n,m)** and insert m in OPEN 

       *    if m belongs to [OPEN U CLOSED]

           *    **Set C(m) = min(C(m), C(n) + C(n,m))**
           *    **If C(m) has decreased and if m belongs to CLOSED, move it to OPEN**

    *   Loop : Go to step 2

The notion of heurisitcsa
-------------------------
Heuristics use domain specific knowledge to estimate the quality or potential of partial solutions.

Example: Manhattan distance heuristic for 8-puzzle

*   Find the manhattan distance for a number from its current position to the position we want it to be, i.e if 5 resides in the 1st square, then find the manhattan distance from 1st square to 5th square.
*   Computing the sum of manhattan distances for all numbers, gives a lower bound on the number of moves that we need to make

Example: Minimum spanning tree for heuristics

*    the cost of minimum spanning tree is less than the cost of optimal tour if all costs are +ve
*    If we represent

   *     Cs - cost of minimum spanning tree
   *     C* - optimal TSP solution 

*    then Cs < C* < 2Cs, works only in eucledian space, which allows triangular inequality

Example: chess programs

Search problem definition using heuristics
------------------------------------------

*    given 5-tuple [S,s,O,G,h] where

   *    S is the set of state
   *    s is the start state
   *    O is the set of transition operators
   *    G is the set of goal state
   *    h() is a heuristic funciton estimating the distance to a goal

*    Goal is to find a minimum cost sequence of state transistions leading from state start "s" to a goal state. 

Alogrithm A*
------------

#.   Initialise: Set OPEN = {s}, CLOSED = {}

g(s) = 0, f(s) = h(s), where

   *   g(n) - minimum cost path from start state to this state
   *   h(n) - heuristic estimate of minimum cost path from current state to goal state
   *    f(n) - g(n) + h(n)

*    Fail: If OPEN={}, terminate and fail
*    Select: Select the minimum cost state,n, from OPEN. Save n in CLOSED.
*    Terminate: If n belongs to G, terminate with success and return f(n)
*    Expand: For each successor, m, of n

   *     If m does not belong to [OPEN U CLOSED]

       *    Set g(m) = g(n) + C(n,m)
       *    Set f(m) = g(m) + h(m)
       *    Insert m in OPEN

   *    If m belongs to [OPEN U CLOSED]

       *    Set g(m) = min {g(m), g(n) + C(n,m)}
       *    Set f(m) = g(m) + h(m)

   *    If f(m) has decreasd and m belongs to CLOSED,

       *    move m to OPEN

   *    Loop : Go to Step 2

Every node has to be expanded atleast once, and if we can ensure that each node is expanded only once, then we can ensure that we have linear time algorithm to reach the goal.

Lets say

::

        S = { n | f(n) < C* }

Every alogrithm has to visit these states. So if any alogrithm which expands all these ends and linear, is a guaranteed to give out a aymptotically optimal solution.
We can ensure that a node is not expanded twice, by ensuring that a node is never moved from CLOSED to OPEN. This works in non-heuristic alogrithm with +ve costs.
Heuristic searches require nodes to added back into OPEN from CLOSED.

--------------------
admissable heuristic
--------------------
A heuristic is called admissiable if it alway under-estimates, that is, we always have h(n) <= f*(n), where f*(n) denotes the minimum distance to a goal state from state n.

If a heuristic over-estimates, then this might cause the algorithm to not expand some nodes whose estimates are high, but there might be some goals underneath that node.

Choosing heuristic function
---------------------------

*  If we have no idea of the problem or heuristic function, choose a heuristic function which is 0 at all states.
*  If we don't have good underestimate, but a tight overestimate then its better to go for branch-and-bound.
*  If we dont' have good overestimate, but a tight underestimate then its better to go heuristic based search.

Results on A*
-------------

*    At any time before A* terminates, there exists in OPEN a state n that is on an optimal path from s to a goal state, with f(n) <= f*(s)a
*    If there is a path from s to a goal state, A* terminates (even when the state space is infinite)
*    Alogrithm A* is admissible, i.e, if there is a path from s to a goal state, A* terminates by finding an optimal path.
*    If A1 and A2 are two versions of A* such that A2 is more informed than A1, then A1 expands at least as many states as does A2.
*    If we have A1 and A2 are two versions of A* such that both are good heuristics, but none is more informed than the other, then the best way to use them is to use max {h1(n), h2(n)} at every state as heuristic function.
*    If the heuristics are very close to optimal, then we will be expanding fewer states.

Monotone Heuristics
-------------------

*    An admissible heuristic function, h(n), is monotonic if for every successor m of n:

   *     h(n) - h(m) <= c(n,m)

*    If the monotone restriction is satisfied, then A* has already found an optimal path to the state it selects for expansion.
*    If the monotone restriction is satisfied, the f-values of the states expanded by A* is non-decreasing. 

Pathmax
-------
converts a non-monotonic heuristic to a monotonic one:

*    During generation of the successor, m of n we set:

    *    h'(m) = max { h(m), h(n) - c(n,m)) }

Non-Admissible heuristics
-------------------------
Non-admissible heuristics can be used to reduce the number of states that have to be expanded. If a sub-optimal solution is also good enough, then using these heuristics which over-estimate tightly are useful in reducing the number of state required to be expanded.
If we are fine to get a sub-optimal solution which is not more than 1.4 times the optimal solution, then we can use a heuristic function which does not estimate more than 1.4 times the actual cost.

Iterative Deepening A* (IDA*)
-----------------------------
similar to iterative deepening for basic non-heuristic search.
We will use depth-first search with heuristic based cost measures at states. # Set C = f(s)

#.    Perform DFBB with cut-off C

    *    Expand a state, n, only if its f-value is less than or equal to C
    *    If a goal is selected for expansion then return C and terminate

#.    Update C to the minimum f-value which exceeded C among states which were examined and Go to Step 2 

During the inital stage we will be expanding to upto a certain stage, from then on we only expand only the ones which are the most likely to be optimal.

It is asymptotically optimal.

Problem reduction search
------------------------
Planning how best to solve a problem that can be recursively decomposed into sub-problems in multiple ways

Examples: matrix multiplication, tower of hanoi, blocks world, theorem proving

AND-OR Graphs
-------------

*    An OR node represents a choice between possible decompositions
*    An AND node represents a given decomposition


------------------
Problem definition
------------------

*    given [G,s,T] where

   *    G: implicitly specified AND/OR graph
   *    S: start node of the AND/OR graph
   *    T: set of terminal nodes
   *    h(n) heuristic function estimating the cost of solving the sub-problem at n

*   the goal is to find a minimum cost solution tree


We can also have heuristic function in AND/OR graphs too.

-------------
Alogrithm AO*
-------------

*   Initialise: Set G* = {s}, f(s) = h(s)
*   Terminate: If s is SOLVED, then terminate
*   Select: Select a non-terminal leaf node n from the marked sub-tree
*   Expand: Make explicit the successors of n

   *    For each new successor, m:

       *    Set f(m) = h(m)
       *    If m is terminal, label m SOLVED

*   Cost Revision: call cost->revise(n)
*   Loop: Go To Step 2


*   Cost revision in AO*

   *    Create Z = {n}
   *    If Z = {} return
   *    Select a node m from Z such that m has no descendants in Z
   *    if m is an AND node with successors r1, r2, ...rk

      *     set f(m) = sum [ f(r1) + c(m,e1) ]
      *     mark the edge to each successor of m
      *     if each successor is labeled solved, then label m as solved.

   *    if m is an OR node with successors r1, r2, ...rk

      *     set f(m) = min [ f(r1) + c(m,e1) ]
      *     mark the edge to each successor of m
      *     if each successor is labeled solved, then label m as solved.

   *    If the cost or label of m has changed, then insert those parents of m into Z for which m is a marked successor.

Game Trees
----------

*   Game trees are OR trees with 2 types of OR nodes,
*   Max nodes represent the choice of my opponent, select the max cost successor
*   Min nodes represent my choice, select the min cost successor

**Shallow Cut-off**, In the below figure we can see that A is a min node, which is the opponent move, B is our move, at B we are guaranteed to get more than 14, but that is not useful as at A opponent will only allow us to get 10 form the left node, so there is no need to evaluate C.

::

                       __ __
                      |     | ROOT
                      |__ __|
                        /
                       /
                      /
                     /\
                    /  \ A
                    \  /
                     \/
                     /\
                    /  \
                   /    \ __ __
                  10     |     | B
                         |__ __|
                           / \
                          /   \
                         /     \
                        14     C  

**Deep Cut-off**, In the below figure, at D we can get only a value of atmost 5, that the value at D <= 5, At Root the right side can produce 10, we will only come down the path of A, if B can produce more than 10, since D can only produce upto 5, D is of no intrest to B, hence ROOT.

::

                       __ __
                      |     | ROOT
                      |__ __|
                        / \
                       /   \ 
                      /     \
                     /\     10
                    /  \ A
                    \  /
                     \/
                      \
                       \
                        \ __ __
                         |     | B
                         |__ __|
                           / \
                          /   \
                         /     \
                        /\      G
                     D /  \ 
                       \  /
                        \/
                        /\
                       /  \
                      /    \
                     5      E

------------------
Alpha-Beta Pruning
------------------

*   Alpha Bound of J

   *    The max current val of all MAX ancestors of J
   *    Exploration of a min node, J, is stopped when its value equals or falls down below alpha
   *    In a min node, we update beta
   *    beta is maintained on min nodes

*   Beta Bound of J

   *    The min current value of all MIN ancestors of J
   *    Exploration of a max node, J, is stopped when its value equals or exceeds beta
   *    In a max nove, we update alpha
   *    alpha is maintained on max nodes

*   In both min and max nodes, we return when alpha >= beta

-------------------------------------
Alpha-Beta Procedure: V(J;alpha,beta)
-------------------------------------

*   If J is a terminal, return V(j) = h(J)
*   If J is a max node:

   *    For each successor Jk of J in succession:

       *    Set alpha = max(alpha, V(Jk; alpha, beta)
       *    If alpha >= beta then return beta, else continue

   *    Return alpha

*   If J is a min node:

   *    For each successor Jk of J in succession:

       *    Set beta = min {beta, V(Jk; alpha, beta)}
       *    If alpha >= beta then return alpha, else continue

   *    Return beta

Wumpus World
------------
Below is picture of Wumpus world which is a grid.

*    **PIT**. Grids can have PITs, and if we enter any of the PIT squares we will fall in the pit. All the horizontally and veritcally adjacent squares of the PIT square would have Breeze in them.
*    **Wumpus**. If we enter a square with a Wumpus we die. A wumpus can exist in the same square as that of PIT. Horizontally and vertiaclly adjacent squares of a wumpus would smell stench.
*    **Gold**: One of the square in the grid would have gold. The aim of the game is to reach this square.
*    **Walls**: Some of the sides of squares would have walls, we cannot move through walls
*    **Arrows**: We can have arrows, we can shoot an arrow vertically of horizontally and any Wumpus in that path would get killed. Arrows cannot pass through walls. If a wumpus gets killed it will emit a scream. The agent would have only one arrow.
*    **Agent** starts from the bottom-left square of a grid.

Logic
-----

*   Logic is a formal system for describing states of affairs, consisting of:

   *    syntax: describes how to make sentences, and
   *    semantincs: describes the relation between the sentences and the state of affairs

*   Proof theory - a set of rules for deducing the entailments of a set of sentences

Propostional logic
------------------
Logics of or,and,implies and other stuff

Inferences :

::

        a || b,  b              a || b,  ~b || c
        ----------              -----------------
            a                        a || c

The numerator are the given propositions which are valid, denominator is the one we can derive

*    **valid** : a proposition is valid, if the value of the proposition is true for all value of inputs. So if a proposition is valid, i.e, true of all combinations of input, then its inverse is false for all combination of inputs, i.e the inverse of valid proposition is unsatisfiable
*    **satisfiable** : a proposition is satisfiable, if the value of the proposition is true of atleast one combination of inputs

In general, the inference problem is NP-complete (Cook's theorem)

Horn sentences of the form

::

        F~~1~~ && F~~2~~ && .... F~~k~~ => G

are polytime procedures

First-order logic
-----------------
First-order logic is a very generalised version of logic when compared to propositional logic. In first-order logic variables can take any values, not just binary

Like propostions, first-order logic has predicates.
A predicate is defined as P(x,y,z), the value of P depends on the value of x,y,z
Example:

::

        forall x, forall y, forall z,  P(x,y,z)
        forsome x, forall  y, forsome z,  P(x,y,z)

-----------------------------
Elements in first-order logic
-----------------------------

*    Constan -> A | 5 | Kolkata | ....
*    Variable -> a | x | s | ....
*    Predicate -> Before | HasColor | Raining | ....
*    Function -> Mother | Cosine | Headoflist | ....

Example :

::

        Everyone loves its mother

                forall x, thereexits y Mother(x,y) && Loves(x,y)

        The samething can be written using functions

                forall x, Loves (x, Mother(x))


*    Sentence -> AtomicSentence
*    AtomicSentence ->
*    Term ->
*    Connective -> ==> | || | && | <==>
*    Quantifier -> forall | forsome(thereexists)

Inference in first-order logic
------------------------------
Inference is propositional logic is easy to define, as the domain of each variable is boolean and beolean satisfiability can be used to solve this. But for first-order logic the domain of the variable can be infiinite, so satisfiability of them is difficult to verify.

---------------
Inference Rules
---------------

*   Universal Elimination

   *    (for all) x Likes(x, IceCream) with the substitution {x / Einstein} give us Likes(Einstein, IceCream). That is, we know all like icecream, so we can deduce Einstein likes IceCream.
   *    The substiution has be done by a ground term

*   Esistential elimination

   *    (there exists ) x Likes(x, IceCream), we may infer Likes(Man, IceCream) as long as Man does not appear elsewhere in the knowledge base. Man here is being used as a placeholder to represent x's which like IceCream. 

*   Existential INtroduction

   *    From LIkes(Monalisa, IceCream) we can infer (there exists) x Likes(x, IceCream).

------------------------
Generalized Modus Ponens
------------------------

*    For atomic sentences pi, pi', and q, where there is a substitution theta, such that SUBST(theta, pi') = SUBST(theta, pi), for all i :

::

        p~~1~~^^'^^,p~~2~~^^'^^,...,p~~n~~^^'^^, (p~~1~~ && p~~2~~ && ... && p~~n~~ => q)
        -------------------------------------------------------------------------------
                                   SUBST(theta,q)

-----------
Unification
-----------
UNIFY(p,q) = theta, where SUBST(theta,p) = SUBST(theta, q)

Examples:
UNIFY(Knows(Erdos,x), Knows(Erdos, Godel)} = {x/Godel}
UNIFT(Knows(Erdos, x), Knows(y,Godel)} = {x/Godel, y/Erdos}
UNIFY(Knows(Erdos, x), Knows(x,Godel)} = F

----------
Horn logic
----------

*   We can convert Horn sentences to a cnonical form and then us egenralized Modus Ponens with unifcation.

   *    We skolemize(replace 'there exists', with some unused variable name) existential formula and remove the universal ones
   *    This gives us a conjunction of clauses, that are inserted in the knowledge base.
   *    Modus Ponens help us in ingerring new clauses.

*   Forward and backward chaining. 

----------------------------
Modus Ponenes - Completeness
----------------------------

*    Reasoning with Modus Ponenes is incomplete
*    Examples:

::

        (far all)x P(x) => Q(x)         (for all)x !P(x) => R(x)
        (for all)x Q(x) => S(x)         (for all)x R(x) => S(x)

*    We should be able to conclude S(A)
*    The problem is that (for all)x !P(x) => R(x) cannot be converted to Horn form, and thus cannot be used by Modus Ponens

-----------------------------
Godel's Compeleteness Theorem
-----------------------------

*    For first-order logic, any sentence hat is entailed by another set of sentences can be proved from that set
*    Entailment in first-order logic is semi-decidable, that is, we can show that sentences followfrom premisses if they do, but we cannot always show if they do not. 

----------
Resolution
----------
Given

*    p1 && p2 ... && pn1 => r1 || r2 .... || rn2
*    s1 && s2 ... && sn3 => q1 || q2 .... || qn4
*    Unify(pj, qk) = theta

then

*   applying A => B ==== !A || B, we get

   *    !p1 || !p2 || ... || !pj ... || !pn1 || r1 || .... || rn2

*   similarly for the second one, we get

   *    !s1 || !s2 || ... || !sn3 || q1 || ...qk || ... || qn4

*   Applying Unify(pj, qk), in the || of the above 2 expansions,

   *    we see that (!pj || qk) will always be true, because atleast one of them is true always.

*   Now we have, by applying && on both the expansions, !pj in the first term is complement of qk, so either of the first or second expansions is always true

   *    !p1 || !p2 || ... || !pj-1 || !pj+1 || ... || !pn1 || r1 || .... || rn2 || !s1 || !s2 || ... || !sj ... || !sn3 || q1 || ..|| qk-1 || qk+1 || .. || qn4

*   By applying reverse of the first rule on the above expansion we get

   *    p1 && pj-1 && pj+1 && ... pn1 && s1 && .... sn3 => r1 && ... rn2!! && q1 && ... qk-1 && qk+1 && ... && qn4

-------------------------
Conversion to Normal Form
-------------------------

*   A formula is said to eb in clause form if it is of the form:
*   All fist-order logic formulas can be converted to clause form
*   Example: Given

   *    Take the existential closure and eliminate redundant qunatifiers, This introduces (for some)x and eliminates (for some)z, where for x1, we have the first (for some)x, and since z is not being used, we eliminate z

       *     (for some)x1 (for all)x {p(x) => { !(for all)y [ q(x,y) => p(f(x1))] && (for all)y [q(x,y) => p(x)]}}

   *    Rename any variable that is qunatified more than once, y has been qunatified twice, so, the y in the first q is not the same y in the second q, both are separately qunatified,

       *    (for some)x1 (for all)x {p(x) => { !(for all)y [ q(x,y) => p(f(x1))] && (for all)z [q(x,z) => p(x)]}}

   *    Eliminate implication

       *    (for some)x1 (for all)x {!p(x) || { !(for all)y [ !q(x,y) || p(f(x1))] && (for all)z [!q(x,z) || p(x)]}}

   *    Move negation inwards

       *    (for some)x1 (for all)x {!p(x) || { (for some)y [ q(x,y) && !p(f(x1))] && (for all)z [!q(x,z) || p(x)]}}

   *    Push the qunatifiers to the right

       *    (for some)x1 (for all)x {!p(x) || { [(for some)y q(x,y) && !p(f(x1))] && [(for all)z !q(x,z) || p(x)]}}

   *    Eliminate existential qunatifiers (skolemization)

       *    Pick out the leftmost (for some)y B(y) and replace it by B(f(xi1, xi2, ...,xin)), where:

           #.  xi1, xi2, ..., xin are all the distinct free variables of (for some)y B(y) that are universally quntified to the left of (for some)y B(y), and
           #.  F is an n-ary function constant which does not occur already: Example:

              *     (for all)x1 (for all)x2 (for all)x3 (for some)y B(y)

*   can be written as
*   B(f(x1, x2, x3)

   *    After applying skolemization

       *    (for all)x {!p(x) || { [q(x,g(x)) && !p(f(a))] && [(for all)z !q(x,z) || p(x)]}}

   *    Move all universal qunatifiers to the left

       *     (for all)x (for all)z {!p(x) || { [q(x,g(x)) && !p(f(a))] && [!q(x,z) || p(x)]}}

   *    Distribute && over ||

       *     (for all)x (for all)z {[!p(x) || q(x,g(x))] && [!p(x) || !p(f(a))] && [!p(x) || !q(x,z) || p(x)]}}

   *    Simplify

       *     (for all)x {!p(x) || [ q(x,g(x)) && !p(f(a))] }


Resolution Refutation proofs
----------------------------

*    Convert the set of rules and facts into clause form(conjuction of clauses)
*    Insert the negation of the goal as another clause, and should not be unsatisfiable
*    Use resolution to deduce a refutation
*    If a refuatation is obtained, then the goal can be deduced from the set of facts and rules.

-------------------------
Resolution in clause form
-------------------------

*   If Unify(zj, !qk) = theta, then

::

        z1 || ... || zm, q1 || ... || qn
        --------------------------------
        SUBST(theta, z1 || ... || zj-1 || zj+1 || ... || zm
        || q1 || ... || qk-1 || qk+1 || ... || qn)

*   Example:

   *    Harry, Ron and Draco are students of Hogwarts school of wizards
   *    Every student is either wicked or is a good Quidditch player, or both
   *    No Quidditch player likes rain and all wicked students like potions
   *    Draco dislikes whatever Harry likes and likes whatever Harry disklikes
   *    Draco likes rain and potions
   *    Is there a student who is good in Quidditch but not in potions.
   *    Clauses are

::

        C1 - Sutdent(Harry) 
        C2 - Student(Ron) 
        C3 - Student(Draco)
        (for all)x, Student(x) => Wicked(x) || Quidditch(x)
        C4 - !Student(x) || Wicked(x) || Quidditch(x)
        (for all)x Quidditch(x) => !Likes(x,Rain)
        (for all)x Wicked(x) => Likes(x, Potions)
        C5 - !Quidditch(x) || !Likes(x,Rain)
        C6 - !Wicked(x) || Likes(x, Potions)
        (for all)x Likes(Harry, x) <=> !Likes(Draco,x)
        C7 - !Likes(Harry,x) || !Likes(Draco,x)
        C8 - Likes(Harry,x) || Likes(Draco,x)
        C9 - Likes(Draco, Rain)
        C10 - Likes(Draco, Potions)

*   Goal is

::

        G  - (for some)x Quidditch(x) && !Likes(x,Potions)
        !G - (for all)x !Quidditch(x) || Likes(x,Potions)
        We will insert !G as C11

*   Deduction

::

        From C10 and C7, we get
        C12 - !Likes(Harry, Potions)
        From C12 and C11(!G), we get
        C13 - !Quidditch(Harry)
        From C12 and C6
        C14 - !Wicked(Harry)
        From C1 and C4
        C15 - Wicked(Harry) || Quidditch(Harry)
        From C15 and C14
        C16 - Quidditch(Harry)
        But C16 and C13 are contradictory

---------------------
Resolution strategies
---------------------

*   Unit Resolution

   *    Every resolution step must involve a unit clause
   *    Leads to a good speedup
   *    Incomplete
   *    Complete for Horn knowledge bases

*   Input Resolution

   *    Every resolution step must involve a input sentence (from the query or the KB).
   *    In Horn KBs, Modus Ponens is a kind of input resolution strategy.
   *    Incomplete
   *    Complete for Horn knowledge bases

*   Linear Resolution

   *    Slight generalization of input resolution
   *    Allows P and Q to be resolved together either if P is in the original KB, or if P is an ancestor of Q in the proof tree
   *    Linear resolution is complete

Logic Programming: Prolog
-------------------------

*   The notion of instantiation

::

        likes(harry, school)
        likes(ron, broom)
        likes(harry,X) :- likes(ron,X)        ( which is <= instead of => )

*   Consider the following goals

::

        ? - Likes(harry, broom)
        Prolog will translate goal into likes(harry,X) :- likes(ron,X)
        likes(ron,broom)

::

        ? - Likes(harry, Y)
        Prolog will first unify Likes(harry,Y) with (harry, school) and print Y = school
        Prolog will then continue to unify the goal with likes(harry,X) :- likes(ron,X) which will continue will continue to be applying likes(ron,broom) and print Y = broom

::

        ? - likes(Z,school)
        first rule will be applied, and print Z = harry
        will continue and apply rule 2 which fails
        will continue and apply rule 3, but can't go further so would not print ron

::

        ? - likes(Z,Y)
        then first rule would print (harry, school)
        then second rule would print (ron, broom)
        then third rule would be expanded further and print (harry, broom)

*   The clauses will be attempted in the order specified
*   Another Example

::

        offspring(Y,X) :- parent(X,Y)
        mother(X,Y) :- parent(X,Y), female(X)
        grandparent(X,Z) :- parent(X,Y), parent(Y,Z)
        sister(X,Y) :- parent(Z,X), parent(Z,Y), female(X), different(X,Y)
        predecessor(X,Z) :- parent(X,Z)
        predecessor(X,Z) :- parent(X,Y), predecessor(Y,Z).

*   The order of the rules is important
*   Lists can be written as

::

                [ item1, item2, ... ]
        or      [ Head | Tail ]
        or      [ Item1, Item2, ... | Others ]
        [a, b, c] = [a | [b,c]] = [a,b | [c]] = [a,b,c|[]]

*   Items can be lists as well

::

        [[a,b],c,[d,[e,f]]]
        Head of the list is [a,b]

*   Membership and Concatenation

::

        member(X, [X, Tail])
        member(X, [Head, Tail] ) :- member(X, Tail).
        conc([], L, L).
        conc([X|L1], L2, [X|L3]) :- conc(L1, L2, L3)
        ? - conc([a], [b], [a,b]) will return true
        ? - conc([a], Z, [a,b]), prolog would return Z = [b]
        ? - conc([a], [b], Z), prolog would return Z = [a,b]

        Example processing:
        ? - conc([a,b], [c,d], [a,b,c,d]) 
        In the first step it will try to match with the first rule, but failes since the first list should be empty
        In the second step X = a L1=[b], L2 = [c,d], L3 = [b,c,d] will result in requirement of conc([b], [c,d], [b,c,d]) ( as in RHS), which is the new sub-goal
        To match the sub-goal it will try to match with the first rule, which will fail, and then try the second rule X = b L1 = [], L2 = [c,d], L3 =[c,d], which is the new sub-goal
        This new sub-goal with match the first rule

*   Adding in front:

::

        add(X,L,[X|L])

*   Deletion of element : del(X, L1, L2)

::

        del(X, [], [])
        del(X, [X|Tail], Tail)
        del(X, [Y|Tail], [Y|Tail1]) :- del(X, Tail, Tail1)

*   Deletion of all occureneces of element : del (X, L1, L2)

::

        del(X, [], [])
        del(X, [X|Tail], Tail) :- del(X, Tail], Tail)
        del(X, [Y|Tail], [Y|Tail1]) :- del(X, Tail, Tail1)

*   Sublist

::

        sublist(S,L) :- conc(L1, L2, L), conc(S, L3, L2)
        Example:
        ? - sublist([a,b], [d,a,b,c])
        L1 = [d] L2 = [a,b,c] L3 = [c]

*   Permutation : permuation(L,P), P is a permutation of L

::

        permuation([], [])
        permutation([X|L],P) :- permutation(L,L1) insert(X,L1,P)

        Example:
            ? - permutation ([a.b,c,d], [d,c,a,b])
            X = a L = [b,c,d] L1
            sub-goals are permutation([b,c,d],L1), insert(a,L1,[d,c,a,b])
            Solving sub-goal permutation([b,c,d],L1)
                X = b L'=[c,d] L1'
            sub-goals generated are permutation([c,d],L1'), insert(b,L1',L1)
            Solving sub-goal permutation([c,d],L1')
                X = c L' '=[d] L1' '
            sub-goals generaetd are permutation([d],L1' '), insert(c,L1' ',L1')
            Solving sub-goal permutation([d],L1' ')
                X = d L' ' '^=[] L1' ' '
            sub-goals generated are permutation([d],L1' ' '), insert(d,L1' ' ',L1' ')
            Solving sub-goal permutation([],L1' ' ')
                L1' ' '=[]
            Solving sub-goal permutation(d,[],L1' ')
                L1' '=[d]
            Solving sub-goal insert(c,[d],L1')
                L1'=[c,d] L1'=[d,c]
            Solving sub-goal insert(b,[c,d],L1)
                L1=[b,c,d] L1=[c,b,d] L1=[c,d,b]
            Solving sub-goal insert(a,[b,c,d],[d,c,a,b]) is not true
            Solving sub-goal insert(a,[c,b,d],[d,c,a,b]) is not true
            Solving sub-goal insert(a,[c,d,b],[d,c,a,b]) is not true
            Solving sub-goal insert(b,[d,c],L1)
                L1=[b,d,c] L1=[d,b,c] L1=[d,c,b]
            Solving sub-goal insert(a,[b,d,c],[d,c,a,b]) is not true
            Solving sub-goal insert(a,[d,b,c],[d,c,a,b]) is not true
            Solving sub-goal insert(a,[d,c,b],[d,c,a,b]) is true
        Example:
            ? - permutation([a,b,c,d],X) — would generate all premutations of [a,b,c,d]
        Another way of writing permutations are
            permutation([],[])
            permutation(L,[X|P]) :- del(X,L,L1), permutation(L1,P)


*   Arthimetic and Logical operators

   *    We have +,-,*,/,mod

       *    is operator forces evaluation
       *    ? - X is 3/2 - will be answered by X=1.5

   *    We have >,<,>=,<=,=:=,=\=

       *    Examples:

::

        GCD:
        gcd(X,X,X)
        gcd(X,Y,D) :- X < Y, Y1 is Y - X, gcd(X,Y1,D)

        Length of a list:
        length([],0)
        length([_|Tail],N) :- length(Tail,N1), N is N1 + 1


*    Example of Control Flow

::

        r(a)
        s(b,c)
        m(b)
        n(a)
        q(X) :- m(X)
        Q(X) :- n(X)
        p(X,Y) :- q(X), r(Y)
        p(x,Y) :- r(X), s(X,Y)
        ? - p(a,Y)
                                             p(a,Y)
                                             /    \
                                         /            \
                                     /                    \ 
                       Y = a     /                            \
                           q(a) & r(Y)                    r(a) & s(a,Y)    (Fail)
                            /    \                             /\  
                         /          \                       /      \
                      /                \                 /            \
                    q(a)               r(Y)            r(a)          s(a,Y)
                    / \                  |              |              | 
                   /   \                 |              |              |
                  /     \                |              |              |
                m(a)   n(a)            r(a)           match          Fail
                 |      |
                 |      |
               Fail   match

*   Exercising control over flow

   *    8-Queens problem

       *    permutation([1,2,3,4,5,6,7,8], Queens) ( the numbers represent the rows, their position in the list represents col)
            safe(Queens)

::

        permutation([[],[])
        permutation([Head|Tail], Permlist) :- permutation(Tail,PermTail), del(Head,Permlist,PermTail).

        safe([])
        safe([Queen|Other]):- safe(Others), noattack(Queen,Others,1)

        noattack(_,[],_)
        noattack(Y,[Y1|Ylist],Xdist) :- Y1 - Y =\= Xdist, Y - Y1 =\= Xdist,
                                        Dist1 is Xdist + 1, noattacks(Y,Ylist,Dist1)

*   CUPS: for controlling backtracking
   
   *    ! is called cut character, which allows processing of further backtracking to be disabled for the variable.
   *    C :- P,Q,R,!,S,T,U
   *    C :- V
   *    A :- B,C,D
   *    ? - A

*   Backtraking within the goal list P,Q,P
*   As sson as the cut is reqched

   *    All alternative of P,Q,R are suppressed
   *    The claure C:- V will also be discarded
   *    Backtracking possible within S,T,U
   *    No effect with A:- B,C,D, that is, backtracking within B,C,D remains active

*   Example:

::

        Maximum of two numbers, 
        If X >= Y then max = X, otherwise max = Y
        max(X,Y,X) :- X >= Y, !
        max(X,Y,Y)

::

        ADding an leement in to a list without duplication
        add(X,L,L) :- member(X,L),!
        add(X,L,[X|L])

*   Negation as failure

   *    Example

::

        Frodo likes all jewellery except rings
        likes(frodo,X) :- ring(X),!,Fail
        likes(frodo,X) :- jewellery(X)

*   The different predicat:

::

        different(X,X) :- !,fail
        different(X,Y). 

*   Quicksort

::

        quicksort([],[])
        quicksort([X|Tail], sorted):- 
                   split(X,Tail,Small,Big)
                   quicksort(Small,SortedSmall)
                   quicksort(Big,SortedBig)
                   conc(SortedSmall,[X|SortedBig],Sorted)
        split(X,[],[],[])
        split(X,[Y|Tail],[Y|Small],Big) :- gt(X,Y),!,split(X,Tail,Small,Big)
        split(X,[Y|Tail],Small,[Y|Big]) :- split(X,Tail,Small,Big)

Constraint Logic programming
----------------------------

*   Example

::

        fat(X)     - X > 60, X < 80
        obese(Y)   - Y > 70, Y < 100
        proper(Z)  - obese(Z),!,Fail
        proper(Z)  - fat(Z)
        ? - proper(65) - yes ( by 2nd rule)
        ? - proper(75) - no (Failed)
        ? - proper(X)  - The first rule will tell X < 70 and X > 100, then the second rule which defines the range X > 60 and X < 70. These conditional value which define the range are maintained in the constraint stack.


Iterative Refinement Search
---------------------------
Iterative Refinement Search tries iteratively to optimize the result, One of the examples is TSP, in which any permuatation is a result, the solution required is to optimise the cost of the tour.

Two approaches

#.    Hill Climbing(find maximum) / Gradient Descent(fidn minimum)
#.    Simulated Annealing - At high temperatures we take higher cost routes with more probability than at lower temparatures. Lower cost routes are always followed. 


*   Hill Climbing

   *    Makesmoves which monotonically improve the quality of solution
   *    Can settle in a local minima
   *    Random-restart hill climbing


*   Simulated Annealing

   *    Initilaize T (temperature)
   *    If T=0 return current state
   *    sel next = randomly selcted succ of current
   *    \E = Varl[next] - Val[current]
   *    For maxmimising problem, If \E > 0, then set current = next
   *    Otherwise set current = next with prob e\E/T
   *    Update T as per schedule and Go To Step2


Memory-bounded Search
---------------------
Search algorithms which try to adapt to the memory limitations.

----------------------
Memory Bounded A : MA*
----------------------

*    Whenever [OPEN U CLOSED] approaches M, some of the least promising state are removed.
*    To guarantee that the alogrithm terminates we need to back upt the cose of the most promising leaf of the subtree being deleted at the root of that subtree.


Planning
--------
Example: Get tea, biscuits and a book

*   Given:

   *    Initial State: The agent is at home without tea, biscuits, book
   *    Goal state: The agent is at home with tea, biscuits, book
   *    States can be represented as predicates such as At(x), Have(y), Sells(x,y)
   *    Actions:

       *    Go(y) : Agent goes to y - casues At(y) to be true
       *    Buy(z) : Agent buys z - causes Have(z) to be true
       *    Steal(z) : Agent steals z

--------------------------------
Diff between Planning and Search
--------------------------------

*    Actions are given as logical descriptions of preconditions and effects.

    *   This enables the planner to make direct connections between states and actions.

*    The planner is free to add actions to the plan whereve they are required, rather than in an incremental way starting from the initial state.
*    Most parts of the world are independent of most other parts - hence divide and conquer works well.
*    In the example above, the state space could start with how should i reach Have(Tea). I can reach Have(Tea) by Buy(Tea) or Steal(Tea) and so on.

------------------
Situation Calculus
------------------

*   Initial State

   *    At(Home, s0) && !Have(Tra, S0) && !Have(Biscuits,s0) && !Have(Book,s0)

*   Goal state

   *    (for some)s At(Home,s) && Have(Tea,s) && Have(Biscuits,s) && Have(Book,s)

*   Operators:

   *    (for all) a,s Have(Tea,Result(a,s)) <=> [(a=Buy(Tea) && At(Tea-shop,s)) || (Have(Tea,s) && a != Drop(Tea))]
   *    Result(a,s) names the situation resulting from executing the action a in the situation s.

STRIPS
------
Called STanford Reserach Institute Problem Solver

-------------------
Representing States
-------------------

*   States are represented by conjunctions of function-free groudn lieterals, no disjunctions are allowed.

   *    At(Home) && !Have(Tea) && !Have(Biscuits) && !Have(Book)

*   Representing goals, similar to the state example
*   Goals can also contain variables

   *    At(x) && Sells(x,Tea)
   *    The above goal is being at a shop that sells tea

*   Action description - serves as a name
*   Precondition - a conjuction of positive literals
*   Effect - a conjuction of literals(+ve or -ve)

   *    Original version had an addlist and a deleltelist

       *    Example

::

        Op( ACTION:    Go(there)
            PRECOND:   At(here) &&  Path(here,there)
            EFFECT:    At(there) && !At(here))

------------------
Representing Plans
------------------

*    A set of plan steps. Each step is one of the operators for the problem
*    A set of step ordering constraints. Each ordering constraing is of the form Si < Sj, indicating Si must occur sometime before Sj.
*    A set of variable binding constraints of the form v = x, where v is a virable in some step, and x is either a constant or aanother variable
*    A set of vausal links written as S->c:S' indicating S satisfies the precondition c for S'
*    Example

::

        Actions 
             Op(ACTION: RightShoe,
                    PRECOND: RighSockON,
                    EFFECT: RightShoeOn)
             Op(ACTION: RightSock,
                    EFFECT: RightSockOn)
             Op(ACTION: LeftShoe,
                    PRECOND: LeftSockOn,
                    EFFECT: LeftShoeOn)
             Op(ACTION: LeftSock,
                    EFFECT: LeftSockOn)

        Initial Plan
          Plan(
             STEPS: {
                 S1: Op(ACTION:start)
                 S2: Op(ACTION:finish,
                        PRECOND: RightShoeOn && LeftShoeOn)
             },
             ORDERINGS: {S1 < S2},
             BINDING: {},
             LINKS: {}
          )

We check the preconditions required the goal, and see that we need RightShoeOn and LeftShoeOn, we define these two as 2 steps, S3 and S4 ( add them into STEPS), We added the links between S3->c: S2 and S4:->c: S2, which are added to ORDERRINGS and LINKS. And as we go on, we keep adding entries into each of the Plan elements.   

*   Any unmentioned literals are considered false
*   Partial Order Planning Alogrithm

::

        --< represents do LHS before RHS

        function POP(initial, goal, operators)
        // Returns plan
           plan <-- Make-Minimal-Plan(initial,goal)
           Loop do
              If Solution(plan) then return plan
              S,c <-- Select-Subgoal(plan)
              Choose-Ooperator(plan,operators,S,c)
              Resolve-Threats(plan)
           end

        Proc Choose-Operator(plan,operators,S,c)
           choose a step S^^'^^ from operators or
              STEPS(plan) that has c as an effect

           if there i sno such step then fail
           add the causal link S^^'^^ -->c:S to LINKS(plan)
           add the ordering constraing S^^'^^ --< S to ORDERINGS(plan)

           if S^^'^^ is anewly added step from operators
              then add S^^'^^ to STEPS(plan) and add
              Start --< S^^'^ --< Finish to ORDERINGS(plan)

        Procedure Resolve-Threats(plan)
           for each S^^''^^ that threatens a link
           S~~i~~ ->c:S~~j~~ in LINKS(plan) do
              choose either
                   Promotion: Add S^^''^^ --< S~~j~~ to ORDERINGS(plan)
                   Demotion: Add S~~j~~ --< S^^''^^ to ORDERINGS(plan)

           if not Consistent(plan) then fail

