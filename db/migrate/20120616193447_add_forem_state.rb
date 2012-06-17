# This migration comes from forem (originally 20120616000459)
class AddForemState < ActiveRecord::Migration
  def change
    unless column_exists?(user_class, :forem_state)
      add_column user_class, :forem_state, :string, :default => 'pending_review'
    end
  end
  
  def user_class
    ActiveSupport::Inflector.pluralize(Forem.user_class.name.downcase).to_sym
  end
end
