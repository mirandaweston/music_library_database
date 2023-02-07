require "spec_helper"
require "rack/test"
require_relative '../../app'

describe Application do
  include Rack::Test::Methods

  let(:app) { Application.new }

  before(:each) do
    albums_seeds_sql = File.read("spec/seeds/albums_seeds.sql")
    artists_seeds_sql = File.read("spec/seeds/artists_seeds.sql")
    connection = PG.connect({ host: "127.0.0.1", dbname: "music_library_test" })
    connection.exec(albums_seeds_sql)
    connection.exec(artists_seeds_sql)
  end

  context "GET /albums" do
    it 'returns the list of albums' do
      response = get('/albums')

      expected_response = 'Doolittle, Surfer Rosa, Waterloo, Super Trouper, Bossanova, Lover, Folklore, I Put a Spell on You, Baltimore, Here Comes the Sun, Fodder on My Wings, Ring Ring'

      expect(response.status).to eq(200)
      expect(response.body).to eq(expected_response)
    end
  end

  context "POST /albums" do
    it 'creates a new album' do
      response = post(
        '/albums',
        title: 'Voyage',
        release_year: '2022',
        artist_id: '2'
      )

      expect(response.status).to eq(200)
      expect(response.body).to eq('')

      response = get('/albums')

      expect(response.body).to include('Voyage')
    end
  end
end