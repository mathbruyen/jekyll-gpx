require 'pathname'
require 'securerandom'
require 'rexml/document'
require 'json'

include REXML

class Helper < Liquid::Drop

  attr_reader :tile_url, :tile_attrib

  def initialize(site)
    @tile_url = site.config['leaflet_tile_url']
    @tile_attrib = site.config['leaflet_tile_attrib']
  end

  def unique_id
    "map-" + SecureRandom.uuid
  end
end

class Gpx < Liquid::Drop

  attr_reader :tracks

  def initialize(doc)
    @tracks = doc.root.get_elements('trk').map { |track| GpxTrack.new(track) }
  end
end

class GpxTrack < Liquid::Drop

  attr_reader :name, :segments

  def initialize(track)
    @name = track.text('name')
    @segments = track.get_elements('trkseg').map { |segment| GpxSegment.new(segment) }
  end
end

class GpxSegment < Liquid::Drop

  attr_reader :points

  def initialize(segment)
    # TODO sort by date
    @points = segment.get_elements('trkpt').map { |point| GpxPoint.new(point) }
  end

  def points_json
    @points.map { |point| [point.lat, point.lon] }.to_json
  end
end

class GpxPoint < Liquid::Drop

  attr_reader :lat, :lon

  def initialize(point)
    @lat = point.attributes['lat'].to_f
    @lon = point.attributes['lon'].to_f
  end
end

class GpxTrace < Liquid::Tag

  def initialize(tag_name, options, tokens)
    super
    options = options.split(' ').map {|i| i.strip }
    @path = options.slice!(0)
    @template = options.slice!(0)
  end

  def render(context)
    site = context.registers[:site]

    gpx_file = (Pathname.new(site.source) + @path).expand_path
    if !gpx_file.file?
      return "File #{gpx_file} could not be found"
    end
    doc = Document.new(File.new(gpx_file))

    tpl_file = (Pathname.new(site.source) + @template).expand_path
    if !tpl_file.file?
      return "File #{tpl_file} could not be found"
    end
    tpl = File.read(tpl_file)
    template = Liquid::Template.parse(tpl)
    template.render('gpx' => Gpx.new(doc), 'helper' => Helper.new(site))
  end
end

Liquid::Template.register_tag('gpx_trace', GpxTrace)
