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
#include <set>
#include <vector>
#include <cstdlib>
#include <fstream>
#include "mX_parms.h"
#include <cassert>

using namespace mX_parms_utils;

void mX_parms_utils::parse_command_line(int argc, std::vector<std::string> &argv, std::string &ckt_filename, double &t_start, double &t_step, double &t_stop, double &tol, int &k, std::vector<double> &init_cond, std::string &parms_file, std::set<int> &specified_parms, int p, int pid)
{
	// take a command-line-ish argc and argv
	// parse it to get the parms specified there
			// change those parms if they haven't been already specified earlier

	int i = 1;

	while (i < argc)
	{
		// got to read in a new parameter and its value

		std::string parm_name = argv[i];
		i++;

		int first_non_minus_index = parm_name.find_first_not_of('-');
		assert(first_non_minus_index != 0);
		parm_name = parm_name.substr(first_non_minus_index);

		if ((parm_name == "c") || (parm_name == "circuit"))
			{
			if (specified_parms.find(CKT_FILENAME) == specified_parms.end())
			{
				specified_parms.insert(CKT_FILENAME);
				ckt_filename = argv[i];
			}
			
			i++;
		}

		if ((parm_name == "ti") || (parm_name == "t_start") || (parm_name == "tstart"))
		{
			if (specified_parms.find(T_START) == specified_parms.end())
			{
				specified_parms.insert(T_START);
				t_start = atof(argv[i].data());
			}
			
			i++;
		}

		if ((parm_name == "tf") || (parm_name == "t_stop") || (parm_name == "tstop"))
		{
			if (specified_parms.find(T_STOP) == specified_parms.end())
			{
				specified_parms.insert(T_STOP);
				t_stop = atof(argv[i].data());
			}
			
			i++;
		}

		if ((parm_name == "h") || (parm_name == "t_step") || (parm_name == "tstep"))
		{
			if (specified_parms.find(T_STEP) == specified_parms.end())
			{
				specified_parms.insert(T_STEP);
				t_step = atof(argv[i].data());
			}
			
			i++;
		}

		if ((parm_name == "tol") || (parm_name == "tolerance"))
		{
			if (specified_parms.find(TOL) == specified_parms.end())
			{
				specified_parms.insert(TOL);
				tol = atof(argv[i].data());
			}
			
			i++;
		}

		if ((parm_name == "k") || (parm_name == "restart"))
		{
			if (specified_parms.find(K) == specified_parms.end())
			{
				specified_parms.insert(K);
				k = atoi(argv[i].data());
			}

			i++;
		}

		if ((parm_name == "pf") || (parm_name == "paramsfile") || (parm_name == "params_file"))
		{
			if (specified_parms.find(PARMS_FILE) == specified_parms.end())
			{
				specified_parms.insert(PARMS_FILE);
				parms_file = argv[i];
			}
			
			i++;
		}

		if (parm_name == "prev")
		{
			specified_parms.insert(PREV);
		}

		if ((parm_name == "i") || (parm_name == "init") || (parm_name == "initcond") || (parm_name == "init_cond") || (parm_name == "x0"))
		{
			std::vector<std::string> init;
			int n = 0;

			while (i < argc)
			{
				std::string next_arg = argv[i];

				if (next_arg[0] == '-')
				{
					break;
				}

				init.push_back(next_arg);
				i++; n++;
			}

			if (specified_parms.find(INIT_COND) == specified_parms.end())
			{
				specified_parms.insert(INIT_COND);
				
				int start_row = (n/p)*(pid) + ((pid < n%p) ? pid : n%p);
				int end_row = start_row + (n/p) - 1 + ((pid < n%p) ? 1 : 0);
	
				for (int j = start_row; j <= end_row; j++)
				{
					if (j-start_row < init_cond.size())
					{
						init_cond[j-start_row] = atof(init[j].data());
					}
	
					else
					{
						init_cond.push_back(atof(init[j].data()));
					}
				}
			}
		}
	}
}

