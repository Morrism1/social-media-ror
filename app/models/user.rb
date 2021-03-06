class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  validates :name, presence: true, length: { maximum: 20 }

  has_many :posts
  has_many :comments, dependent: :destroy
  has_many :likes, dependent: :destroy

  has_many :friendship_invitations, foreign_key: 'user_id'
  has_many :inverse_friendships, -> { where status: false }, class_name: 'FriendshipInvitation',
                                                             foreign_key: 'friend_id'
  has_many :pending_invitations, -> { merge(FriendshipInvitation.not_friends) },
           class_name: 'FriendshipInvitation', foreign_key: 'friend_id'
  has_many :friends, -> { merge(FriendshipInvitation.friends) }, class_name: 'FriendshipInvitation',
                                                                 foreign_key: 'user_id'
  has_many :confirmed_friendships, -> { where status: true }, class_name: 'FriendshipInvitation',
                                                              foreign_key: 'user_id'
  has_many :myfriends, through: :confirmed_friendships, source: :user

  def all_friends
    sent_invitation = friendship_invitations.map { |friendship| friendship.friend if friendship.status }
    sent_invitation += inverse_friendships.map { |friendship| friendship.user if friendship.status }
    sent_invitation.compact
  end

  def confirm_request(user)
    friend = friends.find { |invite| invite.user == user }
    friend.status = true
    friend.save
  end

  def friends?(friend)
    friendship_invitations.find_by(friend_id: friend.id).nil? && sent_invitation?(friend)
  end

  def sent_invitation?(friend)
    friend.friendship_invitations.find_by(friend_id: id).nil?
  end

  def friend_invited?(user)
    !friendship_invitations.find_by(user_id: user.id, status: false).nil?
  end

  def friend_confirmed?(friend)
    !friendship_invitations.find_by(friend_id: friend.id, status: false).nil?
  end
end
