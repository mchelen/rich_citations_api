# Copyright (c) 2014 Public Library of Science
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

require 'test_helper'

class CitationGroupAssignMetadataTest < ActiveSupport::TestCase

  test "it should assign the basic metadata" do
    g = CitationGroup.new
    g.assign_metadata('id'              => 'group-1',
                      'ellipses_before' => true,
                      'text_before'     => 'text before',
                      'text'            => 't e x t',
                      'text_after'      => 'text after',
                      'ellipses_after'  => true,
                      'word_position'   => 42,
                      'section'         => 'Introduction',
                      'extra_metadata'  => { 'count' => 2 }          )

    assert_equal g.group_id,        'group-1'
    assert_equal g.ellipses_before, true
    assert_equal g.text_before,     'text before'
    assert_equal g.text,            't e x t'
    assert_equal g.text_after,      'text after'
    assert_equal g.ellipses_after,  true
    assert_equal g.word_position,   42
    assert_equal g.section,         'Introduction'
    assert_equal g.extra,           'extra_metadata' => { 'count' => 2 }
  end

  test "it should sanitize html for the basic metadata" do
    g = CitationGroup.new
    g.assign_metadata('id'              => 'group-1',
                      'text_before'     => '<span>text before</span>',
                      'text'            => '<span>t e x t</span>',
                      'text_after'      => '<span>text after</span>'              )

    assert_equal g.text_before,     'text before'
    assert_equal g.text,            't e x t'
    assert_equal g.text_after,      'text after'
  end

  test "it should assign references" do
    p = papers(:a)
    g = CitationGroup.new(citing_paper:p)
    g.assign_metadata('references'      => ['ref-2', 'ref-1'],
                      'extra_metadata'  => { 'count' => 2 }          )

    assert_equal g.references.size, 2
    assert_equal g.references[0], references(:ref_2)
    assert_equal g.references[1], references(:ref_1)

    assert_equal g.extra,           'extra_metadata' => { 'count' => 2 }
  end

  test "it should round-trip the metadata" do
    p = papers(:a)
    g = CitationGroup.new(citing_paper:p)

    metadata = { 'id'              => 'group-1',
                 'references'      => ['ref-2', 'ref-1'],
                 'ellipses_before' => false,
                 'text_before'     => 'text before',
                 'text'            => 't e x t',
                 'text_after'      => 'text after',
                 'ellipses_after'  => true,
                 'word_position'   => 42,
                 'section'         => 'Introduction',
                 'extra_metadata'  => { 'count' => 2 }          }

    g.assign_metadata(metadata)
    assert_equal g.metadata, metadata
  end

  test "it should raise an exception if a reference does not exist" do
    p = papers(:a)
    g = CitationGroup.new(citing_paper:p)

    assert_raises(RuntimeError) {
      g.assign_metadata('references'      => ['ref-doesnt-exist'] )
    }
  end

end
