class UserDetail < ApplicationRecord
    validates :full_name, :email, :phone_no, :address, presence: true
    has_one_attached :filled_pdf
end
