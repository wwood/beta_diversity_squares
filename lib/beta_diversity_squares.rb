require 'bio-express_beta_diversity'
require 'bio-logger'
require 'svg_writer'

module Bio
  class BetaDiversitySquares
    def log
      Bio::Log::LoggerPlus['beta_diversity_squares']
    end

    # Given a path to a distance file, return an SVG of beta diversity squares
    #
    # Options:
    # * :order_and_rename: A Hash containing the names of samples as they exist
    # in the distance file. The order of the hash defines the order of the samples
    # as they appear in the SVG, and the values of the hash are the names of the samples
    # as they appear in the SVG.
    def diss_to_svg(distance_file, options={})
      # Parse in the distance file
      diss = Bio::EBD::DistanceMatrix.parse_from_file(distance_file)
      log.info "Parsed in #{diss.sample_names.length} samples"

      # Constants
      box_size = 20
      boxes_start_x_offset = 320
      boxes_start_y_offset = 120
      white_break_size = box_size
      min=0.2 #TODO: find min & max empirically using mean+sd
      max=0.6


      order = diss.sample_names
      if options[:order_and_rename]
        order = options[:order_and_rename].keys
      end
      log.debug "Found order of samples: #{order.inspect}" if log.debug?

      width = boxes_start_x_offset + box_size*order.length + white_break_size
      height = boxes_start_y_offset + box_size*order.length + white_break_size
      svgee = SVGWriter.new(width,height)#Bio::Graphics::SVGEE.new({})

      # Write sample names along the LHS
      # e.g. <text y="130" x="25">Active Young AB12 5221</text>
      # <text y="150" x="25">Active Young AB3 4446</text>
      order.each_with_index do |sample_ident, i|
        name = sample_ident
        if options[:order_and_rename]
          name = options[:order_and_rename][sample_ident]
          if name.nil?
            log.warn "No replacement name found for #{sample_ident}, so using #{sample_ident} instead"
          end
        end
        svgee.text(name, {:x => 25, :y => boxes_start_y_offset+box_size*i})
      end


      # Write the squares themselves
      # <rect stroke-width="0.4" shape-rendering="crispEdges" stroke="black" fill="#000000" height="0" width="0" y="120" x="340"></rect>
      # <rect stroke-width="0.4" shape-rendering="crispEdges" stroke="black" fill="#000000" height="13.082846153846155" width="13.082846153846155" y="113.45857692307692" x="353.4585769230769"></rect>
      order.each_with_index do |sample_ident1, i|
        order.each_with_index do |sample_ident2, j|
          # Don't draw a beta diversity of a sample against itself
          next if i==j

          size = 1-diss.distance(sample_ident1, sample_ident2)
          if size < min
            size = 0
          else
            # Rescale squares to accentuate dynamic range
            size = (size-min)/(max-min)*box_size
          end

          svgee.rectangle(
            x: boxes_start_x_offset+i*box_size,
            y: boxes_start_y_offset+j*box_size,
            width: size,
            height: size,
            fill: "#000000",
            'shape-rendering' => "crispEdges",
          )
        end
      end

      return svgee.svg
    end
  end
end
