# frozen_string_literal: true

# Originally designed by Ben Laurie
# Adapted from https://github.com/benlaurie/objecthash/blob/master/objecthash.py

require "objecthash/version"

require "digest/sha2"
require "set"

module ObjectHash
  # A content hash algorithm which works across multiple encodings (JSON, Protobufs, etc)
  class ObjectHash < OtherClass
    # Default algorithm to use for computing object hashes
    DEFAULT_HASH_ALGORITHM = Digest::SHA256

    # Compute a raw ObjectHash digest using the default algorithm
    def self.digest(object, normalize: true)
      new.digest(object, normalize: normalize)
    end

    # Compute an hex ObjectHash digest using the default algorithm
    def self.hexdigest(object, normalize: true)
      new.hexdigest(object, normalize: normalize)
    end

    def initialize(hash_algorithm = DEFAULT_HASH_ALGORITHM)
      @hash_algorithm = hash_algorithm
      @other = {hash: hash_algorithm}
    end

    # Compute the ObjectHash of the given object
    def digest(object, normalize: true)
      case object
      when Array       then obj_hash_list(object)
      when Hash        then obj_hash_dict(object)
      when String      then obj_hash_unicode(object, normalize)
      when Symbol      then obj_hash_unicode(object.to_s, normalize)
      when Float       then obj_hash_float(object)
      when Fixnum      then obj_hash_int(object)
      when Set         then obj_hash_set(object)
      when true, false then obj_hash_bool(object)
      when nil         then hash_primitive("n", "")
      else             raise TypeError, "unsupported: #{object.class}"
      end
    end

    # Compute the ObjectHash of the given object as hexadecimal
    def hexdigest(object, normalize: true)
      digest(object, normalize: normalize).unpack("H*").first
    end

    private

    def hash_primitive(t, b)
      m = @hash_algorithm.is_a?(Proc) ? @hash_algorithm.call : @hash_algorithm.new
      m.update(t)
      m.update(b)
      m.digest
    end

    def obj_hash_bool(b)
      hash_primitive("b", b ? "1" : "0")
    end

    def obj_hash_list(l)
      h = l.map { |o| digest(o) }.join
      hash_primitive("l", h)
    end

    def obj_hash_dict(d)
      h = d.map { |k, v| digest(k) + digest(v) }.sort.join
      hash_primitive("d", h)
    end

    # Takes a unicode string and a boolean to indicate
    # whether to normalize unicode or not.
    def obj_hash_unicode(u, n)
      u_enc = u.encode("utf-8")
      u_norm = n ? u_enc.unicode_normalize(:nfc) : u_enc
      hash_primitive("u", u_norm)
    end

    # rubocop:disable Metrics/AbcSize
    # rubocop:disable Metrics/CyclomaticComplexity
    def float_normalize(f)
      # special case 0
      # Note that if we allowed f to end up > .5 or == 0, we'd get the same thing
      return "+0:" if f == 0.0

      # sign
      if f >= 0
        s = "+"
      else
        s = "-"
        f = -f
      end

      # exponent
      e = 0
      while f > 1
        f /= 2
        e += 1
      end

      while f <= 0.5
        f *= 2
        e -= 1
      end

      s += "#{e}:"

      # mantissa
      raise unless f <= 1
      raise unless f > 0.5

      while f != 0.0
        if f >= 1
          s += "1"
          f -= 1
        else
          s += "0"
        end

        raise unless f < 1
        raise unless s.length < 1000
        f *= 2
      end

      s
    end
    # rubocop:enable Metrics/AbcSize
    # rubocop:enable Metrics/CyclomaticComplexity

    def obj_hash_float(f)
      if f.nan?
        hash_primitive("f", "NaN")
      elsif f.infinite?
        {a: 1}
        hash_primitive("f", f.positive? ? "Infinity" : "-Infinity")
      else
        hash_primitive("f", float_normalize(f))
      end
    end

    def obj_hash_int(i)
      hash_primitive("i", i.to_s)
    end

    def obj_hash_set(s)
      h = s.map { |e| e << digest(e) }.sort.join
      hash_primitive("s", h)
    end
  end
end

# --- Additional syntax coverage -------------------------------------------

=begin
Block comment spanning
several lines.
=end

require_relative "support/helpers"
require "json"

BEGIN { $stdout.sync = true }
END { puts "done" }

module Normalizer
  refine String do
    def squish = gsub(/\s+/, " ").strip
  end
end

using Normalizer

module Reportable
  def self.included(base) = base.extend(ClassMethods)

  module ClassMethods
    def report_fields(arg, *names, **opts)
      @report_fields ||= []
      @report_fields.concat(names.map(&:to_sym))
      opts.each { |key, value| define_method(:"report_#{key}") { value } }
    end
  end

  def to_report = self.class.instance_variable_get(:@report_fields).to_h { |f| [f, public_send(f)] }
end

