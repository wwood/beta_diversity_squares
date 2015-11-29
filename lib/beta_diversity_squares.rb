require 'bio-express_beta_diversity'
require 'bio-logger'
require 'svg_writer'
require 'descriptive_statistics'

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
      box_size = 20.0
      boxes_start_x_offset = 200
      boxes_start_y_offset = 200
      white_break_size = box_size

      # Get some idea of the distribution, so we can automatically set min and max
      all_distances = []
      diss.sample_names.each_with_index do |s1,i|
        diss.sample_names.each_with_index do |s2, j|
          next unless i<j
          all_distances.push 1.0-diss.distance(s1,s2)
        end
      end
      min=all_distances.percentile(10)
      max=all_distances.percentile(90)
      log.info "Found #{all_distances.length} beta diversities, with 10th percentile #{min} and 90th percentile #{max}"



      order = diss.sample_names
      if options[:order_and_rename]
        order = options[:order_and_rename].keys
      end
      log.debug "Found order of samples: #{order.inspect}" if log.debug?

      row_colours = options[:row_colours]
      row_colours ||= {}

      width = boxes_start_x_offset + box_size*order.length + white_break_size
      height = boxes_start_y_offset + box_size*order.length + white_break_size
      svgee = SVGWriter.new(width,height)

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
        # Draw text of the horizontal label
        svgee.text(name, {:x => 25, :y => boxes_start_y_offset+box_size*i+box_size/4})
        # Draw text of the vertical label
        svgee.text(name, {
          :y => boxes_start_x_offset+box_size*i+box_size/4,
          :x => 25-boxes_start_y_offset,
          :transform => "matrix(0,-1,1,0,0,0)",
        })
      end


      # Write the squares themselves
      # <rect stroke-width="0.4" shape-rendering="crispEdges" stroke="black" fill="#000000" height="0" width="0" y="120" x="340"></rect>
      # <rect stroke-width="0.4" shape-rendering="crispEdges" stroke="black" fill="#000000" height="13.082846153846155" width="13.082846153846155" y="113.45857692307692" x="353.4585769230769"></rect>
      order.each_with_index do |sample_ident1, i|
        order.each_with_index do |sample_ident2, j|
          # Don't draw a beta diversity of a sample against itself
          next if i==j

          size = 1.0-diss.distance(sample_ident1, sample_ident2)
          if size < min
            size = 0.0
          else
            # Rescale squares to accentuate dynamic range
            size = (size-min)/ (max-min)*box_size
          end

          svgee.rectangle(
            x: boxes_start_x_offset+i*box_size-size/ 2,
            y: boxes_start_y_offset+j*box_size-size/ 2,
            width: size,
            height: size,
            fill: row_colours.key?(sample_ident2) ? row_colours[sample_ident2] : "#000000",
            'shape-rendering' => "crispEdges", #i.e. don't anti-alias
          )
        end
      end

      return svgee.svg
    end
  end
end
