class MessageGateway
  module Parser
    class MobileMessenger < SimpleCarrier

      add_carrier_mapping  :northern_telephone,                           '102'
      add_carrier_mapping  :cellular_san_luis_obispo,                     '144'
      add_carrier_mapping  :cellular_properties,                          '15'
      add_carrier_mapping  :us_cellular,                                  '36'
      add_carrier_mapping  :bell,                                         '8'
      add_carrier_mapping  :newtel_mobility,                              '57'
      add_carrier_mapping  :carolina_west_wireless,                       '145'
      add_carrier_mapping  :midwest,                                      '16'
      add_carrier_mapping  :west_central_wireless,                        '37'
      add_carrier_mapping  :cincinnati_bell,                              '125'
      add_carrier_mapping  :cricket_communications,                       '146'
      add_carrier_mapping  :conestoga_wireless,                           '17'
      #unknown mapping for 59
      add_carrier_mapping  :suncom,                                       '1042'
      add_carrier_mapping  :cellular_south,                               '126'
      add_carrier_mapping  :peoples_wireless,                             '147'
      add_carrier_mapping  :first_cellular_of_southern_illinois,          '20'
      add_carrier_mapping  :airadigm_communications,                      '18'
      add_carrier_mapping  :dobson_att,                                   '41'
      add_carrier_mapping  :virgin_mobile,                                '170'
      add_carrier_mapping  :xit_rural_coop,                               '148'
      add_carrier_mapping  :hargray_wireless_llc,                         '21'
      add_carrier_mapping  :fido,                                         '19'
      add_carrier_mapping  :mts,                                          '127'
      add_carrier_mapping  :nebraska,                                     '43'
      add_carrier_mapping  :boost_unlimited,                              '128'
      add_carrier_mapping  :immix_wireless,                               '150'
      add_carrier_mapping  :appalachian_wireless,                         '149'
      add_carrier_mapping  :virgin_ca,                                    '130'
      add_carrier_mapping  :tsi,                                          '129'
      add_carrier_mapping  :cc_communications,                            '151'
      add_carrier_mapping  :iowa,                                         '22'
      add_carrier_mapping  :mohave_cellular,                              '152'
      add_carrier_mapping  :century_tel_wireless,                         '23'
      add_carrier_mapping  :npi,                                          '44'
      add_carrier_mapping  :west_virginia_wireless,                       '153'
      add_carrier_mapping  :telebec,                                      '132'
      add_carrier_mapping  :metro_pcs,                                    '24'
      add_carrier_mapping  :ntelos,                                       '45'
      add_carrier_mapping  :pine_telephone,                               '154'
      add_carrier_mapping  :mobile_tel,                                   '25'
      add_carrier_mapping  :bluegrass_cellular,                           '46'
      add_carrier_mapping  :plateau_telecom,                              '155'
      add_carrier_mapping  :acs_wireless,                                 '26'
      add_carrier_mapping  :golden_state_cellular,                        '156'
      add_carrier_mapping  :psc_wireless,                                 '50'
      add_carrier_mapping  :edge_wireless,                                '48'
      add_carrier_mapping  :srt_communications,                           '157'
      add_carrier_mapping  :att,                                          '1'
      add_carrier_mapping  :plateau_telecom,                              '51'
      add_carrier_mapping  :mid_missouri_telephone,                       '49'
      add_carrier_mapping  :cellcom,                                      '158'
      add_carrier_mapping  :tmobile,                                     '2'
      add_carrier_mapping  :airtouch_paging,                              '52'
      add_carrier_mapping  :pine_belt,                                    '160'
      add_carrier_mapping  :virginia_cellular,                            '159'
      add_carrier_mapping  :att_mobility,                                 '3'
      add_carrier_mapping  :centennial_wireless,                          '53'
      add_carrier_mapping  :verizon_wireless,                             '4'
      add_carrier_mapping  :sasktel,                                      '54'
      add_carrier_mapping  :enid_pioneer_telephone_coop,                  '140'
      add_carrier_mapping  :three_rivers_pcs,                                 '11'
      add_carrier_mapping  :sprint_pcs,                                   '5'
      add_carrier_mapping  :fmtc,                                         '141'
      add_carrier_mapping  :advantage_cellular,                           '12'
      add_carrier_mapping  :aliant,                                      '100'
      add_carrier_mapping  :tmp_simmetry_comms,                           '142'
      add_carrier_mapping  :choice_wireless,                              '13'
      add_carrier_mapping  :m_qube_com,                                   '34'
      add_carrier_mapping  :nextel,                                       '6'
      add_carrier_mapping  :mt_t_mobility,                                '55'
      add_carrier_mapping  :awcc,                                         '77'
      add_carrier_mapping  :amarillo_cellular,                            '143'
      add_carrier_mapping  :amica_wireless,                               '14'
      add_carrier_mapping  :unicel,                                       '35'
      add_carrier_mapping  :alltel,                                       '7'
      add_carrier_mapping  :nbtel_mobility,                               '56'

      def body_value(req)
        @prefix ? req.params['message'].gsub(/^#{Regexp.quote(@prefix)} /, '') : req.params['message']
      end

      def from_value(req)
        req.params['number']
      end

      def to_value(req)
        req.params['shortcode']
      end
    end
  end
end
