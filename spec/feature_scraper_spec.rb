describe FeatureScraper do
  before do
    GisScraper.configure
  end

  root = 'http://gps.digimap.gg/arcgis/rest/services/'
  recursive_layer = root + 'StatesOfJersey/JerseyMappingOL/MapServer/0'
  non_recursive_layer = root + 'JerseyUtilities/JerseyUtilities/MapServer/145'
  let(:scraper) { FeatureScraper.new recursive_layer }
  let(:bad_url_scraper) { FeatureScraper.new 'garbage' }
  let(:odd_pk_scraper) { FeatureScraper.new non_recursive_layer }

  context '#new(url)' do
    it 'instantiates an instance of the class' do
      expect(scraper.class).to eq FeatureScraper
    end
  end

  context '#name' do
    it 'returns the name of the layer' do
      expect(scraper.send(:name)). to eq 'Gazetteer'
    end
  end

  context '#pk' do
    it 'returns the pk field, if it is first in the field list' do
      expect(scraper.send(:pk)).to eq 'OBJECTID'
    end

    it 'returns the pk field, if it is elsewhere in the field list' do
      expect(odd_pk_scraper.send(:pk)).to eq 'OBJECTID'
    end
  end

  context '#max' do
    it 'returns the "maxRecordCount" value for the layer' do
      expect(scraper.send(:max)).to eq 1000
    end
  end

  context '#form' do
    it 'returns a Mechanize::Form for the layer query page' do
      expect(scraper.send(:form).class).to eq Mechanize::Form
    end
  end

  context '#count' do
    it 'returns the number of records for the layer' do
      expect(scraper.send(:count)).to eq 67_537
    end
  end

  context '#data(records_set_num)' do
    it 'returns a hash of json data with no args' do
      expect(scraper.send(:data, 0).class).to eq Hash
    end

    it 'returns data for the set of records' do
      expect(scraper.send(:data, 67)['features'].count).to eq 537
    end
  end

  context '#features(num_threads)' do
    it 'returns an array of the features data for all layer objects' do
      scraper.instance_variable_set(:@max, 2)
      scraper.instance_variable_set(:@loops, 2)
      expect(scraper.send(:features, 1).count).to eq 4
    end
  end

  context '#json_data', :public do
    it 'returns string of json data for all layer objects' do
      scraper.instance_variable_set(:@max, 2)
      allow(scraper).to receive(:count) { 4 }
      expect(scraper.json_data.class).to eq String
    end
  end
end