std::vector<std::string> mX_parms_utils::get_command_line_equivalent_from_file(std::string &filename)
{
	// read a file that has parameters stored in it
		// construct a command-line-ish sequence from those parameters

	std::ifstream infile;
	infile.open(filename.data());

	if (infile.fail())
	{
		std::vector<std::string> v;
		return v;
	}

	std::vector<std::string> command_line_equivalent;
	command_line_equivalent.push_back("ignore");

	while (!infile.eof())
	{
		std::string curr_line;
		getline(infile,curr_line);

		if ((curr_line.length() == 0) || (curr_line[0] == '%'))
		{
			continue;
		}

		std::string LHS,RHS;

		int equals_idx = curr_line.find_first_of('=');
		LHS = curr_line.substr(0,equals_idx);
		RHS = curr_line.substr(equals_idx+1);

		int first_significant_index = LHS.find_first_not_of(" \t");
		int last_significant_index = LHS.find_last_not_of(" \t");
		LHS = LHS.substr(first_significant_index, last_significant_index-first_significant_index+1);

		first_significant_index = RHS.find_first_not_of(" \t");
		last_significant_index = RHS.find_last_not_of(" \t");
		RHS = RHS.substr(first_significant_index, last_significant_index-first_significant_index+1);

		command_line_equivalent.push_back("--" + LHS);
		command_line_equivalent.push_back(RHS);
	}

	infile.close();

	return command_line_equivalent;
}

void mX_parms_utils::get_parms(int argc, char* argv[], std::string &ckt_filename, double &t_start, double &t_step, double &t_stop, double &tol, int &k, std::vector<double> &init_cond, bool &init_cond_specified, int p, int pid)
{
	// get all the required simulation parameters
		// first go through command line options, they get first priority
		// after looking through the command line
			// if the command line options specify a file
				// open the file and read the parameters stored there
		// then, if the command line options specify --prev
			// read parameters from last_used_params.txt
		// then read remaining parameters from default_params.txt

	std::set<int> specified_parms;
	std::string parms_file;

	std::vector<std::string> argv_strings;

	for (int i = 0; i < argc; i++)
	{
		argv_strings.push_back((std::string)(argv[i]));
	}

	parse_command_line(argc, argv_strings, ckt_filename, t_start, t_step, t_stop, tol, k, init_cond, parms_file, specified_parms, p, pid);

	// scanned all command line parameters
		// now scan any files that are necessary

	if (specified_parms.find(PARMS_FILE) != specified_parms.end())
	{
		argv_strings = get_command_line_equivalent_from_file(parms_file);
		parse_command_line(argv_strings.size(), argv_strings, ckt_filename, t_start, t_step, t_stop, tol, k, init_cond, parms_file, specified_parms, p, pid);
	}

	if (specified_parms.find(PREV) != specified_parms.end())
	{
		std::string filename = "last_used_params.txt";
		argv_strings = get_command_line_equivalent_from_file(filename);
		parse_command_line(argv_strings.size(), argv_strings, ckt_filename, t_start, t_step, t_stop, tol, k, init_cond, parms_file, specified_parms, p, pid);
	}

	std::string filename = "default_params.txt";
	argv_strings = get_command_line_equivalent_from_file(filename);
	parse_command_line(argv_strings.size(), argv_strings, ckt_filename, t_start, t_step, t_stop, tol, k, init_cond, parms_file, specified_parms, p, pid);
	
	// by now all parms must have been obtained

	assert(specified_parms.find(CKT_FILENAME) != specified_parms.end());
	assert(specified_parms.find(T_START) != specified_parms.end());
	assert(specified_parms.find(T_STEP) != specified_parms.end());
	assert(specified_parms.find(T_STOP) != specified_parms.end());
	assert(specified_parms.find(TOL) != specified_parms.end());
	assert(specified_parms.find(K) != specified_parms.end());

	init_cond_specified = (specified_parms.find(INIT_COND) != specified_parms.end());

	// remember to update the "last_used_params.txt" file

	if (pid == 0)
	{
		filename = "last_used_params.txt";
		std::ofstream outfile(filename.data(), std::ios::out);
		
		outfile << "circuit " << "= " << ckt_filename << std::endl;
		outfile << "t_start " << "= " << t_start << std::endl;
		outfile << "t_step " << "= " << t_step << std::endl;
		outfile << "t_stop " << "= " << t_stop << std::endl;
		outfile << "tol " << "= " << tol << std::endl;
		outfile << "k " << "= " << k << std::endl;

		outfile.close();
	}

}
