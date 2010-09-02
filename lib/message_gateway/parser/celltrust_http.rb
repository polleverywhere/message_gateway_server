require 'nokogiri'

class MessageGateway
  module Parser
    class CelltrustHttp < SimpleCarrier
      add_carrier_mapping :att,            "att"
      add_carrier_mapping :immix_wireless, "immix_pc_mng"
      add_carrier_mapping :tmobile,        "t-mobile"
      add_carrier_mapping :west_central_wireless, "west_central"
      add_carrier_mapping :att_mobility, "cingular"
      add_carrier_mapping :revol_wireless, "revol"
      add_carrier_mapping :verizon_wireless, "verizon"
      add_carrier_mapping :qwest_corp, "qwest_corp"
      add_carrier_mapping :sprint_pcs, "sprint"
      add_carrier_mapping :nex_tech_wireless, "nextech"
      add_carrier_mapping :nextel, "nextel"
      add_carrier_mapping :alaska, "alaska"
      add_carrier_mapping :alltel, "alltel"
      add_carrier_mapping :all_west_wireless, "all_west"
      add_carrier_mapping :dobson_att, "dobson"
      add_carrier_mapping :breakaway, "breakaway"
      add_carrier_mapping :us_cellular, "us-cellular"
      add_carrier_mapping :cox, "cox"
      add_carrier_mapping :cincinnati_bell, "cincinnati"
      add_carrier_mapping :fmtc, "farmers"
      add_carrier_mapping :att_mobility, "cingular"
      add_carrier_mapping :gci, "gci_corp"
      add_carrier_mapping :att, "cingular-blue"
      add_carrier_mapping :inland_cellular, "inland"
      add_carrier_mapping :cricket_communications, "cricket"
      add_carrier_mapping :ivc, "illinois_valley"
      add_carrier_mapping :hickory, "hickory"
      add_carrier_mapping :nntc, "nntc"
      add_carrier_mapping :iowa, "iowa"
      add_carrier_mapping :scutah, "scutah"
      add_carrier_mapping :metro_pcs, "metro"
      add_carrier_mapping :ubet_wireless, "ubet"
      add_carrier_mapping :midwest, "midwest"
      add_carrier_mapping :syringa, "syringa"
      add_carrier_mapping :npi, "npi"
      add_carrier_mapping :thumb_cellular, "thumb"
      add_carrier_mapping :qwest_corp, "qwest"
      add_carrier_mapping :aliant, "aliant"
      add_carrier_mapping :suncom, "suncom"
      add_carrier_mapping :bell, "bell"
      add_carrier_mapping :centennial_wireless, "centennial"
      add_carrier_mapping :fido, "fido"
      add_carrier_mapping :voce, "voce"
      add_carrier_mapping :mts, "mts"
      add_carrier_mapping :virgin_mobile, "virgin_us"
      add_carrier_mapping :northtel, "northerntel"
      add_carrier_mapping :boost_iden, "boost_iden"
      add_carrier_mapping :rogers, "rogers"
      add_carrier_mapping :boost_cdma, "boost_cdma"
      add_carrier_mapping :cellular_south, "cellular_south"
      add_carrier_mapping :sasktel, "sasktel"
      add_carrier_mapping :ntelos, "ntelos"
      add_carrier_mapping :telebec, "telebec"
      add_carrier_mapping :cellcom, "cellcom"
      add_carrier_mapping :telus, "telus"
      add_carrier_mapping :unicel, "rural"
      add_carrier_mapping :virgin_ca, "virgin_ca"
      add_carrier_mapping :bluegrass_cellular, "bluegrass_cellular"
      add_carrier_mapping :united_wireless, "united"
      add_carrier_mapping :ecit, "cellular_one_east_central"
      add_carrier_mapping :east_kentucky, "East_Kentucky"
      
      def from_value(req)
        p req.params
        req.params['OriginatorAddress']
      end

      def to_value(req)
        req.params['ServerAddress']
      end

      def body_value(req)
        req.params['Message']
      end

      def carrier_value(req)
        req.params['Carrier']
      end
    end
  end
end

