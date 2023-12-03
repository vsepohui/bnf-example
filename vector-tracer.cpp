#include <iostream>
#include <math.h>
#include <map>
#include <vector>

using namespace std; 

class Node {
	public:
		bool is_hash = true;
		bool is_string = false;
		map <string, Node*> hash_node;
		vector <Node*> vector_node;
		vector <string> strings;
		
		Node () {
		};
};




class VectorTracer {
	public:
		Node *node = new Node;
		string digit = "";
		int digit_step = 0;
		
		VectorTracer() {
		}
		
		void dump (Node *n = NULL) {
			if (n == NULL) n = this->node;
			bool h = n->is_hash;
			
			if (h) {
				cout << "{";
				auto it = n->hash_node.begin();
				for (it; it != n->hash_node.end() ; it++) {
					string key = it->first;
					if (key != "") {
						cout << key << " => " << endl;
						Node *value = it->second;
						this->dump(value);
					}
				}
				cout << "}";
			} else {
				if (n->strings.size() > 0) {
					cout << "[";
					auto it = n->strings.begin();
					for (it; it != n->strings.end() ; it++) {
						cout << (*it) << "\t";
					}
					cout << "]";
					cout << endl;
				} else {
					cout << "[";
					if (n->vector_node.size() > 0) {
						auto it = n->vector_node.begin();
						for (it; it != n->vector_node.end() ; it++) {
							this->dump(*it);
						}
					}
					cout << "]";
				}
			}
		}
		
		void parse(string str) {
			this->digit = "";
			this->node = new Node;
			str = this->prepare_multi_and_div(str);
			Node *n = this->_parse(str);
			
			//this->_depack(
				
			//);
			this->node = n;
			return;
		}
				
		float trace (Node *node_param = NULL) {
			Node *node = NULL;
			if (node_param == NULL) {
				node = this->node;
			} else {
				node = node_param;
			}
			
			if (node->is_hash) {
				auto it = node->hash_node.begin();
				string key = it->first;
				Node *value = node->hash_node[key];	
				if (key == "sin" || key == "cos") {
					float a = this->trace(value);
					if (key.compare("sin")) return sin(a);
					if (key.compare("cos")) return cos(a);
				} else if (key == "+" || key == "-" || key == "*" || key == "/" || key == "**") {
					float a, b;
					if (value->is_string) {
						vector<string> s = value->strings;
						a = stof(s[0]);
						b = stof(s[1]);
					} else {
						vector<Node*> v = value->vector_node;
						auto i = v.begin();
						a = this->trace(i[0]);
						b = this->trace(i[1]);					
					}


					if (key == "+") return a + b;
					if (key == "-") return a - b;
					if (key == "*") return a * b;
					if (key == "/") return a / b;
					if (key == "**") return pow(a, b);
				}
			} 
			return 0;
		}
		
		string prepare_multi_and_div (string s) {
			int l = s.length();

			for (int i = 0 ; i < l ; i ++) {
				char c = s[i];
				
				if (c == '*' || c == '/') {
					bool p = false;
					if (s[i+1] == '*') p = true ;
					
					// Go back
					for (int j = i - 1; j >= 0 ; j --) {
						if ((j == 0) || s[j] == '*' || s[j] == '/' || s[j] == '+' || s[j] == '-') {
							// Setup brackets
							// Go backward
							for (int k = j ; k >= 0 ; k --) {
								if (s[k] == '*' || s[k] == '/' || s[k] == '+' || s[k] == '-') {
									string s1 = s.substr(0, k+1);
									s = s1 + '(' + s.substr(k+1);
									i ++;
									j ++;
									k ++;
									l ++;
									break;
								}
																
								if (k == 0) {
									s.insert(0, 1, '(');
									
									i ++;
									j ++;
									k ++;
									l ++;
									break;
								} 
							}
	
							// Go forward
							if (p) i ++;
							for (int k = i + 1 ; k < l ; k ++) {
								if (s[k] == '*' || s[k] == '/' || s[k] == '+' || s[k] == '-') {
									string s1 = s.substr(0, k);
									s = s1 + ')' + s.substr(k);
									i ++;
									j ++;
									k ++;
									l ++;
									break;
								}
								if (k == l - 1) {
									
									s += ')';
									i ++;
									j ++;
									k ++;
									l ++;
									break;
								} 

							}

							break;
							
						}					
					}

				}
			}
			return s;
		}
		
