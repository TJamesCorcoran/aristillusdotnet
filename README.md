# README

This is the backend code for an experimental project I started with a friend.

Currently the code is largely a database schema with a series of API
endpoints (which use token authentication) that allow the data to be
queried and modified.

Entities in the data schema include:
- groups, which consist of ...
- people, ...who can vote in
- elections, which have...
- choices
- membership tiers, which are monthly subscription plans for the service

Additionally,
- people can belong to "groups"
- people have social credit scores
- people can set up a ranked list of voting proxies, so if a given person p-1 does not vote in election e-1, their vote is cast as a clone of proxy-1, if proxy-1 voted, or cast as a clone of proxy-2 if proxy-2 voted, etc
- users (online accounts) may be connected to people
- there is a facility to import legislator rating data from New Hampshire Liberty Alliance
- there is a 

This repo can be found at

	 https://github.com/TJamesCorcoran/aristillusdotnet

This software is copyrighted, and is not GPL-ed, MIT-licensed, etc.,
however at least one non-exclusive licenses to use it have been
granted; if you want to use it, just ask me.

## Installing  (first time)

1. Install `rvm` (ruby version manager)
1. `rvm install ruby-3.3.5`
1. gem install rails
1. `rake db:init`
1. `rake db:migrate`
1. `rake db:seed`

## Updating (every time)

1. git pull
1. bundle install
1. rake db:migrate

## Updating (re-seed, if you've modified `db/seeds.rb`)
1. rake db:seed:replant

## Updating (purge the db, start over 100% clean)

1. rake db:drop 
1. rake db:create
1. rake db:migrate
1. rake db:seed

N.B. the above recreates both `development` and `test` databases.
There is NO NEED to use the RAILS_ENV=test env var in the above process.

In production:

1. RAILS_ENV=production rake db:drop 
1. RAILS_ENV=production rake db:create
1. RAILS_ENV=production rake db:migrate
1. RAILS_ENV=production rake db:seed

## To view routes:

1. `rails routes`

## To run the app

1. ruby bin/rails server
1. http://localhost:3000/admin
1. login with one of these email addrs and password "password"
	 "fred@fred.com"          

## Security

As of today (2024 Oct 25), security is roughly zero.

Note in particular that:

1. CORS is turned off entirely config/initializers/cors.rb
2. CSRF is turned off for APIs e.g. app/controllers/api/v1/users_controller.rb, etc

## to run the tests

  # all
  `rspec`, or
  `bundle exec rspec`

  # just user API tests
  `rspec spec/requests/api/v1/users_controller_test_spec.rb`

## code style testing

`rubocop -A`

modify style enforcer configuration: edit .rubocop.yml

docs:

* https://docs.rubocop.org/rubocop
* https://docs.rubocop.org/rubocop/configuration.html

## web host setup

### rails install

We want to use 'rvm' (ruby version manager).  Install it, create groups, add users to groups

as root:
1. apt-get install libpq-dev
1. apt-get install ruby-full # rvm is written in ruby, so we need a base version 
1. apt-get install software-properties-common
1. apt-add-repository -y ppa:rael-gc/rvm
1. apt-get update
1. apt-get install rvm
1. usermod -a -G rvm deploy # the user 'deploy' needs to be in the 'rvm' group
1. logout & log back in
1. rvm -v # verify it worked
1. rvm install 3.3.5 # (because why not; current version we're using, but these docs will be out of date eventually...)
1. bundle -v # verify it worked


as deploy:
1. echo "export PATH=/usr/share/rvm/bin/rvm:\$PATH" > ~/.bashrc
1. logout & log back in
1. rvm -v # verify it worked

as developer on local machine:
1. cap production rvm:check # verify it worked

### postgres setup

install postgres and create user 'ari_rails_user'
as root
1. `su postgres --command=psql`
1. `create database aristillus_rails;`
1. `create user ari_rails_user with password 'ari_rails_pwd';`
1. `grant all privileges on database aristillus_rails to ari_rails_user;`
1. `alter database aristillus_rails owner to ari_rails_user;`
1. `exit`

test:

1. `psql postgresql://ari_rails_user:ari_rails_pwd@localhost:5432/aristillus_rails`


### deploy infrastructure 

on local machine
1. ssh-keygen -t rsa -f ~/.ssh/keypairs/deploy_domainname
1. scp  ~/.ssh/keypairs/deploy_domainname.pub  root@domainname:/tmp

on the web server:
1. `useradd -m deploy`
1. `su deploy`
1. `cd ; mkdir .ssh`
1. `chmod 700 ~/.ssh`
1. `chmod  600 ~/.ssh/authorized_keys` # if it is too permissive you will SILENTY fail to log in with your keys!!!!
1. `cat /tmp/deploy_domainname.pub >> ~/.ssh/authorized_keys`

on local machine, test that it worked
1. `ssh deploy@domainname -i ~/.ssh/keypairs/deploy_domainname`
1. `whoami` (expect "deploy")

