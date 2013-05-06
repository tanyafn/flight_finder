shared_context "segments_builder"  do

  def build_segments *names
      names.inject([]){ |ary, segment_name| ary << Fabricate.build(segment_name) }
  end

end