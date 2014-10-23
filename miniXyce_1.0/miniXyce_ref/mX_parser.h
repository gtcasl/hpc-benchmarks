#ifndef __MX_PARSER_H__
#define __MX_PARSER_H__

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
#include "mX_source.h"
#include "mX_linear_DAE.h"
#include "mX_sparse_matrix.h"

using namespace mX_source_utils;
using namespace mX_matrix_utils;
using namespace mX_linear_DAE_utils;

namespace mX_parse_utils
{
	mX_linear_DAE* parse_netlist(std::string filename, int p, int pid, int &n, int &num_internal_nodes, int &num_voltage_sources, int &num_current_sources, int &num_resistors, int &num_capacitors, int &num_inductors);
}
#endif
