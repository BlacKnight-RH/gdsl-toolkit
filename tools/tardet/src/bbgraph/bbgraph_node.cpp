/*
 * bbgraph_rrnode.cpp
 *
 *  Created on: Aug 9, 2013
 *      Author: jucs
 */

#include <stdlib.h>
#include <stdio.h>
#include <memory>
#include <set>
#include <queue>
#include "bbgraph_node.h"
#include "../expression/expression.h"

bool bbgraph_rrnode::has_subgraph() {
	for(size_t i = 0; i < children.size(); ++i)
		if(children[i].dst.lock()->get_id()->get_address_machine() == id->get_address_machine())
			return true;
	return false;
}

void bbgraph_rrnode::add_child(shared_ptr<bbgraph_node> child, shared_ptr<expression> condition) {
	struct bbgraph_branch branch = { child, condition };

	children.push_back(branch);
}

void bbgraph_node::add_parent(shared_ptr<bbgraph_rrnode> parent, shared_ptr<expression> condition) {
	struct bbgraph_pref pref = { parent, condition };

	parents.push_back(pref);
}

void bbgraph_rrnode::add_expression(shared_ptr<expression> expression) {
	if(uexp == NULL)
		uexp = shared_ptr<union_expression>(new union_expression(expression->get_size()));
	uexp->add(expression);
}

void bbgraph_rrnode::set_expression(shared_ptr<expression> expression) {
	uexp = shared_ptr<union_expression>(new union_expression(expression->get_size()));
	uexp->add(expression);
}

void bbgraph_rrnode::unmark_all(set<size_t> &seen) {
	marked = false;
	for(size_t i = 0; i < children.size(); ++i) {
		auto child = children[i].dst.lock();

		if(seen.find(child->get_count()) == seen.end()) {
			seen.insert(child->get_count());
			child->unmark_all(seen);
		}
	}
}

//void bbgraph_rrnode::print_dot_label() {
//	printf("\t\"%s\"", id->to_string().c_str());
//	if(id->get_inner())
//		printf(" [label=%zu];\n", id->get_inner());
//	else
//		printf(";\n");
//}

void bbgraph_rrnode::print_dot_subgraph(queue<shared_ptr<bbgraph_node>> &outsiders) {
	if(is_marked())
		return;
	mark();
	printf("\t\t\"%s\" [label=%zu];\n", id->to_string().c_str(), id->get_inner());
	for(size_t i = 0; i < children.size(); ++i) {
		auto child = children[i].dst.lock();
		if(child->get_id()->get_address_machine() == id->get_address_machine()) {
			printf("\t\t\"%s\" -> \"%s\" [label=\"", id->to_string().c_str(), child->get_id()->to_string().c_str());
			children[i].condition->print();
			printf("\"];\n");
			child->print_dot_subgraph(outsiders);
		} else
			outsiders.push(child);
	}
}

void bbgraph_rrnode::print_dot() {
//	printf("\t\"%s\" [label=\"%p\"];\n", id->to_string().c_str(), (void*)id->get_address_machine());

	auto subs = queue<shared_ptr<bbgraph_rrnode>>();
	auto nodes = queue<shared_ptr<bbgraph_node>>();

	nodes.push(shared_from_this());

	while(!nodes.empty()) {
		auto node = nodes.front();
		nodes.pop();

		printf("\tsubgraph cluster%lx {\n", node->get_id()->get_address_machine());
		printf("\t\tlabel=\"%lx\";\n", node->get_id()->get_address_machine());
		node->print_dot_queue_push(subs);
		while(!subs.empty()) {
			auto sub = subs.front();
			subs.pop();

			if(sub->is_marked())
				continue;
			sub->mark();

			printf("\t\t\"%s\" [label=%zu];\n", sub->get_id()->to_string().c_str(), sub->get_id()->get_inner());
			auto children = sub->get_children();
			for(size_t i = 0; i < children.size(); ++i) {
				auto child = children[i].dst.lock();

				if(child->get_id()->get_address_machine() == node->get_id()->get_address_machine()) {
					printf("\t\t\"%s\" -> \"%s\" [label=\"", sub->id->to_string().c_str(), child->get_id()->to_string().c_str());
					children[i].condition->print();
					printf("\"];\n");
					child->print_dot_queue_push(subs);
				} else
					nodes.push(child);
			}
		}
		printf("\t}\n");

		auto parents = node->get_parents();
		for(size_t i = 0; i < parents.size(); ++i) {
			auto parent = parents[i].dst.lock();
			printf("\t\"%s\" -> \"%s\" [label=\"", parent->get_id()->to_string().c_str(),
					node->get_id()->to_string().c_str());
			parents[i].condition->print();
			printf("\"];\n");
		}
	}
//
//
//	if(is_marked())
//		return;
//	auto outsiders = queue<shared_ptr<bbgraph_node>>();
//	if(has_subgraph()) {
//		printf("\tsubgraph cluster%lx {\n", id->get_address_machine());
//		printf("\t\tlabel=\"%lx\";\n", id->get_address_machine());
//		print_dot_subgraph(outsiders);
//		printf("\t}\n");
//	} else {
//		printf("\t\"%s\";\n", id->to_string().c_str());
//	}
//	mark();
//	for(size_t i = 0; i < children.size(); ++i) {
//		auto child = children[i].dst.lock();
//		if(child->is_marked())
//			continue;
//		outsiders.push(child);
////		if(children[i].dst->id->get_address_machine() != id->get_address_machine())
////			printf("\t\"%p\" -> %zu;\n", (void*)id->get_address_machine(), children[i]->id->get_inner());
////		else
////			printf("\t\"%p\" -> \"%p\";\n", (void*)id->get_address_machine(), (void*)children[i]->id->get_address_machine());
//
//	}
//	while(!outsiders.empty()) {
//		auto child = outsiders.front();
//		outsiders.pop();
//
//		printf("\t\"%s\" -> \"%s\";\n", id->to_string().c_str(), child->get_id()->to_string().c_str());
//		child->print_dot();
//	}
}

bool bbgraph_rrnode::replace_with(shared_ptr<bbgraph_node> other) {
	return false;
}

void bbgraph_stubnode::unmark_all(set<size_t> &seen) {
	marked = false;
}

bool bbgraph_stubnode::has_subgraph() {
}

void bbgraph_stubnode::print_dot_subgraph(queue<shared_ptr<bbgraph_node>> &outsiders) {
}

void bbgraph_stubnode::print_dot() {
	printf("\t\"%s\" [color=\"red\"];\n", id->to_string().c_str(), id->get_inner());
}

bool bbgraph_stubnode::replace_with(shared_ptr<bbgraph_node> other) {
	auto parents = get_parents();

	for(size_t i = 0; i < parents.size(); ++i) {
		auto parent_children = parents[i].dst.lock()->get_children();
		for(size_t i = 0; i < parent_children.size(); ++i)
			if(parent_children[i].dst.lock().get() == (void*)this)
				parent_children[i].dst = other;
	}

	return true;
}

size_t bbgraph_node::counter = 0;
