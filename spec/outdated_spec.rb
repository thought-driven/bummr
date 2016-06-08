require 'spec_helper'

describe Bummr::Outdated do
  describe "#parse_gem_from" do
    it 'line' do
      line = '  * devise (newest 4.1.1, installed 3.5.2) in group "default"'

      gem = Bummr::Outdated.instance.parse_gem_from(line)

      expect(gem[:name]).to eq('devise')
      expect(gem[:newest]).to eq('4.1.1')
      expect(gem[:installed]).to eq('3.5.2')
    end

    it 'line in group' do
      line = '  * rake (newest 11.1.2, installed 10.4.2)'

      gem = Bummr::Outdated.instance.parse_gem_from(line)

      expect(gem[:name]).to eq('rake')
      expect(gem[:newest]).to eq('11.1.2')
      expect(gem[:installed]).to eq('10.4.2')
    end

    it 'line with requested' do
      line = '  * rails (newest 4.2.6, installed 4.2.5.1, requested ~> 4.2.0) in group "default"'

      gem = Bummr::Outdated.instance.parse_gem_from(line)

      expect(gem[:name]).to eq('rails')
      expect(gem[:newest]).to eq('4.2.6')
      expect(gem[:installed]).to eq('4.2.5.1')
    end
  end
end
