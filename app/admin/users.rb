# frozen_string_literal: true

ActiveAdmin.register User do
  remove_filter :group_members, :groups, :user_keys, :administered_groups, :reset_password_token, :confirmation_token,
                :cred_logs, :vote_delegations, :delegates, :cred, :authentication_token
  # See permitted parameters documentation:
  # https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  #
  # Uncomment all parameters which should be permitted for assignment
  #
  permit_params :name, :email
  #
  # or
  #
  # permit_params do
  #   permitted = [:name, :email, :person_id, :encrypted_password, :reset_password_token,
  #         :reset_password_sent_at, :remember_created_at]
  #   permitted << :other if params[:action] == 'create' && current_user.admin?
  #   permitted
  # end

  show do
    attributes_table do
      (User.attribute_names.map(&:to_sym) -
       %i[encrypted_password reset_password_token
          reset_password_sent_at reset_password_sent_at
          remember_created_at confirmation_token]
      ).each do |attr|
        row attr
      end
    end

    panel 'Person' do
      table_for [user.person] do
        column('person') { |person| link_to(person.name, admin_person_url(person)) }
      end
    end

    panel 'Cred Log' do
      ul do
        li "total: #{user.get_cred}"
      end
      table_for user.cred_logs do
        column('date', &:created_at)
        column('cred', &:cred)
        column('type') do |cl|
          if cl.cause_type == 'ThirdPartyRating'
            link_to(cl.cause_type, admin_third_party_rating_url(cl.cause))
          else
            cl.cause_type
          end
        end
      end
    end

    panel 'User keys' do
      table_for user.user_keys do
        column('key') { |userkey| userkey.key.name }
        column('value', &:value)
      end
    end

    panel 'Groups' do
      table_for user.groups do
        column('group') { |group| link_to(group.name, admin_group_path(group)) }
      end
    end

    active_admin_comments
  end
end
