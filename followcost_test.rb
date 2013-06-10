##################################################
# TESTS -- followcost project
##################################################

require 'minitest/autorun'
require './followcost.rb'

class TestFollowCost < MiniTest::Test

  def test_date_parser
    assert_equal 1646, FollowCost.date_parser("Sat Dec  6 18:22:15 2008")
  end

  def calculate_milliscobles_of_theoretick
    assert_equal 2.9441069258809236, FollowCost.calculate_milliscobles()
  end

  def test_followcost_complete_with_fetch
    assert 2.9441069258809236, FollowCost.fetch('theoretick')
  end
end
