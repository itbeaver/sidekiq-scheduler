require 'celluloid'
require 'redis'

require 'sidekiq/util'

require 'sidekiq/scheduler'
require 'sidekiq-scheduler/schedule'

module SidekiqScheduler

  # The delayed job router in the system.  This
  # manages the scheduled jobs pushed messages
  # from Redis onto the work queues
  #
  class Manager
    include Sidekiq::Util
    include Celluloid

    def initialize(options={})
      @enabled = options[:scheduler]

      Sidekiq::Scheduler.startup = options[:startup]
      Sidekiq::Scheduler.enabled = options[:enabled]
      Sidekiq::Scheduler.dynamic = options[:dynamic] || false
      Sidekiq.schedule = options[:schedule] if options[:schedule]
    end

    def stop
      @enabled = false
    end

    def start
      # Load the schedule into rufus
      # If dynamic is set, load that schedule otherwise use normal load
      if @enabled && Sidekiq::Scheduler.dynamic && Sidekiq::Scheduler.enabled
        Sidekiq::Scheduler.reload_schedule!
      elsif @enabled && Sidekiq::Scheduler.enabled
        Sidekiq::Scheduler.load_schedule!
      end
    end

    def reset
      clear_scheduled_work
    end

  end

end