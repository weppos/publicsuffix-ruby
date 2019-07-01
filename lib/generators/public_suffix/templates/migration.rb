# frozen_string_literal: true

class CreateDomainSuffixes < ActiveRecord::Migration<%= migration_version %>
  def change
    create_table :domain_suffixes do |t|
      t.string :name,              null: false, default: ""
      t.boolean :private, null: false, default: false

      t.timestamps null: false
    end

    add_index :domain_suffixes, :name,                unique: true
  end
end
