require 'tastymenu/course'
require 'tastymenu/item'

module Tastymenu
  def tastymenu(html_options = {}, &block)
    Tastymenu::Course.new(@controller, nil, html_options, &block).html
  end
end

ActionController::Base.class_eval do
  helper Tastymenu
end
