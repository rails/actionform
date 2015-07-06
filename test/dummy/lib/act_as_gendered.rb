module ActAsGendered
  MALE = { :value => 0, :display_name => "Male" }
  FEMALE = { :value => 1, :display_name => "Female" }

  def self.included(base)
    base.extend(ActAsGenderedMethods)
  end

  module ActAsGenderedMethods
    def act_as_gendered
      extend ClassMethods
      include InstanceMethods

      validates_inclusion_of :gender, :in => [MALE[:value], FEMALE[:value]]
    end
  end

  module ClassMethods
    def get_genders_dropdown
      {
        MALE[:display_name] => MALE[:value],
        FEMALE[:display_name] => FEMALE[:value]
      }
    end
  end

  module InstanceMethods
    def gender_display_name
      return gender == MALE[:value] ?
        MALE[:display_name] :
        FEMALE[:display_name]
    end
  end
end
