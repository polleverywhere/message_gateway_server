class MessageGateway
  module Parser
    class MxTelecom < SimpleCarrier
      add_carrier_mapping  :acs_wireless,           "ACSUS"
      add_carrier_mapping  :all_west_wireless,      "ALLWESTUS"
      add_carrier_mapping  :alltel,                 "ALLTELUS"
      add_carrier_mapping  :att_mobility,           "CINGULARUS"
      add_carrier_mapping  :att,                    "ATTUS"
      add_carrier_mapping  :bluegrass_cellular,     "BLUEGRASSUS"
      add_carrier_mapping  :boost_unlimited,        "BOOSTUS"
      add_carrier_mapping  :cambridge_telecom,      "CTCUS"
      add_carrier_mapping  :cellcom,                "CELLCOMUS"
      add_carrier_mapping  :cellular_south,         "CELLULARSOUTHUS"
      add_carrier_mapping  :centennial_wireless,    "CENTENNIALUS"
      add_carrier_mapping  :cincinnati_bell,        "CINBELLUS"
      add_carrier_mapping  :cricket_communications, "CRICKETUS"
      add_carrier_mapping  :dobson_att,             "DOBSONUS"
      add_carrier_mapping  :ecit,                   "ECITUS"
      add_carrier_mapping  :appalachian_wireless,   "APPALACHIANUS"
      add_carrier_mapping  :fmtc,                   "FARMERSMUTUALUS"
      add_carrier_mapping  :gci,                    "GCIUS"
      add_carrier_mapping  :sprint_pcs,             "GOLDENSTATEUS"
      add_carrier_mapping  :immix_wireless,         "IMMIXUS"
      add_carrier_mapping  :inland_cellular,        "INLANDUS"
      add_carrier_mapping  :ivc,                    "IVCUS"
      add_carrier_mapping  :metro_pcs,              "METROPCSUS"
      add_carrier_mapping  :nex_tech_wireless,      "NEXTECHUS"
      add_carrier_mapping  :nextel,                 "NEXTELUS"
      add_carrier_mapping  :nntc,                   "NUCLANATURITAUS"
      add_carrier_mapping  :ntelos,                 "NTELOSUS"
      add_carrier_mapping  :revol_wireless,         "REVOLUS"
      add_carrier_mapping  :silver_star_pcs,        "GOLDSTARUS"
      add_carrier_mapping  :snake_river_pcs,        "EAGLEUS"
      add_carrier_mapping  :south_central,          "SOUTHCENTRALUTAHUS"
      add_carrier_mapping  :sprint_pcs,             "SPRINTUS"
      add_carrier_mapping  :syringa,                "SYRINGAUS"
      add_carrier_mapping  :tmobile,                "TMOBILEUS"
      add_carrier_mapping  :thumb_cellular,         "THUMBUS"
      add_carrier_mapping  :ubet_wireless,          "UNITABASINUS"
      add_carrier_mapping  :unicel,                 "RURALCELUS"
      add_carrier_mapping  :united_wireless,        "UNITEDWIRELESSUS"
      add_carrier_mapping  :verizon_wireless,       "VERIZONUS"
      add_carrier_mapping  :virgin_mobile,          "VIRGNUS"
      add_carrier_mapping  :west_central_wireless,  "WCENTRALUS"

      def body_value(req)
        req['smsmsg']
      end

      def to_value(req)
        req['smsto']
      end

      def from_value(req)
        req['smsfrom']
      end

      def carrier_value(req)
        req['network']
      end
    end
  end
end