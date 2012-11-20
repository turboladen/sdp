require 'spec_helper'
require 'sdp/parser'
require 'base64'

describe "Parsing and creating descriptions" do
  subject { SDP::Parser.new }

  context "required fields only" do
    let(:description) { REQUIRED_ONLY }

    it "successfully parses and is valid" do
      result = subject.should parse(description)
      result.should be_a_valid_description
    end
  end

  context "missing required values" do
    %w[NO_VERSION NO_ORIGIN NO_NAME NO_CONNECT NO_TIMING].each do |missing_line|
      context missing_line.downcase.sub!(/_/, " ") do
        let(:description) { TestDescriptions.const_get(missing_line.to_sym) }

        it "successfully parses but is not valid" do
          result = subject.should parse(description)
          result.should_not be_a_valid_description
        end
      end
    end
  end

  context "more than one time description" do
    let(:description) { TWO_TIME_DESCRIPTIONS }

    it "successfully parses and is valid" do
      pending "https://github.com/turboladen/sdp/issues/8"

      result = subject.should parse(description)
      result.should be_a_valid_description
    end
  end

  context "one media section" do
    context "required media lines" do
      context "no sections contain connect line" do
        let(:description) { ONE_MEDIA_SECTION_NO_CONNECT }

        it "successfully parses and is not valid" do
          result = subject.should parse(description)
          result.should_not be_a_valid_description
        end
      end

      context "session section contains connect line" do
        let(:description) { ONE_MEDIA_SECTION_CONNECT_IN_SESSION }

        it "successfully parses and is valid" do
          result = subject.should parse(description)
          result.should be_a_valid_description
        end
      end

      context "media section contains connect line" do
        let(:description) { ONE_MEDIA_SECTION_CONNECT_IN_MEDIA }

        it "successfully parses and is valid" do
          result = subject.should parse(description)
          result.should be_a_valid_description
        end
      end
    end
  end

  context "two media sections" do
    context "required media lines" do
      context "no sections contain connect line" do
        let(:description) { TWO_MEDIA_SECTIONS_NO_CONNECT }

        it "successfully parses and is not valid" do
          result = subject.should parse(description)
          result.should_not be_a_valid_description
        end
      end

      context "session section contains connect line" do
        let(:description) { TWO_MEDIA_SECTIONS_CONNECT_IN_SESSION }

        it "successfully parses and is valid" do
          result = subject.should parse(description)
          result.should be_a_valid_description
        end
      end

      context "media sections contain connect line" do
        let(:description) { TWO_MEDIA_SECTIONS_CONNECT_IN_MEDIA }

        it "successfully parses and is valid" do
          result = subject.should parse(description)
          result.should be_a_valid_description
        end
      end
    end
  end

  context "other combinations" do
    let(:valid_sdps) do
      [
        "v=1\no=steve 1234 5555 IN IP4 123.33.22.123\ns=This is a test session\ni=And here's some info\nu=http://bobo.net/thispdf.pdf\ne=bob@thing.com (Bob!)\np=+1 555 123 0987\nc=IN IP4 224.5.234.22/24\nb=CT:1000\nt=11111 22222\nr=7d 1h 0 25h\nz=2882844526 -1h 2898848070 0\n\k=prompt\na=recvonly\na=bobo:the clown\nm=video 49170/2 RTP/AVP 31\na=hotness\na=attribute2:do stuff\nm=audio 12335 RTP/AVP 99\na=make:it now\n",
        "v=1\no=steve 1234 5555 IN IP4 123.33.22.123\ns=This is a test session\ni=And here's some info\nu=http://bobo.net/thispdf.pdf\ne=bob@thing.com (Bob!)\np=+1 555 123 0987\nc=IN IP4 224.5.234.22/24\nb=CT:1000\nt=11111 22222\nr=7d 1h 0 25h\nz=2882844526 -1h 2898848070 0\n\k=prompt\na=recvonly\na=bobo:the clown\n",
        "v=1\no=steve 1234 5555 IN IP4 123.33.22.123\ns=This is a test session\ni=And here's some info\nu=http://bobo.net/thispdf.pdf\ne=bob@thing.com (Bob!)\np=+1 555 123 0987\nc=IN IP4 224.5.234.22/24\nb=CT:1000\nt=11111 22222\nr=7d 1h 0 25h\nz=2882844526 -1h 2898848070 0\n\k=prompt\n",
        "v=1\no=steve 1234 5555 IN IP4 123.33.22.123\ns=This is a test session\ni=And here's some info\nu=http://bobo.net/thispdf.pdf\ne=bob@thing.com (Bob!)\np=+1 555 123 0987\nc=IN IP4 224.5.234.22/24\nb=CT:1000\nt=11111 22222\nr=7d 1h 0 25h\nz=2882844526 -1h 2898848070 0\n\k=clear:password\n",
        "v=1\no=steve 1234 5555 IN IP4 123.33.22.123\ns=This is a test session\ni=And here's some info\nu=http://bobo.net/thispdf.pdf\ne=bob@thing.com (Bob!)\np=+1 555 123 0987\nc=IN IP4 224.5.234.22/24\nb=CT:1000\nt=11111 22222\nr=7d 1h 0 25h\nz=2882844526 -1h 2898848070 0\n",
        "v=1\no=steve 1234 5555 IN IP4 123.33.22.123\ns=This is a test session\ni=And here's some info\nu=http://bobo.net/thispdf.pdf\ne=bob@thing.com (Bob!)\np=+1 555 123 0987\nc=IN IP4 224.5.234.22/24\nb=CT:1000\nt=11111 22222\nr=7d 1h 0 25h\nz=2882844526 -1h\n",
        "v=1\no=steve 1234 5555 IN IP4 123.33.22.123\ns=This is a test session\ni=And here's some info\nu=http://bobo.net/thispdf.pdf\ne=bob@thing.com (Bob!)\np=+1 555 123 0987\nc=IN IP4 224.5.234.22/24\nb=CT:1000\nt=11111 22222\nr=7d 1h 0 25h\n",
        "v=1\no=steve 1234 5555 IN IP4 123.33.22.123\ns=This is a test session\ni=And here's some info\nu=http://bobo.net/thispdf.pdf\ne=bob@thing.com (Bob!)\np=+1 555 123 0987\nc=IN IP4 224.5.234.22/24\nb=CT:1000\nt=11111 22222\n",
        "v=1\no=steve 1234 5555 IN IP4 123.33.22.123\ns=This is a test session\ni=And here's some info\nu=http://bobo.net/thispdf.pdf\ne=bob@thing.com (Bob!)\np=+1 555 123 0987\nc=IN IP4 224.5.234.22/24\nt=11111 22222\n",
        "v=1\no=steve 1234 5555 IN IP4 123.33.22.123\ns=This is a test session\ni=And here's some info\nu=http://bobo.net/thispdf.pdf\ne=bob@thing.com (Bob!)\nc=IN IP4 224.5.234.22/24\nt=11111 22222\n",
        "v=1\no=steve 1234 5555 IN IP4 123.33.22.123\ns=This is a test session\ni=And here's some info\nu=http://bobo.net/thispdf.pdf\nc=IN IP4 224.5.234.22/24\nt=11111 22222\n",
        "v=1\no=steve 1234 5555 IN IP4 123.33.22.123\ns=This is a test session\ni=And here's some info\nc=IN IP4 224.5.234.22/24\nt=11111 22222\n",
        #BANDWIDTH_BETWEEN_ATTRIBUTES
      ]
    end

    it "successfully parses and is valid" do
      valid_sdps.each do |sdp|
        result = subject.should parse(sdp)
        result.should be_a_valid_description
      end
    end
  end
end
