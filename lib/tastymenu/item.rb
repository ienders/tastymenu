module Tastymenu
  class Item
    include ActionView::Helpers::TagHelper
    include ActionView::Helpers::UrlHelper
    
    attr_reader :name, :url_options, :parent_menu_bar
    
    delegate :request_controller, :parent_menu, :level, :to => :parent_menu_bar
    delegate :menu, :to => '@sub_items'
    delegate :[], :[]=, :to => '@html_options'
    
    def initialize(parent_menu_bar, name, url_options = {}, html_options = {})      
      @options = html_options.slice(:link)
      html_options.except!(:link)
      
      @html_options = html_options.symbolize_keys
      @parent_menu_bar = parent_menu_bar
      @name = name.to_s
      @controller = request_controller
      
      @content = content_tag(:span, @name.underscore.titleize)
      
      url, @url_options = build_url(url_options)
      @content = link_to(@content, url) if @options[:link] != false
      
      id_prefix = parent_menu_bar[:id] || parent_menu && parent_menu[:id]
      self[:id] ||= "#{id_prefix}-#{@name}" if id_prefix
      self[:class] = "#{self[:class]} menuitem menuitem-#{level}".strip
      
      @sub_items = Tastymenu::Course.new(request_controller, self)
      yield @sub_items if block_given?
    end
    
    def selected?
      current_page?(url_options) || @sub_items.selected?
    end
    
    def html(last = false)
      html_options = @html_options.dup
      html_options[:class] = "#{html_options[:class]} selected".strip if selected?
      html_options[:class] = "#{html_options[:class]} last".strip if last      
      content = @content
      if @sub_items.menus.any?
        content << @sub_items.html
      end
      content_tag('li', content, html_options)
    end
    
    private
    def build_url(options = {})
      if options.blank? && route_options = (named_route(name) || named_route(name, false))
        options = route_options
      elsif options.is_a?(Hash)
        options[:controller] ||= controller(options)
        options[:action] ||= name unless options[:controller] == name
        options[:only_path] ||= false
      end
      
      url = options.is_a?(Hash) ? url_for(options) : options
      return url, options
    end
    
    def controller(options)
      options[:controller] ||
        (begin; "#{name.camelize}Controller".constantize.controller_path; rescue; end) ||
        parent_menu && parent_menu.url_options[:controller] ||
        request_controller.class.controller_path
    end
    
    def named_route(name, include_parent = true)
      name = "#{parent_menu.name}_#{name}" if parent_menu && include_parent
      method_name = "hash_for_#{name}_url"  
      request_controller.send(method_name) if request_controller.respond_to?(method_name)
    end
  end
end
