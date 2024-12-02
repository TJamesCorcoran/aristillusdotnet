# frozen_string_literal: true

# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

if 2 > 1 # Rails.env.development?
  Rails.logger.debug '== db/seeds.rb users =========='
  Group.destroy_all
  GroupMember.destroy_all

  User.destroy_all
  Person.destroy_all
  Address.destroy_all

  Key.destroy_all
  UserKey.destroy_all

  user_root = User.create!(name: 'root',
                           email: 'root@root.com',
                           person: nil,
                           password: 'password')

  key = Key.create!(name: 'profession')

  group_mover = Group.create!(name: 'NH movers',
                              description: 'NH movers - longer description',
                              owner: user_root)

  group_fbi = Group.create!(name: 'FBI raid victim',
                            description: 'FBI raid victim - longer description',
                            owner: user_root)

  group_admin = Group.create!(name: 'Admin',
                              description: 'application admin',
                              owner: user_root)

  [{ username: 'Fred', email: 'fred@fred.com', job: 'farmer', mover: true, fbi: true, admin: true },
   # ...
   { username: 'Anon', email: 'anon@gmail.com', job: 'NEET', mover: false,
     fbi: false }].each do |tuple|
    addr = Address.create!(first_line: '1 Main St',
                           second_line: '',
                           city: 'Manchester',
                           state: 'NH',
                           zip: '03101',
                           country: 'US')
    person = Person.create!(name: tuple[:username],
                            dob: Date.parse('1 Jan 1970'),
                            male: true,
                            phone: '',
                            address: addr)
    user = User.create!(name: tuple[:username],
                        email: tuple[:email],
                        person: person,
                        password: 'password',
                        confirmed_at: DateTime.now)

    #    AdminUser.create!(email: tuple[:email], password: 'password', password_confirmation: 'password')

    # set profession
    UserKey.create!(user: user, key: key, value: tuple[:job])

    # set groups
    GroupMember.create!(group: group_mover, user: user) if tuple[:mover]

    GroupMember.create!(group: group_fbi, user: user) if tuple[:fbi]

    GroupMember.create!(group: group_admin, user: user) if tuple[:admin]
  end

  Membership.create!(name: 'base', description: 'base', price: 10)
  Membership.create!(name: 'silver', description: 'silver', price: 20)
  Membership.create!(name: 'gold', description: 'gold', price: 50)

  Rails.logger.debug '== db/seeds.rb tiers =========='
  Tier.destroy_all

  Tier.create!(name: 'Founder', description: 'Founder circle', threshhold_low: 100, threshhold_high: nil)
  Tier.create!(name: 'Patron', description: 'Patron circle', threshhold_low: 80, threshhold_high: 99)
  Tier.create!(name: 'Sgt', description: 'Sgt', threshhold_low: 50, threshhold_high: 79)
  Tier.create!(name: 'Newb', description: 'Newb', threshhold_low: 20, threshhold_high: 49)

  Rails.logger.debug '== db/seeds.rb NHLA data =========='
  ImportScripts::ImportCsv::ImportNhlaData.new.rebuild

  Rails.logger.debug '== db/seeds.rb NHLA credibility =========='
  ImportScripts::ImportCreditData.new.doit

end
