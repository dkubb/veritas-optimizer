# encoding: utf-8

require 'spec_helper'

describe Optimizer::Function::Predicate::Inequality::Contradiction, '#optimizable?' do
  subject { object.optimizable? }

  let(:attribute) { Attribute::Integer.new(:id)    }
  let(:predicate) { left.ne(right)                 }
  let(:object)    { described_class.new(predicate) }

  before do
    predicate.should be_kind_of(Function::Predicate::Inequality)
  end

  context 'when left and right are equal' do
    let(:left)  { attribute }
    let(:right) { attribute }

    it { should be(true) }
  end

  context 'when left and right are not equal' do
    let(:left)  { attribute }
    let(:right) { 1         }

    it { should be(false) }
  end
end
