# -*- coding: utf-8 -*-

##
# Convenience methods to use when building an `#inspect` method for
# {AX::Element} and its descendants.
#
# The module only expects three methods in order to operate:
#
#  - `#attributes` returns a list of available attributes
#  - `#attribute` returns the value of a given attribute
#  - `#size_of` returns the size for an attribute
#
module Accessibility::PPInspector

  ##
  # Create an identifier for `self` using various attributes that should
  # make it very easy to identify the element.
  #
  # @return [String]
  def pp_identifier
    # @todo Break this method up into chunks
    # @note use, or lack of use, of #inspect is intentional for visual effect

    if attributes.include? :value
      val = attribute :value
      if val.kind_of? NSString
        return " #{val.inspect}" unless val.empty?
      else
        # we assume that nil is not a legitimate value
        return " value=#{val.inspect}" unless val.nil?
      end
    end

    if attributes.include? :title
      val = attribute(:title)
      return " #{val.inspect}" if val && !val.empty?
    end

    if attributes.include? :title_ui_element
      val = attribute :title_ui_element
      return " #{val.inspect}" if val
    end

    if attributes.include? :description
      val = attribute(:description).to_s
      return " #{val}" unless val.empty?
    end

    if attributes.include? :identifier
      return " id=#{attribute(:identifier)}"
    end

    # @todo should we have other fallbacks?
    return EMPTY_STRING
  end

  ##
  # Create a string that succinctly encodes the screen coordinates
  # of `self`.
  #
  # @return [String]
  def pp_position
    position = attribute :position
    if position
      " (#{position.x}, #{position.y})"
    else
      EMPTY_STRING
    end
  end

  ##
  # Create a string that nicely presents the number of children
  # that `self` has.
  #
  # @return [String]
  def pp_children
    child_count = size_of :children
    if child_count > 1
      " #{child_count} children"
    elsif child_count == 1
      ONE_CHILD
    else # there are some odd edge cases
      ''
    end
  end

  ##
  # Create a string that looks like a labeled check box. The label
  # is the given attribute, and the check box value will be
  # determined by the value of the attribute.
  #
  # @param [Symbol]
  # @return [String]
  def pp_checkbox attr
    " #{attr}[#{attribute(attr) ? CHECKMARK : CROSS }]"
  end


  private

  ##
  # @private
  #
  # Constant string used by {#pp_checkbox}.
  #
  # @return [String]
  CHECKMARK = '✔'

  ##
  # @private
  #
  # Constant string used by {#pp_checkbox}.
  #
  # @return [String]
  CROSS = '✘'

  ##
  # @private
  #
  # Constant string used by {#pp_children}.
  #
  # @return [String]
  ONE_CHILD = ' 1 child'

  ##
  # @private
  #
  # Constant used all over the place.
  #
  # @return [String]
  EMPTY_STRING = ''
end
