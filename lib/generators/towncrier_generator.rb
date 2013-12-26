class TowncrierGenerator < Rails::Generators::Base
  include Rails::Generators::Migration

  def self.next_migration_number(dirname)
    next_migration_number = current_migration_number(dirname) + 1
    ActiveRecord::Migration.next_migration_number(next_migration_number)
  end

  desc "This generator sets up the Towncrier gem"
  source_root File.expand_path("../templates", __FILE__)

  def copy_files
    copy_file "towncrier.yml", "config/towncrier.yml"
    copy_file "towncry.rb", "app/models/towncry.rb"
    empty_directory "app/criers"
    migration_template "create_towncries_table.rb", "db/migrate/create_towncries_table.rb"
  end

end