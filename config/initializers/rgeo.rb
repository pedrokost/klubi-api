#!/usr/bin/ruby
# @Author: Pedro Kostelec
# @Date:   2017-05-19 22:41:14
# @Last Modified by:   Pedro Kostelec
# @Last Modified time: 2017-05-19 23:44:33

RGeo::ActiveRecord::SpatialFactoryStore.instance.tap do |config|
  # By default, use the GEOS implementation for spatial columns.
  # config.default = RGeo::Geos.factory_generator

  config.default = RGeo::Geographic.spherical_factory(srid: 4326)

  # Fetching large MULTIPOLYGON types from the db is very slow w/out this
  # config.register(RGeo::Geos.factory_generator(uses_lenient_assertions: true), geo_type: "multi_polygon")
end
