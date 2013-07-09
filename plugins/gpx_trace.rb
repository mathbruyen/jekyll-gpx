require 'pathname'
require 'securerandom'
require 'rexml/document'
require 'json'

include REXML

class GpxTrace < Liquid::Tag

  def initialize(tag_name, options, tokens)
    super
    options = options.split(' ').map {|i| i.strip }
    @path = options.slice!(0)
    @classes = options
  end

  def renderTrack(track, site)
    id = "map-" + SecureRandom.uuid

    # TODO use an array joined at the end
    source = ""

    source += "<figure>\n"
    source += "<div class=\"leaflet-custom " + @classes.join(' ') + "\" id=\"#{id}\"></div>\n"
    source += "<figcaption>#{track.text('name')}</figcaption>\n"
    source += "</figure>\n"
    source += "<script>$(function() {\n"
    source += "var bounds;\n"
    source += "var map = L.map('#{id}');\n"
    source += "var segment;\n"

    track.each_element('trkseg') { |segment|
      source += "segment = " + segment.get_elements('trkpt').map { |point| [point.attributes['lat'].to_f, point.attributes['lon'].to_f] }.to_json + ";\n"
      source += "bounds = bounds ? bounds.extend(segment) : new L.LatLngBounds(segment);\n"
      source += "L.polyline(segment, {color: 'red'}).addTo(map);\n"
    }

    source += "map.fitBounds(bounds);\n"
    source += "L.tileLayer('#{site.config['leaflet_tile_url']}', { attribution: '#{site.config['leaflet_tile_attrib']}', maxZoom: 18 }).addTo(map);\n"
    source += "})</script>\n"

    source
  end

  def render(context)
    site = context.registers[:site]

    gpx_file = (Pathname.new(site.source) + @path).expand_path
    if !gpx_file.file?
      return "File #{gpx_file} could not be found"
    end

    doc = Document.new(File.new(gpx_file))
    # TODO use .map { ... }.join(' ')
    source = ""
    doc.root.each_element('trk') { |track| source += renderTrack(track, site) }
    source
  end
end

Liquid::Template.register_tag('gpx_race', GpxTrace)
