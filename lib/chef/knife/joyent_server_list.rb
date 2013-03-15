require File.expand_path(File.dirname(__FILE__) + '/base')


module KnifeJoyent
  class JoyentServerList < Chef::Knife

    include KnifeJoyent::Base

    banner "knife joyent server list <options>"

    option :machine_type,
      :long => '--type TYPE',
      :description => 'Type of Joyent machine. smart or virtual.'

    option :tags,
      :long => '--tags TAG=VALUE,',
      :description => 'Joyent machine tags to sort for.'

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
      ]

      list_options = {
        :type => config[:machine_type] ?
          config[:machine_type] + 'machine' :
          nil
      }
      if config[:tags] then
        config[:tags].split(',').each do |a|
          tag = a.split('=')
          list_options['tag.' + tag[0]] = tag[1]
        end
      end

      self.connection.servers.load(
        self.connection.list_machines(list_options).body
      ).sort do |a, b|
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

        servers << s.type
        servers << s.dataset
        ip_regex = Regexp.compile(
          "127\\.0\\.0\\.1|" +
          "10(?:\\.\\d{1,3}){3}|" +
          "172\\.(?:1[6-9]|2\\d|3[01])(?:\\.\\d{1,3}){2}|" +
          "192\\.168(?:\\.\\d{1,3}){2}"
        )
        s.ips.sort! {|a,b| ip_regex.match(a) ? 1 : -1 }
        servers << s.ips.join(" ")
        servers << "#{s.memory/1024} GB".to_s
        servers << "#{s.disk/1024} GB".to_s
      end

      if config[:format] != 'summary' then
        # Reformat server output

        # Arrays of server data
        members = 8
        servers = (0...(servers.length / members)).map do |i|
          servers[(i * members)...((i + 1) * members)]
        end

        # Keys are the first array member.
        keys = servers[0]

        servers = servers[1..-1].map do |server|
          Hash[(0...server.length).map do |i|
            [keys[i], server[i]]
          end]
        end

        ui.output(servers)
      else
        puts ui.list(servers, :uneven_columns_across, 8)
      end
    end
  end
end
