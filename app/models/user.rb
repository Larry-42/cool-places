class User < ActiveRecord::Base
  has_secure_password
  has_many :places
  has_many :comments
end
