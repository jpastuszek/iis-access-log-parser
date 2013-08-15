require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "IISAccessLogParser::Entry" do
	it "can be constructed from string" do
		IISAccessLogParser::Entry.from_string("2011-06-20 00:00:00 38.111.242.43 GET /SharedControls/getListingThumbs.aspx img=48,13045,27801,25692,35,21568,21477,21477,10,18,46,8&premium=0|1|0|0|0|0|0|0|0|0|0|0&h=100&w=125&pos=175&scale=true 80 - 92.20.10.104 Mozilla/4.0+(compatible;+MSIE+8.0;+Windows+NT+6.1;+Trident/4.0;+GTB6.6;+SLCC2;+.NET+CLR+2.0.50727;+.NET+CLR+3.5.30729;+.NET+CLR+3.0.30729;+Media+Center+PC+6.0;+aff-kingsoft-ciba;+.NET4.0C;+MASN;+AskTbSTC/5.8.0.12304) 200 0 0 609")

    IISAccessLogParser::Entry.from_string("2011-06-20 00:00:00 38.111.242.43 GET /SharedControls/getListingThumbs.aspx img=48,13045,27801,25692,35,21568,21477,21477,10,18,46,8&premium=0|1|0|0|0|0|0|0|0|0|0|0&h=100&w=125&pos=175&scale=true 80 - 92.20.10.104 Mozilla/4.0+(compatible;+MSIE+8.0;+Windows+NT+6.1;+Trident/4.0;+GTB6.6;+SLCC2;+.NET+CLR+2.0.50727;+.NET+CLR+3.5.30729;+.NET+CLR+3.0.30729;+Media+Center+PC+6.0;+aff-kingsoft-ciba;+.NET4.0C;+MASN;+AskTbSTC/5.8.0.12304) 200 0 0 609 test oter now")

    #lambda{ IISAccessLogParser::Entry.from_string("2011-06-20 00:00:00 38.111.242.43 GET /SharedControls/getListingThumbs.aspx img=48,13045,27801,25692,35,21568,21477,21477,10,18,46,8&premium=0|1|0|0|0|0|0|0|0|0|0|0&h=100&w=125&pos=175&scale=true 80 - 92.20.10.104 Mozilla/4.0+(compatible;+MSIE+8.0;+Windows+NT+6.1;+Trident/4.0;+GTB6.6;+SLCC2;+.NET+CLR+2.0.50727;+.NET+CLR+3.5.30729;+.NET+CLR+3.0.30729;+Media+Center+PC+6.0;+aff-kingsoft-ciba;+.NET4.0C;+MASN;+AskTbSTC/5.") }.should raise_error ArgumentError
  end

	it "should contain properly parsed date types" do
		e = IISAccessLogParser::Entry.from_string("2011-06-20 00:01:02 38.111.242.43 GET /SharedControls/getListingThumbs.aspx img=48,13045,27801,25692,35,21568,21477,21477,10,18,46,8&premium=0|1|0|0|0|0|0|0|0|0|0|0&h=100&w=125&pos=175&scale=true 80 - 92.20.10.104 Mozilla/4.0+(compatible;+MSIE+8.0;+Windows+NT+6.1;+Trident/4.0;+GTB6.6;+SLCC2;+.NET+CLR+2.0.50727;+.NET+CLR+3.5.30729;+.NET+CLR+3.0.30729;+Media+Center+PC+6.0;+aff-kingsoft-ciba;+.NET4.0C;+MASN;+AskTbSTC/5.8.0.12304) 200 0 0 609 test oter now")

		e.date.should be_kind_of Time
		e.date.day.should == 20
		e.date.month.should == 6
		e.date.year.should == 2011
		e.date.hour.should == 0
		e.date.min.should == 1
		e.date.sec.should == 2
		e.date.zone == 'UTC'

		e.server_ip.should be_kind_of IP::V4
		e.client_ip.should be_kind_of IP::V4

		e.port.should be_kind_of Fixnum
		e.status.should be_kind_of Fixnum
		e.substatus.should be_kind_of Fixnum
		e.win32_status.should be_kind_of Fixnum

		e.time_taken.should be_kind_of Float
		e.time_taken.should == 0.609

		e.username.should be_nil

		e.user_agent.should == "Mozilla/4.0 (compatible; MSIE 8.0; Windows NT 6.1; Trident/4.0; GTB6.6; SLCC2; .NET CLR 2.0.50727; .NET CLR 3.5.30729; .NET CLR 3.0.30729; Media Center PC 6.0; aff-kingsoft-ciba; .NET4.0C; MASN; AskTbSTC/5.8.0.12304)"
	end

	it "should handle correctly nil useragent" do
		e = IISAccessLogParser::Entry.from_string("2011-06-20 00:01:02 38.111.242.43 GET /SharedControls/getListingThumbs.aspx img=48,13045,27801,25692,35,21568,21477,21477,10,18,46,8&premium=0|1|0|0|0|0|0|0|0|0|0|0&h=100&w=125&pos=175&scale=true 80 - 92.20.10.104 - 200 0 0 609 test oter now")

		e.user_agent.should be_nil
	end
end

describe "IISAccessLogParser" do
	it "should read entries for IO" do
		last = nil
		File.open('spec/data/short.log', 'r') do |io|
			IISAccessLogParser.new(io) do |entry|
				last = entry
			end
		end

		last.url.should == '/blahs/uk/leicestershire/little-bowden/invisalign/index.aspx'
	end

	it "should allow reading entries from file" do
		last = nil
		IISAccessLogParser.from_file('spec/data/short.log') do |entry|
			last = entry
		end

		last.url.should == '/blahs/uk/leicestershire/little-bowden/invisalign/index.aspx'
	end
end

