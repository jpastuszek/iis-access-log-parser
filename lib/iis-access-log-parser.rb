require 'ip'
require 'time'

class IISAccessLogParser
	#Fields: date time s-ip cs-method cs-uri-stem cs-uri-query s-port cs-username c-ip cs(User-Agent) sc-status sc-substatus sc-win32-status time-taken
	Entry = Struct.new(:date, :server_ip, :method, :url, :query, :port, :username, :client_ip, :user_agent, :status, :substatus, :win32_status, :time_taken, :other)
	class Entry
		def self.from_string(line)
			# 2011-06-20 00:00:00 83.222.242.43 GET /SharedControls/getListingThumbs.aspx img=48,13045,27801,25692,35,21568,21477,21477,10,18,46,8&premium=0|1|0|0|0|0|0|0|0|0|0|0&h=100&w=125&pos=175&scale=true 80 - 92.20.10.104 Mozilla/4.0+(compatible;+MSIE+8.0;+Windows+NT+6.1;+Trident/4.0;+GTB6.6;+SLCC2;+.NET+CLR+2.0.50727;+.NET+CLR+3.5.30729;+.NET+CLR+3.0.30729;+Media+Center+PC+6.0;+aff-kingsoft-ciba;+.NET4.0C;+MASN;+AskTbSTC/5.8.0.12304) 200 0 0 609

			x, date, server_ip, method, url, query, port, username, client_ip, user_agent, status, substatus, win32_status, time_taken, y, other = *line.match(/^([^ ]* [^ ]*) ([^ ]*) ([^ ]*) ([^ ]*) ([^ ]*) ([^ ]*) ([^ ]*) ([^ ]*) ([^ ]*) ([^ ]*) ([^ ]*) ([^ ]*) ([^ ]*)($| )(.*)/)
			raise ArgumentError, "bad format: '#{line}'" unless x

			date = Time.parse(date + ' UTC')

			server_ip = IP.new(server_ip)
			client_ip = IP.new(client_ip)

			port = port.to_i
			status = status.to_i
			substatus = substatus.to_i
			win32_status = win32_status.to_i

			time_taken = time_taken.to_f / 1000

			query = nil if query == '-'
			username = nil if username == '-'
			user_agent = nil if user_agent == '-'

			user_agent.tr!('+', ' ')

			Entry.new(date, server_ip, method, url, query, port, username, client_ip, user_agent, status, substatus, win32_status, time_taken, other)
		end
	end

	def initialize(log_file)

	end
end

