require 'sidekiq'

require_relative 'sidekiq-scheduler/version'
require_relative 'sidekiq-scheduler/manager'

Sidekiq.configure_server do |config|

  config.on(:startup) do
    startup = Sidekiq::Scheduler.startup
    enabled = Sidekiq::Scheduler.enabled
    scheduler_options = {
      :scheduler => config.options.fetch(:scheduler, true),
      :dynamic => config.options.fetch(:dynamic, false),
      :enabled => enabled.nil? ? true : enabled,
      :startup => startup.nil? ? true : startup,
      :schedule => config.options.fetch(:schedule, nil)
    }

    schedule_manager = SidekiqScheduler::Manager.new(scheduler_options)
    config.options[:schedule_manager] = schedule_manager
    config.options[:schedule_manager].start if scheduler_options[:startup]
  end

  config.on(:shutdown) do
    config.options[:schedule_manager].stop
  end

end