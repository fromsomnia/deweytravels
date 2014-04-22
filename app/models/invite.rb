require 'securerandom'
class Invite < ActiveRecord::Base
  before_create :set_invite_code
  belongs_to :inviter, :class_name => "User"

  # TODO: check this when the Group class is added.
  belongs_to :group

  private
    def set_invite_code
      return if invite_code.present?
      self.invite_code = SecureRandom.hex
    end
end
