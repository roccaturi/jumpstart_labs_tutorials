require "jumpstart_auth"
require "bitly"
require "klout"

class MicroBlogger
  attr_reader :client

  def initialize
    puts "Initializing CLI MicroBlogger"
    @client = JumpstartAuth.twitter
    Bitly.use_api_version_3
    @bitly = Bitly.new("hungryacademy", "R_430e9f62250186d2612cca76eee2dbc6")
    Klout.api_key = 'xu9ztgnacmjx3bu82warbr3h'
  end

  def run
    puts "Welcome to the Vorak Enigma Xerox (VEX), made possible by JumpStart Lab."
    command = ""
    while command != "q"
      printf "Enter command: "
      parts = gets.chomp.split(" ")
      command = parts[0]
      case command
      when "q" then puts "до свидания!"
      when "t" then tweet(parts[1..-1].join(" "))
      when "d" then direct_message(parts[1], parts[2..-1].join(" "))
      when "s" then spam_my_followers(parts[1..-1].join(" "))
      when "e" then everyones_last_tweet
      when "b" then shorten(parts[1])
      when "u" then tweet(parts[1..-2].join(" ") + " " + shorten(parts[-1]))
      when "k" then klout_score
      else puts "Sorry, I don't know: #{command}."
      end 
    end
  end

  class TweetLengthError < StandardError; end 
  class NotFriendsError < StandardError; end

  def tweet(message)
    raise TweetLengthError, "Tweet must be less than or equal to 140 character.  Your message is #{message.length} characters." unless message.length <= 140 
    @client.update(message)
  end

  def direct_message(target, message)
    puts "Trying to send #{target} this direct message:"
    puts message
    screen_names = @client.followers.collect {|follower| @client.user(follower).screen_name}
    raise NotFriendsError, "You are not followed by #{target}.  Twitter forbids direct messages to a user who has not followed you." unless screen_names.include?(target)
    message = "d #{target} #{message}"
    tweet(message)
  end

  def followers_list
    screen_names = []
    @client.followers.each {|follower| screen_names << @client.user(follower).screen_name}
    screen_names
  end

  def spam_my_followers(message)
    victims = followers_list
    victims.each {|follower| direct_message(follower, message)}
  end

  def everyones_last_tweet
    friends = @client.friends
    friends.each do |friend|
      puts @client.friend.followers_count
      puts "#{friend.screen_name} said:"
      puts friend.status.text
      friend.status.created_at.strftime("%A, %b %d")
      puts timestamp
      puts ""
    end
  end

  def shorten(original_url)
    puts "Shortening this url: #{original_url}"
    return @bitly.shorten(original_url).short_url
  end

  def klout_score
    friends = @client.friends.collect {|friend| friend.screen_name}
    friends.each do |friend|
      puts friend
      identity = Klout::Identity.find_by_screen_name(friend)
      user = Klout::User.new(identity.id)
      puts user.score.score
      puts ""
    end
  end
end

blogger = MicroBlogger.new
blogger.run
