ActiveAdmin.register Embed do

  permit_params :profile_id, :kind, :data


  index do
    selectable_column
    id_column
    column :uuid
    column :profile
    # column :kind
    column :updated_at
    actions
  end


  form do |f|
    f.inputs do
      f.input :profile, as: :select, collection: Profile.pluck(:name, :id)

      # f.input :kind, as: :select, collection: Embed.kinds.map { |key,name| [name, key] }

      f.input :data, as: :text
      # todo: integrate friendlier json editor
      # https://lorefnon.me/2015/03/02/dealing-with-json-fields-in-active-admin.html
      # f.input :data, as: :text, input_html: { class: 'jsoneditor-target' }

    end
    f.actions
  end

end
