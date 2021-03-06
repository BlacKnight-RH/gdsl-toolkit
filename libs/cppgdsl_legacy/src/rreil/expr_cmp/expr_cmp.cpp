/*
 * expr_cmp.cpp
 *
 *  Created on: May 21, 2014
 *      Author: Julian Kranz
 */

#include <cppgdsl/rreil/expr_cmp/cmp_op.h>
#include <cppgdsl/rreil/expr_cmp/expr_cmp.h>
#include <cppgdsl/rreil/linear/linear.h>
#include <iosfwd>
#include <iostream>
#include <sstream>

void gdsl::rreil::expr_cmp::put(std::ostream &out) {
  out << *opnd1 << " " << cmp_op_to_string(op) << " " << *opnd2;
}

gdsl::rreil::expr_cmp::expr_cmp(cmp_op op, linear *opnd1, linear *opnd2) {
  this->op = op;
  this->opnd1 = opnd1;
  this->opnd2 = opnd2;
}

gdsl::rreil::expr_cmp::~expr_cmp() {
  delete this->opnd1;
  delete this->opnd2;
}

std::string gdsl::rreil::expr_cmp::to_string() {
  std::stringstream o;
  o << *this;
  return o.str();
}

std::ostream &gdsl::rreil::operator <<(std::ostream &out, expr_cmp &_this) {
  _this.put(out);
  return out;
}

void gdsl::rreil::expr_cmp::accept(visitor &v) {
  v.visit(this);
}
