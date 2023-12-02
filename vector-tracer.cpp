#include <iostream>
#include <math.h>
#include <map>
#include <vector>

using namespace std; 

class Node {
	public:
		Node () {}
		bool is_hash = false;
		bool is_string = false;
		map <string, Node*> hash_node;
		vector <Node*> vector_node;
		vector <string> strings;
		
};



class VectorTracer {
	public:
		Node * node = NULL;
		string digit = "";
		int digit_step = 0;
		
		VectorTracer() {
		}
		void parse(string str) {
			this->digit = "";
			this->node = NULL;
			str = this->prepare_multi_and_div(str);
			Node *n = this->_depack(this->_parse(str));
			this->node = n;
			return;
		}
				
		float trace (Node *node_param = NULL) {
			Node *node = NULL;
			if (node_param == NULL) {
				node = node_param;
			} else {
				node = this->node;
			}
			
			if (node->is_hash) {
				auto it = node->hash_node.begin();
				string key = it->first;
				Node *value = it->second;
				if (key.compare("sin") or key.compare("cos")) {
					float a = this->trace(value);
					if (key.compare("sin")) return sin(a);
					if (key.compare("cos")) return cos(a);
				} else if (key.compare("+") or key.compare("-") or key.compare("*") or key.compare("/") or key.compare("**")) {
					vector<Node*> v = value->vector_node;
					auto i = v.begin();
					float a = this->trace(i[0]);
					float b = this->trace(i[1]);
					if (key.compare("+")) return a + b;
					if (key.compare("-")) return a - b;
					if (key.compare("*")) return a * b;
					if (key.compare("/")) return a / b;
					if (key.compare("**")) return pow(a, b);
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
			return new Node;
		}
		

		Node * _parse_digit (string s) {
			int i = 0;
			char c = s[0];
			
			Node * node = new Node;
			this->digit += c;
			
			int j;
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
				i = j - 1;
				this->digit = buff;
				node->strings.push_back(buff);
				node->is_string = true;
			} else {
				i = j;
				this->digit = buff;
				node->strings.push_back(buff);
				node->is_string = true;
			}
			this->digit_step = i;
			return node;
		}	
				
		Node * _depack (Node *node) {
			if (node->is_hash) {
				auto it = node->hash_node.begin();
				string key = it->first;
				Node *value = it->second;
				
				Node * node = new Node;
				node->is_hash = true;

				map <string, Node*> n;
				n[key] = this->_depack (value);
				node->hash_node = n;
			} else {
				auto v = node->vector_node;
				if (v.size() == 1) {
					auto n = node[0];
					return this->_depack(&n) ;
				} else {
					for (int i = 0; i < v.size() ; i++) {
						// Node *n = v[i];
						v[i] = this->_depack(v[i]);
					}
				}
			}
			
			return node;
		}
};

int main () {
	VectorTracer *tracer = new VectorTracer;
	string math = "2+2*2";
	tracer->parse(math);
	cout << tracer->prepare_multi_and_div(math) << "\n";
}

