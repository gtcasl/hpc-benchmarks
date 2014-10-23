#ifndef __MX_SOURCE_DEFS_H__
#define __MX_SOURCE_DEFS_H__

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

#include <vector>
#include <sstream>

namespace mX_source_utils
{
	class mX_source
	{
		// this class represents a time-varying voltage or current source
			// all that is needed is the value of the output at time "t"

		public:

		virtual double output(double t) = 0;
	};

	class DC : public mX_source
	{
		// DC voltage/current source

		public:

		double val;

		DC(double d)
		{
			val = d;
		}

		virtual double output(double t)
		{
			return val;
		}
	};

	class SINE : public mX_source
	{
		// sinusoidal voltage/current source

		public:

		double offset;
		double amplitude;
		double freq;
		double phase;

		SINE(double off, double amp, double f, double ph);

		virtual double output(double t); 
	};

	class FM : public mX_source
	{
		// frequency modulated voltage/current source

		public:

		double offset;
		double amplitude;
		double carrier_freq;
		double modulation_index;
		double signal_freq;

		FM(double o, double a, double cf, double mi, double sf);

		virtual double output(double t); 
	};

	class PWL : public mX_source
	{
		// piecewise linear voltage/current source

		public:

		std::vector<double> times;
		std::vector<double> values;

		PWL(std::vector<double> ts, std::vector<double> vals);

		virtual double output(double t);
	};

	class PULSE : public mX_source
	{
		// pulse shaped voltage/current source

		public:

		double val1;
		double val2;
		double t_delay;
		double t_rise;
		double pulse_width;
		double t_fall;
		double t_stop;

		PULSE(double d1, double d2, double td, double tr, double pw, double tf, double ts);

		virtual double output(double t);
	};

	struct mX_scaled_source
	{
		// a scaled voltage/current source
			// useful in many contexts
				// eg: when you want -V(t) and already have a source V(t)

		mX_source* src;
		double scale;
	};

	mX_source* parse_source(std::istringstream& input_str);
}
#endif