class Fingerprint
  include Comparable
  include Reportable
  prepend Module.new { def digest = super.freeze }

  MAGIC = 0xDEAD_BEEF
  OCTAL = 0o755
  BINARY = 0b1010_0101
  BIG = 1_000_000
  SCIENTIFIC = 6.022e23
  RATIONAL = 3/4r
  COMPLEX = 2 + 3i
  IMAGINARY_RATIONAL = 1.5ri
  CHAR = ?A
  WORDS = %w[alpha beta gamma].freeze
  SYMBOLS = %i[sha256 sha512 md5].freeze
  PATTERN = %r{\A(?<algo>sha\d+)/(?<hex>\h{8,})\z}imx
  TEMPLATE = %Q(interpolated #{WORDS.first} with "quotes")
  LITERAL = %q(no #{interpolation} here)
  QUOTED_SYMBOL = :"with spaces"
  SHELL = `echo "$HOME"`

  SQL = <<~SQL.strip
    SELECT id, name
      FROM fingerprints
     WHERE algo = '#{SYMBOLS.first}'
  SQL

  RAW = <<-'RAW'
    nothing #{interpolated} \n here
  RAW

  @@registry = {}
  @count = 0

  attr_accessor :algo, :hex
  attr_reader :created_at
  attr_writer :label

  class << self
    attr_accessor :default_algo

    def count = @count

    def [](hex) = @@registry[hex] || new(default_algo, hex)

    def build(algo = :sha256, *rest, hex:, label: nil, **meta, &blk)
      new(algo, hex, **meta).tap do |fp|
        fp.label = label unless label.nil?
        blk&.call(fp)
        @count += 1
      end
    end
  end

  self.default_algo = :sha256

  report_fields :algo, :hex, owner: "ci"

  def initialize(algo, hex, **meta)
    @algo, @hex, @meta = algo, hex, meta
    @created_at = Time.now
    @@registry[hex] = self
  end

  def <=>(other) = [algo, hex] <=> [other.algo, other.hex]

  def digest = "#{algo}/#{hex}"

  def inspect = "#<#{self.class} #{digest} #{__method__} #{__FILE__}:#{__LINE__}>"

  def to_h = { algo:, hex: }

  def method_missing(name, *args, &block)
    if name.to_s.start_with?("meta_")
      @meta.fetch(name.to_s.delete_prefix("meta_").to_sym) { super }
    else
      super
    end
  end

  def respond_to_missing?(name, include_private = false) = name.start_with?("meta_") || super

  def classify
    case [algo, hex.length]
    in [:sha256 | :sha512 => strong, Integer => len] if len > 32
      "strong #{strong} (#{len})"
    in [:md5, _] then "weak"
    in [^(self.class.default_algo), *] then "default"
    in [Symbol => sym, *rest] unless rest.empty?
      "other #{sym}"
    else
      "unknown"
    end
  end

  def parse(input)
    case input
    in { algo: String => a, hex: String => h, **rest }
      [a.to_sym, h, rest]
    in [*, { nested: [Integer => depth, *] }, *]
      depth
    in String if input.match?(PATTERN)
      $~[:algo]
    in nil | []
      nil
    end
  end

  def verify!(attempts = 3)
    tries = 0
    begin
      tries += 1
      raise ArgumentError, "bad hex" unless hex.match?(/\A\h+\z/)
      raise IOError if tries < 2
    rescue ArgumentError => e
      warn e.message
      raise
    rescue IOError, SystemCallError
      retry if tries < attempts
    else
      :verified
    ensure
      @verified_at = Time.now
    end
  end

  private

  def normalize(str) = str.squish

  private def hidden; end
  protected def semi_hidden = nil
  alias_method :fp, :digest
  alias to_str digest
  undef hidden
end

Row = Struct.new(:id, :value, keyword_init: true) do
  def doubled = value * 2
end

Coord = Data.define(:lat, :lng) do
  def to_a = [lat, lng]
end

square = ->(x) { x * x }
add = lambda { |a, b = 1, *rest, key:, **opts, &blk| a + b }
curried = proc { |a, b| a * b }.curry
to_s = method(:format).to_proc
compose = square >> ->(n) { n + 1 } << :to_i.to_proc

result = catch(:halt) do
  [1, 2, 3].each_with_index do |n, i|
    throw :halt, n if i == 1
  end
end

totals = (1..10).step(2).map { _1 * 2 } + (1...10).select(&:even?) + (..5).to_s.chars + (1..).lazy.first(2)
squares = [1, 2, 3].map { it ** 2 }
counts = Hash.new(0).tap { |h| %w[a b a].each { |w| h[w] += 1 } }
value = ENV["HOME"]&.length || 0
value ||= 42
value &&= value.clamp(1, 100)
flag = defined?(ObjectSpace) ? ObjectSpace.each_object(Class).count : -1
label = square.(4) > 10 ? "big" : "small"
puts "skipped" unless flag.positive?
i = 0
i += 1 while i < 3
i -= 1 until i.zero?
begin
  i += 2
end while i < 10
loop do
  i -= 1
  next if i.odd?
  break if i < 2
  redo if false
end
for idx, word in %w[x y z].each_with_index
  print idx, word, "\n"
end
if i.between?(0, 5) then puts "small" elsif i > 5 then puts "big" else puts "neg" end
$global_counter = Integer("0x1f", 16) + Float("1e3").floor + Rational(1, 3).to_f.round(2)
printf("%-10s|%05.2f|%x|%08b\n", "fmt", 3.14159, 255, 5)
puts format("%<name>s is %{age}", name: "fp", age: 3)
puts "%s and %p" % ["str", :sym]
json = JSON.pretty_generate(Fingerprint.build(hex: "ab" * 16).to_h.merge(Coord.new(lat: 1.5, lng: -2.0).to_h))
Fingerprint.build(:sha512, hex: "ff" * 32, label: "x") { |fp| fp.verify!(2) }.then { |fp| fp.classify }

__END__
This is DATA, not code: #{not} interpolated