		Node * _parse (string s) {
		
		     cout << "Parse string: " + s << endl;
			Node * node = new Node;
			int sl = s.length();

			string function = "";
			vector <string> expression;
			string func = "";
			
			
			for (int i = 0; i < sl; i++) {
				cout << "i=" << i << endl;
				cout << "dump: " << endl;
				this->dump();
				char c = s[i];
				if (c == '+' || c == '-' || c == '*' || c == '/') {
					bool p = false;
					string op = ""+c;
					if (c == '*' && s[i+1] == '*') {
						p = true;
						op = "**";
						i ++;
					}

					if (this->digit != "") {
						expression.push_back(this->digit);
						this->digit = "";
					}
					
					if (node->is_hash == false && node->vector_node.size()) {
						Node *n = new Node;
						n->is_hash = true;
						n->hash_node[op] = node;
						node = n;
					} else if (node->is_hash == true) {
						Node *n = new Node;
						n->is_hash = true;
						n->hash_node[op] = node;
						node = n;
					} else {
						if (c == '+' || c == '-') {
							Node * n = this->_parse_digit(s.substr(i,sl -i));
							node->is_hash = false;
							node->vector_node.push_back(n);
							this->digit = "";
							i = i + this->digit_step;
							continue;							
						}
					}

					int j;
					string buff = "";
					int cnt = 0;
					
					for (j = i + 1; j < sl ; j ++) {
						char o = s[j];
						if (o == '(') {
							cnt ++;
						}
						if (o == ')') {
							cnt --;
						} 
						
						buff += o;
						
						if (cnt < 0 || j == (sl-1)) {

							if (node->hash_node[op]->is_hash) {
								Node * t = new Node;
								t->is_hash = false;
								t->vector_node.push_back(node->hash_node[op]);
								t->vector_node.push_back(this->_parse(buff));
								Node * t2 = new Node;
								t2->is_hash = true;
								t2->hash_node[op] = t;
								node = t2;
							} else {
								// push @{$node->{$op}}, $self->_parse ($buff);
							}
							break;
						} 
					}
					i = j;
				} else if (c == '(') {
					int j;
					string buff = "";
					for (int j = i + 0; j < sl ; j ++) {
						int o = s[j];
						buff += o;
						int cnt = 0;
						if (o == '(') {
							cnt ++;
							continue;
						}
						if (o == ')' || j == sl - 1) {
							cnt --;
							if (cnt == -1) {
								node->vector_node.push_back(this->_parse(buff.substr(1)));
								break;
							}
						}
					}
					i = j;
					function = "";
					continue;
				} else if (std::isalpha(c)) { // fuction processiong
					int j;
					int func_end = 0;
					string buff = "";
					
					for (j = i; j < sl ; j ++) {
						
						char o = s[j];
						if (o == '(') {
							func_end = 1;
							int j2;
							
							int cnt = 1;
							for (j2 = j + 1; j2 < sl ; j2 ++) {
								char o = s[j2];
								buff += o;
								if (o == '(') {
									cnt ++;
									continue;
								}
								if (o == ')') {
									cnt --;
									if (cnt == 0) {
										break;
									}
								}
								
							}
							j = j2;
							break;
						} else if (func_end == 0) {
							func += o;
						}
						
						
					}
					i = j;	
					Node * n = new Node;
					n->hash_node[func] = this->_parse(buff);
					node->vector_node.push_back(n);
				} else if (isdigit(c) || c == '.') {
					cout << "s.substr(i,sl-i) = " << s.substr(i,sl-i) << endl;
					this->digit_step = 0;
					Node * n = this->_parse_digit(s.substr(i,sl-i));
					i = this->digit_step + i;
					this->dump(n);
					cout << "this->digit_step=" << this->digit_step << endl;
					
					node->vector_node.push_back(n);
				}			
			}
	
			return node;
		}
		

		Node * _parse_digit (string s) {
			int i = 0;
			char c = s[0];
			
			Node * node = new Node;
			this->digit += c;
			
			int j = 0;
			string buff = this->digit;
			bool had_non_digit = false;
			
			for (j = i + 1; j < s.length() ; j ++) {
				char o = s[j];
				if (isdigit(o) || o == '.') {
					buff += o;
				} else {
					had_non_digit = true;
					break;
				}
			}
			
			if (had_non_digit) {
				j --;
				this->digit = buff;
				node->strings.push_back(buff);
				node->is_string = true;
				node->is_hash = false;
			} else {
				this->digit = buff;
				node->strings.push_back(buff);
				node->is_string = true;
				node->is_hash = false;
			}
			this->digit_step = j;
			return node;
		}	
				
		Node * _depack (Node *node) {
			if (node->is_hash) {
				auto it = node->hash_node.begin();
				string key = it->first;
				Node *value = it->second;
				
				Node * node = new Node;
				// node->is_hash = true;

				map <string, Node*> n;
				n[key] = this->_depack (value);
				node->hash_node = n;
			} else {
				auto v = node->vector_node;
				if (v.size() == 1) {
					auto n = node[0];
					return this->_depack(&n);
				} else if (v.size() == 0) {
					return node;
				} else {
					for (int i = 0; i < v.size() ; i++) {
						Node n = *(v[i]);
						v[i] = this->_depack(&n);
					}
				}
			}
			
			return node;
		}
};

int main () {
	VectorTracer *tracer = new VectorTracer;
	string math = "123+22";
	tracer->parse(math);
	tracer->dump();
	cout << tracer->trace() << "\n";
}

