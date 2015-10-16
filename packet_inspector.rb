require 'packetfu'
require 'resolv'

class PacketInspector
  include PacketFu

  DNS_PORT = 53

  def initialize(pcap_file)
    @packets = PcapFile.read_packets pcap_file
  end

  def packets_from(src_ip)
    @packets.find_all do |packet|
      packet.respond_to?(:ip_src_readable) && packet.ip_src_readable == src_ip
    end
  end

  def udp_packets_with_src_port(port)
    @packets.find_all do |packet|
      packet.respond_to?(:udp_src) && packet.udp_src == port
    end
  end

  # returns a mapping of names to its ip addresses
  def dns_responses
    decoded_responses = udp_packets_with_src_port(DNS_PORT).map { |p| Resolv::DNS::Message.decode(p.payload) }

    decoded_responses.each_with_object({}) do |response, memo|
      name = response.question.first.first.to_s
      memo[name] ||= []
      response.answer.each do |ans|
        case ans.last
        when Resolv::DNS::Resource::IN::CNAME
          memo[name] << ans.last.name
        when Resolv::DNS::Resource::IN::AAAA, Resolv::DNS::Resource::IN::A
          memo[name] << ans.last.address
        else
          puts ans.last
        end
      end
    end
  end
end
