require 'rb-inotify'

paths = %w(/home/vargrant/.bashrc)

notifier = INotify::Notifier.new

paths.each do |path|
    notifier.watch("/home/vagrant/", :all_events, :recursive) do |event|
      puts "#{event.name} - #{event.flags}"
    end
end

notifier.run
