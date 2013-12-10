require 'shelljs/global'
Connection = require("ssh2")

VMNAME = "apk#{Math.random()}".replace(".", "")[0..7]

USER = "azureuser"
PASSWORD = "a1234567P$"

IMAGE = "b39f27a8b8c64d52b05eac6a62ebad85__Ubuntu-13_10-amd64-server-20131113-en-us-30GB"

LOCATION  = "West Europe"

create_vm = "azure vm create --ssh --location '#{LOCATION}' #{VMNAME} #{IMAGE} #{USER} #{PASSWORD}"
create_http_endpoint = "azure vm endpoint create #{VMNAME} 8081 8081"
check_vm_status = "azure vm show #{VMNAME} --json"
delete_vm = "azure vm delete #{VMNAME} -q"

exec create_vm
exec create_http_endpoint


c = new Connection()
c.on "connect", ->
  console.log "Connection :: connect"

c.on "ready", ->
  console.log "Connection :: ready"
  c.exec 'sudo apt-get install nodejs -y &&
          sudo apt-get install npm -y &&
          sudo apt-get install git -y &&
          sudo mkdir /var/www &&
          cd /var/www &&
          sudo git clone https://github.com/kucherenko/azure-homework.git &&
          cd /var/www/azure-homework/build &&
          sudo sh /var/www/azure-homework/build/startup.sh &&
          sudo npm start', (err, stream) ->
    throw err  if err

    stream.on "data", (data, extended) ->
      console.log ((if extended is "stderr" then "STDERR: " else "")) + data

    stream.on "end", ->
      console.log "Stream :: EOF"

    stream.on "close", ->
      console.log "Stream :: close"

    stream.on "exit", (code, signal) ->
      console.log "Stream :: exit :: code: " + code + ", signal: " + signal
      c.end()

c.on "error", (err) ->
  console.log "Connection :: error :: " + err

c.on "end", ->
  console.log "Connection :: end"

c.on "close", (had_error) ->
  console.log "Connection :: close"

isStarted = off

while not isStarted
  result = exec(check_vm_status, silent:true).output
  result = JSON.parse result
  console.log "Status: #{result.InstanceStatus}..."
  isStarted = on if result.InstanceStatus is "ReadyRole"

console.log "################### #{VMNAME}.cloudapp.net ###################"

c.connect
  host: "#{VMNAME}.cloudapp.net"
  port: 22
  username: USER
  password: PASSWORD
