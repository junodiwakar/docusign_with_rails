class UserDetailsController < ApplicationController
	def new
		@user_detail = UserDetail.new
	end

	def create
		@user_detail = UserDetail.new(user_detail_params)

		if @user_detail.save
			filled_pdf_path = fill_pdf_form(@user_detail)
			redirect_to @user_detail, notice: 'User detail was successfully created.'
			@user_detail.send_to_docusign
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
		pdf_path = Rails.root.join('app', 'assets', 'pdf', 'final_sample.pdf')
		filled_pdf_path = Rails.root.join('tmp', "t&c-#{user.id}.pdf")

		pdf_fields = {
			'full_name' => user.full_name,
			'user_name' => user.full_name,
			'email' => user.email,
			'address' => user.address
		}

		pdftk = PdfForms.new('/usr/bin/pdftk')
		pdftk.fill_form(pdf_path, filled_pdf_path, pdf_fields)

		filled_pdf_path.to_s
	end
end
