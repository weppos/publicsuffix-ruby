# frozen_string_literal: true

require 'rails/generators/base'

module PublicSuffix
	module Generators
		class InstallGenerator <Rails::Generators::Base
			include ActiveRecord::Generators::Migration
			source_root File.expand_path('templates',__dir__)
			def generate_migration
				migration_template "migration.rb", "db/migrate/create_domain_suffixes.rb", migration_version: migration_version
			end
			def generate_model
				invoke "active_record:model",["DomainSuffix"],migration: false
			end
			def migration_version
				if rails5_and_up?
					"[#{Rails::VERSION::MAJOR}.#{Rails::VERSION::MINOR}]"
				end
			end
			def rails5_and_up?
				Rails::VERSION::MAJOR >= 5
			end
			def generate_rake
				copy_file "populate_domain_suffix.rake", "lib/tasks/populate_domain_suffix.rake"
			end
			def generate_configuration
				copy_file "config.rb","config/initializers/public_suffix.rb"
			end
		end
	end
end