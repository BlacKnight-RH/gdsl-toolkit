/*
 * virtual.h
 *
 *  Created on: May 21, 2014
 *      Author: Julian Kranz
 */

#pragma once
#include "id.h"
#include <string>

namespace gdsl {
namespace rreil {

class _virtual : public id {
private:
  int_t t;
  bool opt;

  void put(std::ostream &out);

  static size_t subclass_counter;
public:
  _virtual(int_t t, bool opt);

  size_t get_subclass_counter() const;
  int_t get_t();
  bool get_opt();

  bool operator== (id &other) const;
  bool operator<(id const& other) const;
  void accept(id_visitor &v);
};

}  // namespace rreil
} // namespace gdsl
