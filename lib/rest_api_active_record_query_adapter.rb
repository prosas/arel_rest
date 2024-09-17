# This classe only define an REST API QUERY INTERFACE
# for active records
require 'byebug'

# query = {
# 	and: [
# 		{attribute: "a", operator:"=", values: [1]},
# 		{attribute: "b", operator:"=", values: [1]},
# 		{attribute: "c", operator:">", values: [1]},
# 		{attribute: "e", operator:"<", values: [2]},
# 		{
# 			or: [
# 				{attribute: "f", operator: "in", values: [1,2,3]},
# 				{attribute: "g", operator: "in", values: [1,2,3]}
# 			]
# 		},
# 		{
# 			or: [
# 				{attribute: "f", operator: "in", values: [1,2,3]},
# 				{attribute: "g", operator: "in", values: [1,2,3]}
# 			]
# 		}
# 	]
# }

# query = {
# 	or: [
# 		{attribute: "projetos.status", operator: "not_in", values: ["em_diligencia", "diligencia_respondida"]},
# 		{
# 			or: [
# 				{attribute: "projetos.created_at", operator: ">", values: "2024-01-01"},
# 				{attribute: "projetos.created_at", operator: "<", values: "2024-01-30"},
# 			]
# 		}
# 	]
# }

query = {
	and: [
		{attribute: "projetos.status", operator: "not_in", values: ["em_diligencia", "diligencia_respondida"]},
		{attribute: "projetos.valor", operator: ">", values: [0]},
		or: [{attribute: "projetos.id", operator: "=", values: [1]}]
	]
}
# Recevi object query and return array with
# string query and value.
# Ex: query object: {attribute: "a", operator:"=", values: [1]}
# >> ["a = ?", [1]]
TEMPLATE_OPERATORS = {
	"=" => ":attribute = ?",
	">" => ":attribute > ?",
	"<" => ":attribute < ?",
	">=" => ":attribute >= ?",
	"<=" => ":attribute <= ?",
	"in" => ":attribute in (?)",
	"not_in" => ":attribute not in (?)",
}

def build_pair_query_string_and_values(q)
	template = TEMPLATE_OPERATORS[q[:operator].to_s]
	[template.gsub(":attribute", q[:attribute]), q[:values]]
end

# Recevi array of pairs string queries and values and join
# with conector
# Ex: join_query_string_and_values([["a = ?", [1]],["b = ?", [1]]], :or)
# >> ["a = ? or b = ?", [1], [1]]
def join_query_string_and_values(queries_strings, conector)
	query_array = [queries_strings.map{|q| q[0]}.join(" "+conector.to_s+" ")]
	queries_strings.each{|q| query_array << q[1]}
	query_array
end

def query_builder(q)
	conector = q.keys[0]
	pair_query_string_and_values = q[conector].map do |query_obj|
		if query_obj.keys.include?(:or)
			template = "( :query )"
			nested_query = query_builder(query_obj) # Recursive
			string = nested_query.shift
			[template.gsub(":query", string), nested_query]
		else
			build_pair_query_string_and_values(query_obj)
		end
	end
	return join_query_string_and_values(pair_query_string_and_values, conector)

end

p query_builder(query)