on the web server (to set up git access):

as user 'deploy'
1. `mkdir ~/.ssh/keypairs`
1. `ssh-keygen -t rsa -f ~/.ssh/keypairs/git_for_deploy` # empty password
1. `cp  ~/.ssh/keypairs/git_for_deploy.pub  /tmp`
1. `chmod 666  /tmp/git_for_deploy.pub`
1. write ~/.ssh/config

	Host git.domainname
		Hostname git.domainname
		IdentityFile ~/.ssh/keypairs/git_for_deploy
		IdentitiesOnly yes


as user 'git'
1. `cat /tmp/git_for_deploy.pub >> ~/.ssh/authorized_keys`

as user 'deploy': verify correctness
1. git ls-remote git@git.domainname:/home/git/repositories/aristillus_src.git HEAD

on the git server:

XXX

## one time database seeding

1. cd /var/www/aristillus_back_prod/current
1. DISABLE_DATABASE_ENVIRONMENT_CHECK=1 RAILS_ENV=production bundle exec rake db:seed

## deploy

### overview

* deployment is via tool "capistrano"
* relevant config files for that tool include
** ./Capfile
** ./config/deploy.rb
** ./config/deploy/production.rb
** ./config/deploy/staging.rb

at command line type
* `cap staging deploy`
* `cap production deploy`

what this does:
1. ssh as user `deploy` into target machine (specified in above config files)
2. as that user, do a git checkout
3. as that user, do symlink magic to put the newly checked out code in wither
   	  /var/www/aristillus_back_prod/releases
   or
   	  /var/www/aristillus_back_stage/releases

and then create a symlink from either

   	  /var/www/aristillus_back_prod/current

end result:

	/var/www/aristillus_back_*/current

has what you want

### to staging

cap staging deploy

### to production

cap production deploy

## production webservers

### rails server

The following is not correct, but it's what I'm doing 2024 Oct 26:

1. cd /var/www/aristillus_back_prod/current
1. RAILS_ENV=production  ruby bin/rails server -p 5000

we need to get cap deploy to run this, or use unix systemctl, or something.  TBD.

Jeremy is using tmux

	   # as root:
	   tmux attach -t rails_server

### nginx

