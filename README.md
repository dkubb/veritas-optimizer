# Veritas Optimizer

Relational algebra optimizer

[![Build Status](https://secure.travis-ci.org/dkubb/veritas-optimizer.png)](http://travis-ci.org/dkubb/veritas-optimizer)

## Installation

With Rubygems:

```bash
$ gem install veritas-optimizer
$ irb -rubygems
>> require 'veritas-optimizer'
=> true
```

With git and local working copy:

```bash
$ git clone git://github.com/dkubb/veritas-optimizer.git
$ cd veritas-optimizer
$ rake install
$ irb -rubygems
>> require 'veritas-optimizer'
=> true
```

NOTE: This gem works best with ruby 1.9, however if you are using ruby 1.8 you must also install [backports](https://rubygems.org/gems/backports), then require backports and backports/basic_object, eg:

```bash
$ ruby -e 'puts RUBY_VERSION'
=> 1.8.7
$ gem install backports
$ irb -rubygems
>> require 'backports'
=> true
>> require 'backports/basic_object'
=> true
>> require 'veritas-optimizer'  # assuming it was installed by one of the two methods above
=> true
```

## Usage

```ruby
# optimize a relation
new_relation = relation.optimize
new_relation = relation.optimize(optimizer)

# optimize a scalar function
new_function = function.optimize
new_function = function.optimize(optimizer)

# optimize an aggregate function
new_aggregate = function.aggregate
new_aggregate = function.aggregate(optimizer)
```

## Description

The purpose of this gem is to provide a simple API that can be used to optimize a [veritas](https://github.com/dkubb/veritas) relation, scalar or aggregate function. An optional optimizer can be passed in to the #optimize method and return an equivalent but simplified version of the object.

One of the primary benefits of Relational Algebra is that it's based on logic, and the rules for simplifying logic are well known and studied. An optimizer can pass through user-generated objects and typically find ways to simplify or organize them in a way that will be more efficient when the operation is executed.

The goal is not to replace the advanced optimizers that are inside most databases and datastores, but to augment it with some simple optimizations that make the user provided query easier for the datastore to accept. On the ruby side we have knowledge about intent and can perform semantic optimization that the datastore otherwise would not be able to perform. In many cases we have richer constraints and data than many datastores and we can use that information to simplify and possibly short-circuit queries that could otherwise never return valid results.

With the ability to provide custom optimizers we can even target output to a structure optimized for specific datastores. All operations in relational algebra can be transformed into other equivalent operations, ones that are more efficient for the target datastore to execute. The built-in optimizers included in this gem are only a starting point; the intention is to expand them as well as help others create custom optimizers that are optimized for each datastore.

## Design

The contract for an optimizer instance is simple:

1. it must respond to #call, and accept an optimizable object as it's only argument
2. it must return an equivalent object
3. it must return the exact object when it cannot perform further optimizations

The optimizer can perform whatever logic it wishes on the object or any of it's contained objects as far down the tree as it likes as long as the requirements for (2) and (3) are met.

Inside this gem we have the concept of an optimizer chain. It's a chain of responsibility, which means it's a set of objects chained together to form a pipeline. The object is passed into the head of the pipeline and is either matched and returned by one of the optimizers, or it is already fully optimized and passes through to the end of the chain and is returned as-is. This chain organization has proven to be extremely effective, and it is trivial to re-order or add new optimizers into the middle of the chain as needed. Further work will be made to provide APIs to make this even simpler.

Here is an example of an optimizer chain for the restriction operator (think WHERE clause in SQL):

```ruby
Veritas::Algebra::Restriction.optimizer = chain(
  Tautology,            # does the predicate match everything?
  Contradiction,        # does the predicate match nothing?
  RestrictionOperand,   # does the restriction contain another restriction?
  SetOperand,           # does the restriction contain a set operation?
  OrderOperand,         # does the restriction contain an order?
  EmptyOperand,         # does the restriction contain an empty relation?
  MaterializedOperand,  # does the restriction contain a materialized relation?
  UnoptimizedOperand    # does the restriction contain an unoptimized relation?
)
```

The restriction operator enters this pipeline, and tests are made at each stage. If the test returns true, then an optimization is performed. Usually the goal is to eliminate work performed by the system or collapse the tree of operations down into something simpler. More aggressive optimizations are usually checked first because we would like to prune as much of the tree as possible up-front. In this case, the first test checks to see if the restriction matches everything, in which case it's pretty much a no-op, and we can drop it altogether. If that's not the case, we then test to see if it matches nothing, if that's the case then we can return an empty relation. Then we test if it's another restriction, in which case we can "AND" the predicates for both restrictions together and return a single restriction operation. And so on down the list with the first match winning.

We always perform at least two optimization passes on each object, because once a tree has been simplified there could be further optimizations possible. Essentially we keep passing the objects into their corresponding optimizer chains until it passes through unchanged. This may seem rather expensive, and I guess it is, but optimization is very fast. Also it doesn't appear to affect performance much in practice due to our convention of testing for the most aggressive optimizations first; often it results in something that is completely optimized on the first try.

Once the optimization passes are finished, and no further optimization is possible, the result of an #optimize call is memoized. Further calls to #optimize will always return the same object.

## Note on Patches/Pull Requests

* If you want your code merged into the mainline, please discuss the proposed changes with me before doing any work on it. This library is still in early development, and it may not always be clear the direction it is going. Some features may not be appropriate yet, may need to be deferred until later when the foundation for them is laid, or may be more applicable in a plugin.
* Fork the project.
* Make your feature addition or bug fix.
  * Follow this [style guide](https://github.com/dkubb/styleguide).
* Add specs for it. This is important so I don't break it in a future version unintentionally. Tests must cover all branches within the code, and code must be fully covered.
* Commit, do not mess with Rakefile, version, or history.  (if you want to have your own version, that is fine but bump version in a commit by itself I can ignore when I pull)
* Run "rake ci". This must pass and not show any regressions in the
  metrics for the code to be merged.
* Send me a pull request. Bonus points for topic branches.

## Copyright

Copyright &copy; 2011-2012 Dan Kubb. See LICENSE for details.
