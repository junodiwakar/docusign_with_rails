# frozen_string_literal: true

class Users::RegistrationsController < Devise::RegistrationsController
  # before_action :configure_sign_up_params, only: [:create]
  # before_action :configure_account_update_params, only: [:update]

  def create
    super do |resource|
      fill_pdf_form(resource) if resource.persisted?
    end
  end

  private

  def fill_pdf_form(user)
    pdf_path = Rails.root.join('app','assets', 'pdf', 'original_form.pdf')
  
    filled_pdf_filename = "filled_form_#{user.id}.pdf"
    desktop_path = File.join(Dir.home, 'Desktop')
    filled_pdf_path = File.join(desktop_path, filled_pdf_filename)
    full_name = "#{user.first_name} #{user.last_name}"
    pdf_fields = {
      'full_name' => full_name,
      'email' => user.email,
      'address' => user.address
    }
    pdftk = PdfForms.new('/usr/bin/pdftk')
    pdftk.fill_form(pdf_path, filled_pdf_path,pdf_fields)
  end
  
end
