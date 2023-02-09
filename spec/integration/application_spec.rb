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

  context 'GET /albums'  do
    it 'should return the list of albums with links' do
      response = get('/albums')
      
      expect(response.status).to eq(200)
      expect(response.body).to include('<a href="/albums/2">Surfer Rosa</a><br />')
      expect(response.body).to include('<a href="/albums/3">Waterloo</a><br />')
    end
  end
  
  context 'GET /albums/:id' do
    it 'returns info about album 2' do
      response = get('/albums/2')

      expect(response.status).to eq(200)
      expect(response.body).to include('<h1>Surfer Rosa</h1>')
      expect(response.body).to include('Release year: 1988')
      expect(response.body).to include('Artist: Pixies')
    end
  end

  context 'GET /albums/new' do
    it 'return the form to add a new album' do
      response = get('/albums/new')

      expect(response.status).to eq(200)
      expect(response.body).to include('<form method="POST" action="/albums">')
      expect(response.body).to include('<input type="text" name="album_title" />')
      expect(response.body).to include('<input type="text" name="album_release_year" />')
      expect(response.body).to include('<input type="text" name="album_artist_id" />')
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
  
  context 'GET /artists' do
    it 'should return the list of artists with links' do
      response = get('/artists')

      expect(response.status).to eq(200)
      expect(response.body).to include('<a href="artists/2">ABBA</a><br />')
      expect(response.body).to include('<a href="artists/3">Taylor Swift</a><br />')
    end
  end
  
  context 'GET /artists/:id' do
    it 'returns info about artist 2 with link' do
      response = get('/artists/2')
      
      expect(response.status).to eq(200)
      expect(response.body).to include('Name: ABBA')
      expect(response.body).to include('Genre: Pop')
    end
  end

  context "POST /artists" do
    it 'creates a new artist' do
      response = post(
        '/artists',
        name: 'Wild nothing',
        genre: 'Indie'
      )

      expect(response.status).to eq(200)
      expect(response.body).to eq('')

      response = get('/artists')
      expect(response.body).to include('Wild nothing')
    end
  end
end