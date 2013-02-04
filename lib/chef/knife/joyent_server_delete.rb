require File.expand_path(File.dirname(__FILE__) + '/base')

require 'chef/api_client'

module KnifeJoyent
  class JoyentServerDelete < Chef::Knife

    include KnifeJoyent::Base

    banner 'knife joyent server delete <server_id>'

    def run
      unless name_args.size === 1
        show_usage
        exit 1
      end

      id = name_args.first

      server = self.connection.servers.get(id)
      
      msg("ID", server.id.to_s)
      msg("Name", server.name)
      msg("State", server.state)
      msg("Type", server.type)
      msg("Dataset", server.dataset)
      msg("IP's", server.ips)
     
      unless server
        puts ui.error("Unable to locate server: #{id}")
        exit 1
      end
     
      puts "\n"
      confirm("Do you really want to delete this server")
     
      puts ui.color("Stopping server...", :cyan)

      if server.stopped?
        puts ui.color("Server #{id} is already stopped", :cyan)
      else
        if server.stop
          puts ui.color("Server stopped", :cyan)
        else
          puts ui.error("Failed to stop server")
          exit 1
        end
      end
    
      server.destroy
      puts ui.color("Deleted server: #{id}", :cyan)
    
      puts "\n"
      confirm("Delete client and node for #{server.name}?")
      
      node = Chef::Node.load(server.id + ".local")
      puts "deleting node #{node.name}"
      node.destroy
      ui.warn("Deleted node named #{node.name}")
      
      client = Chef::ApiClient.load(server.id + ".local")
      puts "deleting client #{client.name}"
      client.destroy
      ui.warn("Deleted client named #{client.name}")
    end
    
    def msg(label, value)
      if value && !value.empty?
        puts "#{ui.color(label, :cyan)}: #{value}"
      end
    end
  end
end
