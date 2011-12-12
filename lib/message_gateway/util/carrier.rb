class MessageGateway
  module Util
    module Carrier
      include PhoneNumber
      module CarrierClassMethods
        def add_carrier_mapping(carrier_id, native_id)
          init_mappings
          CarrierInfo.lookup(carrier_id) or raise("Unable to look up #{carrier_id.inspect}")
          carrier_mappings[native_id.to_s] = carrier_id
          reverse_carrier_mappings[carrier_id.to_s] = native_id
        end

        def import_carrier_mappings(cls)
          cls.carrier_mappings.each do |native_id, carrier_id|
            add_carrier_mapping(carrier_id, native_id)
          end
        end
      end

      def self.included(o)
        o.module_eval "
          def self.init_mappings
            unless class_variable_defined?(:@@carrier_mappings)
              class_variable_set(:@@carrier_mappings, {})
              class_variable_set(:@@reverse_carrier_mappings, {})
            end
          end

          def self.carrier_mappings
            init_mappings
            class_variable_get(:@@carrier_mappings)
          end

          def self.reverse_carrier_mappings
            init_mappings
            class_variable_get(:@@reverse_carrier_mappings)
          end

          class << self
            include MessageGateway::Util::Carrier::CarrierClassMethods
          end
        "
      end

      def normalize_carrier(id)
        self.class.init_mappings
        self.class.carrier_mappings[id.to_s]
      end

      def denormalize_carrier(carrier)
        self.class.init_mappings
        self.class.reverse_carrier_mappings[carrier.id.to_s]
      end

      def carrier_for_id(id)
        CarrierInfo.lookup(id)
      end

      class CarrierInfo
        CarrierMapping = {}

        attr_reader :id, :name
        def initialize(id, name)
          @id, @name = id, name
        end

        def hash
          @id.hash
        end

        def ==(o)
          o.id == @id
        end

        def email?
          false
        end

        class CarrierInfoWithEmail < CarrierInfo
          include PhoneNumber
          def initialize(id, name, email_domain)
            super(id, name)
            @email_domain = email_domain
          end

          def to_email(num)
            canoncialized_number = canonicalize_phone_number(num)
            if canoncialized_number and canoncialized_number.size == 11
              "#{canoncialized_number}@#{@email_domain}"
            else
              nil
            end
          end

          def email?
            true
          end
        end
        class CarrierInfoWithShorterEmail < CarrierInfoWithEmail
          def to_email(num)
            email_number = super
            email_number && email_number[1,email_number.size]
          end
        end

        def self.lookup(id)
          CarrierMapping[id.to_s]
        end

        def self.register(id, name)
          CarrierMapping[id.to_s] = CarrierInfo.new(id, name)
        end

        def self.register_with_email(id, name, email)
          CarrierMapping[id.to_s] = CarrierInfoWithEmail.new(id, name, email)
        end

        def self.carrier_mapping
          CarrierMapping
        end

        def self.register_with_short_email(id, name, email)
          CarrierMapping[id.to_s] = CarrierInfoWithShorterEmail.new(id, name, email)
        end

        register_with_short_email :att,                   "AT&T/Cingular",                     "txt.att.net"
        register_with_short_email :appalachian_wireless,  "Appalachian Wireless",              "awsms.com"
        register_with_short_email :centennial_wireless,   "Centennial Wireless",               "cwemail.com"
        register_with_short_email :att_mobility,          "AT&T Mobility (formerly Cingular)", "txt.att.net"

        register_with_email       :tmobile,               "T-Mobile",              "tmomail.net"
        register_with_email       :sprint_pcs,            "Sprint PCS",            "messaging.sprintpcs.com"
        register_with_email       :verizon_wireless,      "Verizon Wireless",      "vtext.com"
        register_with_email       :nextel,                "Nextel",                "messaging.nextel.com"
        register_with_email       :boost_prepay,          "Boost Prepay",          "myboostmobile.com"
        register_with_email       :alltel,                "Alltel",                "message.alltel.com"
        register_with_email       :cellular_one,          "Cellular One",          "mobile.celloneusa.com"
        register_with_email       :virgin_mobile,         "Virgin Mobile",         "vmobl.net"
        register_with_email       :us_cellular,           "US Cellular",           "email.uscc.net"
        register_with_email       :bluegrass_cellular,    "Bluegrass Cellular",    "sms.bluecell.com"
        register_with_email       :boost_unlimited,       "Boost Unlimited",       "myboostmobile.com"
        register_with_email       :cellcom,               "Cellcom",               "cellcom.quiktxt.com"
        register_with_email       :cellular_south,        "Cellular South",        "csouth1.com"
        register_with_email       :dobson_att,            "Dobson (part of AT&T",  "mobile.dobson.net"
        register_with_email       :west_central_wireless, "West Central Wireless", "sms.wcc.net"

        register                  :advantage_cellular,    "Advantage Cellular"
        register                  :airadigm_communications, "Airadigm Communications"
        register                  :airtouch_paging,       "AirTouch Paging"
        register                  :awcc,                  "Allied Wireless Communications Company (AWCC)"
        register                  :amica_wireless,        "Amica Wireless"
        register                  :cellular_properties,   "Cellular Properties"
        register                  :carolina_west_wireless, "Carolina West Wireless"
        register                  :conestoga_wireless,    "Conestoga Wireless"
        register                  :cc_communications,     "CC Communications"
        register                  :east_kentucky,         "east_kentucky"
        register                  :enid_pioneer_telephone_coop, "Enid/Pioneer Telephone Coop"
        register                  :edge_wireless,         "Edge Wireless"
        register                  :virgin_ca,             "virgin_ca"
        register                  :telus,                 "telus"
        register                  :telebec,               "telebec"
        register                  :sasktel,               "sasktel"
        register                  :boost_cdma,            "boost_cdma"
        register                  :rogers,                "rogers"
        register                  :boost_iden,            "boost_iden"
        register                  :northtel,              "northtel"
        register                  :mts,                   "mts"
        register                  :voce,                  "voce"
        register                  :fido,                  "Fido"
        register                  :bell,                  "Bell"
        register                  :suncom,                "Suncom"
        register                  :aliant,                "Aliant"
        register                  :npi,                   "NPI"
        register                  :nbtel_mobility,        "NBTel Mobility"
        register                  :midwest,               "Midwest"
        register                  :mid_missouri_telephone, "Mid-Missouri Telephone"
        register                  :m_qube_com,            "m-Qube.com"
        register                  :mt_t_mobility,         "MT&T Mobility"
        register                  :mobile_tel,            "Mobile Tel"
        register                  :scutah,                "Scutah"
        register                  :iowa,                  "Iowa"
        register                  :hickory,               "Hickory"
        register                  :cox,                   "Cox"
        register                  :choice_wireless,       "Choice Wireless"
        register                  :century_tel_wireless,  "Century Tel Wireless"
        register                  :breakaway,             "Breakaway"
        register                  :alaska,                "Alaska"
        register                  :qwest_corp,            "QWest Corp"
        register                  :cincinnati_bell,       "Cincinnati Bell"
        register                  :immix_wireless,        "Immix Wireless"
        register                  :revol_wireless,        "Revol Wireless"
        register                  :unicel,                "Unicel (formerly Rural Cellular"
        register                  :ireland_vodafone,      "Ireland Vodafone"
        register                  :ireland_o2,            "Ireland O2"
        register                  :ireland_meteor,        "Ireland Meteor"
        register                  :ireland_3,             "Ireland 3"
        register                  :ireland_tesco,         "Ireland Tesco"
        register                  :ireland_bulk,          "Ireland Bulk"
        register                  :acs_wireless,          "ACS Wireless"
        register                  :all_west_wireless,     "All West Wireless"
        register                  :cambridge_telecom,     "Cambridge Telecom"
        register                  :cricket_communications,"Cricket Communications"
        register                  :ecit,                  "ECIT - Cellular One of East Central Illinois"
        register                  :first_cellular_of_southern_illinois, "First Cellular of Southern Illinois"
        register                  :hargray_wireless_llc,  "Hargray Wireless LLC"
        register                  :fmtc,                  "FMTC - Farmers Mutual Telephone Company"
        register                  :gci,                   "GCI - General Communications, Inc"
        register                  :golden_state_cellular, "Golden State Cellular"
        register                  :inland_cellular,       "Inland Cellular"
        register                  :amarillo_cellular,     "Cellular One of Amarillo"
        register                  :cellular_san_luis_obispo, "Cellular One of San Luis Obispo"
        register                  :ivc,                   "IVC - Illinois Valley Cellular"
        register                  :metro_pcs,             "Metro PCS"
        register                  :mohave_cellular,       "Mohave Cellular"
        register                  :nex_tech_wireless,     "Nex-Tech Wireless"
        register                  :northern_telephone,    "Northern Telephone"
        register                  :nntc,                  "NNTC - Nucla-Naturita Telephone Company"
        register                  :ntelos,                "nTelos"
        register                  :newtel_mobility,       "NewTel Mobility"
        register                  :nebraska,              "Nebraska Wireless"
        register                  :peoples_wireless,      "Peoples Wireless"
        register                  :pine_belt,             "Pine Belt"
        register                  :pine_telephone,        "Pine Telephone"
        register                  :plateau_telecom,       "Plateau Telecom"
        register                  :silver_star_pcs,       "Silver Star PCS (aka Gold Star"
        register                  :snake_river_pcs,       "Snake River PCS (aka Eagle Telephone System, Inc	"
        register                  :south_central,         "South Central"
        register                  :syringa,               "Syringa"
        register                  :srt_communications,    "SRT Communications"
        register                  :thumb_cellular,        "Thumb Cellular"
        register                  :tmp_simmetry_comms,    "TMP/Simmetry Comms."
        register                  :three_rivers_pcs,      "3 Rivers PCS"
        register                  :tsi,                   "TSI"
        register                  :ubet_wireless,         "UBET Wireless"
        register                  :united_wireless,       "United Wireless"
        register                  :virginia_cellular,     "Virginia Cellular"
        register                  :west_virginia_wireless,  "West Virginia Wireless"
        register                  :xit_rural_coop,        "XIT Rural Telephone Coop"
      end
    end
  end
end
