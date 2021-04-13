module Turbovax
  class TestPortal < Portal
    name "New York Health and Hospitals"
    key "ny_hh"
    # api_url "https://epicmychart.nychhc.org/mychart/OpenScheduling/OpenScheduling/GetOpeningsForProvider"
    api_url "https://epicmychart.nychhc.org/mychart/OpenScheduling/%{hey}/GetOpeningsForProvider"

    api_query_params do
      {
        noCache: rand()
      }
    end

    api_dynamic_variables do
      {
        hey: "there"
      }
    end

    request_headers "Connection" => "keep-alive",
      "accept" => "*/*",
      "x-requested-with" => "XMLHttpRequest",
      "__requestverificationtoken" => ENV["NYC_HHC_REQUEST_VERIFICATION_TOKEN"],
      "user-agent" => "Mozilla/4.0 (Macintosh; Intel Mac OS X 11_0_0) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/86.0.4280.141 Safari/537.36",
      "content-type" => "application/x-www-form-urlencoded; charset=UTF-8",
      "origin" => "https://epicmychart.nychhc.org",
      "sec-fetch-site" => "same-origin",
      "sec-fetch-mode" => "cors",
      "sec-fetch-dest" => "empty",
      "referer" => "https://epicmychart.nychhc.org/MyChart/SignupAndSchedule/EmbeddedSchedule?id=RES,11736948,11736949,11736950,11736951,11736952,11736953,11736954,11736955,11736956,11736957,11736958,11736959,11703875,11703874,11703367,11703868,11703869,11703873,11703870,11703871,11703872&dept=1012009896,1020009908,1015009901,1011009919,1021009929,1022008535,1013009914,1014009903,1021009930,1021009930,1024009929,1025009903,1022008534,1023009915,1055009828,1050009831,1051009831,1052000031,1053009828,1054009831,1051102309,&vt=11790692",
      "accept-encoding" => "gzip, deflate, br",
      "accept-language" => "zh-CN,zh;q=0.9,en-US;q=0.8,en;q=0.7",
      "cookie" => ENV["NYC_HHC_COOKIE"]
  end
end
