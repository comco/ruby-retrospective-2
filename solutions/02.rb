#                         ,-.        _.---._
#                        |  `\.__.-''       `.
#                         \  _        _  ,.   \
#   ,+++=.____mtv.rb_______)_||______|_|_||    |
#  (_.ooo.===================||======|=|=||    |
#     ~~'    by comco     |  ~'      `~' o o  /
#                          \   /~`\     o o  /
#                           `~'    `-.____.-'
class Collection
  include Enumerable

  Properties = [:name, :artist, :album]
  attr_reader :songs, :names, :artists, :albums

  # the collection is initialized by a table of hashes, representing the
  # attributes of a specific song
  def initialize(songs)
    @songs = songs
    # get the attributes of the collection by looking at the columns of the
    # table
    table = songs.map(&:values)
    @names, @artists, @albums = *table.transpose.map(&:uniq)
  end

  def self.parse(text)
    # split the input into an array of song-specific lines
    blocks = text.each_line.map(&:strip).each_slice(4)
    # transform each block of lines to a hash with attributes
    songs = blocks.map { |block| Hash[Properties.zip(block)] }
    new songs
  end

  Song = Struct.new(*Properties)

  def each
    @songs.each do |song|
      # for iteration, construct a new song with the required methods
      yield Song.new(*song.values)
    end
  end

  def filter(criteria)
    filtered_songs = @songs.select { |song| criteria.check.(song) }
    Collection.new filtered_songs
  end

  def adjoin(other)
    merged_songs = @songs | other.songs
    Collection.new merged_songs
  end
end

# a criteria contains a member which is a predicate for checking the criteria
class Criteria < Struct.new(:check)
  # base criterias definition
  def self.name(song_name)
    new ->(song) { song[:name] == song_name }
  end

  def self.artist(artist_name)
    new ->(song) { song[:artist] == artist_name }
  end

  def self.album(album_name)
    new ->(song) { song[:album] == album_name }
  end

  # criteria composition support
  def !
    Criteria.new ->(song) { not check.(song) }
  end

  def |(other)
    Criteria.new ->(song) { check.(song) or other.check.(song) }
  end

  def &(other)
    Criteria.new ->(song) { check.(song) and other.check.(song) }
  end
end
