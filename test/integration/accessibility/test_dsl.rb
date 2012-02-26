# -*- coding: utf-8 -*-
# Functional and system tests for AXElements

class TestAccessibilityDSL < MiniTest::Unit::TestCase
  include Accessibility::Core

  # LSP FTW
  class DSL
    include Accessibility::DSL
  end

  class LanguageTest < AX::Element
    attr_reader :called_action
    def actions=  value; @actions       = value;  end
    def perform  action; @called_action = action; end
  end

  def dsl
    @dsl ||= DSL.new
  end

  def element
    @element ||= LanguageTest.new REF, attrs_for(REF)
  end

  def app
    @@app ||= AX::Application.new REF, attrs_for(REF)
  end

  def text_area
    @@text_area ||= app.main_window.text_area
  end

  def test_static_actions
    def static_action action
      dsl.send action, element
      assert_equal action, element.called_action
    end

    static_action :press
    static_action :show_menu
    static_action :pick
    static_action :decrement
    static_action :confirm
    static_action :increment
    static_action :delete
    static_action :cancel
    static_action :hide
    static_action :unhide
    static_action :terminate
    static_action :raise
  end

  def test_method_missing_forwards
    element.actions = ['AXPurpleRain']
    dsl.purple_rain element
    assert_equal :purple_rain, element.called_action

    assert_raises NoMethodError do
      dsl.hack element
    end
    assert_raises NoMethodError do
      dsl.purple_rain 'A string'
    end
  end

  def test_raise_can_still_raise_exception
    assert_raises ArgumentError do
      dsl.raise ArgumentError
    end
    assert_raises NoMethodError do
      dsl.raise NoMethodError
    end
  end

  def try_typing string, expected = nil
    expected = string unless expected
    text_area.set :focused, to: true
    dsl.type string
    assert_equal expected, text_area.value
  ensure # reset for next test
    dsl.type "\\COMMAND+a \b"
  end

  def test_typing_human_string
    try_typing(
     "A sentence, with punctuation and num8ers. LOL!\tA 'quoted' string--then some @#*$."
    )
  end

  def test_typing_backspaces
    try_typing "The cake is a lie!\b\b\b\bgift!", 'The cake is a gift!'
  end

  def test_typing_hotkeys
    try_typing ", world!\\CONTROL+a Hello", 'Hello, world!'
    try_typing "MacRuby\\OPTION+2",         'MacRuby™'
  end

  def test_typing_command_keys
    try_typing "Hai.\\<- \\<- \b", "Hi."
  end

  def test_typing_ruby_escapes
    try_typing "First.\nSecond."
  end

  def test_dsl_is_mixed_into_toplevel
    assert_includes Object.new.class.ancestors, Accessibility::DSL
  end

  def test_system_wide
    assert_instance_of AX::SystemWide, dsl.system_wide
  end

  def test_element_under_mouse
    [
      app.main_window.close_button,
      app.main_window.value_indicator
    ].each do |element|
      move_mouse_to element
      assert_equal element, dsl.element_under_mouse
    end
  end

  def test_element_at_point
    [
      app.main_window.minimize_button,
      app.main_window.increment_arrow
    ].each do |element|
      assert_equal element, dsl.element_at_point(element.to_point, for: app)
    end
  end

  def test_show_about_window
    dialog = dsl.show_about_window_for app
    assert_instance_of AX::Dialog, dialog
    assert_equal 'AXElementsTester icon', dialog.image.description
  ensure
    press dialog.close_button if dialog
  end

  def test_show_prefs_for_app
    prefs = dsl.show_preferences_window_for app
    assert_kind_of AX::Window, prefs
    assert_equal 'Preferences', prefs.title
  ensure
    press prefs.close_button if prefs
  end

  def test_scroll_to
    table = app.main_window.table
    ['AXIsNyan', 'AXSubrole'].each do |attr|
      text = table.text_field(value: attr)
      dsl.scroll_to text
      assert NSContainsRect(table.bounds, text.bounds)
    end
  end

end