config files

	   /etc/nginx/sites-available/*

restart

	`systemctl restart nginx`

## using the API

Before you can make most API calls you need:

1. to have a user
2. ...who is authenticated
3. ...and who is logged in.

Once you have accomplished those steps (see below), every request needs to contain two JSON fields:
- user_email
- user_token

A failure to provide a matching pair will result in an HTTP 401 error code (unauthorized).

In such a case, repeat the log in step.

Every response will include
- success : true / false
- user_token: replacing the previous one

You must pluck this new token out and use it in the next request.

Example:


devel
    # sign in 
	curl -X POST -H "Content-Type: application/json" -d '{ "user_email": "tjic@tjic.com", "user_password": "password"}' http://localhost:3000/api/v1/sign_in

	=> {"messages":"Signed In Successfully",
	"is_success":true,
	"data":{"user":{
	        "authentication_token":"DppAyJeN2JxZShyybEYd",  # <=== token
			"email":"tjic@tjic.com",
			"name":"Travis Corcoran",
			"id":2,
			"person_id":1,
			"cred":0,
			"created_at":"2024-11-02T18:42:58.806Z",
			"updated_at":"2024-11-08T14:30:24.253Z"}}}


	# use the token in an API call
	curl -X GET -H "Content-Type: application/json" -d '{"user_email":"tjic@tjic.com", "user_token" : "DppAyJeN2JxZShyybEYd"}' http://localhost:3000/api/v1/elections/list_open_elections

	=> {"success":true,"data":{"elections":[]}}

	# [ optional ] use the token to sign out ; destroys the token at the server, so no further API calls can be made with tyhe current token
	curl -X POST -H "Content-Type: application/json" -d '{ "user_email": "tjic@tjic.com", "user_token": "DppAyJeN2JxZShyybEYd"}' http://localhost:3000/api/v1/sign_out

	=> {"success":true, "message":"Signed Out Successfully"}

prod
    # sign in 
	curl -X POST -H "Content-Type: application/json" -d '{ "user_email": "tjic@tjic.com", "user_password": "password"}' https://api.domainname/api/v1/sign_in

	=> {"messages":"Signed In Successfully",
	"is_success":true,
	"data":{"user":{
	        "authentication_token":"DppAyJeN2JxZShyybEYd",  # <=== token
			"email":"tjic@tjic.com",
			"name":"Travis Corcoran",
			"id":2,
			"person_id":1,
			"cred":0,
			"created_at":"2024-11-02T18:42:58.806Z",
			"updated_at":"2024-11-08T14:30:24.253Z"}}}


	# use the token in an API call
	curl -X GET -H "Content-Type: application/json" -d '{"user_email":"tjic@tjic.com", "user_token" : "DppAyJeN2JxZShyybEYd"}' https://api.domainname/api/v1/elections/list_open_elections

	=> {"success":true,"data":{"elections":[]}}

	# [ optional ] use the token to sign out ; destroys the token at the server, so no further API calls can be made with tyhe current token
	curl -X POST -H "Content-Type: application/json" -d '{ "user_email": "tjic@tjic.com", "user_token": "DppAyJeN2JxZShyybEYd"}' https://api.domainname/api/v1/sign_out

	=> {"success":true, "message":"Signed Out Successfully"}


### create a new user (existing /subscribe)

devel:

    curl -X POST -H "Content-Type: application/json" -d '{"email":"fred2@fred.com", "password":"fredfred"}' http://localhost:3000/api/v1/users > /tmp/www.html

production:

    curl -X POST -H "Content-Type: application/json" -d '{"email":"fred2@fred.com", "password":"fredfred"}' https://api.domainname/api/v1/users > /tmp/www.html

success:
	{"id":16,"nym":null,"email":"fred30@fred.com","person_id":null,"created_at":"2024-10-24T15:31:25.123Z",
	 "updated_at":"2024-10-24T15:31:25.123Z"}
	
failure:
	{"error":"Validation failed: Email can't be blank"}

### verify a new user (existing /verify/token )

The user will get an email containing, e.g.

  <a href="http://localhost:3000/users/confirmation?confirmation_token=G3Rrhi-XEnPFC3P-H4by">Confirm my account</a></p>

and this works.

However, I have also created an API to access this

devel:
    curl -X POST -H "Content-Type: application/json" -d '{"token":"G3Rrhi-XEnPFC3P-H4by"}' http://localhost:3000/api/v1/users/verify > /tmp/www.html

production:
    curl -X POST -H "Content-Type: application/json" -d '{"token":"G3Rrhi-XEnPFC3P-H4by"}' https://api.domainname/api/v1/users/verify > /tmp/www.html


success:
	{"id":14,"nym":null,"email":"fred3@fred.com","person_id":null,"created_at":"2024-10-23T18:59:50.178Z","updated_at":"2024-10-23T19:24:59.910Z"}
	
failure:
	{"error":"user not found with token yyy"}


### list all users (experimental ; should be removed)

production:
	curl -X GET -H "Content-Type: application/json" -d ' https://api.domainname/api/v1/users

devel:
	curl -X GET -H "Content-Type: application/json" https//localhost:3000/api/v1/users

### get user reputation

devel:
	curl -X GET -H "Content-Type: application/json" -d '{"user_email": "tjic@tjic.com",  "user_token" : "ar99VzjMJwiUbkkxyqba", "id":"25"}' http://localhost:3000/api/v1/users/get_reputation

production:
	curl -X GET -H "Content-Type: application/json" -d '{"user_email": "tjic@tjic.com",  "user_token" : "ar99VzjMJwiUbkkxyqba", "id":"1"}' https://api.domainname/api/v1/users/get_reputation

success:
	{"id":5,"reputation":25}
	
failure:
	{"id":"25","error":"user not found"}

### list_open_elections

devel:

  curl -X GET -H "Content-Type: application/json" -d '{"user_email": "tjic@tjic.com",  "user_token" : "ar99VzjMJwiUbkkxyqba"}' http://localhost:3000/api/v1/elections/list_open_elections

### vote_in_election

devel:
	curl -X POST -H "Content-Type: application/json" -d '{"id":"25", "election_id": 12, "choice_id": 99 }' http://localhost:3000/api/v1/elections/vote_in_election > /tmp/www.html

## membership tiers

list them all

devel:

  curl -X GET -H "Content-Type: application/json" -d '{"user_email": "...",  "user_token" : "..."}' http://localhost:3000/api/v1/memberships/

  curl -X GET -H "Content-Type: application/json" -d '{"user_email": "...",  "user_token" : "..."}' https://api.domainname/api/v1/memberships/

success:
	{"success":true, "data"=>[
						{"id"=>1, "name"=>"base", "description"=>"description", "price"=>"10.0"},
						{"id"=>2, "name"=>"silver", "description"=>"description", "price"=>"20.0"},
						{"id"=>3, "name"=>"gold", "description"=>"description", "price"=>"50.0"}] }
	


## payments

create a new subscription:

	curl -X POST  -H "Content-Type: application/json" -d  { "user_email": "..." ,
                     "user_token": "...",
                     "payment_method_id": "...", # from Stripe
                     "membership_id": 1   # from an earlier call to list membership tiers
                   } http://localhost:3000/api/v1/payments/create_subscription

success:
	{"success":true, "data"=>{"client_secret"=>"pi_3QNcbxK4nKOvSeRh1OZzwvkg_secret_aYfsyz8v0ZcHaCNGRClaAzJfV"}}