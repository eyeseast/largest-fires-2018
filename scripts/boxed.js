#!/usr/bin/env node

/*
Take a GeoJSON feature collection and turn each polygon feature into a point feature where 
 - the geometry is the original polygon's centroid 
 - bbox is the original polygon's bounding box

Writes to STDOUT
*/

const sander = require("sander");
const turf = require("@turf/turf");

async function box(sourcefile, sinkfile) {
  if (!sourcefile) {
    console.error("No file name given. Nothing to do here.");
    process.exit(1);
  }
  const source = await sander.readFile(sourcefile).then(JSON.parse);
  const sink = turf.featureCollection([]);

  console.error(
    `Processing ${source.features.length} features from ${sourcefile}.
Writing to ${sinkfile}.`
  );

  sink.features = source.features.map(f => {
    const bbox = turf.bbox(f);
    const centroid = turf.centroid(f);

    return { ...f, bbox, geometry: centroid.geometry };
  });

  return sander.writeFile(sinkfile, JSON.stringify(sink, null, 2));
}

box(process.argv[2], process.argv[3]);
