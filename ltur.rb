require 'rubygems'
require 'mechanize'
require 'logger'
require 'pony'

logger = Logger.new(STDOUT)

logger.info "-------------------------------------------------------------------------------------------------"
logger.info "Welcome!"
logger.info "You're using now LTUR Crawler to find 25 EUR offers"
logger.info "developed by Hoang Anh Le [me@lehoanganh.de]"
logger.info "After finding a offer, LTUR will send an email to you via GMail"
logger.info "Therefore, you have to input your email in order to become the message from LTUR Crawler"
logger.info "Version 0.1"
logger.info "------------------------------------------------------------------------------------------------"

index = ""
city_array = []
city_array << "Berlin Hbf"
city_array << "Frankfurt(Main)Hbf"
city_array << "Karlsruhe Hbf"
city_array << "Hamm(Westf)"
city_array << "Dortmund Hbf"
city_array << "Hamburg Hbf"
#city_array << "Saarbruecken Hbf"
#city_array << "Muenchen Hbf"

start_city = "dummy"
end_city = "dummy"
start_date = "dummy"
end_date = "dummy"
interval = 1

logger.info "Searchable Cities:"
logger.info "[0] Berlin Hbf"
logger.info "[1] Frankfurt am Main Hbf"
logger.info "[2] Karlsruhe Hbf"
logger.info "[3] Hamm(Westf)"
logger.info "[4] Dortmund Hbf"
logger.info "[5] Hamburg Hbf"
#logger.info "[5] Saarbruecken Hbf"
#logger.info "[6] Muenchen Hbf"

logger.info "Input your start city: "
index = gets  
index = index.chomp # delete the last enter character
start_city = city_array[index.to_i]
=begin
if start_city.include? "Muenchen"
	start_city = "M%C3%BCnchen+Hbf"
end
if start_city.include? "Saarbruecken"
	start_city = "Saarbr%C3%BCcken+Hbf"
end
=end

logger.info "Input your end city: "
index = gets  
index = index.chomp # delete the last enter character
end_city = city_array[index.to_i]
=begin
if end_city.include? "Muenchen"
	end_city = "M%C3%BCnchen+Hbf"
end
if end_city.include? "Saarbruecken"
	end_city = "Saarbr%C3%BCcken+Hbf"
end
=end

logger.info "Input the time interval for request in minutes (e.g. 10 mins)"
interval = gets
interval = interval.chomp
interval = interval.to_i

logger.info "Input the email"
email = gets
email = email.chomp

agent = Mechanize.new
url = 'http://bahn.ltur.com/index/search/'

today = Time.new.to_date
today = today + 1 # search from tomorrow on
day = today.day
month = today.month
year = today.year
if day < 10
	tomorrow = "0" << day.to_s << "."
else
	tomorrow = day.to_s << "."
end
		
if month < 10
	tomorrow << "0" << month.to_s << "."
else
	tomorrow << month.to_s << "."		
end
tomorrow << year.to_s

check = false
i = 0 # hour index
x = 1 # day index

logger.info "Search for the route:"
logger.info "#{start_city} - #{end_city}" 
until check
	if i > 23
		x += 1 # increment day
		i = 0 # hour back to 0
		today = today + 1
		day = today.day
		month = today.month
		year = today.year
		if day < 10
			tomorrow = "0" << day.to_s << "."
		else
			tomorrow = day.to_s << "."
		end
		
		if month < 10
			tomorrow << "0" << month.to_s << "."
		else
			tomorrow << month.to_s << "."		
		end
		tomorrow << year.to_s
	end

	logger.info "--------------------------"
	logger.info "Find for: #{tomorrow}"	
	if i < 10
		start_time = "0#{i}:01"
	else
		start_time = "#{i}:01"
	end
	logger.info "with start Time: #{start_time}"
	logger.info "--------------------------"

	params = { :mnd => "de",
			   :lang => "de_DE",
			   :searchin => "DE-SB-VI",
			   :trip_mode => "trip_simple",
			   :from_spar => start_city,
			   :to_spar => end_city,
			   :start_datum => tomorrow,
			   :start_time => start_time,
			   :end_datum => tomorrow,
			   :end_time => start_time,
			   :SEA_adults => "1",
			   :SEA_kids1 => "0",
			   :SEA_kids2 => "0",
			   :SEA_adult1 => "",
			   :SEA_adult2 => "",
			   :SEA_adult3 => "",
			   :SEA_adult4 => "",
			   :SEA_adult5 => "",
			   :SEA_kid11 => "",
			   :SEA_kid12 => "",
			   :SEA_kid13 => "",
			   :SEA_kid14 => "",
			   :SEA_kid15 => "",
			   :trainclass_spar => "2",
			   :x => "35",
			   :y => "14"
			   }   
	page = agent.get(url, params)
	prices = page.labels
	prices.each do |price|
		if ! price.to_s.include? "nur"
			puts price
			if price.to_s.strip.include? '25 '
				logger.info "Yuhu, found!"
				logger.info "For date: #{tomorrow}"
				logger.info "from start time: #{start_time}"
				check = true
				Pony.mail({
				  :to => email,
				  :via => :smtp,
				  :subject => 'Your LTUR Crawler Service :)',
				  :body => "You're lucky, there is a 25 EUR offer for you for date: #{tomorrow} with start time: #{start_time}. Go to the LTUR web site to book bahn.ltur.com!!",
				  :via_options => {
					:address              => 'smtp.gmail.com',
					:port                 => '587',
					:enable_starttls_auto => true,
					:user_name            => 'ltur.crawler',
					:password             => 'ltur.crawler',
					:authentication       => :plain, # :plain, :login, :cram_md5, no auth by default
					:domain               => "localhost.localdomain" # the HELO domain provided by the client to the server,
				  }
				})
			end
		end
	end	
	
	# increment hour
	i += 6
	
	if x == 6
		x = 1
		logger.info "sleep"
		sleep (60 * interval)
		today = Time.new.to_date
		today = today + 1
		day = today.day
		month = today.month
		year = today.year
		if day < 10
			tomorrow = "0" << day.to_s << "."
		else
			tomorrow = day.to_s << "."
		end
		if month < 10
			tomorrow << "0" << month.to_s << "."
		else
			tomorrow << month.to_s << "."		
		end
		tomorrow << year.to_s
	end
end


