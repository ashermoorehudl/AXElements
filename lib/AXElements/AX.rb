module AX

  class << self

    end

    # Like {#const_get} except that if the class does not exist yet then
    # it will create the class for you. If not used carefully, you could end
    # up creating a bunch of useless, possibly harmful, classes at run time.
    # @param [#to_sym] const the value you want as a constant
    # @return [Class] a reference to the class being looked up
    def new_const_get const
      if const_defined? const
        const_get const
      else
        create_ax_class const
      end
    end

    # @todo consider using the rails inflector
    # Chomps off a trailing 's' if there is one and then looks up the constant.
    # @param [#to_s] const
    # @return [Class,nil] the class if it exists, else returns nil
    def plural_const_get const
      const = const.to_s.chomp 's'
      if const_defined? const
        const_get const
      else
        nil
      end
    end

    # Creates new class at run time. This method is called for each
    # type of UI element that has not yet been explicitly defined.
    # @param [#to_sym] class_name
    # @return [Class]
    def create_ax_class class_name
      klass = Class.new Element do
        AX.log.debug "#{class_name} class created"
      end
      Object.const_set class_name.to_sym, klass
    end

    # Finds the current mouse position and then calls {#element_at_position}.
    # @return [AX::Element]
    def element_under_mouse
      position = carbon_point_from_cocoa_point NSEvent.mouseLocation
      element_at_position position
    end

    # This will give you the UI element located at the position given (if
    # there is one). If more than one element is at the position then the
    # z-order of the elements will be used to determine which is "on top".
    # @param [CGPoint] point
    # @return [AX::Element]
    def element_at_position point
      element  = Pointer.new '^{__AXUIElement}'
      AXUIElementCopyElementAtPosition(SYSTEM.ref, point.x, point.y, element)
      make_element element[0]
    end


    private

    # Take a point that uses the bottom left of the screen as the origin
    # and returns a point that uses the top left of the screen as the
    # origin.
    # @param [CGPoint] point screen position in Cocoa screen coordinates
    # @return [CGPoint]
    def carbon_point_from_cocoa_point point
      carbon_point = CGPointZero
      NSScreen.screens.each { |screen|
        if NSPointInRect(point, screen.frame)
          height       = screen.frame.size.height
          carbon_point = CGPoint.new point.x, (height - point.y - 1)
        end
      }
      carbon_point
    end


  end


  # @return [AX::SystemWide]
  SYSTEM = Element.make_element AXUIElementCreateSystemWide()

  # @return [AX::Application] the Mac OS X dock application
  DOCK = Application.application_with_bundle_identifier 'com.apple.dock'

end
