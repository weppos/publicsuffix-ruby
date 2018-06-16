# = Public Suffix
#
# Domain name parser based on the Public Suffix List.
#
# Copyright (c) 2009-2018 Simone Carletti <weppos@weppos.net>

module PublicSuffix

  # A {PublicSuffix::List} is a collection of one
  # or more {PublicSuffix::Rule}.
  #
  # Given a {PublicSuffix::List},
  # you can add or remove {PublicSuffix::Rule},
  # iterate all items in the list or search for the first rule
  # which matches a specific domain name.
  #
  #   # Create a new list
  #   list =  PublicSuffix::List.new
  #
  #   # Push two rules to the list
  #   list << PublicSuffix::Rule.factory("it")
  #   list << PublicSuffix::Rule.factory("com")
  #
  #   # Get the size of the list
  #   list.size
  #   # => 2
  #
  #   # Search for the rule matching given domain
  #   list.find("example.com")
  #   # => #<PublicSuffix::Rule::Normal>
  #   list.find("example.org")
  #   # => nil
  #
  # You can create as many {PublicSuffix::List} you want.
  # The {PublicSuffix::List.default} rule list is used
  # to tokenize and validate a domain.
  #
  class List

    DEFAULT_LIST_PATH = File.expand_path("../../data/list.txt", __dir__)

    # Gets the default rule list.
    #
    # Initializes a new {PublicSuffix::List} parsing the content
    # of {PublicSuffix::List.default_list_content}, if required.
    #
    # @return [PublicSuffix::List]
    def self.default(**options)
      @default ||= parse(File.read(DEFAULT_LIST_PATH), options)
    end

    # Sets the default rule list to +value+.
    #
    # @param  value [PublicSuffix::List] the new list
    # @return [PublicSuffix::List]
    def self.default=(value)
      @default = value
    end

    # Parse given +input+ treating the content as Public Suffix List.
    #
    # See http://publicsuffix.org/format/ for more details about input format.
    #
    # @param  string [#each_line] the list to parse
    # @param  private_domains [Boolean] whether to ignore the private domains section
    # @return [PublicSuffix::List]
    def self.parse(input, private_domains: true)
      comment_token = "//".freeze
      private_token = "===BEGIN PRIVATE DOMAINS===".freeze
      space_re = /\p{Space}/
      section = nil # 1 == ICANN, 2 == PRIVATE

      new do |list|
        input.each_line do |line|
          line.strip!
          case # rubocop:disable Style/EmptyCaseCondition

          # skip blank lines
          when line.empty?
            next

          # include private domains or stop scanner
          when line.include?(private_token)
            break if !private_domains
            section = 2

          # skip comments
          when line.start_with?(comment_token)
            next

          else
            rule = line.split(space_re).first
            list.add(rule, private: section == 2)

          end
        end
      end
    end


    # Initializes an empty {PublicSuffix::List}.
    #
    # @yield [self] Yields on self.
    # @yieldparam [PublicSuffix::List] self The newly created instance.
    def initialize
      @rules = Rules.new
      add('*', private: false)
      yield(self) if block_given?
    end

    # Adds the given object to the list and optionally refreshes the rule index.
    #
    # @param  rule [PublicSuffix::Rule::*] the rule to add to the list
    # @return [self]
    def add(rule, private: false)
      exception = false
      if rule[0] == BANG
        exception = true
        rule = rule[1..-1]
      end
      lbls = rule.split(DOT).reverse
      @rules.add(lbls, exception, private)
      self
    end
    alias << add

    # Gets the number of rules in the list.
    #
    # @return [Integer]
    def size
      @rules.size
    end

    # Checks whether the list is empty.
    #
    # @return [Boolean]
    def empty?
      @rules.empty?
    end

    # Removes all rules.
    #
    # @return [self]
    def clear
      @rules = Rules.new
      self
    end

    # Finds and returns the rule corresponding to the longest public suffix for the hostname.
    #
    # @param  name [#to_s] the hostname
    # @param  default [PublicSuffix::Rule::*] the default rule to return in case no rule matches
    # @return [PublicSuffix::Rule::*]
    def find(name, ignore_private: false)
      lbls = name.split(DOT).reverse
      r = @rules.get_regdom(lbls, !ignore_private)
      r.reverse[1..-1].join(DOT)
    end

    # Gets the default rule.
    #
    # @see PublicSuffix::Rule.default_rule
    #
    # @return [PublicSuffix::Rule::*]
    def default_rule
      '*'
    end
  end
end
