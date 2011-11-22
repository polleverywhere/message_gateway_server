require 'nokogiri'

class MessageGateway
  module Parser
    class Mblox < Base
      include CarrierAware
      include Util::Carrier

      add_carrier_mapping  :west_central_wireless,                        '31079'
      add_carrier_mapping  :unicel,                                       '31068'
      add_carrier_mapping  :cincinnati_bell,                              '31607'
      add_carrier_mapping  :att,                                          '31002'
      add_carrier_mapping  :appalachian_wireless,                         '31069'
      add_carrier_mapping  :verizon_wireless,                             '31003'
      add_carrier_mapping  :immix_wireless,                               '31070'
      add_carrier_mapping  :tmobile,                                      '31004'
      add_carrier_mapping  :revol_wireless,                               '31005'
      add_carrier_mapping  :dobson_att,                                   '31006'
      add_carrier_mapping  :nextel,                                       '31007'
      add_carrier_mapping  :centennial_wireless,                          '31030'
      add_carrier_mapping  :cellular_south,                               '31052'
      add_carrier_mapping  :boost_prepay,                                 '31008'
      add_carrier_mapping  :cellular_one,                                 '31075'
      add_carrier_mapping  :alltel,                                       '31009'
      add_carrier_mapping  :cellcom,                                      '31054'
      add_carrier_mapping  :virgin_mobile,                                '31010'
      add_carrier_mapping  :boost_unlimited,                              '31011'
      add_carrier_mapping  :bluegrass_cellular,                           '31078'
      add_carrier_mapping  :us_cellular,                                  '31012'
      add_carrier_mapping  :gci,                                          "gci_corp"
      add_carrier_mapping  :att,                                          "cingular-blue"
      add_carrier_mapping  :inland_cellular,                              "inland"
      add_carrier_mapping  :cricket_communications,                       "cricket"
      add_carrier_mapping  :ivc,                                          "illinois_valley"
      add_carrier_mapping  :hickory,                                      "hickory"
      add_carrier_mapping  :nntc,                                         "nntc"
      add_carrier_mapping  :iowa,                                         "iowa"
      add_carrier_mapping  :scutah,                                       "scutah"
      add_carrier_mapping  :metro_pcs,                                    "metro"
      add_carrier_mapping  :ubet_wireless,                                "ubet"
      add_carrier_mapping  :midwest,                                      "midwest"
      add_carrier_mapping  :syringa,                                      "syringa"
      add_carrier_mapping  :npi,                                          "npi"
      add_carrier_mapping  :thumb_cellular,                               "thumb"
      add_carrier_mapping  :qwest_corp,                                   "qwest"
      add_carrier_mapping  :aliant,                                       "aliant"
      add_carrier_mapping  :suncom,                                       "suncom"
      add_carrier_mapping  :bell,                                         "bell"
      add_carrier_mapping  :centennial_wireless,                          "centennial"
      add_carrier_mapping  :fido,                                         "fido"
      add_carrier_mapping  :voce,                                         "voce"
      add_carrier_mapping  :mts,                                          "mts"
      add_carrier_mapping  :virgin_mobile,                                "virgin_us"
      add_carrier_mapping  :northtel,                                     "northerntel"
      add_carrier_mapping  :boost_iden,                                   "boost_iden"
      add_carrier_mapping  :rogers,                                       "rogers"
      add_carrier_mapping  :boost_cdma,                                   "boost_cdma"
      add_carrier_mapping  :cellular_south,                               "cellular_south"
      add_carrier_mapping  :sasktel,                                      "sasktel"
      add_carrier_mapping  :ntelos,                                       "ntelos"
      add_carrier_mapping  :telebec,                                      "telebec"
      add_carrier_mapping  :cellcom,                                      "cellcom"
      add_carrier_mapping  :telus,                                        "telus"
      add_carrier_mapping  :unicel,                                       "rural"
      add_carrier_mapping  :virgin_ca,                                    "virgin_ca"
      add_carrier_mapping  :bluegrass_cellular,                           "bluegrass_cellular"
      add_carrier_mapping  :united_wireless,                              "united"
      add_carrier_mapping  :ecit,                                         "cellular_one_east_central"
      add_carrier_mapping  :east_kentucky,                                "East_Kentucky"
      add_carrier_mapping  :pcs,                                          '11'
      add_carrier_mapping  :sprint_pcs,                                   '5'
      add_carrier_mapping  :fmtc,                                         '141'
      add_carrier_mapping  :advantage_cellular,                           '12'
      add_carrier_mapping  :aliant_telecom,                               '100'
      add_carrier_mapping  :tmp_simmetry_comms,                           '142'
      add_carrier_mapping  :choice_wireless,                              '13'
      add_carrier_mapping  :m_qube_com,                                   '34'
      add_carrier_mapping  :nextel,                                       '6'
      add_carrier_mapping  :mt_t_mobility,                                '55'
      add_carrier_mapping  :awcc,                                         '77'
      add_carrier_mapping  :amarillo_cellular,                           '143'
      add_carrier_mapping  :amica_wireless,                               '14'
      add_carrier_mapping  :unicel,                                       '35'
      add_carrier_mapping  :alltel,                                       '7'
      add_carrier_mapping  :nbtel_mobility,                               '56'

      def call(env)
        request = Rack::Request.new(env)
        doc = Nokogiri::XML.parse(request.params['xmldata'] || request.params['XMLDATA'])
        from = sanitize_phone_number(doc.xpath('//ResponseService/ResponseList/Response/OriginatingNumber').inner_text)
        to = sanitize_phone_number(doc.xpath('//ResponseService/ResponseList/Response/Destination').inner_text)
        body = doc.xpath('//ResponseService/ResponseList/Response/Data').inner_text
        carrier_id = normalize_carrier(doc.xpath('//ResponseService/ResponseList/Response/Deliverer').inner_text)
        build_and_dispatch(from, to, body, carrier_id)
      end
    end
  end
end
