# encoding: utf-8

module Veritas
  class Optimizer
    module Logic
      class Predicate

        # Abstract base class representing LessThanOrEqualTo optimizations
        class LessThanOrEqualTo < self
          include Comparable

          # Optimize when the operands are a contradiction
          class Contradiction < self
            include Comparable::NeverComparable
            include Predicate::Contradiction

            # Test if the operands are a contradiction
            #
            # @return [Boolean]
            #
            # @api private
            def optimizable?
              super || GreaterThan::Tautology.new(operation.inverse).optimizable?
            end

          end # class Contradiction

          # Optimize when the operands are a tautology
          class Tautology < self
            include Predicate::Tautology

            # Test if the operands are a tautology
            #
            # @return [Boolean]
            #
            # @api private
            def optimizable?
              operation = self.operation
              LessThan::Tautology.new(operation).optimizable? ||
              Equality::Tautology.new(operation).optimizable?
            end

          end # class Tautology

          Veritas::Logic::Predicate::LessThanOrEqualTo.optimizer = chain(
            ConstantOperands,
            Contradiction,
            Tautology,
            NormalizableOperands
          )

        end # class LessThanOrEqualTo
      end # class Predicate
    end # module Logic
  end # class Optimizer
end # module Veritas
