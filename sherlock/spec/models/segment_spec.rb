require 'spec_helper'
require 'shared_examples/segment_spec'
require 'shared_contexts/segments_context'


describe Segment do
  include_context "segments_builder"

  subject { Fabricate(:itn, segments: build_segments(:kja_pek, :pek_bkk)).segments.first }

	it { should be_mongoid_document }
	it { should be_embedded_in(:segmentable) }

  it_behaves_like "a segment of flight"

  it { should validate_uniqueness_of(:orig) }
  it { should validate_uniqueness_of(:dest) }
end
