shared_examples_for "a segmentable object"  do
  describe "validations" do
    it { should validate_that(:orig).equal_to("segments.first.orig") }
    it { should validate_that(:dest).equal_to("segments.last.dest") }
    it { should validate_that(:departing_at).equal_to("segments.first.departing_at") }
    it { should validate_that(:arriving_at).equal_to("segments.last.arriving_at") }

    describe "stops count validation" do
      context "stops count less than segments count by 1" do
        it { should allow_value(subject.segments.size - 1).for(:stops_count) }
      end
      context "stops count not equal to segments count - 1" do
        [-1, 0, 2].each do |diff|
          it { should_not allow_value(subject.segments.size - diff).for(:stops_count) }
        end
      end
    end
  end
end