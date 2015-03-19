class UserLead < ActiveRecord::Base
  attr_accessible :name, :email

  validates :name, presence: true
  validates :email, presence: true, email: {strict_mode: true}, uniqueness: true
end
