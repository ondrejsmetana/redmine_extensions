require 'redmine_extensions/patch_manager'

module RedmineExtensions
  class Engine < ::Rails::Engine

    def self.automount!(path = nil)
      engine = self
      path ||= engine.to_s.underscore.split('/').first
      Rails.application.routes.draw do
        mount engine => path
      end
    end

    config.generators do |g|
      g.test_framework      :rspec,        :fixture => false
      g.fixture_replacement :factory_girl, :dir => 'spec/factories'
      g.assets false
      g.helper false
    end

    config.autoload_paths << config.root.join('lib')
    config.eager_load_paths << config.root.join('app', 'models', 'easy_queries')

    config.to_prepare do
      RedmineExtensions::QueryOutput.register_output :table, RedmineExtensions::QueryOutputs::TableOutput
      ApplicationController.send :include, RedmineExtensions::RailsPatches::ControllerQueryHelpers
      ApplicationController.send :include, RedmineExtensions::RenderingHelper
    end

    initializer 'redmine_extensions.initialize_environment' do |app|
      ActionDispatch::Routing::RouteSet::Generator.send(:include, RedmineExtensions::RailsPatches::RouteSetGeneratorPatch)
    end

    initializer 'redmine_extensions.append_migrations' do |app|
      unless app.root.to_s.match root.to_s
        config.paths['db/migrate'].expanded.each do |expanded_path|
          app.config.paths['db/migrate'] << expanded_path
        end
      end
    end

    initializer 'redmine_extensions.initialize_easy_plugins', after: :load_config_initializers do
      RedmineExtensions.load_easy_plugins

      unless Redmine::Plugin.installed?(:easy_extensions)
        ActiveSupport.run_load_hooks(:easyproject, self)
      end
    end

    # include helpers
    initializer 'redmine_extensions.action_controller' do |app|
      ActiveSupport.on_load :action_controller do
        helper RedmineExtensions::ApplicationHelper
      end
    end

    # initializer :add_html_formatting do |app|
    #   require "redmine_extensions/html_formatting"
    #   Redmine::WikiFormatting.register(:HTML, RedmineExtensions::HTMLFormatting::Formatter, RedmineExtensions::HTMLFormatting::Helper)
    # end

  end
end
