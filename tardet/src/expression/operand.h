/*
 * operand.h
 *
 *  Created on: 23.07.2013
 *      Author: jucs
 */

#ifndef OPERAND_H_
#define OPERAND_H_

#include <stdint.h>
extern "C" {
#include <rreil/rreil.h>
}
#include "expression.h"

class variable : public expression {
private:
	struct rreil_variable *variable_;

public:
	variable(struct rreil_variable *variable);
	~variable() {};
	void print();
};

class immediate : public expression {
private:
	uint64_t immediate_;

public:
	immediate(uint64_t immediate);
	~immediate() {};
	void print();
};

#endif /* OPERAND_H_ */
