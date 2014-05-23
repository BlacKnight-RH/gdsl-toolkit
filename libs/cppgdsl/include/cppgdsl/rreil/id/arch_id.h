/*
 * arch.h
 *
 *  Created on: May 21, 2014
 *      Author: Julian Kranz
 */

#pragma once
#include "id.h"
#include <string>

namespace gdsl {
namespace rreil {

class arch_id : public id {
private:
  std::string name;

  void put(std::ostream &out);
public:
  arch_id(std::string name);

  const std::string& get_name() const {
    return name;
  }

  void accept(id_visitor &v);
};

}  // namespace rreil
}  // namespace gdsl
