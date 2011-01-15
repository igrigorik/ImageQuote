require 'rmagick'
require 'rvg/rvg'

include Magick

module RMagickTextUtil
  def render_cropped_text(caption_text, width_constraint, height_constraint, &block)
    image = render_text(caption_text, width_constraint, &block)
    if height_constraint < image.rows
      percent = height_constraint.to_f / image.rows.to_f
      end_index = (caption_text.size * percent).to_i  # takes a leap into cropping
      image = render_text(caption_text[0..end_index] + "...", width_constraint, &block)
      while height_constraint < image.rows && end_index > 0 # reduce in big chunks until within range
        end_index -= 80
        image = render_text(caption_text[0..end_index] + "...", width_constraint, &block)
      end
      while height_constraint > image.rows                  # lengthen in smaller steps until exceed
        end_index += 10
        image = render_text(caption_text[0..end_index] + "...", width_constraint, &block)
      end
      while height_constraint < image.rows && end_index > 0 # reduce in baby steps until fit
        end_index -= 1
        image = render_text(caption_text[0..end_index] + "...", width_constraint, &block)
      end
    end
    image
  end

  def render_text(caption_text, width_constraint, &block)
    Magick::Image.read("caption:#{caption_text.to_s}") {
      # this wraps the text to fixed width
      self.size = width_constraint
      # other optional settings
      block.call(self) if block_given?
    }.first
  end
end

include RMagickTextUtil