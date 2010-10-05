module HeyookRails
  module HasRoles
    def self.included(base)
      base.extend ClassMethods
    end
    
    module InstanceMethods
      def roles=(roles)                  
        self.roles_mask = (roles & defined_roles).map { |r| 2**defined_roles.index(r) }.sum 
      end

      def roles
        defined_roles.reject { |r| ((roles_mask || 0) & 2**defined_roles.index(r)).zero? }
      end

      def role?(role)
        roles.include? role.to_s
      end
    end  
    
    module ClassMethods
      def has_roles *roles
        
        raise "Must specify at least one role" if roles.empty?          
        
        cattr_accessor :defined_roles, :default_role 
        
        self.default_role = roles.extract_options![:default].to_s
        self.default_role ||= roles.last.to_s
        self.default_role.freeze
        
        self.defined_roles = roles.dup.map(&:to_s).freeze
        
        scope :with_role, lambda { |role| where("roles_mask & #{2**defined_roles.index(role.to_s)} > 0") }  
        
        before_save { self.roles = Array.wrap(default_role) }

        include HeyookRails::HasRoles::InstanceMethods
        
        defined_roles.each do |role|
          define_method "#{role}?" do
            role? "#{role}"
          end
        end
      end 
    end
  end
end

ActiveRecord::Base.send :include, HeyookRails::HasRoles