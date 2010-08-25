class MessageGateway
  module Parser
    class UnwiredAppeal < SimpleCarrier
      add_carrier_mapping :tmobile,               "1"
      add_carrier_mapping :att,                   "3"
      add_carrier_mapping :sprint_pcs,            "4"
      add_carrier_mapping :verizon_wireless,      "5"
      add_carrier_mapping :nextel,                "6"
      add_carrier_mapping :boost_prepay,          "7"
      add_carrier_mapping :alltel,                "8"
      add_carrier_mapping :cellular_one,          "9"
      add_carrier_mapping :virgin_mobile,         "12"
      add_carrier_mapping :us_cellular,           "13"
      add_carrier_mapping :appalachian_wireless,  "21"
      add_carrier_mapping :bluegrass_cellular,    "22"
      add_carrier_mapping :boost_unlimited,       "23"
      add_carrier_mapping :cellcom,               "20"
      add_carrier_mapping :ecit,                  "24"
      add_carrier_mapping :cellular_one,          "14"
      add_carrier_mapping :centennial_wireless,   "15"
      add_carrier_mapping :cincinnati_bell,       "16"
      add_carrier_mapping :immix_wireless,        "25"
      add_carrier_mapping :nntc,                  "36"
      add_carrier_mapping :ntelos,                "19"
      add_carrier_mapping :revol_wireless,        "26"
      add_carrier_mapping :south_central,         "33"
      add_carrier_mapping :unicel,                "27"
      add_carrier_mapping :west_central_wireless, "28"
    end
  end
end
