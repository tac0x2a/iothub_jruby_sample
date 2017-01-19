require 'java'

require "./iot-device-client-1.0.17-with-deps.jar"

java_import "com.microsoft.azure.sdk.iot.device.DeviceClient"
java_import "com.microsoft.azure.sdk.iot.device.IotHubClientProtocol"
java_import "com.microsoft.azure.sdk.iot.device.Message"
java_import "com.microsoft.azure.sdk.iot.device.IotHubEventCallback"


class EventCallback
  include IotHubEventCallback
  def execute(status, context)
    # status: IotHubStatusCode
    # context: Object
    puts "Callback #{context} : #{status.to_s}"
  end
end

require 'json'
conf = JSON.parse(File.read("config.json"))

connection_string = conf['connection_string']
client = Java::ComMicrosoftAzureSdkIotDevice::DeviceClient.new(connection_string, IotHubClientProtocol::AMQPS)

conf['options'].each do |k, v|
  client.setOption(k, v)
end


print "opening..."
client.open()
puts "Done."

10.times do |i|
  puts({"i" => i}.to_json)
  msg = Message.new({"i" => i}.to_json)
  msg.setExpiryTime(5000)
  client.sendEventAsync(msg, EventCallback.new, "ID:#{i}")

  sleep 1
end

print "closing..."
client.close()
puts "Done."

# [EOF]
