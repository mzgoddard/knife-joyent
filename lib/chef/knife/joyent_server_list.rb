require 'chef/knife/joyent_base'

class Chef
  class Knife
    class JoyentServerList < Knife

      include Knife::JoyentBase

      banner "knife joyent server list <options>"

      def run
        servers = [
          ui.color('ID', :bold),
          ui.color('Name', :bold),
          ui.color('State', :bold),
          ui.color('Type', :bold),
          ui.color('Image', :bold),
          ui.color('IPs', :bold),
          ui.color('RAM', :bold),
          ui.color('Disk', :bold),
          ui.color('Tags', :bold)
        ]

        self.connection.servers.sort do |a, b|
          (a.name || '') <=> (b.name || '')
        end.each do |s|
          servers << s.id.to_s
          servers << s.name

          servers << case s.state
          when 'running'
            ui.color(s.state, :green)
          when 'stopping', 'provisioning'
            ui.color(s.state, :yellow)
          when 'stopped'
            ui.color(s.state, :red)
          else
            ui.color('unknown', :red)
          end

          ip_regex = Regexp.compile(
            "127\\.0\\.0\\.1|" +
            "10(?:\\.\\d{1,3}){3}|" +
            "172\\.(?:1[6-9]|2\\d|3[01])(?:\\.\\d{1,3}){2}|" +
            "192\\.168(?:\\.\\d{1,3}){2}"
          )
          s.ips.sort! {|a,b| ip_regex.match(a) ? 1 : -1 }

          servers << s.type
          servers << s.dataset
          servers << s.ips.join(" ")
          servers << "#{s.memory/1024} GB".to_s
          servers << "#{s.disk/1024} GB".to_s
          servers << s.tags.map { |k, v| "#{k}:#{v}" }.join(' ')
        end

        puts ui.list(servers, :uneven_columns_across, 9)
      end
    end
  end
end
