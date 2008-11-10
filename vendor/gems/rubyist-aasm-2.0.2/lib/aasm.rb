require File.join(File.dirname(__FILE__), 'event')
require File.join(File.dirname(__FILE__), 'state')
require File.join(File.dirname(__FILE__), 'state_machine')
require File.join(File.dirname(__FILE__), 'persistence')

module AASM
  class InvalidTransition < Exception
  end
  
  def self.included(base) #:nodoc:
    # TODO - need to ensure that a machine is being created because
    # AASM was either included or arrived at via inheritance.  It
    # cannot be both.
    base.extend AASM::ClassMethods
    AASM::Persistence.set_persistence(base)
    AASM::StateMachine[base] = AASM::StateMachine.new('')

    base.class_eval do
      def base.inherited(klass)
        AASM::StateMachine[klass] = AASM::StateMachine[self].dup
      end
    end
  end

  module ClassMethods
    def aasm_initial_state(set_state=nil)
      if set_state
        AASM::StateMachine[self].initial_state = set_state
      else
        AASM::StateMachine[self].initial_state
      end
    end
    
    def aasm_initial_state=(state)
      AASM::StateMachine[self].initial_state = state
    end
    
    def aasm_state(name, options={})
      sm = AASM::StateMachine[self]
      sm.create_state(name, options)
      sm.initial_state = name unless sm.initial_state

      define_method("#{name.to_s}?") do
        aasm_current_state == name
      end
    end
    
    def aasm_event(name, options = {}, &block)
      sm = AASM::StateMachine[self]
      
      unless sm.events.has_key?(name)
        sm.events[name] = AASM::SupportingClasses::Event.new(name, options, &block)
      end

      define_method("#{name.to_s}!") do |*args|
        aasm_fire_event(name, true, *args)
      end

      define_method("#{name.to_s}") do |*args|
        aasm_fire_event(name, false, *args)
      end
    end

    def aasm_states
      AASM::StateMachine[self].states
    end

    def aasm_events
      AASM::StateMachine[self].events
    end
    
    def aasm_states_for_select
      AASM::StateMachine[self].states.map { |state| state.for_select }
    end
    
  end

  # Instance methods
  def aasm_current_state
    return @aasm_current_state if @aasm_current_state

    if self.respond_to?(:aasm_read_state) || self.private_methods.include?('aasm_read_state')
      @aasm_current_state = aasm_read_state
    end
    return @aasm_current_state if @aasm_current_state
    self.class.aasm_initial_state
  end

  def aasm_events_for_current_state
    aasm_events_for_state(aasm_current_state)
  end

  def aasm_events_for_state(state)
    events = self.class.aasm_events.values.select {|event| event.transitions_from_state?(state) }
    events.map {|event| event.name}
  end

  private
  def aasm_current_state_with_persistence=(state)
    if self.respond_to?(:aasm_write_state) || self.private_methods.include?('aasm_write_state')
      aasm_write_state(state)
    end
    self.aasm_current_state = state
  end

  def aasm_current_state=(state)
    if self.respond_to?(:aasm_write_state_without_persistence) || self.private_methods.include?('aasm_write_state_without_persistence')
      aasm_write_state_without_persistence(state)
    end
    @aasm_current_state = state
  end

  def aasm_state_object_for_state(name)
    self.class.aasm_states.find {|s| s == name}
  end

  def aasm_fire_event(name, persist, *args)
    aasm_state_object_for_state(aasm_current_state).call_action(:exit, self)

    new_state = self.class.aasm_events[name].fire(self, *args)
    
    unless new_state.nil?
      aasm_state_object_for_state(new_state).call_action(:enter, self)
      
      if self.respond_to?(:aasm_event_fired)
        self.aasm_event_fired(self.aasm_current_state, new_state)
      end

      if persist
        self.aasm_current_state_with_persistence = new_state
        self.send(self.class.aasm_events[name].success) if self.class.aasm_events[name].success
      else
        self.aasm_current_state = new_state
      end

      true
    else
      if self.respond_to?(:aasm_event_failed)
        self.aasm_event_failed(name)
      end
      
      false
    end
  end
end
