# encoding: utf-8

require 'spec_helper'

describe Relation::Operation::Insertion, '#optimize' do
  subject { object.optimize }

  let(:object)         { described_class.new(left, right) }
  let(:original_left)  { Relation.new(header, left_body)  }
  let(:original_right) { Relation.new(header, right_body) }
  let(:header)         { [ attribute ]                    }
  let(:attribute)      { Attribute::Integer.new(:id)      }
  let(:left_body)      { [ [ 1 ] ].each                   }
  let(:right_body)     { [ [ 2 ] ].each                   }

  context 'left is an order relation' do
    let(:left)  { original_left.sort_by  { header } }
    let(:right) { original_right.sort_by { header } }

    it 'returns an equivalent relation to the unoptimized operation' do
      should == object
    end

    it 'does not execute left_body#each' do
      left_body.should_not_receive(:each)
      subject
    end

    it 'does not execute right_body#each' do
      right_body.should_not_receive(:each)
      subject
    end

    it { should be_instance_of(Relation::Operation::Order) }

    # check to make sure the insertion is pushed-down
    its(:operand) { should eql(original_left.insert(original_right)) }

    its(:directions) { should == header }

    it_should_behave_like 'an optimize method'
  end

  context 'left is a reverse relation' do
    let(:left)  { original_left.sort_by  { header }.reverse }
    let(:right) { original_right.sort_by { header }.reverse }

    it 'returns an equivalent relation to the unoptimized operation' do
      should == object
    end

    it 'does not execute left_body#each' do
      left_body.should_not_receive(:each)
      subject
    end

    it 'does not execute right_body#each' do
      right_body.should_not_receive(:each)
      subject
    end

    it { should be_instance_of(Relation::Operation::Order) }

    # check to make sure the insertion is pushed-down
    its(:operand) { should eql(original_left.insert(original_right)) }

    its(:directions) { should == [ attribute.desc ] }

    it_should_behave_like 'an optimize method'
  end

  context 'left is a limit relation' do
    let(:left)  { original_left.sort_by  { header }.take(1) }
    let(:right) { original_right.sort_by { header }.take(1) }

    it 'does not push-down insertions' do
      should equal(object)
    end
  end

  context 'left is an offset relation' do
    let(:left)  { original_left.sort_by  { header }.drop(1) }
    let(:right) { original_right.sort_by { header }.drop(1) }

    it 'does not push-down insertions' do
      should equal(object)
    end
  end
end
