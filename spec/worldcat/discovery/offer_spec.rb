# Copyright 2014 OCLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require_relative '../../spec_helper'

describe WorldCat::Discovery::Offer do
  
  context "when retrieving holdings as offers for a bib" do
    before(:all) do
      wskey = OCLC::Auth::WSKey.new('api-key', 'api-key-secret')
      WorldCat::Discovery.configure(wskey)

      url = 'https://beta.worldcat.org/discovery/offer/oclc/30780581'
      stub_request(:get, url).to_return(:body => body_content("offer_set.rdf"), :status => 200)
      @results = WorldCat::Discovery::Offer.find_by_oclc(30780581)
    end
    
    it "should return a offer results set" do
      @results.class.should == WorldCat::Discovery::OfferSearchResults
    end

    it "should contain the right id" do
      uri = RDF::URI("http://132.174.253.29:8080/discovery/offer/oclc/30780581?itemsPerPage=10&startNum=0")
      @results.id.should == uri
    end
    
    it "should have the right number of items" do
      @results.items.size.should == 10
    end
    
    it "should return a result set of Offers" do
      @results.items.each {|offer| offer.class.should == WorldCat::Discovery::Offer}
    end
    
    it "should respond to a request for its items as offers" do
      @results.offers.size.should == 10
      @results.offers.each {|item| item.class.should == WorldCat::Discovery::Offer}
    end
    
    it "should return the Offers in the correct order" do
      i = 1
      @results.offers.each {|offer| offer.display_position.should == i; i += 1}
    end
    
    it "should have the correct total results" do
      @results.total_results.should == 439
    end
    
    it "should have the correct start index" do
      @results.start_index.should == 1
    end
    
    it "should have the correct items per page" do
      @results.items_per_page.should == 10
    end
    
    context "when looking at the first offer" do
      before(:all) do
        @offer = @results.offers.first
        @item_offered = @offer.item_offered
        @collection = @item_offered.collection
        @library = @collection.library
      end
      
      it "should have the correct type" do
        @offer.type.should == RDF::URI.new('http://schema.org/Offer')
      end
      
      it "should have the correct display position" do
        @offer.display_position.should == 1
      end
      
      it "should have the correct item offered" do
        @item_offered.subject.should == RDF::Node.new("A0")
        @item_offered.type.should == RDF::URI.new('http://schema.org/SomeProducts')
        @item_offered.bib.subject.should == RDF::URI.new('http://www.worldcat.org/oclc/30780581')
        @item_offered.bib.name.should == 'The Wittgenstein reader'
      end

      it "should belong to the correct collection" do
        @collection.type.should == RDF::URI.new('http://purl.org/dc/terms/Collection')
        @collection.oclc_symbol.should == 'AIZ'
      end

      it "should be managed by the correct library" do
        @library.id.should == 'http://worldcat.org/wcr/organization/resource/72545'
        @library.type.should == RDF::URI.new('http://schema.org/Library')
        @library.name.should == 'ACADEMIA SINICA INST EUROPEAN AM STUDIES'
        @library.collection.should == @collection
      end
      
      
    end
  end
  
end