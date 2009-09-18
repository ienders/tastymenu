module Tastymenu
  class Course
    include ActionView::Helpers::TagHelper
    
    attr_reader :request_controller, :parent_menu, :menus
    delegate :[], :[]=, :to => '@html_options'
    
    def initialize(request_controller, parent_menu, html_options = {})
      @html_options = html_options.symbolize_keys
      @parent_menu = parent_menu
      @request_controller = request_controller
      @menus = []
      self[:class] = "#{self[:class]} menu menu-#{level}".strip
      yield self if block_given?
    end
    
    def level
      @level ||= begin
        level = 1
        menu = parent_menu
        while menu
          level += 1
          menu = menu.parent_menu
        end
        level
      end
    end
    
    def selected?
      @parent_menu && menus.any? {|menu| menu.selected?}
    end
    
    def menu(name, url_options = {}, html_options = {}, &block)
      menu = Tastymenu::Item.new(self, name, url_options, html_options, &block)
      @menus << menu
      menu
    end
    
    def html
      html_options = @html_options.dup
      html_options[:class] = "#{html_options[:class]} selected".strip if selected?
      content_tag('ul',
        @menus.inject('') {|html, menu| html << menu.html(@menus.last == menu) },
        html_options
      )
    end
  end
end
