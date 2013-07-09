## Jekyll-GPX

Embed [GPX traces](http://en.wikipedia.org/wiki/GPS_eXchange_Format) directly in [Jekyll](http://jekyllrb.com/)/[Octopress](http://octopress.org/) posts and pages. Uses [Leaflet](http://leafletjs.com/) to display maps.

Disclaimer: minimalistic work from a ruby noob, definitely open to suggestions

## Installation

* copy `gpx_trace.rb` in the `(_)plugins` directory
* copy `leaflet-custom.css` in the `source/stylesheets` directory
* copy `leaflet.html` in the `source/_includes` directory
* append `{% if page.enable_gpx_traces %}{% include leaflet.html %}{% endif %}` to `source/_includes/custom/head.html` which loads Leaflet on pages that require it
* set `leaflet_tile_url` and `leaflet_tile_attrib` propertiesin `_config.yml` to Leaflet [tile URL template](http://leafletjs.com/reference.html#tilelayer) (directly embedding API key and style ID in the URL rather than using templating) and [attribution](http://leafletjs.com/reference.html#tilelayer-attribution). For low traffic [OpenStreetMap](http://www.openstreetmap.org/) tiles may be used, larger sites should use alternate services

## Usage

Pages that include traces must declare it in [Jekyll's front-matter](http://jekyllrb.com/docs/frontmatter/):
```
---
enable_gpx_traces: true
---
```
and the custom tag can be used any number of times in the page:
```
{% gpx_race _traces/track.gpx bigmap %}
```
with arguments being:
* the path to the GPX file, relative to the `source` directory
* the list of CSS classes to apply, one of them must define the height of the map (I personally define those in `leaflet-custom.css`)

## License

[MIT License](http://en.wikipedia.org/wiki/MIT_License)
