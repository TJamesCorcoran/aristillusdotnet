# frozen_string_literal: true

# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.2].define(version: 20_241_122_133_913) do
  # These are extensions that must be enabled in order to support this database
  enable_extension 'plpgsql'

  create_table 'active_admin_comments', force: :cascade do |t|
    t.string 'namespace'
    t.text 'body'
    t.string 'resource_type'
    t.bigint 'resource_id'
    t.string 'author_type'
    t.bigint 'author_id'
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.index %w[author_type author_id], name: 'index_active_admin_comments_on_author'
    t.index ['namespace'], name: 'index_active_admin_comments_on_namespace'
    t.index %w[resource_type resource_id], name: 'index_active_admin_comments_on_resource'
  end

  create_table 'addresses', force: :cascade do |t|
    t.string 'first_line'
    t.string 'second_line'
    t.string 'city'
    t.string 'state'
    t.string 'zip'
    t.string 'country'
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
  end

  create_table 'auth_tokens', force: :cascade do |t|
    t.bigint 'user_id', null: false
    t.string 'authentication_token', limit: 30, null: false
    t.datetime 'last_used', precision: nil
    t.string 'ip'
    t.string 'useragent'
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.index %w[user_id ip], name: 'index_auth_tokens_on_user_id_and_ip', unique: true
    t.index ['user_id'], name: 'index_auth_tokens_on_user_id'
  end

  create_table 'billing_events', force: :cascade do |t|
    t.decimal 'amount', precision: 6, scale: 2
    t.text 'stripe_charge'
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
  end

  create_table 'cred_logs', force: :cascade do |t|
    t.bigint 'user_id', null: false
    t.integer 'cred'
    t.string 'cause_type', null: false
    t.bigint 'cause_id', null: false
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.index %w[cause_type cause_id], name: 'index_cred_logs_on_cause'
    t.index ['user_id'], name: 'index_cred_logs_on_user_id'
  end

  create_table 'election_choices', force: :cascade do |t|
    t.string 'name'
    t.bigint 'election_id', null: false
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.index ['election_id'], name: 'index_election_choices_on_election_id'
  end

  create_table 'election_votes', force: :cascade do |t|
    t.bigint 'user_id', null: false
    t.bigint 'election_choice_id', null: false
    t.bigint 'delegated_clone_id'
    t.boolean 'live', default: true, null: false
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.index ['delegated_clone_id'], name: 'index_election_votes_on_delegated_clone_id'
    t.index ['election_choice_id'], name: 'index_election_votes_on_election_choice_id'
    t.index ['user_id'], name: 'index_election_votes_on_user_id'
  end

  create_table 'elections', force: :cascade do |t|
    t.string 'name'
    t.string 'description'
    t.bigint 'tier_id', null: false
    t.datetime 'open_datetime'
    t.datetime 'close_datetime'
    t.boolean 'finalized', default: false, null: false
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.index ['tier_id'], name: 'index_elections_on_tier_id'
  end

  create_table 'group_members', force: :cascade do |t|
    t.bigint 'user_id', null: false
    t.bigint 'group_id', null: false
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.index ['group_id'], name: 'index_group_members_on_group_id'
    t.index ['user_id'], name: 'index_group_members_on_user_id'
  end

  create_table 'groups', force: :cascade do |t|
    t.string 'name'
    t.string 'description'
    t.bigint 'user_id', null: false
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.index ['name'], name: 'index_groups_on_name', unique: true
    t.index ['user_id'], name: 'index_groups_on_user_id'
  end

  create_table 'keys', force: :cascade do |t|
    t.string 'name'
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
  end

  create_table 'memberships', force: :cascade do |t|
    t.string 'name'
    t.string 'description'
    t.decimal 'price'
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
  end

  create_table 'people', force: :cascade do |t|
    t.string 'name'
    t.date 'dob'
    t.boolean 'male', default: true, null: false
    t.string 'phone'
    t.bigint 'address_id'
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.index ['address_id'], name: 'index_people_on_address_id'
    t.index ['name'], name: 'index_people_on_name', unique: true
  end

  create_table 'third_party_rating_entities', force: :cascade do |t|
    t.string 'name'
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
  end

  create_table 'third_party_rating_grades', force: :cascade do |t|
    t.bigint 'third_party_rating_entity_id', null: false
    t.string 'grade'
    t.integer 'value'
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.index ['third_party_rating_entity_id'], name: 'idx_on_third_party_rating_entity_id_a740a24278'
  end

  create_table 'third_party_rating_instances', force: :cascade do |t|
    t.bigint 'third_party_rating_entity_id', null: false
    t.string 'instance'
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.datetime 'interval_begin'
    t.datetime 'interval_end'
    t.index ['third_party_rating_entity_id'], name: 'idx_on_third_party_rating_entity_id_5aa412528e'
  end

  create_table 'third_party_ratings', force: :cascade do |t|
    t.bigint 'person_id', null: false
    t.bigint 'third_party_rating_instance_id', null: false
    t.bigint 'third_party_rating_grade_id', null: false
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.index ['person_id'], name: 'index_third_party_ratings_on_person_id'
    t.index ['third_party_rating_grade_id'], name: 'index_third_party_ratings_on_third_party_rating_grade_id'
    t.index ['third_party_rating_instance_id'], name: 'index_third_party_ratings_on_third_party_rating_instance_id'
  end

  create_table 'tiers', force: :cascade do |t|
    t.string 'name'
    t.string 'description'
    t.integer 'threshhold_low'
    t.integer 'threshhold_high'
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
  end

  create_table 'user_keys', force: :cascade do |t|
    t.bigint 'user_id', null: false
    t.bigint 'key_id', null: false
    t.string 'value'
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.index ['key_id'], name: 'index_user_keys_on_key_id'
    t.index ['user_id'], name: 'index_user_keys_on_user_id'
  end

  create_table 'users', force: :cascade do |t|
    t.string 'name'
    t.string 'email'
    t.bigint 'person_id'
    t.integer 'cred', default: 0
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.string 'encrypted_password', default: '', null: false
    t.string 'reset_password_token'
    t.datetime 'reset_password_sent_at'
    t.datetime 'remember_created_at'
    t.string 'confirmation_token'
    t.datetime 'confirmed_at'
    t.datetime 'confirmation_sent_at'
    t.string 'unconfirmed_email'
    t.json 'tokens'
    t.index ['confirmation_token'], name: 'index_users_on_confirmation_token', unique: true
    t.index ['cred'], name: 'index_users_on_cred'
    t.index ['email'], name: 'index_users_on_email', unique: true
    t.index ['name'], name: 'index_users_on_name', unique: true
    t.index ['person_id'], name: 'index_users_on_person_id'
    t.index ['reset_password_token'], name: 'index_users_on_reset_password_token', unique: true
  end

  create_table 'vote_delegations', force: :cascade do |t|
    t.bigint 'user_id', null: false
    t.integer 'rank'
    t.boolean 'live', default: true, null: false
    t.bigint 'delegate_id', null: false
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.index ['delegate_id'], name: 'index_vote_delegations_on_delegate_id'
    t.index %w[user_id rank], name: 'index_vote_delegations_on_user_id_and_rank', unique: true
    t.index ['user_id'], name: 'index_vote_delegations_on_user_id'
  end

  add_foreign_key 'auth_tokens', 'users'
  add_foreign_key 'cred_logs', 'users'
  add_foreign_key 'election_choices', 'elections'
  add_foreign_key 'election_votes', 'election_choices'
  add_foreign_key 'election_votes', 'election_votes', column: 'delegated_clone_id'
  add_foreign_key 'election_votes', 'users'
  add_foreign_key 'elections', 'tiers'
  add_foreign_key 'group_members', 'groups'
  add_foreign_key 'group_members', 'users'
  add_foreign_key 'groups', 'users'
  add_foreign_key 'people', 'addresses'
  add_foreign_key 'third_party_rating_grades', 'third_party_rating_entities'
  add_foreign_key 'third_party_rating_instances', 'third_party_rating_entities'
  add_foreign_key 'third_party_ratings', 'people'
  add_foreign_key 'third_party_ratings', 'third_party_rating_grades'
  add_foreign_key 'third_party_ratings', 'third_party_rating_instances'
  add_foreign_key 'user_keys', 'keys'
  add_foreign_key 'user_keys', 'users'
  add_foreign_key 'vote_delegations', 'users'
  add_foreign_key 'vote_delegations', 'users', column: 'delegate_id'
end
