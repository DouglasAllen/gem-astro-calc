require "date"

# Credits
# {https://github.com/tingletech/moon-phase tingletech}
class MoonPhases
  YEAR_IN_DAYS = 365.25
  LIMIT_JULIAN_CALENDAR = 2299160
  JULIAN_DAYS_IN_MONTH = 29.530588853
  
  attr_reader :phase, :age, :distance, :latitude, :longitude, :constellation
  attr_reader :sweep, :magnitude # for svg
  
  def initialize(date = Date.today)
    year  = date.year
    month = date.month
    day   = date.day

    #calculate the Julian date at 12h UT
    y = year - ((12 - month) / 10.0).floor
    m = month + 9 
    m = m - 12 if m >= 12
    
    k1 = (YEAR_IN_DAYS * (y + 4712)).floor
    k2 = (30.6 * m + 0.5 ).floor
    k3 = (((y / 100) + 49) * 0.75).floor - 38
    
    julian_day = k1 + k2 + day + 59                                    # for Julian calendar
    julian_day = julian_day - k3 if julian_day > LIMIT_JULIAN_CALENDAR # for Gregorian calendar
        
    #calculate moons age in Julian days
    i_phase  = normalize((julian_day - 2451550.1 ) / JULIAN_DAYS_IN_MONTH)
    @age = i_phase * JULIAN_DAYS_IN_MONTH
    
    @phase = case @age
      when 1.84566..5.53699 then "waxing crescent"
      when 5.53669..9.22831 then "first quarter"
      when 9.22831..12.91963 then "waxing gibbous"
      when 12.91963..16.61096 then "full moon"
      when 16.61096..20.30228 then "waning gibbous"
      when 20.30228..20.30228 then "last quarter"
      when 20.30228..27.68493 then "waning crescent"
      else "new moon"
    end
    
    #convert phase to radians
    i_phase_radians = i_phase * 2 * Math::PI  

    #calculate moon's distance
    distance_phase = 2 * Math::PI * normalize((julian_day - 2451562.2 ) / 27.55454988)
    @distance = 60.4 - 3.3 * Math.cos(distance_phase) - 0.6 * Math.cos(2 * i_phase_radians - distance_phase) - 0.5 * Math.cos(2 * i_phase_radians)

    #calculate moon's ecliptic latitude
    normal = 2 * Math::PI * normalize((julian_day - 2451565.2) / 27.212220817)
    @latitude = (5.1 * Math.sin(normal)).round(3)

    #calculate moon's ecliptic longitude
    real_phase = normalize((julian_day - 2451555.8) / 27.321582241)
    @longitude = (360 * real_phase + 6.3 * Math::sin(distance_phase) + 1.3 * Math.sin(2 * i_phase_radians - distance_phase) + 0.7 * Math.sin(2 * i_phase_radians)).round(3)

    @constellation = case @longitude
      when 33.18..51.16 then "Aries"
      when 51.16..93.44 then "Taurus"
      when 93.44..119.48 then "Gemini"
      when 119.48..135.30 then "Cancer"
      when 135.30..173.34 then "Leo"
      when 173.34..224.17 then "Virgo"
      when 224.17..242.57 then "Libra"
      when 242.57..271.26 then "Scorpio"
      when 271.26..302.49 then "Sagittarius"
      when 302.49..311.72 then "Capricorn"
      when 311.72..348.58 then "Aquarius"
      else "Pisces"
    end

    # the "sweep-flag" and the direction of movement change every quarter moon
    # zero and one are both new moon; 0.50 is full moon    
    case i_phase
    when 0.25..0.50 then
      @sweep     = [0, 0];
      @magnitude = 20 * (i_phase - 0.25) * 4
    when 0.50..0.75 then
      @sweep     = [1, 1];
      @magnitude = 20 - 20 * (i_phase - 0.50) * 4
    when 0.75..1.00 then
      @sweep     = [0, 1];
      @magnitude = 20 * (i_phase - 0.75) * 4
    else 
      @sweep     = [1, 0];
      @magnitude = 20 - 20 * i_phase   * 4
    end
  end

  # Normalizes the value to be in the range 0..1
  #
  # @param value [Float] the value to normalize
  # @return [Float] the normalized value
  def normalize(value)
    value -= value.floor 
    value += 1 if value < 0
    value
  end

  # Provides the unicode characters for the moon phase
  #
  # @return [String] the unicode string showing the moon phase
  def unicode  
    case @phase 
      when 0.0625..0.1875 then "\uD83C\uDF12"
      when 0.1875..0.3125 then "\uD83C\uDF13"
      when 0.3125..0.4375 then "\uD83C\uDF14"
      when 0.4375..0.5625 then "\uD83C\uDF15"
      when 0.5625..0.6875 then "\uD83C\uDF16"
      when 0.6875..0.8125 then "\uD83C\uDF17"
      when 0.8125..0.9375 then "\uD83C\uDF18"
      else "\uD83C\uDF11"      
    end
  end
  
  # Calculates the magnification for a given telescope and eyepiece
  #
  # @param options [Hash] the options for SVG generation
  # @return [String] the SVG output
  def svg(options = {})
    default_options = {
      include_style: true,
      height: "200px",
      background_color: "#111111",
      left: "35%",
      top: "75px",
      moon_color: "#CDCDCD",
      shadow_color: "#000000"
    }
    options = default_options.merge(options)
    
    output = ""
    
    if options[:include_style] then
      output << "<style>"
      output << "#moonholder { height: #{options[:height]}; background-color: #{options[:background_color]}; }"
      output << "#moon       { position:absolute; left:#{options[:left]}; top:#{options[:top]}; }"
      output << ".moon       { fill: #{options[:moon_color]}; }"
      output << ".moonback   { stroke: #{options[:shadow_color]}; stroke-width: 1px; height: 180px; }"
      output << "</style>"
    end
    
    output << "<svg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 100% 100%' version='1.1' id='moon'>"
    output << "  <path d='m100,0 a20,20 0 1,1 0,150 a20,20 0 1,1 0,-150' class='moonback'></path>"
    output << "  <path d='m100,0 a#{@magnitude.round(2)},20 0 1,#{@sweep[0]} 0,150 a20,20 0 1,#{@sweep[1]} 0,-150' class='moon'></path>"
    output << "</svg>"
    output.html_safe
  end    
end
 