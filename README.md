zoho_service gem
=============================

zoho_service gem is a library to read, update and delete data in Zoho Service Desk.

https://desk.zoho.com/DeskAPIDocument#Introduction

## Support Modules (see and onn/off at lib/zoho_service.rb)
* organizations
* tickets
    comments
    threads
    attachments
    timeEntries
* contacts
* accounts
* tasks
* agents
- departments
- uploads
- search
    searchStr
    from & limit
    sortBy
- mailReplyAddress

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

