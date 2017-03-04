Geocoder.configure(:lookup => :test)

Geocoder::Lookup::Test.set_default_stub(
  [
    {
      'latitude'          => 46.0448994,
      'longitude'         => 14.4892307,
      'address'           => 'Univerza v Ljubljani, Tržaška cesta 25, 1000 Ljubljana, Slovenija',
      'city'              => 'Ljubljana',
      'formatted_address' => 'Univerza v Ljubljani, Tržaška cesta 25, 1000 Ljubljana, Slovenija'
    }
  ]
)

Geocoder::Lookup::Test.add_stub(
  "Cesta XV. brigade 2, Metlika", [
    {
      'latitude'          => 45.6474851,
      'longitude'         => 15.3155356,
      'address'           => 'Cesta XV. brigade 2, 8330 Metlika, Slovenija',
      'city'              => 'Metlika',
      'formatted_address' => 'Cesta XV. brigade 2, 8330 Metlika, Slovenija'
    }
  ]
)


Geocoder::Lookup::Test.add_stub(
  "Videm pri Ptuju 49, Videm pri Ptuju", [
    {
      'latitude'          => 46.369447,
      'longitude'         => 15.902942,
      'address'           => 'Videm pri Ptuju 49, 2284 Videm pri Ptuju, Slovenija',
      'city'              => 'Ptuj',
      'formatted_address' => 'Videm pri Ptuju 49, 2284 Videm pri Ptuju, Slovenija'
    }
  ]
)

