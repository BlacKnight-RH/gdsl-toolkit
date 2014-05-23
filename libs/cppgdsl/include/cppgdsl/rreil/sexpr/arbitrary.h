/*
 * arbitrary.h
 *
 *  Created on: May 21, 2014
 *      Author: Julian Kranz
 */

#pragma once

#include "sexpr.h"

namespace gdsl {
namespace rreil {

class arbitrary : public sexpr {
public:
  std::string to_string();
  void accept(sexpr_visitor &v);
};

}
}