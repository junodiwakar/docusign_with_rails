class AppConfig < ApplicationRecord
	def self.method_missing(method, *args, &block)
		find_by(key: method)&.value || super
	end
end