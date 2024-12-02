# frozen_string_literal: true

ActiveAdmin.register ThirdPartyRatingEntity do
  remove_filter :third_party_rating_instances, :third_party_rating_grades

  # See permitted parameters documentation:
  # https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  #
  # Uncomment all parameters which should be permitted for assignment
  #
  # permit_params :name
  #
  # or
  #
  # permit_params do
  #   permitted = [:name]
  #   permitted << :other if params[:action] == 'create' && current_user.admin?
  #   permitted
  # end

  show do
    attributes_table do
      (ThirdPartyRatingEntity.attribute_names.map(&:to_sym) -
       %i[]
      ).each do |attr|
        row attr
      end
    end

    panel 'Instances' do
      table_for third_party_rating_entity.third_party_rating_instances do
        column('instance') { |tpri| link_to(tpri.instance, admin_third_party_rating_instance_url(tpri)) }
      end
    end
    active_admin_comments
  end
end
