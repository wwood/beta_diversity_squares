#Take some of the hassle out of writing the svgs. Very primitive.
class SVGWriter
  def initialize(width, height)
    @svg = ["<svg xmlns=\"http://www.w3.org/2000/svg\" version=\"1.1\" width=\"#{width}\" height=\"#{height}\" xmlns:xlink=\"http://www.w3.org/1999/xlink\">\n"]
  end

  def rect(attributes={})
    @svg.push "<rect"
    attributes.each do |key, value|
      @svg.push " #{key}=\"#{value}\""
    end
    @svg.push " />\n"
  end
  alias_method :rectangle, :rect

  def text(words, attributes={})
    @svg.push "<text"
    attributes.each do |key, value|
      @svg.push " #{key}=\"#{value}\""
    end
    @svg.push ">#{words}</text>"
  end

  def svg
    [@svg, "</svg>"].join('')
  end
end
