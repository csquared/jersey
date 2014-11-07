require 'helper'

class LogTest < UnitTest
  def setup
    super
    Jersey.stream = StringIO.new
  end

  def test_log_nothing_logs_time
    Jersey.log()
    logdata = Logfmt.parse(Jersey.stream.string)
    assert(logdata['now'], 'must log time')
  end

  def test_log_hash
    Jersey.log(foo: 'bar')
    logdata = Logfmt.parse(Jersey.stream.string)
    assert_equal('bar', logdata['foo'])
    assert(logdata['now'], 'must log time')
  end

  def test_log_error
    begin
      raise "boom!"
    rescue => e
      Jersey.log(e)
      loglines = Jersey.stream.string.lines
      logdata = Logfmt.parse(loglines[0])
      assert_equal('boom!', logdata['message'])
      assert_equal(e.object_id, logdata['id'])
      assert(logdata['now'], 'must log time')

      logdata = Logfmt.parse(loglines[1])
      assert_equal(1, logdata['line_number'])
      assert_equal(e.object_id, logdata['id'])

      logdata = Logfmt.parse(loglines[2])
      assert_equal(2, logdata['line_number'])
      assert_equal(e.object_id, logdata['id'])

      logdata = Logfmt.parse(loglines.last)
      assert_equal(10, logdata['line_number'])
      assert_equal(e.object_id, logdata['id'])

      assert_equal(11, loglines.size)
    end
  end
end
