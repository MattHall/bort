class AddIdentityUrlToUser < ActiveRecord::Migration
  def self.up
    change_table :users do |t|
      t.string :identity_url
    end
  end

  def self.down
    change_table :users do |t|
      t.remove :identity_url
    end
  end
end
