class Task::Notifications::DailyUpcomingReminders < Mutations::Command

  DAYS_UNTIL_TASK = 1
  HOUR_OF_DAY     = 8

  optional do
    array :zones, class: String
  end


  def execute
    Rails.logger.info "--- Sending daily task reminders for tasks in timezones: #{zone_names}, tasks: #{tasks.map(&:id)}"
    tasks.each do |task|
      Task::Notifications::ReminderEmail.run task: task
    end
  end


  private


  def tasks
    @tasks ||= begin
      Task.
        not_completed.
        joins(:circle).
        joins(circle: { address: :location }).
        where(locations: { timezone: zone_names }).
        where(due_date: zone_due_dates)
    end
  end


  def timezones
    @timezones ||= if zones.present?
      zones.map{ |tz| ActiveSupport::TimeZone[tz] }
    else
      ActiveSupport::TimeZone.all.select{ |tz| tz.now.hour == HOUR_OF_DAY }
    end
  end


  def zone_due_dates
    timezones.map{|tz| tz.today + DAYS_UNTIL_TASK }.uniq
  end


  def zone_names
    timezones.map{|tz| tz.tzinfo.identifier }.uniq
  end
end