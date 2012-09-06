require File.expand_path(File.dirname(__FILE__) + '/base')


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

      unless server
        puts ui.error("Unable to locate server: #{id}")
        exit 1
      end

      unless server.stopped?
        puts ui.error("Server #{id} is not stopped")
        exit 1
      end

      if server.destroy
        puts ui.color("Deleted server: #{id}", :cyan)
        exit 0
      else
        puts ui.error("Failed to delete server")
        exit 1
      end
    end
  end
end
