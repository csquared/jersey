require 'helper'

class SetupTest < UnitTest
  def test_time_zone
    t = Time.now
    assert_equal('UTC', t.zone)
  end

  def test_time_to_s
    t = Time.now
    assert_equal(t.iso8601, t.to_s)
  end
end
