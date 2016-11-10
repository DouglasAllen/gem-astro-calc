
# Credits
# {http://www.nexstarsite.com/_RAC/articles/formulas.htm Mike Swanson}
class Telescopes

  MM_IN_INCH       = 25.4
  RAYLEIGH_LIMIT   = 5.5
  DAWES_LIMIT      = 4.56
  UNIT_MILLIMETERS = :millimeters
  UNIT_INCHES = :inches

  attr_accessor :unit

  def initialize(unit = UNIT_MILLIMETERS)
    @unit = unit
  end

  # Calculates the magnification for a given telescope and eyepiece
  #
  # @param telescope [Integer] the focal length of the telescope tube
  # @param eyepiece [Integer] the focal length of the eyepiece
  # @return [Float] the magnification of the instrument
  def magnification(telescope, eyepiece)
    telescope / eyepiece
  end

  # Calculates the maximum probable magnification for a telescope
  #
  # @param diameter [Integer] the diameter of the telescope tube
  # @return [Float] the maximum magnification usable with the given diameter
  def maximum_magnification(diameter)
    case @unit
    when UNIT_MILLIMETERS
      diameter * 2
    when UNIT_INCHES
      diameter * 2 / MM_IN_INCH
    end
  end

  # Calculates the focal ration of a telescope
  #
  # @param length [Integer] the focal length of the telescope
  # @param aperture [Integer] the aperture of the telescope tube
  # @return [Float] the focal ratio of the instrument
  def focal_ratio(length, aperture)
    length / aperture
  end

  # Calculates the diameter of the light leaving the eyepiece
  #
  # @param aperture [Integer] the aperture of the telescope tube
  # @param magnification [Integer] the magnification of the instrument
  # @return [Float] the diameter of the total light rays
  def exit_pupil_for_binoculars(aperture, magnification)
    aperture / magnification
  end

  # Calculates the maximum probable magnification for a telescope
  #
  # @param diameter [Integer] the diameter of the telescope tube
  # @return [Float] the maximum magnification usable with the given diameter
  def exit_pupil_for_telescope(length, ratio)
    length / ratio
  end

  # Calculates the true field of view
  #
  # @param apparent [Integer] the apparent field of view of the eyepiece 
  # @param magnification [Integer] the magnification of the telescope and eyepiece
  # @return [Float] the true field of view of the instrument
  def true_field_of_view(apparent, magnification)
    apparent / magnification
  end

  # Calculates the resolving limit of the instrument according to Rayleigh
  #
  # @param diameter [Integer] the diameter of the telescope tube
  # @return [Float] the maximum magnification usable with the given diameter
  def rayleigh_limit(aperture)
    case @unit
    when UNIT_MILLIMETERS
      RAYLEIGH_LIMIT / aperture / MM_IN_INCH
    when UNIT_INCHES
      RAYLEIGH_LIMIT / aperture
    end
  end

  # Calculates the resolving limit of the instrument according to Dawes
  #
  # @param diameter [Integer] the diameter of the telescope tube
  # @return [Float] the maximum magnification usable with the given diameter
  def dawes_limit(aperture)
    case @unit
    when UNIT_MILLIMETERS
      DAWES_LIMIT / aperture / MM_IN_INCH
    when UNIT_INCHES
      DAWES_LIMIT / aperture
    end
  end

  # Calculates the light gathering power between two instruments
  #
  # @param large_aperture [Integer] the aperture of the larger instrument
  # @param small_aperture [Integer] the aperture of the smaller instrument
  # @return [Float] the light gathering power of the instrument
  def light_gathering_power(large_aperture, small_aperture)
    (large_aperture * large_aperture) / (small_aperture * small_aperture)
  end

  # Calculates the maximum probable magnification for a telescope
  #
  # @param aperture [Integer] the aperture in centimeters of the telescope tube
  # @return [Float] the maximum magnitude with the given aperture
  def limiting_magnitude(aperture)
    case @unit
    when UNIT_MILLIMETERS
      5 * Math.log10(aperture * 10) + 7.5
    when UNIT_INCHES
      5 * Math.log10(aperture / 2.54) + 7.5
    end
  end

end

