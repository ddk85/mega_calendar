class Holiday < ActiveRecord::Base
  unloadable
  attr_accessible :user_id
  attr_accessible :start
  attr_accessible :end
  attr_accessible :reason
  belongs_to(:user)
  validates :user_id, presence: true, allow_blank: false
  validates :reason, presence: true, allow_blank: false
  validates_presence_of :start, :end
  validate :validate_holiday

  def validate_holiday
    if self.start && self.end && (start_changed? || end_changed?) && self.end < self.start
      errors.add :end, :greater_than_start
    end
  end

  def self.get_activated_users
    if Setting.plugin_mega_calendar['displayed_type'] == 'users'
      return User.where(["users.id IN (?) AND users.login IS NOT NULL AND users.login <> ''",Setting.plugin_mega_calendar['displayed_users']]).order("users.lastname ASC")
    else
      return User.where(["users.id IN (SELECT user_id FROM groups_users WHERE group_id IN (?)) AND users.login IS NOT NULL AND users.login <> ''",Setting.plugin_mega_calendar['displayed_users']]).order("users.lastname ASC")
    end
  end
  
  def self.get_allowed_users
    if Setting.plugin_mega_calendar['allowed_users_type'] == 'users'
      return User.where(["users.id IN (?) AND users.login IS NOT NULL AND users.login <> ''",Setting.plugin_mega_calendar['allowed_users']]).order("users.lastname ASC")
    else
      return User.where(["users.id IN (SELECT user_id FROM groups_users WHERE group_id IN (?)) AND users.login IS NOT NULL AND users.login <> ''",Setting.plugin_mega_calendar['allowed_users']]).order("users.lastname ASC")
    end
  end

  def self.get_allowed_groups
    if Setting.plugin_mega_calendar['allowed_users_type'] != 'users'
      return Group.where(["users.id IN (?)",Setting.plugin_mega_calendar['allowed_users']]).order("users.lastname ASC")
    else
      return Group.all.order("users.lastname ASC")
    end
  end
  def self.get_activated_groups
    if Setting.plugin_mega_calendar['displayed_type'] != 'users'
      return Group.where(["users.id IN (?)",Setting.plugin_mega_calendar['displayed_users']]).order("users.lastname ASC")
    else
      return Group.all.order("users.lastname ASC")
    end
  end
end
