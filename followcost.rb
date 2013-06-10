#
# title: followcost.rb
# author: @theoretick
# date: 06june2013
# description: followcost.com replacement commandline implementation in Ruby
#
#####################################################################

# https://gist.github.com/vosechu/ad9f79b353cfbf4a842d
#
# Followcost.com rated your friends in milliscobles, a fictitious unit
# which was defined thusly: "'1/1000 of the average daily Twitter status
# updates by Robert Scoble as of 10:09 CST September 25, 2008.' At that
# time, Scoble was averaging 21.21 tweets per day, so a milliscoble is
# 0.02121 tweets per day."
#
#
# Our script should do several things:
#
# * Take a username and calculate their milliscoble rating
# * Take a username and find the milliscoble rating of all their friends
# * Sort those users with the highest number of milliscobles and output it to the terminal
# * Run via the terminal
#
#
# To create a command-line interface you should use Thor or Rake.
# Thor docs can be found here:
#   http://whatisthor.com/)
#
# Twitter's search api can be found here:
#   https://dev.twitter.com/docs/api/1/get/search
#####################################################################

require 'minitest/autorun'
require 'net/http'
require 'json'
require 'date' # to parse num of days

class FollowCost

  MILLISCOBLE = 0.02121

  ##################################################
  # TEST-MODE TO ALLOW TWEAKING WITHOUT EXTRA API CALLS
  TEST_MODE = false
  MOCK_DATA = {"id"=>17926040, "id_str"=>"17926040", "name"=>"Lucas C", "screen_name"=>"theoretick", "location"=>"Portland, OR", "url"=>"http://about.me/lucascharles", "description"=>"Quantum Mechanic. Linguistics, Mindhacks, Cognitive training, and Self-teachery.", "protected"=>false, "followers_count"=>468, "friends_count"=>379, "listed_count"=>36, "created_at"=>"Sat Dec 06 18:22:15 +0000 2008", "favourites_count"=>25, "utc_offset"=>-28800, "time_zone"=>"Pacific Time (US & Canada)", "geo_enabled"=>true, "verified"=>false, "statuses_count"=>4846, "lang"=>"en", "status"=>{"created_at"=>"Sat Jun 08 18:43:12 +0000 2013", "id"=>343438073910140929, "id_str"=>"343438073910140929", "text"=>"RT @newsyc20: Show HN: Easily add a NSA backdoor to your Rails app. https://t.co/mVNwfQz887 (http://t.co/RqXllEIrtr)", "source"=>"<a href=\"https://mobile.twitter.com\" rel=\"nofollow\">Mobile Web (M5)</a>", "truncated"=>false, "in_reply_to_status_id"=>nil, "in_reply_to_status_id_str"=>nil, "in_reply_to_user_id"=>nil, "in_reply_to_user_id_str"=>nil, "in_reply_to_screen_name"=>nil, "geo"=>nil, "coordinates"=>nil, "place"=>nil, "contributors"=>nil, "retweeted_status"=>{"created_at"=>"Sat Jun 08 18:00:07 +0000 2013", "id"=>343427234058620930, "id_str"=>"343427234058620930", "text"=>"Show HN: Easily add a NSA backdoor to your Rails app. https://t.co/mVNwfQz887 (http://t.co/RqXllEIrtr)", "source"=>"<a href=\"http://news.ycombinator.com\" rel=\"nofollow\">newsyc</a>", "truncated"=>false, "in_reply_to_status_id"=>nil, "in_reply_to_status_id_str"=>nil, "in_reply_to_user_id"=>nil, "in_reply_to_user_id_str"=>nil, "in_reply_to_screen_name"=>nil, "geo"=>nil, "coordinates"=>nil, "place"=>nil, "contributors"=>nil, "retweet_count"=>3, "favorite_count"=>1, "favorited"=>false, "retweeted"=>false, "possibly_sensitive"=>false, "lang"=>"en"}, "retweet_count"=>3, "favorite_count"=>0, "favorited"=>false, "retweeted"=>false, "possibly_sensitive"=>false, "lang"=>"en"}, "contributors_enabled"=>false, "is_translator"=>false, "profile_background_color"=>"352726", "profile_background_image_url"=>"http://a0.twimg.com/images/themes/theme5/bg.gif", "profile_background_image_url_https"=>"https://si0.twimg.com/images/themes/theme5/bg.gif", "profile_background_tile"=>false, "profile_image_url"=>"http://a0.twimg.com/profile_images/1685670370/Sketch10612323_normal.jpg", "profile_image_url_https"=>"https://si0.twimg.com/profile_images/1685670370/Sketch10612323_normal.jpg", "profile_link_color"=>"D02B55", "profile_sidebar_border_color"=>"829D5E", "profile_sidebar_fill_color"=>"99CC33", "profile_text_color"=>"3E4415", "profile_use_background_image"=>true, "default_profile"=>false, "default_profile_image"=>false, "following"=>nil, "follow_request_sent"=>nil, "notifications"=>nil}
  ##################################################

  def self.get_user_data()

    if TEST_MODE == true
      puts 'WARNING:: TEST MODE: ON'
      puts 'SIMULATED DATA REQUESTS ONLY'
      return MOCK_DATA
    end

    uri = URI("http://api.twitter.com/1/users/show.json?screen_name=#{@screen_name}")
    response_data = Net::HTTP.get_response(uri)
    return JSON.parse(response_data.body)
  end

  def self.date_parser(date_string)
    # parses text-string to return total number of days
    # uses "modified julian day number" method to find diff from current
    date = DateTime.parse(date_string)
    today = Time.now.to_datetime
    total = today.mjd - date.mjd
    total = 1 if total == 0  #to avoid division by zero
    return total
  end

  def self.calculate_milliscobles()
    total_tweets = @json_hash["statuses_count"]
    total_days = date_parser(@json_hash["created_at"])
    milliscoble_rating = total_tweets.to_f / total_days
    return milliscoble_rating
  end

  # Main function, calls all children
  def self.calculate(user)
    @screen_name = user
    @json_hash = get_user_data()
    @user_score = calculate_milliscobles()
    puts @user_score
  end
end

# FollowCost.calculate('theoretick')

##################################################
# TESTS
##################################################

class TestFollowCost < MiniTest::Test

  def test_date_parser
    assert_equal 1646, FollowCost.date_parser("Sat Dec  6 18:22:15 2008")
  end

  def test_calculate_milliscobles
    assert_equal 2.9441069258809236, FollowCost.calculate_milliscobles()
  end

  def test_followcost_complete_with_calculate
    assert 2.9441069258809236, FollowCost.calculate('theoretick')
  end
end
