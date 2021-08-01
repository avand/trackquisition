require 'minitest/autorun'
require_relative '../lib/track.rb'

class TrackTest < Minitest::Test
  def test_generate_signature_is_case_insensitive
    signature = Track.generate_signature('FOO', 120_000)
    assert_equal 'foo-120', signature
  end

  def test_generate_signature_removes_whitespace
    signature = Track.generate_signature('F O O', 120_000)
    assert_equal 'foo-120', signature
  end

  def test_generate_signature_removes_special_characters
    signature = Track.generate_signature('f!o~o', 120_000)
    assert_equal 'foo-120', signature
  end

  def test_generate_signature_takes_the_first_five_characters
    signature = Track.generate_signature('foobar', 120_000)
    assert_equal 'fooba-120', signature
  end

  def test_generate_signature_rounds_duration
    {
      110_000 => 11,
      130_455 => 13,
      128_939 => 13,
    }.each do |input, output|
      signature = Track.generate_signature('foo', input)
      assert_equal output, signature
    end
  end
end
