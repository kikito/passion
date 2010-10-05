require('passion/oop/init')

context( 'Beholder', function()

  context('When included by a class', function()

    local MyClass = class('MyClass')
    
    function MyClass:initialize()
      super.initialize(self)
      self.counter = 0
    end
    
    function MyClass:count(increment)
      self.counter = self.counter + increment
    end
    
    function MyClass:count2(increment)
      self.counter = self.counter + increment
    end

    test('Should not throw errors', function()
      assert_not_error(function() MyClass:include(Beholder) end)
    end)
    
    context('When starting observing', function()

      test('It should allow calling of methods by name, with parameters', function()
        local obj = MyClass:new()
        obj:observe('event1', 'count', 1)
        Beholder.trigger('event1')
        assert_equal(obj.counter, 1)
      end)
      
      test('It should allow calling of methods by function, with parameters', function()
        local obj = MyClass:new()
        obj:observe('event2', function(myself, increment) myself:count(increment) end, 1)
        Beholder.trigger('event2')
        assert_equal(obj.counter, 1)
      end)
      
      test('It should allow chaining of calls', function()
        local obj = MyClass:new()
        obj:observe('event3', 'count', 1)
        obj:observe('event3', 'count', 1)
        Beholder.trigger('event3')
        assert_equal(obj.counter, 2)
      end)

    end)
    
    context('When stopping observing', function()
    
      test('It should allow completely stopping observing one event', function()
        local obj = MyClass:new()
        obj:observe('event4', 'count', 1)
        Beholder.trigger('event4')
        obj:stopObserving('event4')
        Beholder.trigger('event4')
        assert_equal(obj.counter, 1)
      end)
      
      test('It should allow stopping observing individual actions on one event', function()
        local obj = MyClass:new()
        obj:observe('event5', 'count', 1)
        obj:observe('event5', 'count2', 1)
        Beholder.trigger('event5')
        obj:stopObserving('event5', 'count')
        Beholder.trigger('event5')
        assert_equal(obj.counter, 3)
      end)
    
    end)
    
    context('When using tables as event ids', function()
      
      local obj
      before(function()
        obj = MyClass:new()
      end)
      
      test('It should allow observing table events', function()
        obj:observe({'event6', 1}, 'count', 1)
        Beholder.trigger({'event6', 1})
        assert_equal(obj.counter, 1)
      end)
      
      test('1-element registration should be triggered with non-table events', function()
        obj:observe({'event7'}, 'count', 1)
        Beholder.trigger('event7')
        assert_equal(obj.counter, 1)
      end)
      
      test('Non-table registrations should be triggered with 1-element tables', function()
        obj:observe('event8', 'count', 1)
        Beholder.trigger({'event8'})
        assert_equal(obj.counter, 1)
      end)
      
      test('Different tables should not trigger other table-based actions', function()
        obj:observe({'event9', 'foo'}, 'count', 1)
        Beholder.trigger({'event9', 'foo'}) -- should trigger
        Beholder.trigger({'event9', 'bar'}) -- should not trigger
        assert_equal(obj.counter, 1)
      end)
      
     
      
      
      
    end)

  end)

end)
