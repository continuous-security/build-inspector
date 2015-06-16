class VagrantWhisperer
    HOME = '/home/vagrant'
    REPO_DIR = "#{HOME}/repo"

    def initialize
        @ssh_opts = parse_ssh_config(`vagrant ssh-config`)
        #{}`vagrant ssh-config | awk -v ORS=' ' '{print "-o " $1 "=" $2}'`
    end

    def runCommands(commands)
        file_path = 'tmp_runCommands.sh'
        dest_path = "#{HOME}/#{file_path}"
        tf = File.new(file_path, 'w')
        tf.write "#!/bin/bash\n"
        commands.each do |cmd|
            puts "#{cmd}\n"
            tf.write "#{cmd}\n"
        end
        sendFile(file_path, dest_path)
        File.delete(file_path)

        `vagrant ssh --command "chmod +x #{dest_path}"`
        `vagrant ssh --command "./#{file_path}"`
        `vagrant ssh --command "rm #{dest_path}"`
    end

    def sendFile(local_path, remote_path)
        opts_str = @ssh_opts.map { |k,v| "-o #{k}=#{v}"}.join(' ')
        cmd = "scp #{opts_str} #{local_path} #{@ssh_opts['User']}@#{@ssh_opts['HostName']}:#{remote_path}"
        puts cmd
        `#{cmd}`
    end

private

    def parse_ssh_config(config)
        ssh_opts = {}
        config.lines.map(&:strip).each do |e|
            next if e.empty?
            k,v = e.split(/\s+/)
            ssh_opts[k] = v
        end

        ssh_opts
    end

end
