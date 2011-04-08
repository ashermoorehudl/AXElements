class TestAXRawAttrOfElement < MiniTest::Unit::TestCase
  def test_returns_raw_values
    ret = AX.raw_attr_of_element(DOCK, KAXChildrenAttribute)
    assert CFGetTypeID(ret) == CFArrayGetTypeID()
  end
  def test_returns_nil_for_non_existant_attributes
    AX.log.level = Logger::DEBUG
    assert_nil AX.raw_attr_of_element(DOCK, 'MADEUPATTRIBUTE')
    AX.log.level = Logger::WARN
    assert_match /#{KAXErrorAttributeUnsupported}/, @log_output.string
  end
end

# @todo this is a bit too invasive
# class TestAXRawParamAttrOfElement < MiniTest::Unit::TestCase
# end

class TestAXAttrOfElement < MiniTest::Unit::TestCase
  def test_does_not_return_raw_values
    ret = AX.attr_of_element(DOCK, KAXChildrenAttribute)
    assert_kind_of AX::Element, ret.first
  end
end

class TestAXProcessAXData < MiniTest::Unit::TestCase
  def test_works_with_nil_values
    ret = AX.raw_attr_of_element(DOCK, KAXFocusedUIElementAttribute)
    assert_nil AX.process_ax_data(ret)
  end
  def test_works_with_boolean_false
    ret = AX.raw_attr_of_element(DOCK, 'AXEnhancedUserInterface')
    assert_equal false, AX.process_ax_data(ret)
  end
  # @todo
  # def test_works_with_boolean_true
  # end
  def test_works_with_a_new_element
    mb  = AX.raw_attr_of_element(FINDER, KAXMenuBarAttribute)
    ret = AX.process_ax_data(mb)
    assert_instance_of AX::MenuBar, ret
  end
  def test_works_with_array_of_elements
    ret = AX.raw_attr_of_element(DOCK, KAXChildrenAttribute).first
    assert_kind_of AX::Element, AX.process_ax_data(ret)
  end
  # @todo this type takes a few steps to get to
  #  def test_works_with_a_number
  #  end
  # @todo this type exists in the documentation but is not easy to find
  #  def test_works_with_array_of_numbers
  #  end
  def test_works_with_a_size
    mb  = AX.raw_attr_of_element(FINDER, KAXMenuBarAttribute)
    ret = AX.raw_attr_of_element(mb, KAXSizeAttribute)
    assert_instance_of CGSize, AX.process_ax_data(ret)
  end
  def test_works_with_a_point
    menu_bar = AX.raw_attr_of_element(FINDER, KAXMenuBarAttribute)
    ret = AX.raw_attr_of_element(menu_bar, KAXPositionAttribute)
    assert_instance_of CGPoint, AX.process_ax_data(ret)
  end
  # @todo this type takes a few steps to get to
  # def test_works_with_a_range
  # end
  # @todo this type takes a few steps to get to
  # def test_works_with_a_rect
  # end
  def test_works_with_strings
    ret = AX.raw_attr_of_element(DOCK, KAXTitleAttribute)
    assert_kind_of NSString, AX.process_ax_data(ret)
  end
end

class TestAXPluralConstGet < MiniTest::Unit::TestCase
  def test_finds_things_that_are_not_pluralized
    refute_nil AX.plural_const_get( 'Application' )
  end
  def test_finds_things_that_are_pluralized_with_an_s
    refute_nil AX.plural_const_get( 'Applications' )
  end
  def test_returns_nil_if_the_class_does_not_exist
    assert_nil AX.plural_const_get( 'NonExistant' )
  end
end

class TestAXElementUnderMouse < MiniTest::Unit::TestCase
  def test_returns_some_kind_of_ax_element
    assert_kind_of AX::Element, AX.element_under_mouse
  end
  # @todo need to manipulate the mouse and put it in some
  #       well known locations and make sure I get the right
  #       element created
end

class TestAXElementAtPosition < MiniTest::Unit::TestCase
  def test_returns_a_menubar_for_coordinates_10_0
    item = AX.element_at_position( CGPoint.new(10, 0) )
    assert_instance_of AX::MenuBarItem, item
  end
end

class TestAXHierarchy < MiniTest::Unit::TestCase
  ITEM = AX::DOCK.list.application_dock_item
  RET  = AX.hierarchy( ITEM )
  def test_returns_array_of_elements
    assert_instance_of Array, RET
    assert_kind_of     AX::Element, RET.first
  end
  def test_correctness
    assert_equal 3, RET.size
    assert_instance_of AX::ApplicationDockItem, RET.first
    assert_instance_of AX::List,                RET.second
    assert_instance_of AX::Application,         RET.third
  end
end

class TestAXAttrsOfElement < MiniTest::Unit::TestCase
  def setup; @attrs = AX.attrs_of_element(DOCK); end
  def test_returns_array_of_strings
    assert_instance_of String, @attrs.first
  end
  def test_make_sure_certain_attributes_are_present
    assert @attrs.include?(KAXRoleAttribute)
    assert @attrs.include?(KAXChildrenAttribute)
    assert @attrs.include?(KAXTitleAttribute)
  end
end

# @todo this requires me to be more invasive
# class TestAXParamAttrsOfElement < MiniTest::Unit::TestCase
#   def test_returns_array_if_element_has_param_attributes
#   end
#   def test_make_sure_certain_attributes_are_present
#   end
# end

class TestAXActionsOfElement < MiniTest::Unit::TestCase
  def test_works_when_there_are_no_actions
    assert_empty AX.actions_of_element(DOCK)
  end
  def test_returns_array_of_strings
    list = AX.raw_attr_of_element(DOCK,KAXChildrenAttribute).first
    app  = AX.raw_attr_of_element(list,KAXChildrenAttribute).first
    assert_instance_of String, AX.actions_of_element(app).first
  end
  def test_make_sure_certain_actions_are_present
    list = AX.raw_attr_of_element(DOCK,KAXChildrenAttribute).first
    app  = AX.raw_attr_of_element(list,KAXChildrenAttribute).first
    actions = AX.actions_of_element(app)
    assert actions.include?(KAXPressAction)
    assert actions.include?(KAXShowMenuAction)
  end
end

class TestAXLogAXCall < MiniTest::Unit::TestCase
  def setup; super; AX.log.level = Logger::DEBUG; end
  def teardown; AX.log.level = Logger::WARN; end
  def test_code_is_returned
    assert_equal KAXErrorIllegalArgument, AX.log_ax_call(DOCK, KAXErrorIllegalArgument)
    assert_equal KAXErrorAPIDisabled, AX.log_ax_call(DOCK, KAXErrorAPIDisabled)
    assert_equal KAXErrorSuccess, AX.log_ax_call(DOCK, KAXErrorSuccess)
  end
  def test_logs_nothing_for_success_case
    AX.log_ax_call(DOCK, KAXErrorSuccess)
    assert_empty @log_output.string
  end
  def test_looks_up_code_properly
    AX.log_ax_call(DOCK, KAXErrorAPIDisabled)
    assert_match /API Disabled/, @log_output.string
    AX.log_ax_call(DOCK, KAXErrorNotImplemented)
    assert_match /Not Implemented/, @log_output.string
  end
end