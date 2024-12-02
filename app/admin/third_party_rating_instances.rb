# frozen_string_literal: true

ActiveAdmin.register ThirdPartyRatingInstance do
  remove_filter :third_party_rating_entity, :third_party_ratings, :interval_begin, :interval_end

  # See permitted parameters documentation:
  # https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  #
  # Uncomment all parameters which should be permitted for assignment
  #
  # permit_params :third_party_rating_entity_id, :instance
  #
  # or
  #
  # permit_params do
  #   permitted = [:third_party_rating_entity_id, :instance]
  #   permitted << :other if params[:action] == 'create' && current_user.admin?
  #   permitted
  # end

  show do
    attributes_table do
      (ThirdPartyRatingInstance.attribute_names.map(&:to_sym) -
       %i[]
      ).each do |attr|
        row attr
      end
    end

    panel 'Ratings' do
      table_for third_party_rating_instance.third_party_ratings do
        column('person') { |tpr| link_to(tpr.person.name, admin_person_url(tpr.person)) }
        column('grade') { |tpr| tpr.third_party_rating_grade.grade }
      end
    end
    active_admin_comments
  end
end
