class User::Update < ::Form
  attribute :user, :model, primary: true

  attribute :first_name,  :string
  attribute :last_name,   :string
  attribute :email,       :string
  attribute :location,    :string, default: proc { user.location.try(:address) }
  attribute :language,    :integer

  def language_options
    User.languages.map do |key, val|
      [ I18n.t("language.#{key}"), val ]
    end
  end

  class Submit < ::Form::Submit
    def execute
      user.assign_attributes(inputs.slice(:first_name, :last_name, :language))
      user.identity.assign_attributes(inputs.slice(:email))

      user.location = Location.location_from(location)

      user.save
      user.identity.save
    end
  end
end