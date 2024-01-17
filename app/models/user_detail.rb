class UserDetail < ApplicationRecord
    validates :full_name, :email, :phone_no, :address, presence: true
    # has_one_attached :filled_pdf

    def create_docusign_client
		app_config = AppConfig.where(key: "docusign_access_token").first_or_create
		auth_token = app_config.value
		config = DocuSign_eSign::Configuration.new
		config.host = Rails.configuration.host_url
		api_client = DocuSign_eSign::ApiClient.new(config)
		api_client.default_headers["Authorization"] = "Bearer #{auth_token}"
		envelopes_api = DocuSign_eSign::EnvelopesApi.new(api_client)
    end

    def send_to_docusign
		begin
			options = DocuSign_eSign::CreateEnvelopeOptions.new
			response = create_docusign_client.create_envelope(Rails.configuration.ds_account_id, make_envelope, DocuSign_eSign::CreateEnvelopeOptions.default)
			self.update(docusign_envelope_id: response.envelope_id)
			get_embedded_link # only when request from desktop
		rescue Exception => e
			if e.message == "Unauthorized"
				DocusignJwtCreator.new({}).check_jwt_token
				send_to_docusign
			else
				p e	
			end
		end
    end

    def get_embedded_link
		begin
			view_request = DocuSign_eSign::RecipientViewRequest.new
			view_request.return_url = "#{Rails.configuration.app_url}/user_details/#{self.id}"
			view_request.authentication_method = 'none'
			view_request.email = self.email
			view_request.user_name = self.full_name
			view_request.client_user_id = self.id.to_s
			view_request.ping_frequency = '600' # seconds
			view_request.ping_url = "#{Rails.configuration.app_url}/quote/payment?state=123" # Optional setting
			view_request.frame_ancestors = [Rails.configuration.message_origins_url, Rails.configuration.app_url]
			view_request.message_origins = [Rails.configuration.message_origins_url]
			result = create_docusign_client.create_recipient_view Rails.configuration.ds_account_id, docusign_envelope_id, view_request
			self.update(docusign_focused_url: result.url)
		rescue Exception => e
			
			if e.message == "Unauthorized"
				DocusignJwtCreator.new({}).check_jwt_token
				get_embedded_link
				else
				p e
			end
		end
    end
    
    def make_envelope
		envelope_definition = DocuSign_eSign::EnvelopeDefinition.new
		envelope_definition.email_subject = 'User signed terms and conditions document'
		
		doc1 = DocuSign_eSign::Document.new
		doc1.document_base64 = Base64.encode64(File.binread(Rails.root.join('tmp', "t&c-#{self.id}.pdf")))
		doc1.name = 'T&C'
		doc1.file_extension = 'pdf'
		doc1.document_id = 1

		# The order in the docs array determines the order in the envelope
		envelope_definition.documents = [doc1]
		# Create a signer recipient to sign the document, identified by name and email
		# We're setting the parameters via the object creation
		signer1 = DocuSign_eSign::Signer.new({ email: self.email, name: self.full_name, clientUserId: self.id.to_s, recipientId: self.id.to_s })

		signer1.routing_order = '1'
		# The DocuSign platform searches throughout your envelope's documents for matching
		# anchor strings. So the sign_here_2 tab will be used in both document 2 and 3
		# since they use the same anchor string for their "signer 1" tabs.
		## to create sign stamp
		sign_here = DocuSign_eSign::SignHere.new
		sign_here.anchor_string = 'signature'
		sign_here.anchor_units = 'inches' 
		sign_here.anchor_x_offset = '0'
		sign_here.anchor_y_offset = '-0.3'

		# Tabs are set per recipient/signer
		tabs = DocuSign_eSign::Tabs.new
		tabs.sign_here_tabs = [sign_here]
		# tabs.date_signed_tabs = [signdate_here]
		signer1.tabs = tabs
		# Add the recipients to the envelope object
		recipients = DocuSign_eSign::Recipients.new
		recipients.signers = [signer1]

		envelope_definition.recipients = recipients
		# Request that the envelope be sent by setting status to "sent".
		# To request that the envelope be created as a draft, set status to "created"
		envelope_definition.status = 'sent'
		envelope_definition
    end
end
