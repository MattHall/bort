class BortMigration < ActiveRecord::Migration
  def self.up
    # Create Sessions Table
    create_table :sessions do |t|
      t.string :session_id, :null => false
      t.text :data
      t.timestamps
    end

    add_index :sessions, :session_id
    add_index :sessions, :updated_at
    
    # Create OpenID Tables
    create_table :open_id_authentication_associations, :force => true do |t|
      t.integer :issued, :lifetime
      t.string :handle, :assoc_type
      t.binary :server_url, :secret
    end

    create_table :open_id_authentication_nonces, :force => true do |t|
      t.integer :timestamp, :null => false
      t.string :server_url, :null => true
      t.string :salt, :null => false
    end
    
    # Create Users Table
    create_table :users do |t|
      t.string :login, :limit => 40
      t.string :identity_url      
      t.string :name, :limit => 100, :default => '', :null => true
      t.string :email, :limit => 100
      t.string :crypted_password, :limit => 40
      t.string :salt, :limit => 40
      t.string :remember_token, :limit => 40
      t.string :activation_code, :limit => 40
      t.string :state, :null => false, :default => 'passive'      
      t.datetime :remember_token_expires_at
      t.datetime :activated_at
      t.datetime :deleted_at
      t.timestamps
    end
    
    add_index :users, :login, :unique => true
    
    # Create Passwords Table
    create_table :passwords do |t|
      t.integer :user_id
      t.string :reset_code
      t.datetime :expiration_date
      t.timestamps
    end
    
    # Create Roles Databases
    create_table :roles do |t|
      t.string :name
    end
    
    create_table :roles_users, :id => false do |t|
      t.belongs_to :role
      t.belongs_to :user
    end
    
    # Create admin role
    admin_role = Role.create(:name => 'admin')
    
    # Create default admin user
    user = User.create do |u|
      u.login = 'admin'
      u.password = u.password_confirmation = 'chester'
      u.email = APP_CONFIG[:admin_email]
    end
    
    # Activate user
    user.register!
    user.activate!
    
    # Add admin role to admin user
    user.roles << admin_role
  end

  def self.down
    # Drop all Bort tables
    drop_table :sessions
    drop_table :users
    drop_table :passwords
    drop_table :roles
    drop_table :roles_users
    drop_table :open_id_authentication_associations
    drop_table :open_id_authentication_nonces
  end
end
