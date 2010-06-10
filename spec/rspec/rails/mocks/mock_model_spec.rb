require 'spec_helper'
require File.dirname(__FILE__) + '/ar_classes'

describe "mock_model(RealModel)" do
  describe "with #id stubbed" do
    before(:each) do
      @model = mock_model(MockableModel, :id => 1)
    end
    it "is named using the stubbed id value" do
      @model.instance_variable_get(:@name).should == "MockableModel_1"
    end
    it "returns string of id value for to_param" do
      @model.to_param.should == "1"
    end
  end

  describe "with params" do
    it "does not mutate its parameters" do
      params = {:a => 'b'}
      model = mock_model(MockableModel, params)
      params.should == {:a => 'b'}
    end
  end

  describe "as association" do
    before(:each) do
      @real = AssociatedModel.create!
      @mock_model = mock_model(MockableModel)
      @real.mockable_model = @mock_model
    end

    it "passes: associated_model == mock" do
      @mock_model.should == @real.mockable_model
    end

    it "passes: mock == associated_model" do
      @real.mockable_model.should == @mock_model
    end
  end

  describe "#is_a?" do
    before(:each) do
      @model = mock_model(SubMockableModel)
    end
    it "says it is_a?(RealModel)" do
      @model.is_a?(SubMockableModel).should be(true)
    end
    it "says it is_a?(OtherModel) if RealModel is an ancestors" do
      @model.is_a?(MockableModel).should be(true)
    end
  end

  describe "#kind_of?" do
    before(:each) do
      @model = mock_model(SubMockableModel)
    end
    it "says it is kind_of? if RealModel is" do
      @model.kind_of?(SubMockableModel).should be(true)
    end
    it "says it is kind_of? if RealModel's ancestor is" do
      @model.kind_of?(MockableModel).should be(true)
    end
  end

  describe "#instance_of?" do
    before(:each) do
      @model = mock_model(SubMockableModel)
    end
    it "says it is instance_of? if RealModel is" do
      @model.instance_of?(SubMockableModel).should be(true)
    end
    it "does not say it instance_of? if RealModel isn't, even if it's ancestor is" do
      @model.instance_of?(MockableModel).should be(false)
    end
  end

  describe "#model_name" do
    before(:each) do
      @model = mock_model(SubMockableModel)
    end
    it "says its model_name" do
      @model.model_name(SubMockableModel).should == "SubMockableModel"
    end
  end


  describe "#destroyed?" do
    context "default" do
      it "returns false" do
        @model = mock_model(SubMockableModel)
        @model.destroyed?.should be(false)
      end
    end
  end

  describe "#marked_for_destruction?" do
    context "default" do
      it "returns false" do
        @model = mock_model(SubMockableModel)
        @model.marked_for_destruction?.should be(false)
      end
    end
  end

  describe "#persisted?" do
    context "with default id" do
      it "returns true" do
        mock_model(MockableModel).should be_persisted
      end
    end

    context "with explicit id" do
      it "returns true" do
        mock_model(MockableModel, :id => 37).should be_persisted
      end
    end

    context "with id nil" do
      it "returns false" do
        mock_model(MockableModel, :id => nil).should_not be_persisted
      end
    end
  end


  describe "#valid?" do
    context "default" do
      it "returns true" do
        mock_model(MockableModel).should be_valid
      end
    end
    context "stubbed with false" do
      it "returns false" do
        mock_model(MockableModel, :valid? => false).should_not be_valid
      end
    end
  end

  describe "#as_new_record" do
    it "says it is a new record" do
      m = mock_model(MockableModel)
      m.as_new_record.should be_new_record
    end

    it "has a nil id" do
      mock_model(MockableModel).as_new_record.id.should be(nil)
    end

    it "returns nil for #to_param" do
      mock_model(MockableModel).as_new_record.to_param.should be(nil)
    end
  end

  describe "ActiveModel Lint tests" do
    require 'test/unit/assertions'
    require 'active_model/lint'
    include Test::Unit::Assertions
    include ActiveModel::Lint::Tests

    # to_s is to support ruby-1.9
    ActiveModel::Lint::Tests.public_instance_methods.map{|m| m.to_s}.grep(/^test/).each do |m|
      example m.gsub('_',' ') do
        send m
      end
    end

    def model
      mock_model(MockableModel, :id => nil)
    end

  end
end
