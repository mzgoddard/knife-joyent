require File.expand_path(File.dirname(__FILE__) + '/base')


module KnifeJoyent
  class JoyentServerStop < Chef::Knife

    include KnifeJoyent::Base

    banner 'knife joyent server stop <server_id>'

    option :delete,
      :long => '--delete',
      :description => 'delete the server after it is stopped'

    def delete_for_node(server)
      delete = KnifeJoyent::JoyentServerDelete.new
      delete.name_args = [ server.id ]
      delete.run
    end

    def run
      unless name_args.size === 1
        show_usage
        exit 1
      end

      id = name_args.first

      server = self.connection.servers.get(id)

      unless server
        puts ui.error("Unable to locate server: #{id}")
        exit 1
      end

      if server.stopped?
        puts ui.error("Server #{id} is already stopped")
        if config[:delete]
          delete_for_node(server)
        end
        exit 1
      end

      if server.stop
        puts ui.color("Stopped server: #{id}", :cyan)
        if config[:delete]
          delete_for_node(server)
        end
        exit 0
      else
        puts ui.error("Failed to stop server")
        exit 1
      end
    end
  end
end
