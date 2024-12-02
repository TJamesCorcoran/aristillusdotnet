# frozen_string_literal: true

ActiveAdmin.register ThirdPartyRatingGrade do
  #  remove_filter :address, :user, :third_party_ratings

  # See permitted parameters documentation:
  # https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  #
  # Uncomment all parameters which should be permitted for assignment
  #
  # permit_params :third_party_rating_entity_id, :grade, :value
  #
  # or
  #
  # permit_params do
  #   permitted = [:third_party_rating_entity_id, :grade, :value]
  #   permitted << :other if params[:action] == 'create' && current_user.admin?
  #   permitted
  # end
end
