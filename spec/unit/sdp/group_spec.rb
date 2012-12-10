require 'spec_helper'
require 'sdp/group'


describe SDP::Group do
  describe "#add_field" do
    let(:field_instance) { double "SDP::Field", sdp_type: nil }

    before do
      subject.should_receive(:check_allowed_field)
      subject.should_receive(:update_fields)
      subject.should_receive(:define_field_accessor)
      subject.stub(:sdp_type)
    end

    context "param is a String" do
      it "calls SDP::Field.new_from_string" do
        field = "v=0"
        SDP::Field.should_receive(:new_from_string).with(field).
          and_return field_instance
        subject.add_field(field)
      end
    end

    context "param is a Hash" do
      it "calls SDP::Field.new_from_hash" do
        field = {}
        SDP::Field.should_receive(:new_from_hash).with(field).
          and_return field_instance
        subject.add_field(field)
      end
    end

    context "param is a Symbol" do
      it "calls SDP::Field.new_from_type" do
        field = :field
        SDP::Field.should_receive(:new_from_type).with(field).
          and_return field_instance
        subject.add_field(field)
      end
    end

    context "param is a SDP::Field" do
      it "doesn't create any SDP::Field" do
        field = SDP::Field.new
        SDP::Field.should_not_receive(:new_from_string)
        SDP::Field.should_not_receive(:new_from_hash)
        SDP::Field.should_not_receive(:new_from_type)
        subject.add_field(field)
      end
    end
  end

  describe "#has_field?" do
    context "field is a Symbol" do
      context "@fields contains the type" do
        let(:field) { double "SDP::Field", sdp_type: :pants }

        it "returns true" do
          subject.instance_variable_set(:@fields, [field])
          subject.should have_field(:pants)
        end
      end

      context "@fields does not contain the type" do
        let(:field) { double "SDP::Field", sdp_type: :shirts }

        it "returns false" do
          subject.instance_variable_set(:@fields, [field])
          subject.should_not have_field(:pants)
        end
      end
    end
  end

  describe "#add_group" do
    before do
      subject.should_receive(:check_allowed_group)
      subject.should_receive(:define_group_accessor)
      subject.stub(:sdp_type)
    end

    let(:group_instance) { double "SDP::Group", sdp_type: :group }

    context "group is a Hash" do
      it "calls SDP::Group.new_from_hash" do
        group = {}
        SDP::Group.should_receive(:new_from_hash).with(group).
          and_return(group_instance)
        subject.add_group(group)
      end
    end

    context "group is a Symbol" do
      it "calls SDP::Group.new_from_type" do
        group = :pants
        SDP::Group.should_receive(:new_from_type).with(group).
          and_return(group_instance)
        subject.add_group(group)
      end
    end

    context "group is a SDP::Group" do
      it "calls SDP::Group.new_from_type" do
        group = SDP::Group.new
        SDP::Group.should_not_receive(:new_from_hash)
        SDP::Group.should_not_receive(:new_from_type)
        subject.add_group(group)
      end
    end
  end

  describe "#has_group?" do
    context "group is a Symbol" do
      context "@groups contains the type" do
        let(:group) { double "SDP::Group", sdp_type: :pants }

        it "returns true" do
          subject.instance_variable_set(:@groups, [group])
          subject.should have_group(:pants)
        end
      end

      context "@groups does not contain the type" do
        let(:group) { double "SDP::Group", sdp_type: :shirts }

        it "returns false" do
          subject.instance_variable_set(:@groups, [group])
          subject.should_not have_field(:group)
        end
      end
    end

    context "group is a SDP::Group" do
      context "@groups contains the type" do
        let(:group) { SDP::Group.new }

        it "returns true" do
          subject.instance_variable_set(:@groups, [group])
          subject.should have_group(group)
        end
      end

      context "@groups does not contain the type" do
        let(:group) do
          class Tester < SDP::Group; end
        end

        it "returns false" do
          subject.instance_variable_set(:@groups, [group])
          subject.should_not have_field(:group)
        end
      end
    end
  end

  describe "#to_s" do
    it "sorts then outputs a string" do
      subject.should_receive(:sdp_sort).and_return []
      subject.to_s.should == ""
    end
  end

  describe "#to_hash" do
    let(:field) { double "SDP::Field", to_hash: { pants: :party } }
    let(:group) { double "SDP::Field", to_hash: { dance: :party } }

    it "outputs a Hash with the groups and fields" do
      subject.instance_variable_set(:@fields, [field])
      subject.instance_variable_set(:@groups, [group])
      subject.to_hash.should == { pants: :party, dance: :party }
    end
  end

  describe "#sdp_sort" do
    pending "Figuring out how to mock #fields"
  end

  describe "#groups" do
    let(:pants_group) { double "SDP::Group", sdp_type: :pants }
    let(:dance_group) { double "SDP::Group", sdp_type: :dance }

    before do
      subject.instance_variable_set(:@groups, [pants_group, dance_group])
    end

    context "no param given" do
      context "no block" do
        it "returns the existing list of groups" do
          subject.groups.should == [pants_group, dance_group]
        end
      end

      context "with a block" do
        it "yields the existing list of groups" do
          expect { |b| subject.groups(nil, &b) }.
            to yield_successive_args pants_group, dance_group
        end
      end
    end

    context "type param given" do
      context "no block" do
        it "returns groups by that type" do
          subject.groups(:pants).should == [pants_group]
        end
      end

      context "with a block" do
        it "yields the group by that type" do
          expect { |b| subject.groups(:pants, &b) }.
            to yield_successive_args pants_group
        end
      end
    end
  end

  describe "#fields" do
    let(:pants_field) { double "SDP::Field", sdp_type: :pants }
    let(:dance_field) { double "SDP::Field", sdp_type: :dance }

    before do
      subject.instance_variable_set(:@fields, [pants_field, dance_field])
    end

    context "no param given" do
      context "no block" do
        it "returns the existing list of fields" do
          subject.fields.should == [pants_field, dance_field]
        end
      end

      context "with a block" do
        it "yields the existing list of fields" do
          expect { |b| subject.fields(nil, &b) }.
            to yield_successive_args pants_field, dance_field
        end
      end
    end

    context "type param given" do
      context "no block" do
        it "returns fields by that type" do
          subject.fields(:pants).should == [pants_field]
        end
      end

      context "with a block" do
        it "yields the field by that type" do
          expect { |b| subject.fields(:pants, &b) }.
            to yield_successive_args pants_field
        end
      end
    end
  end

  describe "#added_field_types" do
    let(:field) { double "SDP::Field::Pants", sdp_type: :pants }
    let(:field2) { double "SDP::Field::Pants", sdp_type: :pants }

    it "returns a unique list of sdp types that have been added to the group" do
      subject.instance_variable_set(:@fields, [field, field2])
      subject.added_field_types.should == [:pants]
    end
  end

  describe "#added_group_types" do
    let(:group) { double "SDP::Group::Pants", sdp_type: :pants }
    let(:group2) { double "SDP::Group::Pants", sdp_type: :pants }

    it "returns a unique list of sdp types that have been added to the group" do
      subject.instance_variable_set(:@groups, [group, group2])
      subject.added_group_types.should == [:pants]
    end
  end

  describe "#recursive_fields" do
    let(:subgroup_field) { double "SDP::Field" }
    let(:subgroup) do
      g = SDP::Group.new
      g.instance_variable_set(:@fields, [subgroup_field])
      g.should_receive :recursive_fields

      g
    end

    let(:group_field) { double "SDP::Field" }
    let(:group) do
      g = SDP::Group.new
      g.instance_variable_set(:@fields, [group_field])
      g.instance_variable_set(:@groups, [subgroup])

      g
    end

    let(:field) { double "SDP::Field" }

    before do
      subject.instance_variable_set(:@fields, [field])
      subject.instance_variable_set(:@groups, [group])
    end

    context "no block" do
      it "returns all fields from itself and child groups, recursively" do
        subject.recursive_fields.should == [field, group_field, subgroup_field]
      end
    end

    context "block given" do
      it "yields all fields from itself and child groups, recursively" do
        expect { |b|
          subject.recursive_fields(&b)
        }.to yield_successive_args field, group_field, subgroup_field
      end
    end
  end

  describe "#errors" do
    context "no fields or groups" do
      specify { subject.errors.should be_empty }
    end

    context "missing fields, missing groups, fields with missing values" do
      let(:missing_fields) { [:field] }
      let(:missing_groups) { [:group] }
      let(:fields_with_missing_values) { [:fields_with_missing_values] }
      let(:child_group) do
        g = double "SDP::Group"
        g.should_receive(:errors).and_return %w[some errors]
        g.should_receive(:sdp_type).and_return :child_group

        g
      end

      before do
        subject.should_receive(:missing_fields).twice.and_return missing_fields
        subject.should_receive(:missing_groups).any_number_of_times.
          and_return missing_groups
        subject.should_receive(:fields_with_missing_values).any_number_of_times.
          and_return fields_with_missing_values
        subject.instance_variable_set(:@groups, [child_group])
      end

      it "gets errors for fields, groups, and child fields and groups" do
        subject.errors.should == {
          missing_fields: [:field],
          missing_groups: [:group],
          fields_with_missing_values: [:fields_with_missing_values],
          child_errors: [{ child_group: %w[some errors] }]
        }
      end
    end
  end
end
