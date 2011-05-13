# encoding: utf-8

require 'spec_helper'

describe Optimizer::Function::Connective::Disjunction::ContradictionLeftOperand, '#optimize' do
  subject { object.optimize }

  let(:attribute)  { Attribute::Integer.new(:id)                        }
  let(:left)       { Function::Proposition::Contradiction.instance      }
  let(:right)      { attribute.eq(1)                                    }
  let(:connective) { Function::Connective::Disjunction.new(left, right) }
  let(:object)     { described_class.new(connective)                    }

  before do
    object.should be_optimizable
  end

  it { should equal(right) }
end
