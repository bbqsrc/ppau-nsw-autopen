require 'sinatra'
require 'prawn'
require 'date'
require 'time'
require 'base64'
require 'stringio'

index = File.open("#{File.dirname(__FILE__)}/static/index.html").read
set :public_folder, File.dirname(__FILE__) + '/static'

get '/' do
  index
end

post '/' do
  form = Prawn::Document.new(:template => "DECLARATION_OF_PARTY_MEMBERSHIP_1_Feb_2012.pdf")
  draft form
  
  left_col = 13
  mid_col = 178
  right_col = 343
  sm_right_col = 436
  
  form.text_box params[:first_name], :at => [left_col, 607]
  form.text_box params[:middle_name], :at => [mid_col, 607]
  form.text_box params[:last_name], :at => [right_col, 607]
  form.text_box "#{params[:address]}, #{params[:suburb]} NSW", :at => [left_col, 535]
  form.text_box params[:postcode], :at => [sm_right_col, 535]

  dob_row = 462
  dob = Date.parse(params[:date_of_birth])
  form.text_box dob.mday.to_s, :at => [left_col, dob_row]
  form.text_box dob.strftime("%B"), :at => [mid_col, dob_row]
  form.text_box dob.year.to_s, :at => [right_col, dob_row]

  form.text_box "Pirate Party Australia (NSW Branch)", :at => [left_col, 392]

  form.text_box Time.now.strftime("%d/%m/%Y"), :at => [sm_right_col, 297]
  form.image decode_image(params[:signature]), :at => [left_col-5, 315], :scale => 0.5

  response.headers['content-type'] = 'application/pdf'
  response.headers['content-disposition'] = 'attachment; filename="ppau-nsw-application.pdf"'
  form.render
end

def draft(form)
    form.text_box "DRAFT - NOT TO BE SUBMITTED TO NSWEC", :at => [80, 300]
end

def decode_image(data)
  img = /data:image\/png;base64,(.*)/.match(data)[1]
  img = Base64.decode64(img)
  StringIO.new(img)
end
