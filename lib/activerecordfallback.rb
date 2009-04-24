module ActiveRecordFallback

  # constructs a URI parameter string like "?a=b&c=d"
  # from a hash, for example the :conditions hash from a call to ActiveRecord::find()
  # like {:a=>'b', :c=>'d'}
  def self.uri_params(options)
    return options.empty? ?
         '' :
         '?' + options.collect { |k,v| "#{k}=#{v}"  #FIXME escape !!
                               }.join('&')
  end

  module ClassMethods

    def find(*args)
      use_fallback = false

      if args.first == :first

        options = args.extract_options!
        validate_find_options(options)

        #begin
          result = find_initial(options)
        #rescue ActiveRecord::RecordNotFound=>e
        #  use_fallback = true
        #end

        use_fallback = true if result.nil?

      else
        return super(*args)
      end
 
      if use_fallback
        result = find_initial_fallback(options)
      end

      return result
    end
 
  end

  def self.included(sub)
    sub.extend ClassMethods
  end

end

module ActiveRecordClassMethods
  include ActiveRecordFallback
end

ActiveRecord::Base.send(:include, ActiveRecordClassMethods)
