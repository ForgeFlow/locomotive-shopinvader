require 'spec_helper'

describe ShopInvader::Liquid::Drops::Store do

  let(:indices)   { '[]' }
  let(:routes)    { '[]' }
  let(:metafields){ {'_store' => {}} }
  let(:services)  { build_services_for_algolia(indices: indices) }
  let(:site)      { instance_double('Site', metafields: metafields) }
  let(:context)   { ::Liquid::Context.new({}, {}, { services: services, site: site }) }
  let(:drop)      { described_class.new.tap { |d| d.context = context } }

  describe 'asking for a store object' do

    context "the collection exists in search engine" do

      let(:indices) { '[{"name": "category" }]' }

      it { expect(drop.before_method('category')).to be_an_instance_of(ShopInvader::Liquid::Drops::SearchEngineCollection) }

    end

    context "the collection do not exist in algolia so it's an ErpCollection" do

      it { expect(drop.before_method('categories')).to be_an_instance_of(ShopInvader::Liquid::Drops::ErpCollection) }

    end

    context "the object is a singleton and do not exist in algolia so it's an ErpItem" do

      it { expect(drop.before_method('category')).to be_an_instance_of(ShopInvader::Liquid::Drops::ErpItem) }

    end


  end

end
