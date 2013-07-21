## Jekyll-GPX

Embed [GPX traces](http://en.wikipedia.org/wiki/GPS_eXchange_Format) directly in [Jekyll](http://jekyllrb.com/)/[Octopress](http://octopress.org/) posts and pages. Uses [Leaflet](http://leafletjs.com/) to display maps.

Disclaimer: minimalistic work from a ruby noob, definitely open to suggestions

## Installation

* copy `gpx_trace.rb` in the `(_)plugins` directory
* copy `leaflet-custom.css` in the `source/stylesheets` directory
* copy `leaflet.html` in the `source/_includes` directory
* append `{% if page.enable_gpx_traces %}{% include leaflet.html %}{% endif %}` to `source/_includes/custom/head.html` which loads Leaflet on pages that require it
* set `leaflet_tile_url` and `leaflet_tile_attrib` properties in `_config.yml` to Leaflet [tile URL template](http://leafletjs.com/reference.html#tilelayer) (directly embedding API key and style ID in the URL rather than using templating) and [attribution](http://leafletjs.com/reference.html#tilelayer-attribution). For low traffic [OpenStreetMap](http://www.openstreetmap.org/) tiles may be used, larger sites should use alternate services

## Usage

First define a template for the map, for example at `_traces/my_template.tpl`:
```
{% for track in gpx.tracks %}
{% assign id = helper.unique_id %}
<figure>
  <div class="leaflet-custom bigmap" id="{{ id }}"></div>
  <figcaption>{{ track.name }}</figcaption>
</figure>
<script>$(function() {
  var bounds;
  var map = L.map('{{ id }}');
  var segment;
  {% for segment in track.segments %}
  	segment = {{ segment.points_json }};
    bounds = bounds ? bounds.extend(segment) : new L.LatLngBounds(segment);
    L.polyline(segment, {color: 'red'}).addTo(map);
  {% endfor %}
  map.fitBounds(bounds);
  L.tileLayer('{{ helper.tile_url }}', { attribution: '{{ helper.tile_attrib }}', maxZoom: 18 }).addTo(map);
})</script>
{% endfor %}
```
The template receives arguments:
* `gpx`: the GPX trace as an object
* `helper`: a helper object containing tile configuration and ways to obtain unique map identifiers

Pages that include traces must declare it in [Jekyll's front-matter](http://jekyllrb.com/docs/frontmatter/):
```
---
enable_gpx_traces: true
---
```
and the custom tag can be used any number of times in the page:
```
{% gpx_trace _traces/track.gpx _traces/my_template.tpl %}
```
with arguments being:
* the path to the GPX file, relative to the `source` directory
* the path to the template file, relative to the `source` directory

## License

[MIT License](http://en.wikipedia.org/wiki/MIT_License)
