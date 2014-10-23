//@HEADER
// ************************************************************************
// 
//               miniXyce: A simple circuit simulation benchmark code
//                 Copyright (2011) Sandia Corporation
// 
// Under terms of Contract DE-AC04-94AL85000, there is a non-exclusive
// license for use of this work by or on behalf of the U.S. Government.
// 
// This library is free software; you can redistribute it and/or modify
// it under the terms of the GNU Lesser General Public License as
// published by the Free Software Foundation; either version 2.1 of the
// License, or (at your option) any later version.
//  
// This library is distributed in the hope that it will be useful, but
// WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
// Lesser General Public License for more details.
//  
// You should have received a copy of the GNU Lesser General Public
// License along with this library; if not, write to the Free Software
// Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307
// USA
// Questions? Contact Michael A. Heroux (maherou@sandia.gov) 
// 
// ************************************************************************
//@HEADER

// Author : Karthik V Aadithya
// Mentor : Heidi K Thornquist
// Date : July 2010

#include <string>
#include <cmath>
#include "mX_source.h"

using namespace mX_source_utils;

// ------------------------------------------------------------------
// Implementations for the SINE class
mX_source_utils::SINE::SINE(double off, double amp, double f, double ph)
  : offset(off),
    amplitude(amp),
    freq(f),
    phase(ph)
{}

double mX_source_utils::SINE::output(double t) 
{
  double pi = 3.1415926535;
  return (offset + amplitude * sin(2*pi*freq*t + phase));
}

// ------------------------------------------------------------------
// Implementations for the FM class
mX_source_utils::FM::FM(double o, double a, double cf, double mi, double sf)
  : offset(o),
    amplitude(a),
    carrier_freq(cf),
    modulation_index(mi),
    signal_freq(sf)
{}

double mX_source_utils::FM::output(double t) 
{
  double pi = 3.1415926535;
  return (offset + amplitude * sin(2*pi*carrier_freq*t + modulation_index*sin(2*pi*signal_freq*t)));
}

// ------------------------------------------------------------------
// Implementations for the PWL class
mX_source_utils::PWL::PWL(std::vector<double> ts, std::vector<double> vals)
  : times(ts),
    values(vals)
{}

double mX_source_utils::PWL::output(double t) 
{
  if (times.size() == 1)
  {
    return values[0];
  }

  if (t <= times[0])
  {
    return values[0];
  }

  if (t >= times.back())
  {
    return values.back();
  }

  int start_index = 0;
  int end_index = times.size()-1;
  int mid_index = (start_index + end_index)/2;
			
  while(true)
  {
    if (end_index - start_index == 1)
    {
      break;
    }
    if (times[mid_index] > t)
    {
      end_index = mid_index;
      mid_index = (start_index + end_index)/2;
    }
    else
    {
      if (times[mid_index] < t)
      {
        start_index = mid_index;
        mid_index = (start_index + end_index)/2;
      }
      else
      {
        return values[mid_index];
      }
    }
  }

  return (values[start_index] + (values[end_index]-values[start_index])*((t - times[start_index])/(times[end_index] - times[start_index])));
}

// ------------------------------------------------------------------
// Implementations for the PULSE class

mX_source_utils::PULSE::PULSE(double d1, double d2, double td, double tr, double pw, double tf, double ts)
  : val1(d1),
    val2(d2),
    t_delay(td),
    t_rise(tr),
    pulse_width(pw),
    t_fall(tf),
    t_stop(ts)
{}

double mX_source_utils::PULSE::output(double t)
{
  double t_total = t_delay + t_rise + pulse_width + t_fall + t_stop;
  double n = floor(t/t_total);
  double t_disp = t - n*t_total;

  if ((t_disp >= 0) && (t_disp <= t_delay))
  {
    return val1;
  }				

  if ((t_disp >= t_delay) && (t_disp <= t_delay + t_rise))
  {
    return (val1 + ((val2-val1)/(t_rise))*(t_disp-t_delay));
  }

  if ((t_disp >= t_delay + t_rise) && (t_disp <= t_delay + t_rise + pulse_width))
  {
    return val2;
  }
			
  if ((t_disp >= t_delay + t_rise + pulse_width) && (t_disp <= t_delay + t_rise + pulse_width + t_fall))
  {
    return val2 + ((val1-val2)/(t_fall))*(t_disp-(t_delay + t_rise + pulse_width));
  }

  return val1;
}

// ------------------------------------------------------------------
// Implementation to parse the source type

mX_source* mX_source_utils::parse_source(std::istringstream& input_str)
{
	// ok, so you know you have a source in the box
		// but you don't know what kind of beast it is
		// this function will look at the box and return the correct source object for you

	std::string src_type;
	input_str >> src_type;

	if (src_type == "DC")
	{
		double val;
		input_str >> val;
		return new DC(val);
	}

	if (src_type == "SINE")
	{
		double offset,amp,f,ph;
		input_str >> offset >> amp >> f >> ph;
		return new SINE(offset,amp,f,ph);
	}

	if (src_type == "FM")
	{
		double offset,amp,cf,mi,sf;
		input_str >> offset >> amp >> cf >> mi >> sf;
		return new FM(offset,amp,cf,mi,sf);
	}

	if (src_type == "PWL")
	{
		int pwl_size;
		std::vector<double> times;
		std::vector<double> values;

		double t,v;

		input_str >> pwl_size;

		for (int i = 0; i < pwl_size; i++)
		{
			input_str >> t >> v;
			times.push_back(t);
			values.push_back(v);
		}

		return new PWL(times,values);
	}

	if (src_type == "PULSE")
	{
		double v1,v2,td,tr,pw,tf,ts;
		input_str >> v1 >> v2 >> td >> tr >> pw >> tf >> ts;
		return new PULSE(v1,v2,td,tr,pw,tf,ts);
	}

	return 0;
}
