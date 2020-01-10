require 'rails_helper'

RSpec.describe "Letters", type: :request do
  def data(response)
    JSON.parse(response.body, symbolize_names: true)[:data]
  end

  def attributes(response)
    data = data(response)
    if data.is_a? Array
      data.first[:attributes]
    else
      data[:attributes]
    end
  end

  describe "GET /letters" do
    before { create(:letter) }
    before { create(:letter, public_only: false) }
    # before { Letter.all.each { |l| l.save } }

    context 'when all letters are requested w/o auth' do
      before { get '/letters' }

      it 'should return 200' do
        expect(response).to have_http_status(200)
      end

      it 'should only have one letter' do
        expect(data(response).length).to eq(1)
      end

      it 'should not get all letters in database' do
        expect(Letter.count).to eq(2)
      end

      it 'should have a date with a year of 1957 - 1965' do
        date = attributes(response)[:date]
        expect(Date.parse(date).year).to be_between(1957, 1965)
      end

      it 'should not have the content' do
        expect(attributes(response)).not_to have_key(:content)
      end

      it 'should include all the attributes' do
        LetterSerializer._attributes.each do |attr|
          next if attr == :id
          expect(attributes(response)).to have_key(attr.to_s.dasherize.to_sym)
        end
      end

      it 'should include a flat list of recipients' do
        expect(attributes(response)[:postmark]).to be_kind_of(String)
      end
    end

    # context 'when all letters are requested with auth' do
    #   # before { header 'HTTP_ORIGIN', 'http://ot.ecdsdev.org' }
    #   before {
    #     header 'HTTP_ORIGIN', 'http://ot.ecdsdev.org'
    #     get '/letters'
    #   }
    #   it 'should get all letters' do
    #     expect(JSON.parse(response.body)['data'].length).to eq(2)
    #   end

    #   it 'should get as many letters as as there are in the db' do
    #     expect(JSON.parse(response.body)['data'].length).to eq(Letter.count)
    #   end
    # end
  end
end
