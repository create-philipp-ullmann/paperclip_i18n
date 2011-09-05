require 'rubygems'
require 'bundler/setup'
require 'paperclip_i18n'

$enabled = false

ActiveSupport::Notifications.subscribe(/sql/i) do |*args|
  if $enabled
    event = ActiveSupport::Notifications::Event.new(*args)
    puts "SQL #{event.duration}: #{event.payload[:sql]}"
  end
end

def connect(environment)
  conf = YAML::load(File.open(File.dirname(__FILE__) + '/database.yml'))
  ActiveRecord::Base.establish_connection(conf[environment])
end

# Open ActiveRecord connection
connect('test')

original_stdout = $stdout
$stdout = StringIO.new

begin
  load(File.dirname(__FILE__) + "/schema.rb")
ensure
  $stdout = original_stdout
end

# Disable logging of paperclip, because it would throw nil.info(..) error message
Paperclip.options[:log] = false