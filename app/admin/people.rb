# frozen_string_literal: true

ActiveAdmin.register Person do
  remove_filter :address, :user, :third_party_ratings

  # See permitted parameters documentation:
  # https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  #
  # Uncomment all parameters which should be permitted for assignment
  #
  # permit_params :name, :dob, :male, :phone, :address_id
  #
  # or
  #
  # permit_params do
  #   permitted = [:name, :dob, :male, :phone, :address_id]
  #   permitted << :other if params[:action] == 'create' && current_user.admin?
  #   permitted
  # end

  show do
    attributes_table do
      (Person.attribute_names.map(&:to_sym) -
       %i[]
      ).each do |attr|
        row attr
      end
    end

    panel 'User' do
      table_for [person.user] do
        column('user') { |user| link_to(user.name, admin_user_url(user)) }
      end
    end

    panel 'Ratings' do
      table_for person.third_party_ratings do
        column('instance') do |tpr|
          link_to(tpr.third_party_rating_instance.instance,
                  admin_third_party_rating_instance_url(tpr.third_party_rating_instance))
        end
        column('grade') do |tpr|
          link_to(tpr.third_party_rating_grade.grade, admin_third_party_rating_grade_url(tpr.third_party_rating_grade))
        end
      end
    end
    active_admin_comments
  end
end
