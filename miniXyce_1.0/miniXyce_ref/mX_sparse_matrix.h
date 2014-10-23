#ifndef __MX_SPARSE_MATRIX_DEFS_H__
#define __MX_SPARSE_MATRIX_DEFS_H__

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
#include <list>
#include <map>

namespace mX_matrix_utils
{
	struct distributed_sparse_matrix_entry
	{
		int column;		// global column index
		double value;	// value stored in the matrix
		distributed_sparse_matrix_entry* next_in_row;	// pointer to next entry in the same row
	};

	struct data_transfer_instruction
	{
		std::list<int> indices;		// which elements of the vector to send
		int pid;		// to which processor the data is to be sent
	};

	struct distributed_sparse_matrix
	{
		// the data structure for a distributed sparse matrix is a 1-d threaded list
			// a set of pointers called row_headers point to the first entry of each row
			// each row entry in turn points to the next entry in the same row

		// but a distributed matrix needs more data than this
			// there is a list of data transfer instructions
				// these instructions are to be followed whenever a mat-vec product is needed
		
		// each processor also stores 2 entries start_row and end_row
			// it is assumed that all processors store contiguous rows of the distributed matrix

		int start_row;
		int end_row;
                int local_nnz;

		std::vector<distributed_sparse_matrix_entry*> row_headers;
		std::list<data_transfer_instruction*> send_instructions;

                distributed_sparse_matrix();
	};


	void distributed_sparse_matrix_add_to(distributed_sparse_matrix* M, int row_idx, int col_idx, double val, int n, int p);

	void sparse_matrix_vector_product(distributed_sparse_matrix* A, std::vector<double> &x, std::vector<double> &y);

	double norm(std::vector<double> &x);

	void gmres(distributed_sparse_matrix* A, std::vector<double> &b, std::vector<double> &x0, double &tol, double &err, int k, std::vector<double> &x, int &iters, int &restarts);

        void destroy_matrix(distributed_sparse_matrix* A);

        void print_vector(std::vector<double> &x);

        void print_matrix(distributed_sparse_matrix &A);
}

#endif
