/*
 * throw.cpp
 *
 *  Created on: May 21, 2014
 *      Author: Julian Kranz
 */

#include <cppgdsl/rreil/statement/throw.h>

using namespace std;

gdsl::rreil::_throw::_throw(exception *inner) {
  this->inner = inner;
}

gdsl::rreil::_throw::~_throw() {
  delete this->inner;
}

std::string gdsl::rreil::_throw::to_string() {
  return "throw " + inner->to_string();
}

void gdsl::rreil::_throw::accept(statement_visitor& v) {
  v.visit(this);
}

void gdsl::rreil::_throw::put(std::ostream &out) {
  out << to_string();
}