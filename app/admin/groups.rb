# frozen_string_literal: true

ActiveAdmin.register Group do
  remove_filter :group_members, :users, :owner_id # , :description
  # See permitted parameters documentation:
  # https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  #
  # Uncomment all parameters which should be permitted for assignment
  #
  permit_params :name, :description
  #
  # or
  #
  # permit_params do
  #   permitted = [:name, :description, :user_id]
  #   permitted << :other if params[:action] == 'create' && current_user.admin?
  #   permitted
  # end

  show do
    attributes_table do
      (Group.attribute_names.map(&:to_sym) - []).each do |attr|
        row attr
      end
    end

    panel 'members' do
      table_for group.users do
        column('members') { |user| link_to(user.name, admin_user_path(user)) }
      end
    end

    active_admin_comments
  end
end
