Similarity Search
=================

.. contents::

Data model
----------
How data is represented. No of dimensions and in what kind of space they are. ex. eucledian space

distance model
--------------
how distances are to be computed. ex. eucledian distance. ex. minimum no of operations to move from one data point to another.

similarity search models
------------------------

*    Branch and bound
*    Greedy walks
*    mappings : LSH, random projections, minhashing
*    epsilon nets 


Branch and Bound
----------------
Branch and bound tree is built using the initial data set. The tree is built in such a way that at a node we either move to left or right or both based on a certain condition at that vertex. As we go on moving along the tree, we reach leaves ( could be more than 1 if at a vertex we had to go on both directions). We compute the distance for all of the leaves that we end up, the one nearest is the nearest neighbour. This algorithm is highly dependant on initial free for finding the nearest neighbour.

Greedy walks
------------
In this method we walk in the space from one point to another point if that point is closer than the point that is now, if there are more than 1 point closer to the input sample then we take the one that is closest to the input sample. When we end up at a state where we cannot move any further, then that point is called the nearest neighbour.

Mappings
--------
In this method we increase the dimension space to very large, and then we compute the nearest neighbour in this space.

Epsilon nets
------------
The data is divided in space into groups. The first group would contain all the samples. The groups at the next level would be half the size in the space or so. We start our search from the first level and keep going down to lower levels.

Similarity search in Bipartite graphs
-------------------------------------
Examples : say n persons and m movies, that is n person vertices in the graph and m movie vertices in the graphs. Links only go between person and movie. There are no person to person links, or movie to movie links. A link from person to movie indicates that the person likes this movie.

Person-person similarity
------------------------
To find person-person to similrity, i.e who are all the persons who like the same movies as this person. To find this attribute we need to find the 2-step chains from this person to other persons. What we are doing here is in the first step is to find all the movies the person like and in the second step we get links to all the persons that like this movie

Person-movie personality
------------------------
To find person-movie personality, that is what are movies that this user might like. To find this we go one step ahead from what we have done in person-person similarity, after the 2-steps we know the persons who have the same taste as this person, from this person's node we go to the all the movies this person liks, which essentially gives all the movies that the actual user might like.

Goodness of a data set
----------------------
Goodness of a data set is a measure to see how good the data set works when we are going to use similarity search for new samples over this data set.

Take a object p and sort all objects based on the distance from p. Lets say rank(r) is defined as what position r is in this sorted list. The data set is said to have
disorder D if

for all p,r,s rank(s with respect to r) <= D * (rank(r) + rank(p))

