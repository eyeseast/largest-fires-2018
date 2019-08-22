
CURRENT_YEAR_ZIP="https://rmgsc.cr.usgs.gov/outgoing/GeoMAC/2018_fire_data/current_year_all_states/2018_perimeters_dd83.zip"

LARGEST_QUERY="SELECT * FROM \"2018_perimeters_dd83\" WHERE latest='Y' ORDER BY GISACRES DESC LIMIT 10"
PERIMETER_FILTER="SELECT * FROM \"2018_perimeters_dd83\" WHERE latest='Y'"


perimeters/2018_perimeters_dd83.zip:
	mkdir -p $(dir $@)
	wget -O $@ $(CURRENT_YEAR_ZIP)
	touch $@

perimeters/2018_perimeters_dd83.shp: perimeters/2018_perimeters_dd83.zip
	unzip -d $(dir $@) $<
	touch $@

perimeters/perimeters.json: perimeters/2018_perimeters_dd83.shp
	ogr2ogr -f GeoJSON $@ -mapFieldType "Date=String" -sql $(PERIMETER_FILTER) $<

perimeters/perimeters.mbtiles: perimeters/perimeters.json
	tippecanoe -o $@ -zg --drop-densest-as-needed $<

perimeters/perimeters.csv: perimeters/2018_perimeters_dd83.dbf
	in2csv $< > $@

perimeters: perimeters/perimeters.json

perimeters/largest.json: perimeters/2018_perimeters_dd83.shp
	ogr2ogr -f GeoJSON $@ -mapFieldType "Date=String" -sql $(LARGEST_QUERY) $<

perimeters/largest-boxed.json: perimeters/largest.json
	./scripts/boxed.js "$<" "$@"

largest: perimeters/largest-boxed.json

clean:
	rm perimeters/*