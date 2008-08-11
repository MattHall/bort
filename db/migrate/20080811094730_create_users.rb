class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
      t.string :login, :limit => 40
      t.string :name, :limit => 100, :default => '', :null => true
      t.string :email, :limit => 100
      t.string :crypted_password, :limit => 40
      t.string :salt, :limit => 40
      t.string :remember_token, :limit => 40
      t.string :activation_code, :limit => 40
      t.string :state, :null => :no, :default => 'passive'
      t.datetime :remember_token_expires_at
      t.datetime :activated_at
      t.datetime :deleted_at
      t.timestamps
    end
    add_index :users, :login, :unique => true
  end

  def self.down
    drop_table :users
  end
end
