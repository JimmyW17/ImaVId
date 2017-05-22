class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  has_one :album

  after_save :link_user_album

  # def create_user_album
  #   Album.create(user_id: User.last.id)
  # end

  def link_user_album
    User.last.create_album
  end
end
