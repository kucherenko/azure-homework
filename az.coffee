require 'shelljs/global'
Connection = require("ssh2")

VMNAME = "apk#{Math.random()}".replace ".", ""
USER = "azureuser"
PASSWORD = "a1234567P$"
IMAGE = "b39f27a8b8c64d52b05eac6a62ebad85__Ubuntu-13_10-amd64-server-20131113-en-us-30GB"
LOCATION  = "North Europe"
create_vm = "azure vm create #{VMNAME} #{IMAGE} #{USER} #{PASSWORD} --location '#{LOCATION}'"
create_http_endpoint = "azure vm endpoint create #{VMNAME} 8081 8081"
create_ssh_endpoint = "azure vm endpoint create #{VMNAME} 22 22"
delete_vm = "azure vm delete #{VMNAME} -q"

exec create_vm
exec create_ssh_endpoint
exec create_http_endpoint

c = new Connection()
c.on "connect", ->
  console.log "Connection :: connect"

c.on "ready", ->
  console.log "Connection :: ready"
  c.sftp (err, sftp) ->
  throw err  if err
  sftp.on "end", ->
    console.log "SFTP :: SFTP session closed"

  sftp.opendir "/tmp", readdir = (err, handle) ->
    throw err  if err
    sftp.readdir handle, (err, list) ->
      throw err  if err
      if list is false
        sftp.close handle, (err) ->
          throw err  if err
          console.log "SFTP :: Handle closed"
          sftp.end()

        return
      console.dir list
      readdir `undefined`, handle


c.on "error", (err) ->
  console.log "Connection :: error :: " + err

c.on "end", ->
  console.log "Connection :: end"

c.on "close", (had_error) ->
  console.log "Connection :: close"

c.connect
  host: "#{VMNAME}.cloudapp.net"
  port: 22
  username: USER
  password: PASSWORD
