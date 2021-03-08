/* Definitions for Fortran expressions

   Copyright (C) 2020 Free Software Foundation, Inc.

   This file is part of GDB.

   This program is free software; you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation; either version 3 of the License, or
   (at your option) any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program.  If not, see <http://www.gnu.org/licenses/>.  */

#ifndef FORTRAN_EXP_H
#define FORTRAN_EXP_H

#include "expop.h"

extern struct value *eval_op_f_abs (struct type *expect_type,
				    struct expression *exp,
				    enum noside noside,
				    enum exp_opcode opcode,
				    struct value *arg1);
extern struct value *eval_op_f_mod (struct type *expect_type,
				    struct expression *exp,
				    enum noside noside,
				    enum exp_opcode opcode,
				    struct value *arg1, struct value *arg2);
extern struct value *eval_op_f_ceil (struct type *expect_type,
				     struct expression *exp,
				     enum noside noside,
				     enum exp_opcode opcode,
				     struct value *arg1);
extern struct value *eval_op_f_floor (struct type *expect_type,
				      struct expression *exp,
				      enum noside noside,
				      enum exp_opcode opcode,
				      struct value *arg1);
extern struct value *eval_op_f_modulo (struct type *expect_type,
				       struct expression *exp,
				       enum noside noside,
				       enum exp_opcode opcode,
				       struct value *arg1, struct value *arg2);
extern struct value *eval_op_f_cmplx (struct type *expect_type,
				      struct expression *exp,
				      enum noside noside,
				      enum exp_opcode opcode,
				      struct value *arg1, struct value *arg2);
extern struct value *eval_op_f_kind (struct type *expect_type,
				     struct expression *exp,
				     enum noside noside,
				     enum exp_opcode opcode,
				     struct value *arg1);

namespace expr
{

using fortran_abs_operation = unop_operation<UNOP_ABS, eval_op_f_abs>;
using fortran_ceil_operation = unop_operation<UNOP_FORTRAN_CEILING,
					      eval_op_f_ceil>;
using fortran_floor_operation = unop_operation<UNOP_FORTRAN_FLOOR,
					       eval_op_f_floor>;
using fortran_kind_operation = unop_operation<UNOP_FORTRAN_KIND,
					      eval_op_f_kind>;

using fortran_mod_operation = binop_operation<BINOP_MOD, eval_op_f_mod>;
using fortran_modulo_operation = binop_operation<BINOP_FORTRAN_MODULO,
						 eval_op_f_modulo>;

/* The Fortran "complex" operation.  */
class fortran_cmplx_operation
  : public tuple_holding_operation<operation_up, operation_up>
{
public:

  using tuple_holding_operation::tuple_holding_operation;

  value *evaluate (struct type *expect_type,
		   struct expression *exp,
		   enum noside noside) override
  {
    value *arg1 = std::get<0> (m_storage)->evaluate (nullptr, exp, noside);
    value *arg2 = std::get<1> (m_storage)->evaluate (value_type (arg1),
						     exp, noside);
    return eval_op_f_cmplx (expect_type, exp, noside, BINOP_FORTRAN_CMPLX,
			    arg1, arg2);
  }

  enum exp_opcode opcode () const override
  { return BINOP_FORTRAN_CMPLX; }
};

} /* namespace expr */

#endif /* FORTRAN_EXP_H */