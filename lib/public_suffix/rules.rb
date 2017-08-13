# = Public Suffix
#
# Domain name parser based on the Public Suffix List.
#
# Copyright (c) 2009-2017 Simone Carletti <weppos@weppos.net>

module PublicSuffix

  # A Rule is a special object which holds a single definition
  # of the Public Suffix List.
  #
  # There are 3 types of rules, each one represented by a specific
  # subclass within the +PublicSuffix::Rule+ namespace.
  #
  # To create a new Rule, use the {PublicSuffix::Rule#factory} method.
  #
  #   PublicSuffix::Rule.factory("ar")
  #   # => #<PublicSuffix::Rule::Normal>
  #
  class Rules
    def initialize
      @children = {}
      @terminus = false
      @priv = false
      @exception = false
    end

    def empty?
      @children.empty? && !@terminus
    end

    def size
      sz = @terminus ? 1 : 0
      @children.each{|k,v|sz += v.size}
      sz
    end

    def add(x, excpt, priv)
      lbl = x.shift
      if lbl.nil?
        raise 'Duplicate rule' if @terminus
        @terminus = true
        @priv = priv
        @exception = excpt
        return
      end
      @children[lbl] ||= Rules.new
      @children[lbl].add(x, excpt, priv)
    end

    def get_regdom(lbls, priv = true, matched_lbls = [])
      # Avoid modifying our input by copying it first
      lbls = lbls.dup
      lbl = lbls.shift
      if lbl.nil?
        if @terminus && (!@priv || priv)
          if @exception
            return matched_lbls
          end
          raise DomainNotAllowed, "#{matched_lbls.reverse.join(".")} is not allowed according to Registry policy"
        end
        return nil
      end
      r = @children[lbl].get_regdom(lbls, priv, matched_lbls + [lbl]) if @children.key?(lbl)
      return r if !r.nil?
      r = @children['*'].get_regdom(lbls, priv, matched_lbls + [lbl]) if @children.key?('*')
      return r if !r.nil?
      if @terminus && (!@priv || priv)
        return matched_lbls if @exception
        return matched_lbls + [lbl]
      end
      nil
    end
  end
end
