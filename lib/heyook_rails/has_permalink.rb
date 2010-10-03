module HeyookRails
  module HasPermalink
    def self.included(base)
      base.extend ClassMethods
    end 
    
    module ClassMethods
      def has_permalink 
        include HeyookRails::HasPermalink::InstanceMethods                 
        before_save :set_permalink                  
      end 
    end 

    module InstanceMethods
      def to_param
        "#{id}-#{permalink}" 
      end            

      private
        def set_permalink
          self.permalink = name.downcase.gsub(/[^0-9a-z]+/, ' ').strip.gsub(' ', '-') if name
        end
    end 
  end
end

ActiveRecord::Base.send :include, HeyookRails::HasPermalink