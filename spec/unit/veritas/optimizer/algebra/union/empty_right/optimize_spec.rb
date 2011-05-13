# encoding: utf-8

require 'spec_helper'

describe Optimizer::Algebra::Union::EmptyRight, '#optimize' do
  subject { object.optimize }

  let(:header)   { Relation::Header.new([ [ :id, Integer ] ]) }
  let(:left)     { Relation.new(header, [ [ 1 ] ].each)       }
  let(:right)    { Relation::Empty.new(header)                }
  let(:relation) { left.union(right)                          }
  let(:object)   { described_class.new(relation)              }

  before do
    object.should be_optimizable
  end

  it { should equal(left) }
end
