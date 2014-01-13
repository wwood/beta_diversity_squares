#Take some of the hassle out of writing the svgs. Very primitive.
class SVGWriter
  def initialize(width, height)
    @svg = "<svg xmlns=\"http://www.w3.org/2000/svg\" version=\"1.1\" width=\"#{width}\" height=\"#{height}\" xmlns:xlink=\"http://www.w3.org/1999/xlink\">\n"
  end

  def rect(attributes={})
    @svg += "<rect"
    attributes.each do |key, value|
      @svg += " #{key}=\"#{value}\""
    end
    @svg += " />\n"
  end
  alias_method :rectangle, :rect

  def text(words, attributes={})
    @svg += "<text"
    attributes.each do |key, value|
      @svg += " #{key}=\"#{value}\""
    end
    @svg += ">#{words}</text>"
  end

  def svg
    @svg + "</svg>"
  end
end
