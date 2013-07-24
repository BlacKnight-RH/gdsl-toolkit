/*
 * itree.cpp
 *
 *  Created on: 22.07.2013
 *      Author: jucs
 */

#include <tr1/functional>
#include <tr1/memory>
#include <stdlib.h>
#include <stdio.h>
#include "itree.h"

#include "expression/expression.h"

using namespace std::tr1;

itree::itree(shared_ptr<class expression> expression, size_t int_start,
		size_t int_end) {
	this->root = new itree_leaf_node(expression, int_start, int_end);
}

void itree::print() {
	root->print();
}

char itree::contains(rreil_variable* variable) {
	return root->contains(variable);
}

itree_node::itree_node(size_t int_start, size_t int_end) {
	this->interval.start = int_start;
	this->interval.end = int_end;
}

itree_inner_node::itree_inner_node(itree_node **children, size_t children_count,
		size_t int_start, size_t int_end) :
		itree_node(int_start, int_end) {
	this->children = children;
	this->children_count = children_count;
}

enum itree_node_type itree_inner_node::type_get() {
	return ITREE_NODE_TYPE_INNER;
}

itree_node **itree_inner_node::children_get() {
	return children;
}

size_t itree_inner_node::children_count_get() {
	return children_count;
}

itree_inner_node::~itree_inner_node() {
	for(size_t i = 0; i < children_count; ++i) {
		delete children[i];
	}
	free(children);
}

void itree_inner_node::print() {
	for(size_t i = 0; i < children_count; ++i)
		children[i]->print();
}

char itree_inner_node::contains(rreil_variable* variable) {
	for(size_t i = 0; i < children_count; ++i)
		if(children[i]->contains(variable))
			return 1;
	return 0;
}

itree_leaf_node::itree_leaf_node(shared_ptr<class expression> expression,
		size_t int_start, size_t int_end) :
		itree_node(int_start, int_end) {
	this->expression = expression;
}

enum itree_node_type itree_leaf_node::type_get() {
	return ITREE_NODE_TYPE_LEAF;
}

//void *itree_leaf_node::expression_get() {
//	return expression;
//}

itree_inner_node *itree_leaf_node::split(
		shared_ptr<class expression> *expressions, size_t *offsets,
		size_t children_count) {
	struct {
		size_t start;
		size_t end;
	} interval;
	auto interval_calc = [&](size_t index) {
		if(!index) {
			interval.start = this->interval.start;
			interval.end = this->interval.start + offsets[index] - 1;
		} else if(index == children_count - 1) {
			interval.start = this->interval.start + offsets[index - 1];
			interval.end = this->interval.end;
		} else {
			interval.start = this->interval.start + offsets[index - 1];
			interval.end = this->interval.start + offsets[index] - 1;
		}
	};

	itree_node **children = (itree_node**)malloc(
			sizeof(itree_node*) * children_count);
	for(size_t i = 0; i < children_count; ++i) {
		interval_calc(i);
		children[i] = new itree_leaf_node(expressions[i], interval.start,
				interval.end);
	}

	return new itree_inner_node(children, children_count, this->interval.start,
			this->interval.end);
}

itree_leaf_node::~itree_leaf_node() {
	expression.reset();
}

void itree_leaf_node::print() {
	printf("[%zu..%zu]: ", interval.start, interval.end);
	expression->print();
	printf("\n");
}

char itree_leaf_node::contains(rreil_variable *variable) {
	return expression->contains(variable);
}
