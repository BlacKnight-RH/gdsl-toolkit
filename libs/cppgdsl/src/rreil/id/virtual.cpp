/*
 * _virtual.cpp
 *
 *  Created on: May 21, 2014
 *      Author: Julian Kranz
 */

#include <cppgdsl/rreil/id/virtual.h>

using namespace gdsl::rreil;

_virtual::_virtual(int_t t) {
  this->t = t;
}

int_t _virtual::get_t() {
  return this->t;
}
