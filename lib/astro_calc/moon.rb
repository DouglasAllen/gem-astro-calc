require 'date'

module Astro # :nodoc:
  #
  # Provides functions for lunar phases and lunar month dates (eg. new/full
  # moon)
  #
  # This file is a thoughtless manual compilation of Astro::MoonPhase perl
  # module (which, in turn, is influenced by moontool.c). I don't know
  # how it all works.
  module Moon # :doc:
    class << self
      # a container structure for phase() return value. accessors:
      #   phase - moon phase, 0 or 1 for new moon, 0.5 for full moon, etc
      #   illumination - moon illumination, 0.0 .. 0.1
      #   age - moon age, in days from the most recent new moon
      #   distance - moon distance from earth, in kilometers
      #   angle - moon angle
      #   sun_distance - sun distance from earth, in kilometers
      #   sun_angle - sun angle
      Phase = Struct.new(:phase, :illumination, :age, :distance, :angle,
                         :sun_distance, :sun_angle)

      # a container structure for phasehunt() return value. accessors:
      #   moon_start - a DateTime of the most recent new moon
      #   moon_end   - a DateTime of the next new moon
      #   moon_fill  - a DateTime of the full moon of this lunar month
      #   first_quarter, last_quarter -- <...>
      PhaseHunt = Struct.new(:moon_start, :first_quarter, :moon_full,
                             :last_quarter, :moon_end)

      # Astronomical constants.
      # 1980 January 0.0
      EPOCH      = 2_444_238.5

      # Constants defining the Sun's apparent orbit.
      #
      # ecliptic longitude of the Sun at epoch 1980.0
      ELONGE     = 278.833540
      # ecliptic longitude of the Sun at perigee
      ELONGP     = 282.596403
      # eccentricity of Earth's orbit
      ECCENT     = 0.016718
      # semi-major axis of Earth's orbit, km
      SUNSMAX    = 1.495985e8

      # sun's angular size, degrees, at semi-major axis distance
      SUNANGSIZ  = 0.533128

      # Elements of the Moon's orbit, epoch 1980.0.

      # moon's mean longitude at the epoch
      MMLONG     = 64.975464
      # mean longitude of the perigee at the epoch
      MMLONGP    = 349.383063
      # mean longitude of the node at the epoch
      MLNODE     = 151.950429
      # inclination of the Moon's orbit
      MINC       = 5.145396
      # eccentricity of the Moon's orbit
      MECC       = 0.054900
      # moon's angular size at distance a from Earth
      MANGSIZ    = 0.5181
      # semi-major axis of Moon's orbit in km
      MSMAX      = 384_401.0
      # parallax at distance a from Earth
      MPARALLAX  = 0.9507
      # synodic month (new Moon to new Moon)
      SYNMONTH   = 29.53058868

      # Finds the key dates of the specified lunar month.
      # Takes a DateTime object (or creates one using now() function).
      # Returns a PhaseHunt struct instance. (see Constants section)
      #
      #    # find the date/time of the full moon in this lunar month
      #    Astro::Moon.phasehunt.moon_full.strftime("%D %T %Z") \
      #    # => "03/04/07 02:17:40 +0300"

      def phasehunt(date = nil)
        date = DateTime.now unless date
        sdate = date.ajd

        adate = sdate - 45
        ad1 = DateTime.jd(adate)

        k1 = ((ad1.year + ((ad1.month - 1) *
                           (1.0 / 12.0)) - 1900) * 12.3685).floor

        adate = nt1 = meanphase(adate,  k1)

        loop do
          adate += SYNMONTH
          k2 = k1 + 1
          nt2 = meanphase(adate, k2)
          break if nt1 <= sdate && nt2 > sdate
          nt1 = nt2
          k1 = k2
        end

        PhaseHunt.new(*[
          truephase(k1, 0.0),
          truephase(k1, 0.25),
          truephase(k1, 0.5),
          truephase(k1, 0.75),
          truephase(k2, 0.0)
        ].map do |_|
          _.new_offset(date.offset)
        end)
      end

      # Finds the lunar phase for the specified date.
      # Takes a DateTime object (or creates one using now() function).
      # Returns a Phase struct instance. (see Constants section)
      #
      #    # find the current moon illumination, in percents
      #    Astro::Moon.phase.illumination * 100     # => 63.1104513958699
      #
      #    # find the current moon phase (new moon is 0 or 100,
      #    # full moon is 50, etc)
      #    Astro::Moon.phase.phase * 100            # => 70.7802812241989

      def phase(dt = nil)
        dt = DateTime.now.to_time.utc.to_datetime unless dt
        pdate = dt.ajd

        # Calculation of the Sun's position.

        day = pdate - EPOCH	# date within epoch
        n = ((360 / 365.2422) * day) % 360.0
        m = (n + ELONGE - ELONGP) % 360.0	# convert from perigee
        # co-ordinates to epoch 1980.0
        ec = kepler(m, ECCENT)	# solve equation of Kepler
        ec = Math.sqrt((1 + ECCENT) / (1 - ECCENT)) * Math.tan(ec / 2)
        ec = 2 * todeg(Math.atan(ec))	# true anomaly
        lambdasun = (ec + ELONGP) % 360.0	# Sun's geocentric ecliptic
        # longitude
        # Orbital distance factor.
        f = ((1 + ECCENT * Math.cos(torad(ec))) / (1 - ECCENT * ECCENT))
        sundist = SUNSMAX / f	# distance to Sun in km
        sunang = f * SUNANGSIZ	# Sun's angular size in degrees

        # Calculation of the Moon's position.

        # Moon's mean longitude.
        ml = (13.1763966 * day + MMLONG) % 360.0

        # Moon's mean anomaly.
        mm = (ml - 0.1114041 * day - MMLONGP) % 360.0

        # Moon's ascending node mean longitude.
        mn = (MLNODE - 0.0529539 * day) % 360.0

        # Evection.
        ev = 1.2739 * Math.sin(torad(2 * (ml - lambdasun) - mm))

        # Annual equation.
        ae = 0.1858 * Math.sin(torad(m))

        # Correction term.
        a3 = 0.37 * Math.sin(torad(m))

        # Corrected anomaly.
        mmp = mm + ev - ae - a3

        # Correction for the equation of the centre.
        mec = 6.2886 * Math.sin(torad(mmp))

        # Another correction term.
        a4 = 0.214 * Math.sin(torad(2 * mmp))

        # Corrected longitude.
        lp = ml + ev + mec - ae + a4

        # Variation.
        v = 0.6583 * Math.sin(torad(2 * (lp - lambdasun)))

        # True longitude.
        lpp = lp + v

        # Corrected longitude of the node.
        np = mn - 0.16 * Math.sin(torad(m))

        # Y inclination coordinate.
        y = Math.sin(torad(lpp - np)) * Math.cos(torad(MINC))

        # X inclination coordinate.
        x = Math.cos(torad(lpp - np))

        # Ecliptic longitude.
        lambdamoon = todeg(Math.atan2(y, x))
        lambdamoon += np

        # Ecliptic latitude.
        betam = todeg(Math.asin(Math.sin(torad(lpp - np)) *
                                  Math.sin(torad(MINC))))

        # Calculation of the phase of the Moon.

        # Age of the Moon in degrees.
        moonage = lpp - lambdasun

        # Phase of the Moon.
        moonphase = (1 - Math.cos(torad(moonage))) / 2

        # Calculate distance of moon from the centre of the Earth.

        moondist = (MSMAX * (1 - MECC * MECC)) /
                   (1 + MECC * Math.cos(torad(mmp + mec)))

        # Calculate Moon's angular diameter.

        moondfrac = moondist / MSMAX
        moonang = MANGSIZ / moondfrac

        # Calculate Moon's parallax.

        moonpar = MPARALLAX / moondfrac

        pphase = moonphase
        mpfrac = (moonage % 360) / 360.0
        mage = SYNMONTH * mpfrac
        dist = moondist
        angdia = moonang
        sudist = sundist
        suangdia = sunang
        Phase.new(mpfrac, pphase, mage, dist, angdia, sudist, suangdia)
      end

      private

      def torad(x)
        x * Math::PI / 180.0
      end

      def todeg(x)
        x * 180.0 / Math::PI
      end

      def dsin(x)
        Math.sin(torad(x))
      end

      def dcos(x)
        Math.sin(torad(x))
      end

      def meanphase(sdate, k)
        ## Time in Julian centuries from 1900 January 0.5
        t = (sdate - 2_415_020.0) / 36_525
        (t * (0.0001178 * t - (0.000000155 * t) * t) + 0.00033) *
          dsin(166.56 + (132.87 - 0.009173 * t) * t) +
          2_415_020.75933 + SYNMONTH * k
      end

      def truephase(k, phase)
        apcor = 0

        k += phase # add phase to new moon time
        t = k / 1236.85	# time in Julian centuries from
        # 1900 January 0.5
        t2 = t * t	# square for frequent use
        t3 = t2 * t	# cube for frequent use

        # mean time of phase */
        pt = 2_415_020.75933 +
             SYNMONTH * k +
             0.0001178 * t2 -
             0.000000155 * t3 +
             0.00033 * dsin(166.56 + 132.87 * t - 0.009173 * t2)

        # Sun's mean anomaly
        m = 359.2242 + 29.10535608 * k - 0.0000333 * t2 - 0.00000347 * t3

        # Moon's mean anomaly
        mprime =
          306.0253 + 385.81691806 * k + 0.0107306 * t2 + 0.00001236 * t3

        # Moon's argument of latitude
        f = 21.2964 + 390.67050646 * k - 0.0016528 * t2 - 0.00000239 * t3

        if phase < 0.01 || (phase - 0.5).abs < 0.01
          # Corrections for New and Full Moon.

          pt += (0.1734 - 0.000393 * t) * dsin(m) +
                0.0021 * dsin(2 * m) -
                0.4068 * dsin(mprime) +
                0.0161 * dsin(2 * mprime) -
                0.0004 * dsin(3 * mprime) +
                0.0104 * dsin(2 * f) -
                0.0051 * dsin(m + mprime) -
                0.0074 * dsin(m - mprime) +
                0.0004 * dsin(2 * f + m) -
                0.0004 * dsin(2 * f - m) -
                0.0006 * dsin(2 * f + mprime) +
                0.0010 * dsin(2 * f - mprime) +
                0.0005 * dsin(m + 2 * mprime)
          apcor = 1
        elsif (phase - 0.25).abs < 0.01 || (phase - 0.75).abs < 0.01
          pt += (0.1721 - 0.0004 * t) * dsin(m) +
                0.0021 * dsin(2 * m) -
                0.6280 * dsin(mprime) +
                0.0089 * dsin(2 * mprime) -
                0.0004 * dsin(3 * mprime) +
                0.0079 * dsin(2 * f) -
                0.0119 * dsin(m + mprime) -
                0.0047 * dsin(m - mprime) +
                0.0003 * dsin(2 * f + m) -
                0.0004 * dsin(2 * f - m) -
                0.0006 * dsin(2 * f + mprime) +
                0.0021 * dsin(2 * f - mprime) +
                0.0003 * dsin(m + 2 * mprime) +
                0.0004 * dsin(m - 2 * mprime) -
                0.0003 * dsin(2 * m + mprime)

          corr = 0.0028 - 0.0004 * dcos(m) + 0.0003 * dcos(mprime)
          pt += (phase < 0.5 ? corr : -corr)
          apcor = 1
        end

        if !apcor || apcor.zero?
          raise "truephase() called with invalid phase selector (#{phase})."
        end
        DateTime.jd(pt + 0.5)
      end

      def kepler(m, ecc)
        m = torad(m)
        e = m
        loop do
          delta = e - ecc * Math.sin(e) - m
          e -= delta / (1 - ecc * Math.cos(e))
          break if delta.abs <= 1e-6
        end
        e
      end
    end
  end
end
