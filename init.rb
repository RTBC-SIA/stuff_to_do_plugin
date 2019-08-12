# -*- encoding: utf-8 -*-
#
require 'redmine'

# Patches to the Redmine core.
# Including dispatcher.rb in case of Rails 2.x
require 'dispatcher' unless Rails::VERSION::MAJOR >= 3

# Rails 5.1/Rails 4
reloader = defined?(ActiveSupport::Reloader) ? ActiveSupport::Reloader : ActionDispatch::Reloader
if Rails::VERSION::MAJOR < 3
  Dispatcher.to_prepare do
    require 'stuff_to_do_dispatch'
  end
else
  reloader.to_prepare do
    require 'stuff_to_do_dispatch'
  end
end

# This is the important line.
# It requires the file in lib/stuff_to_do_plugin/hooks.rb
require_dependency 'stuff_to_do_plugin/hooks'

Redmine::Plugin.register :stuff_to_do_plugin do
  name 'Stuff To Do Plugin'
  author 'Eric Davis, Steffen Schüssler'
  url 'https://github.com/neffets/redmine-stuff-to-do-plugin'
  author_url 'https://github.com/neffets'
  description "The Stuff To Do plugin allows a user to order and prioritize the issues they are doing into a specific order. It will also allow other privilged users to reorder the user's workload. compatible redmine 2.x - 4.x"
  version '0.7.0'

  requires_redmine version_or_higher: '2.0.0'

  settings(partial: 'settings/stuff_to_do_settings',
           default: {
             'use_as_stuff_to_do': '0',
             'threshold': '-1',
             'email_to': 'example1@example.com,example2@example.com',
             'use_time_grid': '0',
             'statuses_for_stuff_to_do': ['all']
           })

  project_module :stuff_to_do do
    permission :view_stuff_to_do, {stuff_to_do: :index}
    permission :view_others_stuff_to_do, {stuff_to_do: :index}
    permission :view_all_users_stuff_to_do, {stuff_to_do: :index}
    permission :manage_stuff_to_do_reportees, {stuff_to_do: :index}
    permission :view_all_reportee_issues, {stuff_to_do: :index }
    permission :view_all_reportee_stuff_to_do, {stuff_to_do: :index }
  end

  menu(:top_menu, :stuff_to_do, { controller: 'stuff_to_do', action: 'index'}, caption: :stuff_to_do_title, if: Proc.new{
    User.current.allowed_to?({ controller: 'stuff_to_do', action: 'index'}, nil, global: true) && !User.current.nil? && User.current.pref[:stuff_to_do_enabled]
  })

end
