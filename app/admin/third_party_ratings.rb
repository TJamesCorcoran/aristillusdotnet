# frozen_string_literal: true

ActiveAdmin.register ThirdPartyRating do
  remove_filter :person, :third_party_rating_instance, :third_party_rating_grade

  # See permitted parameters documentation:
  # https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  #
  # Uncomment all parameters which should be permitted for assignment
  #
  # permit_params :person_id, :third_party_rating_instance_id, :third_party_rating_grade_id
  #
  # or
  #
  # permit_params do
  #   permitted = [:person_id, :third_party_rating_instance_id, :third_party_rating_grade_id]
  #   permitted << :other if params[:action] == 'create' && current_user.admin?
  #   permitted
  # end
end
