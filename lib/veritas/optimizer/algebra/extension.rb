# encoding: utf-8

module Veritas
  class Optimizer
    module Algebra

      # Abstract base class representing Extension optimizations
      class Extension < Relation::Operation::Unary

          # The optimized extensions
          #
          # @return [Hash{Attribute => Function}]
          #
          # @api private
          attr_reader :extensions

          # Initialize a Summarization optimizer
          #
          # @return [undefined]
          #
          # @api private
          def initialize(*)
            super
            @extensions = optimize_extensions
          end

        private

          # Optimize the extensions
          #
          # @return [Hash{Attribute => Function}]
          #
          # @api private
          def optimize_extensions
            extensions = {}
            operation.extensions.each do |attribute, function|
              extensions[attribute] = Function.optimize_operand(function)
            end
            extensions.freeze
          end

        # Optimize when operands are optimizable
        class UnoptimizedOperand < self
          include Function::Unary::UnoptimizedOperand

          # Test if the operand is unoptimized
          #
          # @return [Boolean]
          #
          # @api private
          def optimizable?
            super || extensions_optimizable?
          end

          # Return an Extension with an optimized operand
          #
          # @return [Algebra::Extension]
          #
          # @api private
          def optimize
            operation = self.operation
            operation.class.new(operand, extensions)
          end

        private

          # Test if the extensions are optimizable
          #
          # @return [Boolean]
          #
          # @api private
          def extensions_optimizable?
            !extensions.eql?(operation.extensions)
          end

        end # class UnoptimizedOperand

        Veritas::Algebra::Extension.optimizer = chain(
          MaterializedOperand,
          UnoptimizedOperand
        )

      end # class Extension
    end # module Algebra
  end # class Optimizer
end # module Veritas
