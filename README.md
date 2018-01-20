zoho_service gem
=============================

zoho_service gem is a library to read, update and delete data in Zoho Service Desk.

https://desk.zoho.com/DeskAPIDocument#Introduction

## Support Modules (see and onn/off at lib/zoho_service.rb)
- [x] organizations
- [x] tickets [comments threads attachments timeEntries]
- [x] contacts
  - [x] tasks
- [x] accounts
- [x] tasks
- [x] agents
- [x] departments
### Not ready yet:
- [ ] uploads
- [ ] search [searchStr sortBy]
- [ ] mailReplyAddress
- [ ] from & limit
- [ ] sortBy

## Installation

Add this line to your application's Gemfile:

    gem 'zoho_service', git: 'https://github.com/chaky222/zoho_service'

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install zoho_service

## Usage

### Get the token

You can get the token read "Zoho Service Desk API documentation" available here:

https://desk.zoho.com/DeskAPIDocument

### Setup Token and Host

Before accessing ZohoService, you must first configure the connector with token.

    require "zoho_service"
    zoho_service_connector = ZohoService::ApiConnector.new('224d6ade955bbb18f82ebd00f5c6642e')
    puts zoho_service_connector.organizations.to_json
    puts zoho_service_connector.tickets.to_json
    puts zoho_service_connector.tickets.first.comments.to_json

Example how to use this gem you can find in file 'bin/zoho_service'. Here some lines from it:
```ruby
require 'zoho_service'
zoho_conn = ZohoService::ApiConnector.new('224d6ade955bbb18f82ebd00f5c6642e', {}, true)

# ticket = c.tickets.first.update(subject: 'zzzz Вот ваш первый талон.')
# ticket = c.tickets.first

ticket = zoho_conn.tickets.new({
  "subCategory": "Sub General",
  "contactId": zoho_conn.contacts.first.id,
  "subject": "100500 started",
  "dueDate": (Time.now + 300.days).utc,
  "departmentId": zoho_conn.departments.first.id,
  "channel": "Email",
  "description": "Hai This is Description",
  "assigneeId": zoho_conn.agents.first.id,
  "phone": "1 888 900 9646",
  "email": "example@example.com",
  "status": "Open"
}).save!

puts "\n\n ticket=[#{ticket.to_json}] \n\n"

comm = ticket.comments.create({ 
  "isPublic": "true",
  "content": "comm 1005002"
})

comm = ticket.comments.new({ 
  "isPublic": "true",
  "content": "comm 1005003"
}).save!

comm = ticket.comments.first
comm.delete!

puts "\n\n comm=[#{comm.to_json}] \n\n"

ticket.update(description: ticket.description + ' bla-bla-bla ')

```

My mail=chaky22222222@gmail.com.
