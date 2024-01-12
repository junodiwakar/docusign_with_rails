class UserDetailsController < ApplicationController
	def new
		@user_detail = UserDetail.new
	end

	def create
		@user_detail = UserDetail.new(user_detail_params)

		if @user_detail.save
		filled_pdf_io = fill_pdf_form(@user_detail)
		@user_detail.filled_pdf.attach(io: filled_pdf_io, filename: "filled_form_#{@user_detail.id}.pdf", content_type: 'application/pdf')

		redirect_to @user_detail, notice: 'User detail was successfully created.'
		else
			render :new
		end
	end
    
	def show
		@user = UserDetail.find(params[:id])
	end
	
	private

	def user_detail_params
		params.require(:user_detail).permit(:full_name, :email, :phone_no, :address)
	end

	def fill_pdf_form(user)
		pdf_path = Rails.root.join('app', 'assets', 'pdf', 'original_form.pdf')
		filled_pdf = Tempfile.new(['filled_form', '.pdf'])

		pdf_fields = {
		'full_name' => user.full_name,
		'email' => user.email,
		'address' => user.address
		}

		pdftk = PdfForms.new('/usr/bin/pdftk')
		pdftk.fill_form(pdf_path, filled_pdf.path, pdf_fields)

		filled_pdf.rewind
		filled_pdf
	end
end
