= tastymenu

== DESCRIPTION:

tastymenu adds a helper method for generating menus (could be dropdown, etc, depending on your CSS/Javascript).
Please note that this plugin borrows heavily from obrie's http://github.com/pluginaweek/menu_helper/.
 
== INSTALLATION: 

 $ gem sources -a http://gems.github.com/ (if you havn't already, which is unlikely)
 $ gem install ienders-tastymenu
 
== USAGE:

In say, your main layout erb file:

   tastymenu do |main|
     main.menu :users
     main.menu :orders
     main.menu :about do |about|
       about.menu :faq, '/faq'
       about.menu :contact_us
     end
     main.menu :search, 'Search!', 'http://www.google.com', :class => 'search'
   end