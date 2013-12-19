module MobileMessenger
  module Util
    module Carriers
    
      def self.carrier_name(id)
        MM_CARRIERS[id]
      end
      
      def self.carrier_id(name)
        MM_CARRIERS.key(name)
      end
    
      MM_CARRIERS = {
        -1   => "Deactivated",
        0    => "Unknown Carrier",
        1    => "AT&T Wireless (Cingular Blue)",
        2    => "TMobile",
        3    => "AT&T (Cingular Orange)",
        4    => "Verizon Wireless",
        5    => "Sprint",
        6    => "Nextel Communications",
        7    => "Alltel",
        8    => "Bell Mobility",
        11   => "3 Rivers PCS *",
        12   => "Advantage Cellular *",
        13   => "Choice Wireless LC *",
        14   => "Amica Wireless *",
        15   => "Cellular Properties *",
        16   => "Midwest Wireless *",
        17   => "Conestoga Wireless *",
        18   => "Airadigm Communications *",
        19   => "Fido/Microcell Connexions",
        20   => "First Cellular of S. Illinois *",
        21   => "Hargray Wireless LLC *",
        22   => "Iowa Wireless Svc *",
        23   => 'Century Tel Wireless *',
        24   => "Metro PCS *",
        25   => "Mobiletel *",
        26   => "ACS Wireless *",
        27   => "ACS Wireless *",
        28   => "Western Wireless *",
        29   => "Rogers Cantel Inc",
        30   => "PCS ONE *",
        31   => "PCS Primeco *",
        32   => 'Qwest Wireless *',
        34   => 'm-Qube.com *',
        35   => 'Rural Cellular Corp ',
        36   => 'US Cellular Corp',
        37   => 'West Central Cellular ',
        41   => 'Dobson Cellular',
        43   => 'Nebraska Wireless * ',
        44   => 'NPI Wireless *',
        45   => 'NTELOS',
        46   => 'Bluegrass Cellular',
        48   => 'Edge Wireless * ',
        49   => 'Mid-Missouri Telephone *',
        50   => 'PSC Wireless * ',
        51   => 'Plateau Telecomm *',
        52   => 'Airtouch Paging * ',
        53   => 'Centennial Cellular Corp',
        54   => 'Sasktel Mobility',
        55   => "MT&T Mobility *",
        56   => "NBTel Mobility *",
        57   => "NewTel Mobility *",
        59   => "Other Carrier *",
        71   => "Telcl",
        72   => "Telefonica",
        73   => "Revol",
        74   => "Cox Wireless",
        77   => "AWCC (Allied Wireless Communication Services) - former Alltel.",
        100  => "Aliant Telecom",
        102  => "Northern Telephone",
        125  => "Cincinnati Bell",
        126  => "Cellular South",
        127  => "MTS",
        128  => "Boost Mobile",
        129  => "TSI *",
        130  => "Virgin Mobile Canada",
        132  => "Telebec",
        140  => "Enid/Pioneer Telephone Coop. *",
        141  => "Farmers Wireless *",
        142  => "Simmetry Communications *",
        143  => "Cellular One of Amarillo *",
        144  => "CellularOne of San Luis Obispo *",
        145  => "Carolina West Wireless",
        146  => "Cricket/Leap",
        147  => "Peoples Telephone Cooperative *",
        148  => "XIT Rural Telephone Cooperative *",
        149  => "Appalachian Wireless",
        150  => "Immix Wireless",
        151  => "CC Communications *",
        152  => "Mohave Cellular *",
        153  => "West Virginia Wireless *",
        154  => "Pine Telephone *",
        155  => "Superior Wireless *",
        156  => "Golden State *",
        157  => "SRT Communications *",
        158  => "Cellcom",
        159  => "Virginia Cellular *",
        160  => "Pine Belt *",
        170  => "Virgin Mobile USA",
        171  => "Cellular One of East Central Illinois",
        172  => "GCI/Alaska Digitel",
        173  => "Inland Cellular",
        174  => "Illinois Valley",
        175  => "Nex-Tech",
        176  => "United Wireless",
        181  => "Claro",
        191  => "Movistar",
        201  => "Nextel Communications",
        211  => "Personal",
        221  => "Miniphone-Argentina *",
        231  => "OTRO-Argentina *",
        1042 => "SunCom Wireless *",
        9000 => "COIN",
      }
    end
  end
end
