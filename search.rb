#!/usr/bin/ruby
require 'watir-webdriver'
require 'headless'
require 'mail'

origin = 'gig'
dest = 'atl'
month = 'Mar'

headless = Headless.new
headless.start
b = Watir::Browser.new :chrome, :switches => %w[--no-sandbox]
b.goto("http://www.aa.com/reservation/awardFlightSearchAccess.do")
b.radio(value: "oneWay").set
b.text_field(name: "originAirport").set(origin)
b.text_field(name: "destinationAirport").set(dest)
b.select_list(name: "flightParams.flightDateParams.travelMonth").select(month)
b.button(value: "Continue").click
b.span(text: "Close Full Calendar").wait_until_present

dates = b.elements(text: "20K").map { |e| e.parent.dd(class: "date").text }.sort

Mail.defaults do
  delivery_method :smtp, :openssl_verify_mode => 'none'
end

dates.each do |day|
  b.dd(text: day).click
  b.span(text: "Continue").click
  b.span(id: "flightTabDate_0").wait_until_present

  datestring = b.span(id: "flightTabDate_0").text

  Mail.deliver do
    to      'email@email.com'
    from    'watcher@watcher'
    subject "Flight: #{datestring}"
    add_file :filename => 'flight.png', :content => b.screenshot.png
  end

  b.back
  b.span(text: "Close Full Calendar").wait_until_present
end

b.quit
headless.destroy
