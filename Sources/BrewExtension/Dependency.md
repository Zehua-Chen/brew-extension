# Dependency

## Representing Dependency

### Terminology

**Dependency graph**:
* The dependency graph is represented as a directed edge graph;;
* In the graph, if node A depends on node B, then node A has an arrow going toward node B;
* Node A is said to have outcoming connections (aka. "outcomings") to node B;
* Node B is said to have incoming connections (aka. "incomings") to node A;

### Implementation

* The dependency graph is implemented as a dictionary where the key is node and the value 
is a pair of sets containing the nodes that have incoming connections to "this" node, and 
the nodes that have outcoming connections to "this" node, respectively.

## Actions

### Uninstalling

