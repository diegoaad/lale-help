class User < ActiveRecord::Base
  # has_many :feedback

  has_many :triggered_system_events, class_name: '::SystemEvent'
  has_many :notifications, class_name: '::SystemEvent::Notification'

  has_one :identity, dependent: :destroy

  belongs_to :location
  belongs_to :primary_circle, class_name: 'Circle'

  has_many :task_roles, class_name: 'Task::Role'
  has_many :tasks, ->{ distinct }, through: :task_roles

  has_many :circle_roles, class_name: 'Circle::Role'
  has_many :circles, ->{ distinct }, through: :circle_roles

  has_many :working_group_roles, class_name: 'WorkingGroup::Role'
  has_many :working_groups, ->{ distinct }, through: :working_group_roles

  enum language: [:en, :de, :fr]

  alias_attribute :active_since, :created_at

  def login_token
    @login_token ||= begin
      previous = Token.login.active.for_user_id(self.id).first
      if previous.present?
        previous
      else
        Token.login.active.create context: { user_id: self.id }
      end
    end
  end

  def name
    "#{first_name} #{last_name}"
  end

  def email
    identity.try :email
  end



  def tasks_for_circle circle
    task_assignments.where(circle: circle).tasks
  end

  def initials
    (first_name.first + last_name.first).upcase
  end

  def admin?
    self.is_admin
  end

  def organizer?
    self.circle_roles.count > 1 || self.working_group_roles.count > 0
  end

  def public_profile?
    identity.try :public_profile
  end
end
